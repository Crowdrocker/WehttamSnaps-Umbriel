# wehttamsnaps — Scene Switcher (obs-websocket)

`scene-switcher.sh` switches OBS scenes over **obs-websocket** and prints a
coloured **terminal banner** (the section-4 separator + scene name) to Konsole
so you see the switch land — no X11 global key grab, fully Wayland-native.

## Why this exists

On Wayland, OBS built-in hotkeys can be unreliable because they depend on an
X11 global key grab that MangoWM (wlroots) doesn't always honour. The robust
fix is to **bind the switch in MangoWM** and have that bind spawn this script,
which talks to OBS over the websocket on `127.0.0.1:4455`. That's the clean
Wayland story: no X dependency, and the banner confirms the switch.

## Prerequisites

1. **obs-websocket plugin** — install the plugin (on CachyOS: `yay -S
   obs-websocket` or it ships with `obs-studio` ≥ 28). In OBS: **Tools →
   obs-websocket Server Settings** → enable, port `4455`, leave password blank
   for localhost (or set one and configure it below).
2. **curl + jq + python3** — all already on CachyOS. The script uses a tiny
   inline python websocket client so you don't need `websocat`/`wscat`.

## Install

```bash
mkdir -p ~/.config/wehttamsnaps/scripts
cp scene-switcher.sh ~/.config/wehttamsnaps/scripts/
chmod +x ~/.config/wehttamsnaps/scripts/scene-switcher.sh
```

Optional config file `~/.config/wehttamsnaps/scene-switcher.conf`:

```sh
OBS_WS_HOST="127.0.0.1"
OBS_WS_PORT="4455"
OBS_WS_PASS=""     # leave blank if OBS auth is off on localhost
```

## Commands

| Command | OBS scene |
|---------|-----------|
| `starting` | `00 │ Starting Soon` |
| `streamstart` | `00 │ Stream Starting` |
| `live` | `10 ─ Live` |
| `justchatting` | `10 ─ Just Chatting` |
| `brb` | `20 ┊ BRB` |
| `techpause` | `20 ┊ Tech Pause` |
| `ending` | `30 ✦ Ending` |
| `offline` | `30 ✦ Offline` |
| `overlaytest` | `40 ◆ Overlay Test` |
| `config` | `50 ⚙ Config / Never Air` |
| `toggle-record` / `rec` | start/stop recording |
| `toggle-stream` / `stream` | start/stop streaming |
| `status` | print current scene + record/stream state |
| `list` | list all scenes OBS knows about |

## Bind in MangoWM `input.conf`

```ini
# Scene switching via obs-websocket (Wayland-native, no X grab)
bind=SUPER+F1,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh starting
bind=SUPER+F2,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh live
bind=SUPER+F3,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh justchatting
bind=SUPER+F4,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh brb
bind=SUPER+F5,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh ending
bind=SUPER+F6,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh offline
bind=SUPER+SHIFT+R,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh toggle-record
bind=SUPER+SHIFT+S,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh toggle-stream
bind=SUPER+SHIFT+T,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh status
```

After editing, reload MangoWM (e.g. `SUPER+SHIFT+R` if that's your reload bind,
or `killall -SIGHUP mangowm`). Now `SUPER+F2` switches to Live and prints:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ─ Live
  switched ✓   (10 ─ Live)   18:32:46
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

(coloured purple bar / magenta symbol / cyan scene name / dim status, in Konsole)

## Run from Konsole directly

```bash
~/.config/wehttamsnaps/scripts/scene-switcher.sh live
~/.config/wehttamsnaps/scripts/scene-switcher.sh status
~/.config/wehttamsnaps/scripts/scene-switcher.sh list
```

## Troubleshooting

- **"could not reach obs-websocket"** → OBS isn't running or the plugin server
  is off. Check Tools → obs-websocket Server Settings, port 4455.
- **"OBS rejected the scene switch"** → no scene with that exact name exists.
  Run `scene-switcher.sh list` to see the names OBS actually has, then edit the
  `SCENES` table in the script (or rename your scenes in OBS to match the
  convention in the guide).
- **Password auth** → this shell version assumes no password on loopback. If
  you set a password, either disable auth on `127.0.0.1`, or use the python
  client instead: `pip install obs-websocket-py` and replace `ws_call`.
