# 🔊 Adaptive Sound System (J.A.R.V.I.S. & iDroid)

Documentation for `/usr/local/bin/sound-system`, a context-aware PipeWire audio feedback script built for **Umbriel** that automatically switches between **J.A.R.V.I.S.** (Paul Bettany voice) and **iDroid** (Metal Gear Solid voice) based on your active workspace or gaming state.

---

## 📁 Directory Layout & Multi-Take Randomization

All audio clips are stored in `/usr/share/wehttamsnaps/sounds/` under two voice folders:

```text
/usr/share/wehttamsnaps/sounds/
├── jarvis/
│   ├── jarvis-startup.mp3
│   ├── morning.mp3 / afternoon.mp3 / evening.mp3
│   ├── reloading-config.mp3
│   ├── jarvis-screen-capture.mp3
│   └── alt/                  # Archived backup takes
└── idroid/
    ├── gamemode-on.mp3
    ├── gamemode-off.mp3
    ├── steam-launch.mp3
    └── alt/
```

### Multi-Take Support
* Naming alternate takes with `-` or `_` suffixes in the top-level directory (for example, `greeting.mp3`, `greeting-2.mp3`, `greeting_v2.mp3`) causes `sound-system` to pick a random take on every trigger via `shuf`.
* Keep unused or experimental takes in the `alt/` subfolder so they are excluded from random rotation.

---

## 🧠 Automatic Voice Mode Switching

`sound-system` queries `umbriel workspaces` (and checks `~/.cache/wehttamsnaps/gaming-mode.active`) to choose the active voice profile automatically:

| Context / Workspace | Active Voice | Trigger Behavior |
| :--- | :--- | :--- |
| `Browser`, `Term`, `Photo`, `Media`, `Comm`, `Music`, `Files`, `Misc` | **J.A.R.V.I.S.** | Standard desktop and productivity feedback |
| `Gaming` (3) or `Stream` (6) | **iDroid** | Tactical combat/broadcast voice feedback |
| `gaming-mode.active` flag enabled (`Mod+Shift+G`) | **iDroid** | Overrides all workspaces until toggled off |

*(If a requested clip does not exist in the active voice folder, the script automatically falls back to the other voice folder).*

---

## 💻 CLI Command Reference

### System & Compositor Events

| Command | Sound Clip Played | Notes |
| :--- | :--- | :--- |
| `sound-system startup` | `jarvis-startup` + `morning`/`afternoon`/`evening` | Chains boot intro with time-of-day greeting |
| `sound-system shutdown` | `jarvis-shutdown` | Session exit feedback |
| `sound-system config-reload` | `reloading-config` | Triggered on `Mod+Shift+R` / `Ctrl+Mod+R` |
| `sound-system screenshot` | `jarvis-screen-capture` | Triggered by `umbriel-screenshot.sh` |
| `sound-system locking-screen` | `locking-screen` | Triggered before `inir lock activate` |
| `sound-system steam-launch` | `steam-launch` | Switches mode to `idroid` and launches Steam |
| `sound-system streaming` | `jarvis-streaming` | Switches mode to `idroid` for broadcast |
| `sound-system photo-mode` | `photo-mode` | Switches mode to `jarvis` for editing |
| `sound-system photo-export` | `photo-export` | Export completion confirmation |

### Window & Workspace Actions

| Command | Sound Clip Played |
| :--- | :--- |
| `sound-system window-close` | `closing-window` |
| `sound-system window-float` | `window-float` |
| `sound-system window-fullscreen` | `window-fullscreen` |
| `sound-system window-tile` | `window-tile` |
| `sound-system window-center` | `window-center` |
| `sound-system workspace <name>` | `workspace-switch` (also updates voice mode) |
| `sound-system workspace-next` | `workspace-next` |
| `sound-system workspace-previous` | `workspace-previous` |

### Gaming Mode & Diagnostics

| Command | Action |
| :--- | :--- |
| `sound-system gamemode-on` | Enables `gaming-mode.active`, locks `idroid` voice, plays `gamemode-on` |
| `sound-system gamemode-off` | Removes flag, restores `jarvis` voice, plays `gamemode-off` |
| `sound-system gaming-toggle` | Toggles gaming mode on/off (`Mod+Shift+G`) |
| `sound-system status` | Displays saved mode, auto-detected mode, workspace, and gaming flag |
| `sound-system list` | Lists all active `.mp3` clips in `jarvis/` and `idroid/` |
| `sound-system mode <jarvis\|idroid>` | Manually forces a voice mode |
| `sound-system play <name> [mode]` | Plays a specific clip on demand |

---

## 🔗 Installation & Symlink Check

If `sound-system` stops responding after a fresh install or Stow deploy, restore its permissions and `/usr/bin` symlink:

```bash
sudo chmod +x /usr/local/bin/sound-system
sudo ln -sf /usr/local/bin/sound-system /usr/bin/sound-system
sound-system status
```
