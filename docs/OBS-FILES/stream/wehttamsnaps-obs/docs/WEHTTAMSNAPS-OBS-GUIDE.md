# wehttamsnaps — OBS Studio Master Setup Guide

**For:** wehttamsnaps on Twitch
**System:** CachyOS Linux, KDE Plasma 6.7.4, Wayland, Kernel 7.1.6-1-cachyos
**GPU:** AMD Radeon RX 580 (Polaris 20, GCN 4.0) — VA-API H.264 + HEVC encode via `radeonsi`
**CPU:** i7-4790 (8 threads) / 16 GiB RAM
**Compositor (planned):** MangoWM with Event-Horizon-shell (KDE components: Dolphin, Konsole, Kate)

This guide is the single reference for everything you asked about: a text-and-symbol scene-naming convention with prefixes, the keybinds worth memorising, optimal VA-API encoder settings for the RX 580 on Arch, PipeWire audio separation for game/Discord/desktop, the best noise-suppression filters on Linux, how to make your own animated logo and stinger, how to add StreamLabs/StreamElements overlays and a chat box, the custom-dock question, and a MangoWM-vs-Sway recommendation. Every other file in this package is a ready-to-import artefact built from this guide.

---

## 1. Text & Symbol Separator Samples with Prefixes (scene-naming convention)

The reason to use prefixes and separators in OBS scene names is muscle memory and ordering. OBS sorts scenes alphabetically in the Scenes dock, so if you prefix them with symbols and numbers they stay in a predictable broadcast order top-to-bottom — the order you actually switch them in during a stream. The separators (the symbol characters between the prefix and the human name) exist purely to make the list scannable at a glance while you are mid-game and glancing at a second monitor.

Below is the full convention I have used to wire the scene collection JSON in this package (`scene-collection/wehttamsnaps.json`). The prefix is a number that fixes sort order; the separator is a Unicode symbol that telegraphs the *kind* of scene; the body is the human-readable name.

### 1.1 The prefix + separator legend

`00 │ ` — **Pre-stream / holding scenes** (what viewers see before you go live). The pipe `│` reads as "a wall between nothing and the show."

`10 ─ ` — **Live gameplay scenes** (the actual content). The em dash `─` reads as "the main line, the show itself."

`20 ┊ ` — **Intermission scenes** (BRB, snack, tech issues). The light vertical dashes `┊` read as "a break in the line."

`30 ✦ ` — **End-of-stream scenes** (Ending, Outro). The sparkle `✦` reads as "the curtain call."

`40 ◆ ` — **Utility / overlay-only scenes** (Just Chatting with no game, a raw "overlay test" scene). The diamond `◆` reads as "a tool, not a performance."

`50 ⚙ ` — **Technical / never-broadcast scenes** (a scene you switch to when configuring something live but never want on the output). The gear `⚙` is self-explanatory.

### 1.2 The full scene list as it appears in OBS (sorted)

```
00 │ Starting Soon
00 │ Stream Starting
10 ─ Live  (game capture + cam + overlays)
10 ─ Just Chatting
20 ┊ BRB
20 ┊ Tech Pause
30 ✦ Ending
30 ✦ Offline
40 ◆ Overlay Test
50 ⚙ Config / Never Air
```

Because OBS sorts these alphabetically and the numbers lead, the list always renders in exactly that order. When you are mid-broadcast and reach for the Scenes dock, your eye lands on the symbol first and you know instantly whether you are about to cut to gameplay, an intermission, or the outro. This is the entire point of "text and symbol separators with prefixes" — it is a low-tech, zero-plugin way to never fumble a scene switch.

### 1.3 Separator symbol samples (copy-paste palette)

If you want to swap the symbols above for your own, here is a palette grouped by feel so you can pick a consistent set. Keep one symbol per *category* and the convention stays readable:

**Wall / boundary feel:** `│ ║ ┃ ╟ ╠ ╡ ╢ ╞ ╥ ╨ ╫ ╬`

**Line / flow feel:** `─ ━ ─ ─ ═ ═ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋`

**Sparkle / event feel:** `✦ ✧ ✶ ✷ ✸ ✹ ✺ ✻ ✼ ✽ ✾ ❀ ❁ ❂`

**Diamond / utility feel:** `◆ ◇ ◈ ◉ ◊ ⬢ ⬡ ⬣ ⬠`

**Gear / technical feel:** `⚙ ⚙ ⚙ ⚙ ⚙ ⚙ ⚙ ⚙ ⚙ ⚙`

**Arrow / direction feel (good for "transition" sources):** `▶ ◀ ▲ ▼ ➜ ➔ ➝ ➞ ➟ ➠ ➡`

**Apostrophe / accent feel (good as a tiny separator inside a source name, e.g. a scene *item*):** `• · ‧ ‧ ∙ ⋅ ◦ ◦`

**Full block / progress feel (good for "starting soon" countdown vibes):** `█ ▓ ▒ ░ ▚ ▞`

A practical rule: never mix more than four symbol families in one scene collection, or the dock turns into visual noise. The six-symbol set above (│ ─ ┊ ✦ ◆ ⚙) is deliberately restrained.

### 1.4 Prefix-only variant (if you hate symbols)

If you decide symbols are too much, the prefix numbers alone still sort correctly. A minimal convention would be:

```
00 Starting Soon
05 Stream Starting
10 Live
15 Just Chatting
20 BRB
25 Tech Pause
30 Ending
35 Offline
40 Overlay Test
50 Config
```

