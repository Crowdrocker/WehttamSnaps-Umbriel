#!/usr/bin/env python3
"""
Render animated 'Now Playing' and 'Follow' lower-third overlays as transparent
PNG frame sequences (so they work as OBS Image-Sequence stingers / media), plus
single static PNGs. Brand: purple->cyan neon gradient bar, @wehttamsnaps,
magenta accent, aperture tick. True RGBA (Pillow).

Outputs (in lower-thirds/):
  now-playing/frame_%04d.png   (60 frames, 1.0s, 1000x180)
  now-playing.png              (static final frame)
  follow/frame_%04d.png        (60 frames, 1.0s, 1000x180)
  follow.png                   (static final frame)
"""
import math, os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = os.path.dirname(__file__)
PURPLE = (138, 43, 226)
CYAN = (0, 229, 255)
MAGENTA = (255, 70, 180)
WHITE = (255, 255, 255)
DIM = (200, 210, 230)

W, H = 1000, 180
FPS = 60
N = 60  # 1 second


def font(size, bold=True, techy=False):
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


def grad_bar(x0, y0, w, h, a_cyan=235):
    """A horizontal purple->cyan gradient bar on a transparent layer."""
    bar = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for x in range(w):
        t = x / max(1, w - 1)
        r = int(PURPLE[0] + (CYAN[0] - PURPLE[0]) * t)
        g = int(PURPLE[1] + (CYAN[1] - PURPLE[1]) * t)
        b = int(PURPLE[2] + (CYAN[2] - PURPLE[2]) * t)
        ImageDraw.Draw(bar).line([(x0 + x, y0), (x0 + x, y0 + h - 1)],
                                 fill=(r, g, b, 255))
    return bar


def text_on(canvas, s, fnt, fill, x, y, glow_color=None, glow_r=4):
    d = ImageDraw.Draw(canvas)
    if glow_color:
        gl = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        ImageDraw.Draw(gl).text((x, y), s, font=fnt, fill=glow_color + (255,))
        gl = gl.filter(ImageFilter.GaussianBlur(glow_r))
        canvas.alpha_composite(gl)
    d.text((x, y), s, font=fnt, fill=fill + (255,))


def ease_out(t):
    return 1 - (1 - t) ** 3


def render_lower_third(label, value, sub, out_dir, static_name, accent=MAGENTA):
    os.makedirs(out_dir, exist_ok=True)
    f_label = font(34, bold=True, techy=True)
    f_value = font(40, bold=True)
    f_sub = font(24, bold=False)

    # measure
    tmp = Image.new("RGBA", (10, 10), (0, 0, 0, 0))
    lb = ImageDraw.Draw(tmp).textbbox((0, 0), label, font=f_label)
    vb = ImageDraw.Draw(tmp).textbbox((0, 0), value, font=f_value)
    sb = ImageDraw.Draw(tmp).textbbox((0, 0), sub, font=f_sub)
    label_w = lb[2] - lb[0]
    value_w = vb[2] - vb[0]

    bar_x = 60
    bar_y = 40
    bar_h = 100
    bar_w = 880  # full bar width
    content_x = bar_x + 28
    content_y = bar_y + 16

    def frame(t):
        """t in [0,1]. Animate: bar slides in from left, text fades in."""
        canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        # bar reveal width
        reveal = ease_out(min(1.0, t / 0.45))
        cur_w = int(bar_w * reveal)
        if cur_w <= 0:
            return canvas
        bar = grad_bar(bar_x, bar_y, cur_w, bar_h)
        # subtle glow under bar
        glow = bar.filter(ImageFilter.GaussianBlur(6))
        canvas.alpha_composite(glow)
        canvas.alpha_composite(bar)
        # top accent line (magenta)
        acc = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(acc).line([(bar_x, bar_y - 2), (bar_x + cur_w, bar_y - 2)],
                                 fill=accent + (220,), width=2)
        canvas.alpha_composite(acc)
        # text — fade + slight slide, starts after bar is ~60% revealed
        text_t = max(0.0, (t - 0.25) / 0.55)
        text_t = ease_out(min(1.0, text_t))
        alpha = int(255 * text_t)
        slide = int(20 * (1 - text_t))
        if alpha > 0:
            # render text onto a temp layer then composite with alpha
            tl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
            text_on(tl, label, f_label, WHITE, content_x, content_y - 4,
                    glow_color=CYAN, glow_r=3)
            text_on(tl, value, f_value, CYAN, content_x + label_w + 16,
                    content_y - 8, glow_color=accent, glow_r=3)
            text_on(tl, sub, f_sub, DIM, content_x,
                    content_y + 50, glow_color=accent, glow_r=2)
            # apply alpha by multiplying the layer's alpha
            arr = np.array(tl)
            arr[..., 3] = (arr[..., 3].astype(np.uint16) * alpha // 255).astype(np.uint8)
            tl = Image.fromarray(arr, "RGBA")
            # slide: shift content right by `slide`
            if slide > 0:
                shifted = Image.new("RGBA", (W, H), (0, 0, 0, 0))
                shifted.alpha_composite(tl, (slide, 0))
                tl = shifted
            canvas.alpha_composite(tl)
        # @wehttamsnaps tag at far right of bar
        tag_t = max(0.0, (t - 0.5) / 0.5)
        tag_t = ease_out(min(1.0, tag_t))
        tag_alpha = int(255 * tag_t)
        if tag_alpha > 0:
            f_tag = font(22, bold=True, techy=True)
            tag = Image.new("RGBA", (W, H), (0, 0, 0, 0))
            text_on(tag, "@wehttamsnaps", f_tag, accent,
                    bar_x + bar_w - 180, bar_y + bar_h // 2 - 12,
                    glow_color=CYAN, glow_r=2)
            arr = np.array(tag)
            arr[..., 3] = (arr[..., 3].astype(np.uint16) * tag_alpha // 255).astype(np.uint8)
            canvas.alpha_composite(Image.fromarray(arr, "RGBA"))
        return canvas

    # animated frames (loop: 0->1 then hold at 1 for the rest)
    for i in range(N):
        t = i / (N - 1)
        im = frame(t)
        im.save(os.path.join(out_dir, f"frame_{i:04d}.png"))
    # static final frame
    final = frame(1.0)
    final.save(os.path.join(OUT, static_name))
    return final


def main():
    render_lower_third("NOW PLAYING", "— track / artist", "album • streaming source",
                       os.path.join(OUT, "now-playing"), "now-playing.png")
    render_lower_third("FOLLOW", "@wehttamsnaps", "twitch.tv/wehttamsnaps",
                       os.path.join(OUT, "follow"), "follow.png")
    # verify alpha on one frame
    im = Image.open(os.path.join(OUT, "now-playing", "frame_0000.png"))
    a = np.array(im.split()[-1])
    print(f"frame 0 alpha: mean={a.mean():.1f} min={a.min()} max={a.max()} transparent={int((a==0).sum())}")
    im2 = Image.open(os.path.join(OUT, "now-playing.png"))
    a2 = np.array(im2.split()[-1])
    print(f"final now-playing.png: mode={im2.mode} alpha mean={a2.mean():.1f} min={a2.min()} max={a2.max()}")
    print(f"wrote {N} frames each to now-playing/ and follow/, plus static PNGs")


if __name__ == "__main__":
    main()
