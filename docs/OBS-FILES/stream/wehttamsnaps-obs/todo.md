# wehttamsnaps OBS Studio Setup — Master TODO

## Section 0 — Brand lock-in
- [x] Read all uploaded MangoWM configs
- [x] Inspect ws-logo.jpg, STARTINGSOON.jpg, overlay template jpg
- [x] Confirm brand: purple→cyan neon gradient, "V⊗S" camera-aperture motif, @wehttamsnaps

## Section 1 — Master reference guide
- [x] Write `docs/WEHTTAMSNAPS-OBS-GUIDE.md` (all 10 how-to topics)

## Section 2 — Animated wehttamsnaps stinger
- [x] Render 120 PNG frame sequence (aperture reveal + brand sweep)
- [x] Encode to WebM (sandbox libvpx drops alpha — documented; PNG sequence primary + Arch re-encode script)
- [x] Contact sheet + README.md with import instructions

## Section 3 — Six scene cards
- [x] 6 cards rendered (starting-soon, stream-starting, live, brb, ending, offline)
- [x] All @wehttamsnaps, purple→cyan gradient, contact sheet + README.md

## Section 4 — Logo overlay PNG (transparent, sized for cam frame)
- [x] Render wehttamsnaps logo procedurally (Pillow → true RGBA) at 1080×1080 master
- [x] Produce 400×400 cam-bug version sized for cam.png frame
- [x] Write logo-overlay/README.md (placement on Live scene cam frame)

## Section 5 — Shell scene-switcher script (obs-websocket + terminal banners)
- [x] `scripts/scene-switcher.sh` using obs-websocket, firing terminal banners
- [x] README.md

## Section 6 — Ready-to-import OBS Scene Collection JSON
- [x] `scene-collection/wehttamsnaps.json` with all scenes/sources pre-wired
- [x] README.md

## Section 7 — Lower-third overlays (Now Playing / Follow)
- [x] HTML/CSS animated lower-thirds + transparent PNG versions
- [x] README.md

## Section 8 — StreamElements overlay package themed to wehttamsnaps
- [x] HTML/CSS/JS overlay package (chat box, alerts, now playing, dock)
- [x] README.md

## Section 9 — Final package + handoff
- [x] Clean up test files, bundle everything, write top-level README
- [x] Attach all deliverables, mark todo complete, call complete