The five-unit gaps (00, 05, 10…) leave room to insert a scene later without renumbering everything.

### 1.5 Applying the convention to scene *items* (sources inside a scene)

The same trick works for the Sources list inside a scene. Prefix items so the ones you tweak most sit at the top and the background plate sits at the bottom:

```
[Cam] wehttamsnaps webcam
[Overlay] lower-third Now Playing
[Overlay] chat box
[Overlay] logo bug
[Game] game capture
[Audio] desktop (PipeWire)
[Audio] Discord (PipeWire)
[Background] Starting Soon card
```

Square brackets instead of symbols here, because the Sources dock is denser and brackets scan faster than wide Unicode glyphs.

---

## 2. Useful Keybinds (OBS + MangoWM, Arch/Wayland/RX 580 aware)

### 2.1 Inside OBS (set in Settings → Hotkeys)

OBS hotkeys are global by default on Linux when OBS is running, which is what you want mid-game. Set these once and they survive scene-collection imports:

**Scene switching (the ones you will use every stream):**
- `Start Streaming` → `Ctrl + Alt + S` (or a stream-deck button)
- `Stop Streaming` → `Ctrl + Alt + Shift + S`
- `Start Recording` → `Ctrl + Alt + R`
- `Stop Recording` → `Ctrl + Alt + Shift + R`
- Switch to `10 ─ Live` → `F13` (or `Ctrl + 1`)
- Switch to `10 ─ Just Chatting` → `F14` (or `Ctrl + 2`)
- Switch to `20 ┊ BRB` → `F15` (or `Ctrl + 3`)
- Switch to `30 ✦ Ending` → `F16` (or `Ctrl + 4`)
- Switch to `00 │ Starting Soon` → `F17` (or `Ctrl + 5`)
- Switch to `30 ✦ Offline` → `F18` (or `Ctrl + 6`)

The `F13–F24` keys are ideal for OBS because almost no game binds them and most keyboards expose them via a macro layer or a stream deck. On a normal keyboard without F13+, fall back to the `Ctrl + number` set. **Do not bind scene switches to plain number keys** — games eat those.

**Source toggles (show/hide overlays without leaving the game):**
- Toggle `[Cam]` → `Ctrl + Shift + C`
- Toggle `[Overlay] lower-third` → `Ctrl + Shift + L`
- Toggle `[Overlay] chat box` → `Ctrl + Shift + H`
- Toggle `[Overlay] logo bug` → `Ctrl + Shift + B`
- Toggle microphone mute → `Ctrl + Shift + M` (mirror of the MangoWM `SUPER+SHIFT+M` sink mute, but for the *OBS* mic source)

**Transition control:**
- `Transition` (cut to the selected scene with the stinger) → `Ctrl + Alt + Space`
- `Quick Transition 1` (cut, no animation) → `Ctrl + Alt + 1`
- `Quick Transition 2` (the wehttamsnaps stinger) → `Ctrl + Alt + 2`

**Important Wayland caveat:** OBS hotkeys rely on X11/legacy global grab on some compositors. Under MangoWM (wlroots-based) you generally get global hotkeys working through the **obs-portal / xdg-desktop-portal-wlr** path that you already start in `execs.conf`. If a hotkey ever stops firing, the fix is to bind it from the compositor side instead: add a MangoWM bind that sends the key to OBS via `wtype` or, cleaner, use the **obs-websocket** scene-switcher script included in this package (`scripts/scene-switcher.sh`) and bind *that* in MangoWM. That is the robust Wayland-native path and it is what section 5 of this package implements.

### 2.2 Outside OBS — MangoWM binds you already have that matter for streaming

Your `keybinds.conf` already has the right chords. The ones to keep top-of-mind while live:

- `SUPER+SHIFT+O` → launches OBS (with your J.A.R.V.I.S. sound). This is your "go live" muscle-memory chord.
- `SUPER+CTRL+T` → opens Twitch as a Brave app window. Use this for the dashboard / chat monitor on a second tag.
- `SUPER+CTRL+D` → Discord as a Brave app window.
- `SUPER+CTRL+Y` → YouTube as a Brave app window (for premieres / VOD checks).
- `ALT+SHIFT+P` → Spotify launcher (for the "Now Playing" lower-third source if you wire it to Spotify).
- `NONE, XF86AudioMute` / `NONE, XF86AudioRaiseVolume` → system sink volume. These affect what *you* hear, not what OBS captures (OBS captures per-app via PipeWire, see section 4), so these are safe to mash on stream.
- `ALT, XF86AudioMute` → mutes the *source* (mic). Handy pre-stream check.
- `SUPER+ALT+R` → your AGS record script (local clip recording, separate from OBS).
- `SUPER+SHIFT+S` → Steam (so you do not tab to it).

### 2.3 New binds I recommend adding to MangoWM for the stream workflow

Add these to `~/.config/mango/custom/keybinds.conf` (your override file, loaded last) so they survive a settings-UI regeneration:

```
# Scene switching via the obs-websocket script (Wayland-native, no X grab needed)
bind=SUPER+F1,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh starting
bind=SUPER+F2,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh live
bind=SUPER+F3,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh justchatting
bind=SUPER+F4,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh brb
bind=SUPER+F5,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh ending
bind=SUPER+F6,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh offline

# Toggle OBS recording without focusing OBS
bind=SUPER+SHIFT+R,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh toggle-record
```

These hand the scene switch to the obs-websocket script in section 5, which both fires the scene change in OBS *and* prints the section-4 terminal banner. That is the cleanest Wayland story: no global key grab, no X dependency, and the banner gives you a visible confirmation in Konsole that the switch landed.

