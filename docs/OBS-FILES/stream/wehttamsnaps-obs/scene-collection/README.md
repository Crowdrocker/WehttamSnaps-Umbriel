# wehttamsnaps — OBS Scene Collection (ready-to-import)

`wehttamsnaps.json` is a pre-wired OBS **Scene Collection** with all ten scenes
and every source already placed, named, and routed. Import it once, fill in the
four `REPLACE_ME_...` placeholders, and you're ready to stream.

## Import

1. Copy the whole `wehttamsnaps-obs/` folder somewhere stable, e.g.
   `~/stream/wehttamsnaps-obs/` (the source paths in the JSON are relative, so
   keep the folder layout intact).
2. OBS → **Scene Collection → Import** → click the `+` under "Collection Path"
   → browse to `scene-collection/wehttamsnaps.json` → **Import**.
3. **Scene Collection → wehttamsnaps** to activate it.
4. OBS → **Settings → Output**:
   - **Streaming**: Simple mode → Video Bitrate `6000`, Encoder `H.264 VAAPI`,
     Audio Bitrate `160`, Keyframe Interval `2`. (See guide section 3.)
   - **Recording**: Standard, `H.264 VAAPI`, Rate Control `CQP`, `CQ` `18`,
     MKV container.
5. OBS → **Settings → Audio**: Sample rate `48 kHz`, Channels `Stereo`, set
   **Tracks** to `3` (for the Discord-on-track-2 VOD trick in guide section 4).

## The REPLACE_ME placeholders

Open each source's properties and fill in:

| Source | Property | What to set |
|--------|----------|-------------|
| `[Cam] webcam` | Device | your webcam (e.g. `/dev/video0`, 1280×720@30) |
| `[Game] game capture` | PipeWire session | pick the game window/monitor via the portal picker |
| `[Audio] Game (PipeWire)` | Source name | pick the game's PipeWire client (start the game first) |
| `[Audio] Discord (PipeWire)` | Source name | pick the Discord client |
| `[Audio] Desktop (PipeWire)` | Source name | pick your browser / Spotify / desktop client |
| `[Overlay] StreamElements` | URL | your StreamElements overlay URL (see streamelements/README.md) |
| `[Overlay] chat box` | URL | your StreamElements chat-box widget URL |
| `[Overlay] Now Playing` | URL | your StreamElements Now Playing widget URL |

The `[Background]` card sources already point at the rendered PNGs in
`../scene-cards/` and the `[Overlay] logo bug` already points at
`../logo-overlay/wehttamsnaps-logo-cam-bug.png` — no action needed on those as
long as the folder layout is intact.

## Scenes included

| Scene | Contents |
|-------|----------|
| `00 │ Starting Soon` | Starting Soon card (full-screen) |
| `00 │ Stream Starting` | Stream Starting card (full-screen) |
| `10 ─ Live` | game capture + cam (320px bottom-left) + logo bug + StreamElements overlay + Now Playing + chat box + Game/Discord/Desktop audio |
| `10 ─ Just Chatting` | cam (540px, left) + chat box + StreamElements overlay + Now Playing + Desktop audio |
| `20 ┊ BRB` | BRB card (full-screen) |
| `20 ┊ Tech Pause` | Tech Pause card (full-screen) |
| `30 ✦ Ending` | Ending card (full-screen) |
| `30 ✦ Offline` | Offline card (full-screen) |
| `40 ◆ Overlay Test` | Live card as backdrop (for testing overlays without going live) |
| `50 ⚙ Config / Never Air` | empty scene — switch here while configuring live, never broadcast it |

## Transitions

The collection ships three transitions:

- **wehttamsnaps stinger** (default for scene→scene) — the animated aperture
  stinger from `stinger/wehttamsnaps-stinger.webm`, Transition Point 1000ms.
  If the WebM alpha doesn't render on your build, switch its path to the PNG
  image sequence `../stinger/frames/frame_%04d.png` (see stinger/README.md).
- **Cut** — instant.
- **Fade** — 500ms crossfade.

Set the stinger as your default: **Settings → General → Default Scene
Transition → wehttamsnaps stinger**, or right-click the transitions dock.

## Audio track routing (do this once after import)

Open the **Audio Mixer → ⚙ → Advanced Audio Properties** and set:

| Source | Track 1 (live) | Track 2 (VOD-drop Discord) | Track 3 (mic ISO) |
|--------|:-:|:-:|:-:|
| `Mic/Aux` | ✓ | | ✓ |
| `[Audio] Game` | ✓ | | |
| `[Audio] Discord` | ✓ | ✓ | |
| `[Audio] Desktop` | ✓ | | |

Then **Output → Streaming → Audio Track = 1**, **Output → Recording → Audio
Track = All**. Result: the live stream gets the full mix (track 1), and your
local recording keeps Discord isolated on track 2 so you can mute it in the VOD
edit without touching the game.

## Filters on the mic (recommended, from guide section 5)

Open `Mic/Aux → Filters` and add in this order (the script leaves filters empty
so you can tune — these are the values from the guide):

1. **Noise Gate** — close `-45 dB`, open `-35 dB`, attack 25ms, hold 200ms,
   release 150ms.
2. **Compressor** — ratio 3:1, threshold `-18 dB`, attack 6ms, release 60ms,
   output gain `2 dB`.
3. **EQ (3-band)** — high-pass 80 Hz, +2 dB presence ~3 kHz.
4. **Limiter** — threshold `-3 dB`, release 60ms.

(Optionally add an OBS RNNoise filter *only* if you are not running RNNoise at
the PipeWire layer — don't double-process. See guide section 5.)

## Rebuild

```bash
cd scene-collection
python3 build_collection.py   # regenerates wehttamsnaps.json
```

Edit `build_collection.py` to add scenes, change cam size/position, or wire
different overlays, then re-import.
