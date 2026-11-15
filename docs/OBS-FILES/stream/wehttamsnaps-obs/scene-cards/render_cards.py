#!/usr/bin/env python3
"""
Render the six wehttamsnaps OBS scene cards (1920x1080, purple->cyan gradient).
All cards share the brand gradient + aperture motif + @wehttamsnaps footer so
the package is visually consistent with the stinger and lower-thirds.
"""
import math, os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

W, H = 1920, 1080
OUT = os.path.join(os.path.dirname(__file__), "..", "scene-cards")
os.makedirs(OUT, exist_ok=True)

PURPLE = np.array([138, 43, 226], dtype=np.float32)
CYAN = np.array([0, 229, 255], dtype=np.float32)
MAGENTA = (255, 70, 180)
CYAN_RGB = (0, 229, 255)
WHITE = (255, 255, 255)
DEEP = (18, 12, 30)

_xs = np.linspace(0.0, 1.0, W, dtype=np.float32)[None, :, None]
_ys = np.linspace(0.0, 1.0, H, dtype=np.float32)[:, None, None]
GRAD = (PURPLE * (1 - _xs) + CYAN * _xs).astype(np.float32)
_shimmer = (np.sin((_xs + _ys * 0.5) * math.pi * 2.0) * 0.5 + 0.5) * 25.0
GRAD = np.clip(GRAD + _shimmer, 0, 255) * 0.62  # darken for contrast


def get_font(size, bold=True):
    paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/TTF/DejaVuSans.ttf",
    ]
    for c in paths:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
    return ImageFont.load_default()


def base_panel():
    return Image.fromarray(GRAD.astype(np.uint8), "RGB").convert("RGBA")


