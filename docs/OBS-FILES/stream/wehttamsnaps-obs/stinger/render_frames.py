#!/usr/bin/env python3
"""
wehttamsnaps stinger frame renderer (numpy-accelerated).

Produces a 1920x1080 RGBA PNG frame sequence (60 fps x 2.0s = 120 frames)
that encodes to a transparent VP9 WebM stinger for OBS.

Design:
  Phase A (0.0-0.5s): aperture blades close over a transparent field, wiping in.
  Phase B (0.5-1.0s): full-screen purple->cyan panel, brand text + aperture
                       revealed by a horizontal sweep. Transition Point @ t=1.0s.
  Phase C (1.0-1.5s): panel sweeps away, aperture opens, transparency returns.
  Phase D (1.5-2.0s): fully transparent hold so OBS can settle.

Output: frames/frame_0000.png ... frame_0119.png  (RGBA)
"""
import math
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

W, H = 1920, 1080
FPS = 60
DURATION = 2.0
NFRAMES = int(FPS * DURATION)
OUT = os.path.join(os.path.dirname(__file__), "frames")
os.makedirs(OUT, exist_ok=True)

PURPLE = np.array([138, 43, 226], dtype=np.float32)
CYAN = np.array([0, 229, 255], dtype=np.float32)
MAGENTA = (255, 70, 180)
WHITE = (255, 255, 255)

# Precompute base gradient (H, W, 3) once
_xs = np.linspace(0.0, 1.0, W, dtype=np.float32)[None, :, None]  # (1,W,1)
_ys = np.linspace(0.0, 1.0, H, dtype=np.float32)[:, None, None]  # (H,1,1)
BASE_GRAD = (PURPLE * (1 - _xs) + CYAN * _xs).astype(np.float32)  # (H,W,3)
# diagonal shimmer
_shimmer = (np.sin((_xs + _ys * 0.5) * math.pi * 2.0) * 0.5 + 0.5) * 30.0
BASE_GRAD = np.clip(BASE_GRAD + _shimmer, 0, 255)
# darken for contrast
BASE_GRAD *= 0.55


def lerp(a, b, t):
    return a + (b - a) * t


def ease_in_out(t):
    return t * t * (3 - 2 * t)


def clamp(x, lo=0.0, hi=1.0):
    return max(lo, min(hi, x))


def frame_env(t):
    if t < 0.5:
        return ease_in_out(t / 0.5)
    if t < 1.0:
        return 1.0
    if t < 1.5:
        return 1.0 - ease_in_out((t - 1.0) / 0.5)
    return 0.0


def panel_reveal_mask(t):
    """
    (H,W) float32 0..1 — the geometric wipe that brings the brand panel in and out.
    Phase A (0.0-0.5): expanding disc from center (aperture closing) -> full.
    Phase B (0.5-1.0): full (1.0).
    Phase C (1.0-1.5): contracting disc back to center -> 0.
    Phase D: 0.
    Uses a feathered radial distance so edges are soft.
    """
    H_, W_ = H, W
    yy, xx = np.ogrid[:H_, :W_]
    cx, cy = W_ / 2.0, H_ / 2.0
    dist = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2).astype(np.float32)
    max_r = math.hypot(cx, cy)  # corner distance
    feather = 60.0
    if t < 0.5:
        # radius grows from 0 -> max_r
        r = ease_in_out(t / 0.5) * (max_r + feather)
        m = np.clip((r - dist) / feather, 0.0, 1.0)
    elif t < 1.0:
        m = np.ones((H_, W_), dtype=np.float32)
    elif t < 1.5:
        r = (1.0 - ease_in_out((t - 1.0) / 0.5)) * (max_r + feather)
        m = np.clip((r - dist) / feather, 0.0, 1.0)
    else:
        m = np.zeros((H_, W_), dtype=np.float32)
    return m


def sweep_mask(t):
    """(H,W) float32 in 0..1 — horizontal band for the brand-TEXT reveal only."""
    if t < 0.5:
        sx = -W * 0.2
    elif t < 1.0:
        sx = lerp(-W * 0.2, W + W * 0.2, ease_in_out((t - 0.5) / 0.5))
    else:
        sx = lerp(W + W * 0.2, -W * 0.2, ease_in_out(clamp((t - 1.0) / 0.5)))
    feather = 250
    xs = np.arange(W, dtype=np.float32)[None, :]
    d = sx - xs
    a = np.clip((d + feather) / (2 * feather), 0.0, 1.0)
    return np.repeat(a, H, axis=0)


