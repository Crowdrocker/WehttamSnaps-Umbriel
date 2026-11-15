# wehttamsnaps — OBS Studio Streaming Setup (Arch / CachyOS / Wayland / RX 580)

A complete, ready-to-import OBS streaming package for **@wehttamsnaps**, themed
to your brand: **purple (#8A2BE2) → cyan (#00E5FF)** neon gradient, **magenta
(#FF46B4)** accent, **6-blade camera-aperture** motif, Orbitron wordmark.
Everything was built to be consistent across the stinger, scene cards, logo,
lower-thirds, and overlay widgets — and to work natively on your stack
(CachyOS, KDE Plasma 6.7.4 / MangoWM, Wayland, AMD Radeon RX 580, i7-4790,
16 GB RAM).

## What's in here

```
wehttamsnaps-obs/
├── README.md                        ← you are here
├── docs/
│   └── WEHTTAMSNAPS-OBS-GUIDE.md    ← THE master reference (read this first)
├── stinger/                         animated aperture stinger transition
│   ├── wehttamsnaps-stinger.webm    VP9 WebM (OBS-importable; re-encode on Arch)
│   ├── frames/frame_0000..0119.png  120-frame RGBA sequence (guaranteed alpha)
│   ├── stinger-contact-sheet.png    9-frame preview
│   └── README.md
├── scene-cards/                     six 1920×1080 scene backdrops
│   ├── 00-starting-soon.png … 30-offline.png
│   ├── scene-cards-contact-sheet.png
│   └── README.md
├── logo-overlay/                    transparent logo overlay for the cam frame
│   ├── wehttamsnaps-logo-overlay.png   1080×1080 master (true RGBA)
│   ├── wehttamsnaps-logo-cam-bug.png   400×400 cam-bug
│   └── README.md
├── scripts/
│   ├── scene-switcher.sh            obs-websocket scene switcher + terminal banners
│   └── README.md
├── scene-collection/
│   ├── wehttamsnaps.json            ready-to-import OBS Scene Collection
│   ├── build_collection.py
│   └── README.md
├── lower-thirds/                    Now Playing / Follow overlays
│   ├── now-playing.html / follow.html   live HTML/CSS (Browser source)
│   ├── now-playing.png / follow.png     static transparent PNGs
│   ├── now-playing/ follow/             60-frame animated PNG sequences
│   ├── theme.css / render_lower_thirds.py / lower-thirds-contact-sheet.png
│   └── README.md
└── streamelements/                  StreamElements overlay package
    ├── index.html                   all-in-one overlay scene
    ├── alerts.html  chat-box.html  now-playing.html  dock.html
    ├── theme.css  overlay.js  index-preview.png
    └── README.md
```

## Quick-start (5 minutes to a themed stream)

1. **Read the guide.** Open `docs/WEHTTAMSNAPS-OBS-GUIDE.md`. It answers every
   question you asked — the text/symbol separator scene-naming convention,
   keybinds, RX 580 VA-API encoder settings, PipeWire audio separation,
   noise-removal filters, stinger how-to, StreamLabs/StreamElements, the
   custom-dock answer, and the MangoWM-vs-Sway recommendation. The other
   folders are the ready-to-import artefacts built from it.

2. **Install the prereqs** (CachyOS):
   ```bash
   sudo pacman -S --needed obs-studio obs-websocket \
       pipewire pipewire-pulse wireplumber pavucontrol qpwgraph \
       xdg-desktop-portal-wlr ffmpeg jq curl python-pillow
   # VA-API: confirm the RX 580 encoder is seen
   vainfo | grep -E 'H264High|HEVCMain'
   # set the driver if vainfo fails:
   echo 'LIBVA_DRIVER_NAME=radeonsi' | sudo tee /etc/environment.d/radeonsi.conf
   ```

3. **Copy this folder** somewhere stable:
   ```bash
   mkdir -p ~/stream && cp -r wehttamsnaps-obs ~/stream/
   ```

4. **Import the Scene Collection.** OBS → **Scene Collection → Import** →
   browse to `scene-collection/wehttamsnaps.json`. All 10 scenes + sources are
   pre-wired. Fill in the four `REPLACE_ME_...` placeholders (webcam device,
   PipeWire clients, StreamElements URLs) per `scene-collection/README.md`.

5. **Set the encoder.** Settings → Output → Streaming: `H.264 VAAPI`, 6000 kbps,
   keyframe 2s. Recording: `H.264 VAAPI`, CQP 18, MKV. (Full values in guide
   section 3.)

6. **Add the stinger transition.** It's already in the collection — just set it
   as the default: Settings → General → Default Scene Transition →
   `wehttamsnaps stinger`. If the WebM alpha doesn't render on your OBS build,
   switch its path to the PNG sequence `stinger/frames/frame_%04d.png` (see
   `stinger/README.md`).

7. **Wire the scene switcher (Wayland-native).** Install
   `scripts/scene-switcher.sh` and add the MangoWM binds from
   `scripts/README.md` to your `input.conf`. Now `SUPER+F2` switches to Live
   and prints a coloured banner in Konsole.

8. **Add the custom dock.** View → Docks → Custom Browser Docks → point at
   `streamelements/dock.html`. That's the "OBS doesn't have a custom dock"
   answer — Browser Docks are the custom dock.

## The brand, locked

| Token | Value |
|-------|-------|
| Purple | `#8A2BE2` |
| Cyan | `#00E5FF` |
| Magenta accent | `#FF46B4` |
| Gradient | `linear-gradient(90deg, #8A2BE2, #00E5FF)` |
| Motif | 6-blade camera aperture (purple→cyan blades, magenta hub) |
| Wordmark | `wehttamsnaps` in Orbitron (fallback DejaVu Sans Bold) |
| Tagline | `LIVE • CREATE • SNAP` |
| Footer | `@wehttamsnaps  •  twitch.tv/wehttamsnaps  •  youtube  •  tiktok  •  x` |

Every artefact in this package uses these exact values, so the stinger, cards,
logo, lower-thirds, and overlay widgets all look like one coherent system.

## Regenerating anything

All visual artefacts are produced by Python scripts (numpy + Pillow) so you can
tweak colours, sizes, text, and re-run:

```bash
cd stinger          && python3 render_frames.py        # 120 stinger frames
cd scene-cards      && python3 render_cards.py         # 6 scene cards
cd logo-overlay     && python3 render_logo.py          # logo PNGs
cd lower-thirds     && python3 render_lower_thirds.py  # lower-third frames
cd scene-collection && python3 build_collection.py     # scene collection JSON
```

The HTML/CSS overlays (`streamelements/`, `lower-thirds/*.html`) are plain
text — edit them directly; the shared colours live in each folder's
`theme.css`.

## A note on the stinger WebM

The included `wehttamsnaps-stinger.webm` was encoded with this sandbox's ffmpeg
5.1 / libvpx, which drops the VP9 alpha plane (a known limitation of that older
build — decoded frames show opaque alpha regardless of source). **The PNG frame
sequence in `stinger/frames/` has verified real alpha** and is the guaranteed
import path. On your Arch box with modern libvpx 1.14+, re-encoding the
sequence to WebM writes alpha correctly — the exact command is in
`stinger/README.md`. OBS supports PNG image-sequence stingers natively, so
either path works.

## File map by request

| You asked for | Delivered in |
|---------------|--------------|
| Text + symbol separator samples with prefixes | guide §1 + scene names in the JSON |
| Useful keybinds (OBS + compositor) | guide §2 |
| RX 580 VA-API encoder settings on Arch | guide §3 |
| Separate game/Discord/desktop audio via PipeWire | guide §4 + audio sources in JSON |
| Best PipeWire + OBS noise-removal filters | guide §5 |
| How to make an animated logo / custom stinger | guide §6 + `stinger/` |
| Add StreamLabs/StreamElements overlays + chat box | guide §7 + `streamelements/` |
| Custom dock for chat + stream info | guide §8 + `streamelements/dock.html` |
| MangoWM vs Sway recommendation | guide §9 |
| Generate the actual animated stinger | `stinger/` |
| Edit scene cards → @wehttamsnaps, lock gradient | `scene-cards/` |
| Logo → transparent PNG sized for cam frame | `logo-overlay/` |
| Shell scene-switcher (obs-websocket + banners) | `scripts/scene-switcher.sh` |
| Ready-to-import Scene Collection JSON | `scene-collection/wehttamsnaps.json` |
| Now Playing / Follow lower-thirds | `lower-thirds/` |
| StreamElements overlay package themed to wehttamsnaps | `streamelements/` |

## References

- ArchWiki — VA-API, PipeWire, OBS Studio, Wayland
- OBS Studio docs — Scene Collections, Browser Docks, Stinger transitions
- obs-websocket v5 protocol
- werman/noise-suppression-for-voice (RNNoise)
- StreamElements / StreamLabs cloud widget docs

(URLs in the guide's reference list.)

---

Made for **@wehttamsnaps**. Aperture open. 📸