def draw_aperture(d, size, cx, cy, color=CYAN_RGB, glow=MAGENTA, open_frac=0.1):
    s = size
    outer = s // 2
    inner = int(outer * 0.18)
    # ring
    ring = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(ring).ellipse([0, 0, s - 1, s - 1], outline=glow + (255,),
                                 width=max(3, s // 80))
    ring = ring.filter(ImageFilter.GaussianBlur(3))
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    img.alpha_composite(ring, (cx - s // 2, cy - s // 2))
    blades = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blades)
    n = 6
    rot = 15
    for i in range(n):
        a0 = math.radians(rot + i * (360 / n))
        a1 = math.radians(rot + (i + 1) * (360 / n))
        bcx = bcy = s // 2
        p0 = (bcx, bcy)
        p1 = (bcx + outer * math.cos(a0), bcy + outer * math.sin(a0))
        p2 = (bcx + outer * math.cos(a1), bcy + outer * math.sin(a1))
        mid_a = (a0 + a1) / 2
        mid_r = (1 - open_frac * 0.85) * outer
        p3 = (bcx + mid_r * math.cos(mid_a), bcy + mid_r * math.sin(mid_a))
        bd.polygon([p0, p1, p3, p2], fill=color + (255,))
    g = blades.filter(ImageFilter.GaussianBlur(s // 90))
    img.alpha_composite(g, (cx - s // 2, cy - s // 2))
    img.alpha_composite(blades, (cx - s // 2, cy - s // 2))
    hub = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(hub).ellipse([bcx - inner, bcy - inner, bcx + inner, bcy + inner],
                                fill=glow + (255,))
    img.alpha_composite(hub, (cx - s // 2, cy - s // 2))
    return img


def text(d, s, font, fill, cx, cy, glow=True, glow_radius=4):
    bbox = d.textbbox((0, 0), s, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = cx - tw // 2 - bbox[0]
    y = int(cy - th / 2) - bbox[1]
    if glow:
        gl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(gl).text((x, y), s, font=font, fill=fill)
        gl = gl.filter(ImageFilter.GaussianBlur(glow_radius))
        d.image.paste  # noop
        return (x, y), gl
    return (x, y), None


def draw_text_on(canvas, s, font, fill, cx, cy, glow_radius=4, glow_color=None):
    td = ImageDraw.Draw(canvas)
    bbox = td.textbbox((0, 0), s, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = cx - tw // 2 - bbox[0]
    y = int(cy - th / 2) - bbox[1]
    gc = glow_color if glow_color else fill
    gl = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(gl).text((x, y), s, font=font, fill=gc)
    gl = gl.filter(ImageFilter.GaussianBlur(glow_radius))
    canvas.alpha_composite(gl)
    td.text((x, y), s, font=font, fill=fill)


def footer(canvas, label="@wehttamsnaps", sub="twitch.tv/wehttamsnaps  •  youtube  •  tiktok  •  x"):
    f_main = get_font(46, bold=True)
    f_sub = get_font(30, bold=False)
    # separator line
    line = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(line)
    ld.line([(W // 2 - 360, H - 130), (W // 2 + 360, H - 130)], fill=CYAN_RGB + (180,), width=2)
    line = line.filter(ImageFilter.GaussianBlur(1))
    canvas.alpha_composite(line)
    draw_text_on(canvas, label, f_main, WHITE, W // 2, H - 85, glow_radius=5, glow_color=CYAN_RGB)
    draw_text_on(canvas, sub, f_sub, CYAN_RGB, W // 2, H - 40, glow_radius=3)


def make_card(filename, title, subtitle, aperture_open=0.1, show_aperture=True):
    canvas = base_panel()
    # vignette
    vig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(vig).rectangle([0, 0, W, H], fill=(0, 0, 0, 90))
    canvas.alpha_composite(vig)
    # aperture behind text
    if show_aperture:
        ap = draw_aperture(None, int(min(W, H) * 0.5), W // 2, H // 2 - 40,
                           open_frac=aperture_open)
        ap_glow = ap.filter(ImageFilter.GaussianBlur(8))
        canvas.alpha_composite(ap_glow)
        canvas.alpha_composite(ap)
    # central neon glow
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([W // 2 - 500, H // 2 - 500, W // 2 + 500, H // 2 + 500],
                                 fill=(120, 80, 200, 50))
    glow = glow.filter(ImageFilter.GaussianBlur(120))
    canvas.alpha_composite(glow)
    # title
    f_title = get_font(170, bold=True)
    f_sub = get_font(56, bold=False)
    draw_text_on(canvas, title, f_title, WHITE, W // 2, H // 2 - 40,
                 glow_radius=8, glow_color=CYAN_RGB)
    if subtitle:
        draw_text_on(canvas, subtitle, f_sub, CYAN_RGB, W // 2, H // 2 + 90,
                     glow_radius=4)
    footer(canvas)
    canvas.convert("RGB").save(os.path.join(OUT, filename))
    print("wrote", filename)


def main():
    make_card("00-starting-soon.png", "STARTING SOON", "the stream will begin shortly", aperture_open=0.15)
    make_card("00-stream-starting.png", "STREAM STARTING", "getting things ready", aperture_open=0.2)
    make_card("10-live.png", "LIVE", "@wehttamsnaps", aperture_open=0.05)
    make_card("20-brb.png", "BE RIGHT BACK", "don't go anywhere", aperture_open=0.5)
    make_card("30-ending.png", "ENDING STREAM", "thanks for watching", aperture_open=0.3)
    make_card("30-offline.png", "OFFLINE", "stream has ended", aperture_open=0.9)
    # contact sheet
    files = ["00-starting-soon.png", "00-stream-starting.png", "10-live.png",
             "20-brb.png", "30-ending.png", "30-offline.png"]
    cw, ch = 640, 360
    sheet = Image.new("RGB", (cw * 3, ch * 2), (20, 20, 28))
    for i, f in enumerate(files):
        im = Image.open(os.path.join(OUT, f)).resize((cw, ch))
        sheet.paste(im, ((i % 3) * cw, (i // 3) * ch))
    sheet.save(os.path.join(OUT, "scene-cards-contact-sheet.png"))
    print("wrote scene-cards-contact-sheet.png")


if __name__ == "__main__":
    main()
