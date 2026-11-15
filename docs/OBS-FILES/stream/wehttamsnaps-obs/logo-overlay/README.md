# wehttamsnaps — Logo Overlay

A transparent RGBA logo overlay for the **Live** scene, sized to sit cleanly on
top of your `cam.png` frame.

## Files

| File | Size | Use |
|------|------|-----|
| `wehttamsnaps-logo-overlay.png` | 1080×1080 | Master — full-res transparent logo |
| `wehttamsnaps-logo-cam-bug.png` | 400×400  | Cam-bug version — sized for a webcam frame |
| `render_logo.py` | — | Source script (re-run to tweak colours/size) |

Both PNGs are **true RGBA** (verified: alpha channel ranges 0–255, ~318k fully
transparent pixels on the master) — the background is genuinely see-through,
so in OBS it will composite cleanly over your camera feed with no black box.

## How it was made

`render_logo.py` draws the logo procedurally with Pillow on an
`Image.new("RGBA", (S, S), (0,0,0,0))` canvas, which guarantees a real alpha
channel (unlike an AI-generated image that comes back as flat RGB). It reuses
the same brand elements as the stinger and scene cards:

- 6-blade camera aperture, purple→cyan gradient blades, magenta hub + glow ring
- `wehttamsnaps` wordmark in Orbitron (techy geometric sans)
- magenta accent underline
- `LIVE • CREATE • SNAP` tagline in cyan
- a soft drop shadow so the logo reads even over a bright cam background

## OBS import — place on the cam frame (Live scene)

1. **Scene → 10 │ ▶ LIVE** (or whichever scene holds your webcam).
2. **Sources → + → Image** → name it `Logo Bug` → browse to
   `wehttamsnaps-logo-cam-bug.png`.
3. Position it in the **bottom-right corner of the cam frame** (classic bug
   position). Right-click the source → **Transform → Edit Transform** and set:
   - **Position**: X = cam-right − 410, Y = cam-bottom − 410 (so the 400px logo
     sits 10px inside the cam edge).
   - Or just drag it into the corner and nudge with the arrow keys (1px) /
     Shift+arrow (10px).
4. **Right-click → Order → Move to top** so it sits above the camera source.
5. Optional glow: **Right-click → Filters → + → Drop Shadow** → blur 8, color
   `#000000` opacity 60. (The built-in shadow is already drawn, so this is
   optional.)
6. To reuse on every scene that shows the cam: **Right-click → Copy**, then on
   the other scenes **Paste (Reference)** so it stays in sync.

## Tweak & re-render

```bash
cd wehttamsnaps-obs/logo-overlay
# edit render_logo.py — change PURPLE/CYAN/MAGENTA, open_frac, font sizes, etc.
python3 render_logo.py
```

Outputs are regenerated in place. The 400×400 cam-bug is a Lanczos downscale of
the 1080×1080 master, so always edit the master build and re-run.
