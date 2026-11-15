# wehttamsnaps Animated Stinger

A 2-second, 60fps, 1920×1080 **transparent** stinger transition for OBS, themed to the wehttamsnaps brand (purple→cyan gradient + camera-aperture logo + @wehttamsnaps). Ready to import.

## Files

- `wehttamsnaps-stinger.webm` — VP9 WebM with alpha (`alpha_mode=1`). Primary import file.
- `frames/frame_0000.png … frame_0119.png` — the 120 RGBA source frames (verified alpha). Use these if you prefer an **Image Sequence** stinger (see below) or if the WebM imports without transparency on your build.
- `stinger-contact-sheet.png` — 9-frame preview so you can eyeball the animation before importing.
- `render_frames.py` — the renderer (numpy + Pillow) that generated the frames, in case you want to tweak colors/timing and re-render.

## Animation timeline

| Time | Frame | What happens |
|------|-------|--------------|
| 0.00–0.50s | 0–29   | Aperture blades close over a transparent field, wiping the brand panel in from center. |
| 0.50–1.00s | 30–59  | Full purple→cyan panel with the aperture logo + "wehttamsnaps" + "twitch.tv/wehttamsnaps". This is the **Transition Point** — OBS swaps the underlying scene here. |
| 1.00–1.50s | 60–89  | Aperture opens, panel wipes back out to transparency. |
| 1.50–2.00s | 90–119 | Fully transparent hold so OBS can settle before the next scene is fully visible. |

## Import into OBS (WebM — primary)

1. OBS → **Settings → Scene Transitions** (or the + in the Transitions dock).
2. **Add → Stinger**. Name it `wehttamsnaps Stinger`.
3. **Video File:** browse to `wehttamsnaps-stinger.webm`.
4. **Transition Point:** set to **`1000 ms`** (i.e. 1.0 seconds — frame 60, the moment the aperture is fully closed and the panel is at full opacity). This is the instant OBS swaps the scene behind the stinger.
5. **Transition Type:** leave default. **Audio Monitoring:** off (the stinger has no audio).
6. Click OK. Right-click the new transition → **Set as default** if you want it on every scene switch, or assign it per-scene via the scene's right-click menu.
7. Trigger it with a hotkey (see the guide, section 2.1: `Ctrl+Alt+2` for quick transition 2) or the scene-switcher script in `../scripts/scene-switcher.sh`.

## Import into OBS (Image Sequence — fallback / guaranteed alpha)

If the WebM imports without transparency on your build, use the PNG sequence instead — OBS supports image-sequence stingers natively and PNGs carry alpha unambiguously:

1. OBS → **Add → Stinger**.
2. **Video File:** select the *folder* `frames/` (or the first frame `frame_0000.png` — OBS will detect the sequence).
3. **Transition Point:** `1000 ms` (same as above).
4. The downside: image-sequence stingers load 120 PNGs into memory (~150 MB), so prefer the WebM if it works for you.

## Re-encoding the WebM with guaranteed alpha (run on your Arch box)

The included WebM was tagged `alpha_mode=1` (VP9 alpha). On a current Arch system with `libvpx 1.14+` and `ffmpeg 7.x`, OBS will read the alpha correctly. If for any reason it imports opaque, regenerate it from the frame sequence on your machine — Arch's libvpx writes the alpha plane properly:

```bash
cd ~/.config/wehttamsnaps/obs/stinger
ffmpeg -framerate 60 -i frames/frame_%04d.png \
  -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 18 \
  -auto-alt-ref 0 -lag-in-frames 0 -row-mt 1 \
  -metadata title="wehttamsnaps stinger" \
  wehttamsnaps-stinger.webm
```

The keys that make alpha work: `-pix_fmt yuva420p` (the only VP9 pixel format with alpha), `-auto-alt-ref 0` (otherwise VP9 hides alpha behind alt-reference frames and OBS shows black), `-lag-in-frames 0` (deterministic, no first-frame stall).

## Tweaking the design

Edit `render_frames.py`:
- `PURPLE` / `CYAN` / `MAGENTA` near the top — the brand colors.
- `DURATION` and `FPS` — length and smoothness (more fps = bigger files).
- `frame_env()` and `panel_reveal_mask()` — the in/out timing.
- `draw_aperture()` — number of blades (`n = 6`), colors, open-fraction curve.

Re-render with `python3 render_frames.py` (needs `pillow` and `numpy`), then re-encode with the ffmpeg line above.