---

## 3. Optimal OBS VA-API Encoder Settings for the AMD Radeon RX 580 on Arch Linux

### 3.1 What the RX 580 actually supports

The RX 580 is Polaris 20 (GCN 4.0). Per the ArchWiki hardware-video-acceleration table and `vainfo` on a radeonsi stack, it exposes:

- **H.264 (AVC) encode** — `VAEntrypointEncSlice` and the low-power `VAEntrypointEncSliceLP`. This is the workhorse and what you should use for Twitch.
- **H.264 decode** — full.
- **HEVC (H.265) 8-bit encode** — present on Polaris, but the encoder quality at a given bitrate is *worse* than H.264 on this generation, and Twitch does not accept HEVC anyway. Use HEVC only for **local recording** if you want smaller files and can spare the bitrate.
- **HEVC 10-bit encode** — available; useful only for HDR local recording, which the RX 580 cannot meaningfully produce from an SDR game capture, so skip it.
- **AV1** — not supported on Polaris. Do not attempt.
- **VP9 encode** — not exposed via VA-API on Polaris.

So the answer for your card is unambiguous: **stream with H.264 VA-API (the "VAAPI" encoder in OBS), record locally with H.264 VA-API at a high bitrate, or with HEVC VA-API if you want smaller files and do not mind the quality-per-bit trade-off on Polaris.**

### 3.2 Prerequisites on Arch

Install the VA-API stack and verify (you likely already have most of this on CachyOS):

```bash
sudo pacman -S --needed mesa libva-mesa-driver mesa-vdpau libva libva-utils vulkan-radeon
vainfo | grep -iE "VAEntrypointEnc|H264|HEVC"
```

You want to see `VAProfileH264High : VAEntrypointEncSlice` and `VAEntrypointEncSliceLP`, plus `VAProfileHEVCMain : VAEntrypointEncSlice`. If `vainfo` fails to find a driver, set `LIBVA_DRIVER_NAME=radeonsi` (in `~/.config/environment-d/` or your shell profile) — this is the correct driver name for the open AMDGPU stack, as documented in the ArchWiki VA-API configuration section.

OBS itself: install `obs-studio` from the official repos (or `obs-studio-git` from the AUR if you want bleeding edge). The Flatpak also works and bundles a known-good FFmpeg, but the native package talks to your system VA-API more directly. On Wayland you additionally want `xdg-desktop-portal-wlr` (already in your `execs.conf`) so the PipeWire screen capture works.

### 3.3 Stream encoder settings (Twitch, 1080p30 or 720p60)

Twitch ingest caps ordinary affiliates/partners at **6000 kbps** for video (the "6000 kbps" guideline) plus 160 kbps audio. For the RX 580 with an i7-4790, the sweet spot is 1080p30 or 720p60 — 1080p60 VA-API on Polaris is achievable but pushes the encoder and can drop frames under heavy scene motion, so only attempt it if your `vainfo`-confirmed encoder holds up in a stress test (section 3.6).

In OBS: **Settings → Output → Output Mode: Advanced → Streaming tab.**

- **Encoder:** `H.264 VAAPI` (if you only see "Software (x264)", your OBS is not seeing VA-API — see section 3.7).
- **Rate Control:** `CBR` (Twitch requires a stable bitrate; VBR causes buffering for viewers).
- **Bitrate:** `6000` kbps (the Twitch cap). If you sometimes buffer, drop to `4500` for 720p60 or `3500` for 720p30.
- **Keyframe Interval:** `2` seconds (Twitch demands ≤ 2s; do not set to 0/auto on VA-API).
- **GPU:** `0` (your single RX 580).
- **BFrames:** `2` (Polaris handles 2 B-frames comfortably; 0 is safer if you see artifacts).
- **Quality / Preset:** `Quality` (or `Balanced`). Avoid `Speed` on VA-API for streaming — it softens detail.
- **Profile:** `high` (do not use `main` or `baseline` for game capture; `high` keeps 8x8 transform and better quality per bit).
- **Level:** `4.2` for 1080p30 / 720p60; `4.0` for 720p30. Setting the level explicitly avoids Twitch ingest rejections.
- **Max QP / Min QP:** leave at VA-API defaults (do not clamp on Polaris; clamping causes stutter).
- **RC lookahead / Other advanced:** leave OFF — VA-API on Polaris does not benefit from lookahead and enabling it can stall the encoder.

### 3.4 Audio for streaming (OBS, simple, paired with the PipeWire separation in section 4)

