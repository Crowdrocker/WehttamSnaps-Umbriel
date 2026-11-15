#!/usr/bin/env python3
"""
Render the wehttamsnaps transparent logo overlay using Pillow on a TRUE RGBA
canvas so the alpha channel is real (not the fake-RGBA that generate_image
produced). Two outputs:

  - wehttamsnaps-logo-overlay.png   1080x1080 transparent master
  - wehttamsnaps-logo-cam-bug.png    400x400 cam-bug version sized to sit on
                                     the cam.png frame on the Live scene

Brand: purple->cyan neon gradient, 6-blade camera aperture motif (matching the
stinger + scene cards), magenta accent underline, "wehttamsnaps" wordmark in
Orbitron (techy), with "VES" aperture mark above it.
"""
import math, os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = os.path.dirname(__file__)

PURPLE = (138, 43, 226)
CYAN = (0, 229, 255)
MAGENTA = (255, 70, 180)
WHITE = (255, 255, 255)


def get_font(size, bold=True, techy=False):
    paths = []
    if techy:
        paths.append("/opt/novnc/app/styles/Orbitron700.ttf")
    paths.append("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold
                 else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    for c in paths:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()


def gradient_rgb(a, b, n):
    """Return a list of n RGB tuples interpolating a->b."""
    return [
        (int(a[0] + (b[0] - a[0]) * i / max(1, n - 1)),
         int(a[1] + (b[1] - a[1]) * i / max(1, n - 1)),
         int(a[2] + (b[2] - a[2]) * i / max(1, n - 1)))
        for i in range(n)
    ]


def draw_aperture(cx, cy, size, open_frac=0.12, glow=True):
    """6-blade camera aperture on a transparent layer, drawn centred at (cx,cy)."""
    s = size
    canvas = Image.new("RGBA", (s * 2, s * 2), (0, 0, 0, 0))
    ox = oy = s  # centre of the canvas
    outer = s // 2
    inner = max(4, int(outer * 0.16))
    n = 6
    rot = 15
    # outer ring (magenta glow)
    ring = Image.new("RGBA", (s * 2, s * 2), (0, 0, 0, 0))
    ImageDraw.Draw(ring).ellipse([ox - outer, oy - outer, ox + outer, oy + outer],
                                 outline=MAGENTA + (255,), width=max(4, s // 70))
    ring = ring.filter(ImageFilter.GaussianBlur(s // 45))
    canvas.alpha_composite(ring)
    # crisp inner ring (cyan)
    ring2 = Image.new("RGBA", (s * 2, s * 2), (0, 0, 0, 0))
    ImageDraw.Draw(ring2).ellipse([ox - outer, oy - outer, ox + outer, oy + outer],
                                  outline=CYAN + (255,), width=max(2, s // 120))
    canvas.alpha_composite(ring2)
    # blades — gradient per blade
    blade_layer = Image.new("RGBA", (s * 2, s * 2), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blade_layer)
    blade_colors = gradient_rgb(PURPLE, CYAN, n)
    for i in range(n):
        a0 = math.radians(rot + i * (360 / n))
        a1 = math.radians(rot + (i + 1) * (360 / n))
        p0 = (ox, oy)
        p1 = (ox + outer * math.cos(a0), oy + outer * math.sin(a0))
        p2 = (ox + outer * math.cos(a1), oy + outer * math.sin(a1))
        mid_a = (a0 + a1) / 2
        mid_r = (1 - open_frac * 0.85) * outer
        p3 = (ox + mid_r * math.cos(mid_a), oy + mid_r * math.sin(mid_a))
        col = blade_colors[i]
        bd.polygon([p0, p1, p3, p2], fill=col + (235,))
    # soft glow under blades
    glow_blades = blade_layer.filter(ImageFilter.GaussianBlur(s // 60))
    canvas.alpha_composite(glow_blades)
    canvas.alpha_composite(blade_layer)
    # hub
    hub = Image.new("RGBA", (s * 2, s * 2), (0, 0, 0, 0))
    ImageDraw.Draw(hub).ellipse([ox - inner, oy - inner, ox + inner, oy + inner],
                                fill=MAGENTA + (255,))
    hub_glow = hub.filter(ImageFilter.GaussianBlur(s // 50))
    canvas.alpha_composite(hub_glow)
    canvas.alpha_composite(hub)
    # crop to size and paste at (cx,cy)
    cropped = canvas.crop((ox - outer - s // 6, oy - outer - s // 6,
                           ox + outer + s // 6, oy + outer + s // 6))
    return cropped, s  # the layer + the paste-box half-size


def text_layer(size, text, font, fill, glow_color, glow_radius):
    """Render text centred on its own transparent layer of given size."""
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (size[0] - tw) // 2 - bbox[0]
    y = (size[1] - th) // 2 - bbox[1]
    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).text((x, y), text, font=font, fill=glow_color + (255,))
    glow = glow.filter(ImageFilter.GaussianBlur(glow_radius))
    layer.alpha_composite(glow)
    d.text((x, y), text, font=font, fill=fill + (255,))
    return layer


def build_logo(S):
    """Build the logo composition at square size S (transparent)."""
    canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    # ---- aperture mark (top ~55%) ----
    ap_size = int(S * 0.46)
    ap_layer, half = draw_aperture(S // 2, 0, ap_size, open_frac=0.12)
    # place aperture centred at upper area
    box_w, box_h = ap_layer.size
    canvas.alpha_composite(ap_layer, (S // 2 - box_w // 2, int(S * 0.04)))

    # ---- wordmark "wehttamsnaps" ----
    wm_font = get_font(int(S * 0.085), bold=True, techy=True)
    wm = text_layer((S, int(S * 0.16)), "wehttamsnaps", wm_font, WHITE, CYAN,
                    glow_radius=int(S * 0.006))
    wm_y = int(S * 0.62)
    canvas.alpha_composite(wm, (0, wm_y))

    # ---- magenta accent underline ----
    ulw = int(S * 0.46)
    ulh = max(3, int(S * 0.012))
    ul = Image.new("RGBA", (ulw, ulh * 5), (0, 0, 0, 0))
    ImageDraw.Draw(ul).rounded_rectangle([0, ulh, ulw, ulh * 2 + 1],
                                         radius=ulh // 2, fill=MAGENTA + (255,))
    ul = ul.filter(ImageFilter.GaussianBlur(2))
    ImageDraw.Draw(ul).rounded_rectangle([0, ulh, ulw, ulh * 2 + 1],
                                         radius=ulh // 2, fill=MAGENTA + (255,))
    canvas.alpha_composite(ul, (S // 2 - ulw // 2, wm_y + int(S * 0.135)))

    # ---- small tagline under underline ----
    tag_font = get_font(int(S * 0.032), bold=False)
    tag = text_layer((S, int(S * 0.06)), "LIVE  •  CREATE  •  SNAP", tag_font, CYAN,
                     MAGENTA, glow_radius=2)
    canvas.alpha_composite(tag, (0, wm_y + int(S * 0.165)))

    # ---- outer drop shadow so it reads on bright cam bg ----
    shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [S * 0.12, S * 0.02, S * 0.88, S * 0.74], radius=int(S * 0.06),
        fill=(0, 0, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(S * 0.03))
    # place shadow BEHIND everything by rebuilding canvas
    final = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    final.alpha_composite(shadow)
    final.alpha_composite(canvas)
    return final


def main():
    # 1080x1080 master
    master = build_logo(1080)
    master.save(os.path.join(OUT, "wehttamsnaps-logo-overlay.png"))
    # 400x400 cam-bug
    cam = master.resize((400, 400), Image.LANCZOS)
    cam.save(os.path.join(OUT, "wehttamsnaps-logo-cam-bug.png"))
    # verify alpha
    for name, im in [("master", master), ("cam-bug", cam)]:
        a = im.split()[-1]
        import numpy as np
        arr = np.array(a)
        print(f"{name}: mode={im.mode} size={im.size} "
              f"alpha mean={arr.mean():.1f} min={arr.min()} max={arr.max()} "
              f"fully_transparent_px={(arr==0).sum()} fully_opaque_px={(arr==255).sum()}")
    print("wrote wehttamsnaps-logo-overlay.png (1080x1080)")
    print("wrote wehttamsnaps-logo-cam-bug.png (400x400)")


if __name__ == "__main__":
    main()
