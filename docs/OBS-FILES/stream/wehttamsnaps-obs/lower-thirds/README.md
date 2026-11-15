# wehttamsnaps — Lower-Third Overlays (Now Playing / Follow)

Two animated lower-thirds themed to the wehttamsnaps brand (purple→cyan neon
gradient bar, magenta accent, `@wehttamsnaps` tag). Each ships in **two
formats**:

1. **HTML/CSS** — live, data-driven, tiny. Add as an OBS **Browser source**.
2. **Transparent PNG frame sequence + static PNG** — works anywhere, no
   browser needed; drop in as an image source or image-sequence media.

## Files

```
lower-thirds/
├── theme.css                       shared neon-bar theme (both HTML overlays)
├── now-playing.html                live Now Playing (Browser source)
├── follow.html                     live Follow call-to-action (Browser source)
├── now-playing.png                 static final frame (1000×180, transparent)
├── follow.png                      static final frame (1000×180, transparent)
├── now-playing/frame_0000..0059.png   60-frame animation @ 60fps (1.0s)
├── follow/frame_0000..0059.png        60-frame animation @ 60fps (1.0s)
└── render_lower_thirds.py          regenerate the PNGs
```

## OBS import — HTML/CSS (recommended, live data)

1. Sources → **+ → Browser** → name `[Overlay] Now Playing`.
2. **Local file** → browse to `now-playing.html` (check "Local file").
3. Width `1000`, Height `180`. Uncheck "Shutdown source when not visible" if
   you want it to stay warm. **Custom CSS**: leave default (it uses theme.css
   via relative link — keep both files in the same folder).
4. Position it bottom-center of the canvas (e.g. X=460, Y=860).
5. To feed the track text **without editing the HTML**, append query params to
   the URL/path:
   `now-playing.html?track=Daft Punk - Aerodynamic&sub=Discovery • Spotify`
   Or use a tiny StreamElements snippet to push the live track — see
   `streamelements/README.md`.

For the **Follow** overlay, same steps with `follow.html`. It loops the entrance
animation every ~8s (remove the `loop` class on the `.lt` div for a one-shot).

## OBS import — PNG frame sequence (no browser)

1. Sources → **+ → Image** → name `[Overlay] Now Playing (static)`.
2. Browse to `now-playing.png` (or `follow.png`). This is the fully-revealed
   frame — drop it on and it just sits there.
3. For the **animated** version: Sources → **+ → Media** → enable "Image
   Sequence" in the media properties → browse to `now-playing/frame_0000.png`
   → set frame rate `60`, loop. OBS plays the 60 frames as a 1-second reveal
   then holds the last frame.

## Customise

**Colours:** edit `theme.css` `:root` vars (`--purple`, `--cyan`, `--magenta`).

**Text:** edit the `<span>`s in the HTML, or regenerate the PNGs:

```bash
cd lower-thirds
# edit render_lower_thirds.py — change label/value/sub strings
python3 render_lower_thirds.py
```

**Size:** the overlays are 1000×180. To make them wider/narrower, change `--bar-w`
in `theme.css` and `W` in `render_lower_thirds.py`, then re-run.

## Animation timing

- 0–0.45s: gradient bar slides in from the left (cubic-bezier ease-out).
- 0.25–0.80s: label + value + sub fade in with a 20px right-to-left slide.
- 0.50–1.00s: `@wehttamsnaps` tag fades in.
- After 1.0s: bar holds with a slow shimmer sweep every 3.5s. (Follow overlay
  re-runs the whole entrance every 8s via the `loop` class.)