def draw_aperture(size, rotation_deg, open_fraction=0.0):
    s = size
    canvas = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    cx = cy = s // 2
    outer = s // 2
    inner = int(outer * 0.18)
    # outer ring with glow
    ring = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(ring).ellipse([0, 0, s - 1, s - 1], outline=MAGENTA + (255,),
                                 width=max(3, s // 80))
    ring = ring.filter(ImageFilter.GaussianBlur(3))
    canvas.alpha_composite(ring)
    # blades
    blades = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blades)
    n = 6
    for i in range(n):
        a0 = math.radians(rotation_deg + i * (360 / n))
        a1 = math.radians(rotation_deg + (i + 1) * (360 / n))
        p0 = (cx, cy)
        p1 = (cx + outer * math.cos(a0), cy + outer * math.sin(a0))
        p2 = (cx + outer * math.cos(a1), cy + outer * math.sin(a1))
        mid_a = (a0 + a1) / 2
        mid_r = lerp(0, outer, 1.0 - open_fraction * 0.85)
        p3 = (cx + mid_r * math.cos(mid_a), cy + mid_r * math.sin(mid_a))
        bd.polygon([p0, p1, p3, p2], fill=(0, 229, 255, 255))
    glow = blades.filter(ImageFilter.GaussianBlur(s // 90))
    canvas.alpha_composite(glow)
    canvas.alpha_composite(blades)
    # hub
    hub = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(hub).ellipse([cx - inner, cy - inner, cx + inner, cy + inner],
                                fill=MAGENTA + (255,))
    canvas.alpha_composite(hub)
    return canvas


def get_font(size, bold=True):
    paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/TTF/DejaVuSans.ttf",
    ]
    for c in paths:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
    return ImageFont.load_default()


def draw_text_centered(text, font, fill, y_center, canvas_size=(W, H)):
    tmp = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    td = ImageDraw.Draw(tmp)
    bbox = td.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (canvas_size[0] - tw) // 2 - bbox[0]
    y = int(y_center - th / 2) - bbox[1]
    gl = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    ImageDraw.Draw(gl).text((x, y), text, font=font, fill=fill)
    gl = gl.filter(ImageFilter.GaussianBlur(5))
    tmp.alpha_composite(gl)
    td.text((x, y), text, font=font, fill=fill)
    return tmp


def render_frame(i):
    t = i / FPS
    env = frame_env(t)
    frame = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    if env <= 0.001:
        frame.save(os.path.join(OUT, f"frame_{i:04d}.png"))
        return

    sweep = sweep_mask(t)  # text reveal only
    reveal = panel_reveal_mask(t)  # geometric panel wipe (in/out)
    final_alpha = (reveal * env * 255.0).astype(np.uint8)  # (H,W)

    # panel: base gradient + alpha
    panel = Image.fromarray(BASE_GRAD.astype(np.uint8), "RGB").convert("RGBA")
    panel.putalpha(Image.fromarray(final_alpha, "L"))
    frame.alpha_composite(panel)

    # text layers (revealed by sweep)
    if env > 0.2:
        font_big = get_font(150, bold=True)
        font_small = get_font(56, bold=True)
        txt = draw_text_centered("wehttamsnaps", font_big, WHITE, H * 0.5 + 220)
        sub = draw_text_centered("twitch.tv/wehttamsnaps", font_small, (0, 229, 255), H * 0.5 + 320)
        sw_img = Image.fromarray((sweep * 255.0).astype(np.uint8), "L")
        for layer in (txt, sub):
            layer.putalpha(ImageChops.multiply(layer.getchannel("A"), sw_img))
            frame.alpha_composite(layer)

    # aperture
    ap_size = int(min(W, H) * 0.55)
    if t < 0.5:
        open_frac = 0.0
        spin = 360 * (t / 0.5) * 1.5
    elif t < 1.0:
        open_frac = 0.05
        spin = 540 + 60 * ((t - 0.5) / 0.5)
    else:
        open_frac = lerp(0.05, 1.0, ease_in_out((t - 1.0) / 0.5))
        spin = 600 + 360 * ((t - 1.0) / 0.5) * 1.5
    aperture = draw_aperture(ap_size, spin, open_fraction=open_frac)
    ap_masked = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ap_masked.alpha_composite(aperture, ((W - ap_size) // 2, (H - ap_size) // 2))
    # aperture rides the env envelope directly (it IS the wipe during A/C),
    # then settles during B. During B (0.5-1.0) also clip to panel reveal so it
    # never pokes outside the disc.
    if 0.5 <= t < 1.0:
        ap_masked.putalpha(ImageChops.multiply(ap_masked.getchannel("A"),
                                               Image.fromarray(final_alpha, "L")))
    else:
        ap_env = Image.new("L", (W, H), int(255 * env))
        ap_masked.putalpha(ImageChops.multiply(ap_masked.getchannel("A"), ap_env))
    frame.alpha_composite(ap_masked)

    # central neon glow
    if env > 0.3:
        glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(glow).ellipse([W // 2 - 600, H // 2 - 600, W // 2 + 600, H // 2 + 600],
                                     fill=(120, 80, 200, int(40 * env)))
        glow = glow.filter(ImageFilter.GaussianBlur(120))
        glow.putalpha(ImageChops.multiply(glow.getchannel("A"),
                                          Image.fromarray(final_alpha, "L")))
        frame.alpha_composite(glow)

    frame.save(os.path.join(OUT, f"frame_{i:04d}.png"))


def main():
    print(f"Rendering {NFRAMES} frames at {FPS}fps -> {OUT}")
    for i in range(NFRAMES):
        render_frame(i)
        if i % 20 == 0:
            print(f"  frame {i:03d}/{NFRAMES}", flush=True)
    print("done")


if __name__ == "__main__":
    main()