- **Audio Encoder:** `AAC` at `160` kbps (Twitch's effective cap for non-partner audio; 192 is fine too).
- **Sample rate:** `48 kHz` (Settings → Audio).
- **Channels:** `Stereo`.

### 3.5 Local recording encoder settings (best quality, separate from stream)

In OBS: **Settings → Output → Output Mode: Advanced → Recording tab**, with **Recording Path** set to a fast local disk.

**Option A — H.264 VAAPI, max quality, large files:**
- **Type:** `Custom Output (FFmpeg)` is overkill; use the standard `Standard` recording type with the `H.264 VAAPI` encoder.
- **Rate Control:** `CQP` (constant quality) at **QP 18–20**. CQP gives far better quality-per-bit than CBR for recording.
- **Keyframe Interval:** `2`.
- **Preset:** `Quality`.
- **Profile:** `high`.

**Option B — HEVC VAAPI, smaller files, slightly lower quality per bit on Polaris:**
- **Encoder:** `H.265 HEVC VAAPI`.
- **Rate Control:** `CQP` at **QP 22–24** (HEVC needs a higher QP number to hit the same quality as H.264).
- Everything else as Option A.
- Use this only if disk space matters more than pristine quality; on Polaris, H.264 CQP at QP 18 usually looks better than HEVC CQP at QP 22 at equivalent file sizes for game capture.

**Recording format:** `mkv` (Matroska). MKV is crash-safe — if OBS dies mid-recording, the file is recoverable, unlike MP4. Remux to MP4 afterwards with **File → Remux Recordings** if you need MP4 for editing.

### 3.6 Stress-testing the encoder before going live

Before your first real stream, run a 10-minute test stream to Twitch's "Auto" ingest (or a private test session) while running the most motion-heavy game you own. Watch the **Stats dock** in OBS (View → Docks → Stats). Targets:

- **Dropped frames (streaming):** 0. If you drop, lower bitrate first (6000 → 4500), then resolution.
- **Skipped frames (rendering/encoding):** 0. If non-zero on VA-API, drop BFrames to 0 and/or drop to 720p60.
- **Encoding lag:** 0.
- **GPU usage:** check with `amdgpu_top` (or `nvtop`); the VA-API encoder on the 580 should sit well under 30% during a 1080p30 6 Mbps encode. If it pegs, you have a config problem, not a hardware problem.

### 3.7 Troubleshooting "OBS only shows the Software (x264) encoder"

This is the single most common VA-API failure on Arch and it has a short checklist:

1. Confirm `vainfo` works *as your user* (not just as root). If it only works as root, your user is not in the `video` group: `sudo usermod -aG video $USER` then re-login.
2. Confirm `LIBVA_DRIVER_NAME=radeonsi` is set in your session environment. With MangoWM you can put it in `~/.config/mango/hyprmango/env.conf` as `env=LIBVA_DRIVER_NAME,radeonsi` (you already have an env.conf; add the line).
3. If you installed OBS as a Flatpak, give it device permission: `flatpak override --user --device=all com.obsproject.Studio`. Better: use the native package.
4. Make sure no other process has the encoder open (a stuck ffmpeg can hold it).
5. Restart OBS fully after any of the above — OBS probes VA-API at startup.

---

## 4. Separating Game Audio, Discord, and Desktop Audio in OBS with PipeWire

The goal: in OBS, have three independent audio sources — *game audio*, *Discord voice*, and *desktop/system audio* — each on its own track, each mutable/solo-able, and each routable to a separate stream audio track so you can mute Discord from the VOD without muting the game. PipeWire makes this straightforward once you understand that OBS on Linux can capture **per-application audio** natively via the PipeWire Audio Capture source (no virtual cable needed for the basic case).

### 4.1 The two approaches and when to use each

**Approach A — Per-application capture (simplest, recommended to start).** OBS 30+ ships a **"Application Audio Capture (Pipewire)"** source. Add one per app you care about (the game, Discord, your browser). Each captures only that app's audio. This needs zero virtual sinks and is the right starting point.

**Approach B — Virtual sinks with qpwgraph (full control, needed for routing tricks).** You create PipeWire virtual sinks, route apps into them with `qpwgraph` or `pw-loopback`, then capture the sinks in OBS as "Audio Output Capture (Pipewire)" sources. Use this when you want, e.g., to hear Discord in your headphones but *also* route it to OBS, or to keep game audio out of your headphones while still capturing it.

### 4.2 Approach A step by step (do this first)

1. In OBS, in your `10 ─ Live` scene, add a source → **Application Audio Capture (Pipewire)**. Name it `[Audio] Game`.
2. In the source properties, pick the game's client (start the game first so it appears). PipeWire matches by client name; if the game is not running yet, leave it and pick it once it launches.
3. Add a second **Application Audio Capture (Pipewire)** → name it `[Audio] Discord` → pick the Discord client.
4. Add a third for your browser / Spotify / whatever you count as "desktop" → `[Audio] Desktop (Browser)`.
5. For pure system sounds (notification pings, etc.) that are not tied to one app, add an **Audio Output Capture (Pipewire)** pointed at your real output sink → `[Audio] System Sinks`. Keep this one low or muted by default; it is mostly a safety net.

Now in **Settings → Audio → Advanced**, set **Tracks** to at least 3, and in the **Audio Mixer → Advanced Audio Properties** (click the gear in the mixer) assign:
- `[Audio] Game` → Track 1 (and 1 only, for the live stream)
- `[Audio] Discord` → Track 1 *and* Track 2 (so the VOD can drop Discord by deselecting track 2)
- `[Audio] Desktop` → Track 1
- `Mic` → Track 1 *and* Track 3

Then in **Output → Streaming**, set **Audio Track** to `1`. In **Output → Recording**, set **Audio Track** to `All` (or `1,2,3`) so the local recording keeps everything and you can strip Discord in post.

### 4.3 Approach B step by step (when you need routing)

Install the tools:

```bash
sudo pacman -S --needed qpwgraph pipewire pipewire-pulse wireplumber pavucontrol
```

Create two virtual sinks (game, discord) and a combined "stream" sink:

```bash
pactl load-module module-null-sink object.linger=1 media.class=audio/sink sink_name=game_capture channels=2 rate=48000 sink_properties=device.description=GameCapture
pactl load-module module-null-sink object.linger=1 media.class=audio/sink sink_name=discord_capture channels=2 rate=48000 sink_properties=device.description=DiscordCapture
```

(`module-null-sink` works because pipewire-pulse implements it; the `object.linger=1` keeps the sink alive after the creating client exits.) To make them permanent, drop those lines into a wireplumber script or `~/.config/pipewire/pipewire.conf.d/10-virtual-sinks.conf` as `context.exec` entries.

Open `qpwgraph`. You will see your real output (headphones) on one side and the new virtual sinks on the other. Route:

- Game client → `GameCapture` sink *and* → headphones (so you still hear it).
- Discord client → `DiscordCapture` sink *and* → headphones.
- `GameCapture` and `DiscordCapture` monitor outputs → OBS (via "Audio Output Capture (Pipewire)" sources named `[Audio] Game` and `[Audio] Discord`).

The advantage over Approach A is that you can re-route on the fly in qpwgraph without touching OBS, and you can decide per-app whether *you* hear it while OBS always captures it.

### 4.4 Discord specifically — one gotcha

Discord on Linux (the official client or WebCord) outputs to your default sink. If you want Discord *only* in OBS and not in your headphones (e.g., to avoid echo when your mic also picks up the headphone bleed), set Discord's output device in its own settings to the `DiscordCapture` sink, then in qpwgraph route `DiscordCapture` → OBS *and* → headphones *with a lower gain* if you still want to hear your friends. Do not route Discord to headphones only — OBS would miss it.

---

## 5. Best PipeWire and OBS Audio Filters for Background Noise Removal on Linux

You have two layers to clean: (a) the *system* mic signal before it reaches anything, and (b) the OBS mic source after it enters OBS. The professional move is to clean at the system layer with RNNoise via PipeWire, then add light OBS filters for final shaping. Do not stack heavy noise gates *and* RNNoise *and* OBS RNNoise — that triple-processes the voice and makes it sound underwater. Pick one noise-removal engine and use light supporting filters for the rest.

### 5.1 System layer — RNNoise as a PipeWire filter (recommended primary)

The cleanest Linux-native solution is the **werman/noise-suppression-for-voice** RNNoise plugin run as a PipeWire filter chain, exposing a virtual "clean mic" source that OBS then captures. This is the same RNNoise model OBS uses internally, but running it at the PipeWire layer means *every* app (Discord, OBS, browsers) gets the cleaned signal consistently.

Install:

```bash
# AUR: noise-suppression-for-voice-git (provides the ladspa plugin)
yay -S noise-suppression-for-voice-git
# or build from source: https://github.com/werman/noise-suppression-for-voice
```

Create `~/.config/pipewire/pipewire.conf.d/10-rnnoise.conf`:

```
context.modules = [
  { name = libpipewire-module-filter-chain
    args = {
      node.description = "Clean Mic (RNNoise)"
      media.name       = "Clean Mic (RNNoise)"
      filter.graph = {
        nodes = [
          {
            type  = ladspa
            name  = rnnoise
            plugin = /usr/lib/ladspa/librnnoise_ladspa.so
            label  = noise_suppression_stereo
            control = {
              "VAD Threshold (%)" = 50.0
            }
          }
        ]
        links = [
          { output = "rnnoise" input = "rnnoise" }
        ]
      }
      capture.props = {
        node.name   = "capture.rnnoise"
        media.class = Audio/Sink
        audio.channels = 1
        audio.position = [ MONO ]
      }
      playback.props = {
        node.name   = "rnnoise_source"
        media.class = Audio/Source
        audio.channels = 1
        audio.position = [ MONO ]
      }
    }
  }
]
```

Restart PipeWire (`systemctl --user restart pipewire wireplumber`). You now have a `Clean Mic (RNNoise)` source. In OBS, add an **Audio Input Capture (Pipewire)** source named `[Audio] Mic` and select `Clean Mic (RNNoise)`. Tune the `VAD Threshold` between 30 (aggressive, more suppression, risk of clipping quiet speech) and 70 (gentle, less suppression). 50 is the safe default; drop to 40 if your room is noisy.

**NoiseTorch** (`noisetorch` AUR) is a GUI alternative that does the same thing with a one-click virtual mic; use it if you do not want to edit pipewire configs. EasyEffects (`easyeffects`) can also host RNNoise as a plugin on the input chain and gives you a full EQ + gate + RNNoise pipeline with a GUI — the most flexible option if you want to also shape the mic tone.

### 5.2 OBS layer — light supporting filters

On the OBS `[Audio] Mic` source, add these filters in this order (top to bottom = signal flow):

1. **Noise Gate** — Threshold `-35 dB`, Attack `5 ms`, Hold `200 ms`, Release `150 ms`. This is your *silence* gate, not your noise remover. It cuts the stream when you are not talking so RNNoise residual hiss never reaches the output.
2. **RNNoise** (the built-in OBS filter, *if* you did NOT install the system-level RNNoise above; otherwise skip — do not double up). If using it standalone: VAD threshold `30–40`.
3. **Compressor** — Ratio `3:1`, Threshold `-18 dB`, Attack `6 ms`, Release `60 ms`, Output gain `0 dB`, Sidechain = the mic itself. This evens out your voice level.
4. **EQ (3-band or parametric)** — gentle: cut ~`-3 dB` at `100 Hz` (rumble), small `+1.5 dB` shelf at `3 kHz` (presence), cut `-2 dB` at `8 kHz` (sibilance). Do not over-EQ on a dynamic mic in an untreated room; it makes things worse, not better.
5. **Limiter** — Threshold `-3 dB`, Release `60 ms`. Final safety so a cough or desk-thump does not clip the stream.

If you went the system-RNNoise route (5.1), drop filter #2 entirely. The remaining four (gate, compressor, EQ, limiter) are the standard broadcast chain and will make your mic sound 80% of the way to a dedicated streamer setup on any XLR or USB mic.

### 5.3 What to avoid

Do not run **both** EasyEffects RNNoise **and** OBS RNNoise **and** NoiseTorch — three RNNoise instances in series destroy intelligibility. Pick one noise remover (I recommend the PipeWire filter-chain in 5.1 because it is app-agnostic and survives OBS restarts), and let the OBS chain handle dynamics only.

---

## 6. How to Make Your Own Animated Logo or Custom Stinger

A stinger transition is just a short video with an **alpha channel** (transparency) that OBS plays between two scenes. The classic form is a "wipe": the stinger covers the outgoing scene, the swap happens at the midpoint, and the stinger reveals the incoming scene. There are three ways to make one, in order of effort.

### 6.1 The recipe (what you asked for) + the rendered file (what I also built)

**Toolchain:** design the still logo → animate it → render a PNG frame sequence with transparency → encode to **VP9 in a WebM container with alpha** (this is the format OBS imports cleanly as a stinger; MP4 cannot carry alpha).

**Step 1 — Design.** Make the logo in Inkscape/Krita/Illustrator as a vector or layered raster with a transparent background. Your existing `ws-logo.jpg` (the "V25" + aperture neon mark) is the starting point; for a stinger you want a version on a transparent background, not a JPEG (JPEG has no alpha).

**Step 2 — Animate.** Two free options:
- **Blender** (3D / 2D, full control): import the logo as a plane, keyframe a reveal (aperture blades rotate open, the neon text sweeps in with an emission shader), set the output to PNG RGBA, 1920×1080, 60 fps, 2 seconds. Render the frame sequence to a folder.
- **Synfig Studio** or **Penpot** (2D vector animation, lower learning curve): same idea, export PNG RGBA frames.
- **After Effects via wine / Rive / Lottie**: possible but more friction on Arch; only if you already know them.

**Step 3 — Render frames.** Whatever tool you use, render to a **PNG sequence with alpha** (`frame_0000.png`, `frame_0001.png`, …). 60 fps for 2 seconds = 120 frames. Keep the canvas 1920×1080 even if the art is smaller; the transparent border is fine and lets you position the stinger in OBS.

**Step 4 — Encode to transparent WebM.** The exact ffmpeg command (this is the one I used to build the included stinger):

```bash
ffmpeg -framerate 60 -i frames/frame_%04d.png \
  -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 18 \
  -tile-columns 2 -tile-rows 0 -frame-parallel 0 \
  -auto-alt-ref 0 -lag-in-frames 0 -row-mt 1 \
  -metadata title="wehttamsnaps stinger" \
  stinger/wehttamsnaps-stinger.webm
```

The keys: `-pix_fmt yuva420p` (the only VP9 pixel format that carries alpha), `-auto-alt-ref 0` (otherwise VP9 hides the alpha behind alt-refs and OBS shows a black frame), `-crf 18 -b:v 0` (constant quality, no bitrate cap), `-lag-in-frames 0` (deterministic, no lookahead stalling the first frames).

**Step 5 — Import to OBS.** Settings → Scene Transitions → Add → **Stinger** → point the "Video File" at the WebM → set "Transition Point" to the frame/time where the stinger is fully covering the screen (the midpoint of the reveal). The "Transition Point" is the magic number: it tells OBS *when* during the stinger to actually swap the underlying scene. For a symmetric 2-second stinger, set it to `1.0s` (or the equivalent frame).

### 6.2 The included, ready-to-import stinger

Rather than leave you with only the recipe, this package ships a fully rendered wehttamsnaps stinger at `stinger/wehttamsnaps-stinger.webm` — a 2-second, 60fps, 1920×1080, alpha-channel VP9 transition built from your purple→cyan gradient and aperture logo motif. See `stinger/README.md` for the import steps and the exact frame the Transition Point should be set to.

---

## 7. Adding StreamLabs or StreamElements Overlays and a Chat Box

Both StreamLabs and StreamElements deliver overlays as a **browser URL** — you paste the URL into an OBS **Browser source** and it renders your alerts, chat box, labels, and "Now Playing" widgets live. On Linux this works identically to Windows because OBS's browser source is Chromium-based (CEF) on both. You do not install either as a separate app.

### 7.1 StreamElements (recommended — the overlay package in this package is themed to it)

1. Go to streamelements.com, log in with your Twitch account (`wehttamsnaps`).
2. Dashboard → **Overlays** → **New Overlay** → either pick a template or **Blank**. The editor opens.
3. In the editor, add widgets: **Alert Box**, **Chat Box**, **Labels** (for "Now Playing" / follower count), **Spinner / Tips**, etc. Each overlay has a unique URL like `https://streamelements.com/overlay/abc123...`.
4. Copy that URL.
5. In OBS, in your `10 ─ Live` scene, add a source → **Browser**. Name it `[Overlay] StreamElements`. Paste the URL. Set width `1920`, height `1080`. Check "Refresh browser when scene becomes active" if you want it to reload on each scene switch.
6. The chat box specifically: in the StreamElements editor add a **Chat Box** widget, style it (this package's `streamelements/` folder contains a themed chat-box CSS you can paste into the widget's custom CSS), copy the *widget* URL (or the whole overlay URL), and add it as a Browser source sized to where you want chat to appear.

### 7.2 StreamLabs

1. streamlabs.com, log in with Twitch.
2. Dashboard → **Alert Box** (and **Widgets** for chat box, event list, donation ticker, etc.). Each widget has a "Widget URL".
3. In OBS, add a **Browser** source per widget, paste the URL, size it.

### 7.3 A note on StreamLabs Desktop on Linux

StreamLabs *Desktop* (the all-in-one streaming app, the thing people mean when they say "StreamLabs" on Windows) **does not have a native Linux build**. You only ever need the **cloud widgets + OBS Browser source** path on Linux, which is what sections 7.1 and 7.2 describe. Do not waste time trying to run StreamLabs Desktop under Wine; the browser-widget path is the supported Linux workflow and is objectively better anyway (it keeps OBS as your encoder, so you keep VA-API).

### 7.4 The themed package in this bundle

`streamelements/` contains a self-contained overlay package themed to wehttamsnaps: a chat box, an alert box, a "Now Playing" label, and a follower-goal bar, all using your purple→cyan gradient. You can either (a) paste the individual widget HTML/CSS into StreamElements' "Custom CSS" fields, or (b) host the folder and point a Browser source at `index.html` for a local, no-account-needed overlay. See `streamelements/README.md`.

---

## 8. Custom Docks in OBS — the answer to "my OBS doesn't seem to have a custom dock option"

You are not missing a menu item; OBS does not have a generic "Create Custom Dock" button in the way some all-in-one apps do. What it *does* have, and what gives you a custom chat + stream-info dock, is **Browser Docks** — you can dock any web page as a panel inside the OBS window. That is the mechanism. Here is exactly how to get a chat dock and a stream-info dock.

### 8.1 Built-in: dock the Twitch chat as a Browser Dock

1. In OBS, **View → Docks → Custom Browser Docks…**
2. Click **Add**. Title: `Twitch Chat`. URL: `https://www.twitch.tv/popout/wehttamsnaps/chat?popout=` (this is the pop-out chat for your own channel; log in once and it persists).
3. Click **Add** again. Title: `Twitch Dashboard`. URL: `https://dashboard.twitch.tv/u/wehttamsnaps/stream-manager` (the live stream manager with stats, health, chat, and activity feed).
4. Click **Add** again. Title: `Stream Info`. URL: `https://dashboard.twitch.tv/u/wehttamsnaps/stream-manager/edit-stream-info` (the "edit stream info" panel: title, category, tags).
5. Close the dialog. Each dock now appears under **View → Docks**; toggle them on, then drag them by their tab into the docking area (usually right side or bottom) until they snap in.

That is your custom chat + stream-info dock, built entirely from OBS's built-in Browser Docks — no plugin, no "custom dock option" needed, because Browser Docks *are* the custom dock option.

### 8.2 If you genuinely want the old "Custom Dock" plugin behaviour

There used to be a third-party plugin (`obs-custom-docks`) that added arbitrary Qt-widget docks. It is unmaintained against current OBS and I do not recommend it. The Browser Dock path in 8.1 is the supported, future-proof equivalent and is strictly more capable because any web widget (StreamElements chat, Twitch dashboard, a local stats page, even a self-built HTML dashboard) can be a dock.

### 8.3 A self-built wehttamsnaps dock (bonus)

If you want a single dock that shows chat *and* stream info *and* your scene-switch banners in one panel, build a small local HTML page and dock *that*. This package includes `streamelements/dock.html` — a combined chat + stream-info + banner panel themed to wehttamsnaps that you can dock via **Custom Browser Docks** pointing at the local file URL (`file:///home/wehttamsnaps/.config/wehttamsnaps/obs/dock.html`) or host it locally with `python3 -m http.server` and point the dock at `http://localhost:8000/dock.html`.

---

## 9. MangoWM vs Sway — recommendation for someone who loves KDE components but wants tiling

You said it well: you want KDE's *components* (Dolphin, Konsole, Kate, the file dialogs, the integration) but the *feel* of a tiling workflow, and you are weighing MangoWM vs Sway, possibly with Event-Horizon-shell instead of Waybar. Here is the honest, opinionated answer.

**Sway** is the safe, boring, correct default. It is the reference wlroots tiling compositor, it has been production-stable for years, its config format is a documented standard, every tool in the Wayland ecosystem (slurp, grim, wlr-randr, waybar, nwg-*, xdg-desktop-portal-wlr) is tested against it first, and "KDE apps on Sway" is a path thousands of people walk without surprises. If you want to spend your time streaming and *not* debugging your compositor, Sway is the answer. Your existing config tree (env.conf, execs.conf, rules.conf, keybinds.conf) ports to Sway almost line-for-line because MangoWM's syntax was deliberately Hyprland/Sway-adjacent — the main edits are `bind=SUPER,r,reload_config` → `bindsym $mod+r reload`, `spawn,` → `exec `, and the Mango-specific `mmsg dispatch ...` calls → `swaymsg ...`. Your `rules.conf` window rules become Sway `assign`/`for_window` lines. It is a weekend of porting, not a rewrite.

**MangoWM** is the more interesting choice and the one your configs are already written for, so switching cost is near zero *right now*. It is newer, smaller-community, and its documentation is thinner than Sway's, which means when something does not work you will be reading source instead of a wiki. Its selling points for your case: it borrows the Hyprland-style feature surface (scroller layout, dwindle, overview, layer animations, scenefx blur/shadows) that you clearly enjoy — your `decoration.conf` and `animations.conf` lean hard into that — and it natively supports the QuickShell/Event-Horizon-shell IPC calls you already bind (`qs ipc call ...`). Sway can run QuickShell too, but Event-Horizon-shell, Noctalia-shell, and Dank-Material-Shell are all built and tested against the Hyprland/Mango family first, so on Sway you would be the one filing the compatibility bugs.

**My recommendation, given everything you uploaded:** stay on MangoWM for now, because your config tree is already a Mango tree and it is wired to your J.A.R.V.I.S. sound system, Event-Horizon-shell, and the wehttamsnaps scripts. The risk is low *because* you have already done the integration work. Keep Sway in your back pocket as the fallback: if you ever hit a Mango bug that blocks streaming (e.g., a screencopy/xdg-desktop-portal regression that breaks OBS capture), you can boot a Sway session from your display manager for that stream and port your binds in an hour. Do not switch to Sway preemptively — that would throw away the working Mango setup for a hypothetical problem.

**On Event-Horizon-shell vs Waybar:** Event-Horizon-shell (and its siblings Noctalia and Dank-Material-Shell) are QuickShell-based, which means they are far more flexible than Waybar and they match the Mango/Hyprland aesthetic you want. The trade-off is the same as Mango vs Sway: more power, smaller community, more debugging. Given you already bind `qs ipc call ...` extensively and your `execs.conf` starts `qs`, Event-Horizon-shell is the consistent choice. If you want a bar that "just works" with zero fiddling, Waybar is the fallback — but you would lose the cohesive Mango+QuickShell feel you have built.

**One concrete thing to tweak in your configs before you stream:** your `rules.conf` notes that Mango has no `block-out-from "screencast"` equivalent (the niri feature that hid KeePassXC and your welcome app from screen shares). On OBS this matters: when you capture a window or the whole screen, sensitive windows will be visible. Until Mango adds that feature, the mitigation is a **dedicated "Never Air" tag** (your `50 ⚙` scene's underlying workspace) that you move password managers to before going live, and using **Window Capture (Pipewire)** in OBS for the game specifically rather than full-screen capture, so OBS never sees the rest of your desktop. The scene collection in this package is built around window capture for exactly this reason.

---

## 10. File map of this package

```
wehttamsnaps-obs/
├── docs/
│   └── WEHTTAMSNAPS-OBS-GUIDE.md          ← this file
├── stinger/
│   ├── wehttamsnaps-stinger.webm          ← ready-to-import transparent VP9 transition
│   ├── frames/                            ← the PNG frame sequence it was rendered from
│   └── README.md                          ← import + transition-point instructions
├── scene-cards/
│   ├── 00-starting-soon.png               ← six 1920x1080 cards, @wehttamsnaps, gradient locked
│   ├── 00-stream-starting.png
│   ├── 10-live.png
│   ├── 20-brb.png
│   ├── 30-ending.png
│   ├── 30-offline.png
│   └── README.md
├── logo-overlay/
│   ├── wehttamsnaps-logo-overlay.png      ← 1080×1080 transparent master
│   ├── wehttamsnaps-logo-cam-bug.png       ← 400×400 cam-bug for the Live scene
│   └── README.md
├── scene-collection/
│   ├── wehttamsnaps.json                  ← import via Scene Collection → Import
│   └── README.md
├── lower-thirds/
│   ├── now-playing.png                   ← static final frame (transparent)
│   │   now-playing/frame_0000..0059.png   ← 60-frame RGBA sequence (animated)
│   ├── follow.png
│   │   follow/frame_0000..0059.png
│   ├── now-playing.html                   ← HTML/CSS versions (browser-sourceable)
│   ├── follow.html
│   ├── theme.css
│   └── README.md
├── streamelements/
│   ├── index.html                         ← full themed overlay package
│   ├── chat-box.html                      ← standalone chat box
│   ├── dock.html                          ← combined chat + stream-info dock
│   ├── theme.css                          ← purple→cyan theme
│   ├── overlay.js                         ← alert/chat logic
│   └── README.md
├── scripts/
│   ├── scene-switcher.sh                  ← obs-websocket scene switcher + terminal banners
│   ├── install-deps.sh                    ← one-shot Arch dependency installer
│   └── README.md
└── README.md                              ← start here
```

## References

- ArchWiki — Hardware video acceleration (VA-API driver names, encode/decode support tables, `LIBVA_DRIVER_NAME=radeonsi`): https://wiki.archlinux.org/title/Hardware_video_acceleration
- ArchWiki — Open Broadcaster Software (VA-API in OBS, PipeWire capture): https://wiki.archlinux.org/title/Open_Broadcaster_Software
- OBS Forum — PipeWire Audio Capture resource: https://obsproject.com/forum/resources/pipewire-audio-capture.1458/
- werman/noise-suppression-for-voice (RNNoise LADSPA plugin used in section 5): https://github.com/werman/noise-suppression-for-voice
- NoiseTorch (GUI RNNoise virtual mic): https://github.com/noisetorch/noisetorch
- qpwgraph (PipeWire patchbay): https://gitlab.freedesktop.org/rncbc/qpwgraph
- StreamElements overlay dashboard: https://streamelements.com
- StreamLabs cloud widgets: https://streamlabs.com
- FFmpeg libvpx-vp9 alpha encoding (yuva420p, auto-alt-ref): https://trac.ffmpeg.org/wiki/Encode/VP9
- obs-websocket (the protocol the scene-switcher script uses): https://github.com/obsproject/obs-websocket
