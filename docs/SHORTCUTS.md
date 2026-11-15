# ⌨️ WehttamSnaps-Umbriel Cheat Sheet & Shortcuts

## 1. `dotfile-git-sync` & `fzf` Controls
Run `dotfile-git-sync` from any terminal and press **Enter** to default to `~/Documents/GitHub/WehttamSnaps-Umbriel`.

| Key | Action |
| :--- | :--- |
| **`Up` / `Down`** (or `Ctrl+P` / `Ctrl+N`) | Move up and down through `~/.config` folders |
| **Type any text** | Fuzzy-filter folder names in real time |
| **`Tab`** | Select or deselect the highlighted folder (multi-select) |
| **`Shift + Tab`** | Select/deselect and move up |
| **`Ctrl + A`** | Select all visible folders (use carefully!) |
| **`Enter`** | Move selected folders to repo, Stow symlinks back, commit & push |
| **`Esc`** or **`Ctrl + C`** | Cancel and exit safely without making changes |

> **Tip:** Avoid selecting runtime/cache directories like `go`, `mozilla`, `pulse`, `service`, `session`, or `libaccounts-glib`.

---

## 2. Umbriel & iNiR Shell Keybinds

| Shortcut | Action |
| :--- | :--- |
| **`Mod + Return`** | Launch Ghostty Terminal |
| **`Mod + E`** | Open File Manager (Yazi / Dolphin) |
| **`Mod + Q`** | Close Focused Window |
| **`Mod + Space`** | Toggle iNiR Overview |
| **`Mod + Comma`** | Open iNiR Settings GUI |
| **`Mod + Shift + W`** | Cycle iNiR Shell Style (Waffle / iRiS / Material ii) |
| **`Mod + V`** | Open Clipboard History (`cliphist`) |
| **`Print`** | Region / Fullscreen / Window Screenshot |
| **`Mod + Alt + G`** | Game Launcher Scratchpad |
| **`Alt + Shift + P`** | Spotify Scratchpad |
| **`Mod + Alt + S`** | Launch Steam (iDroid voice feedback) |
| **`Mod + Shift + G`** | Toggle Gaming Mode (disables heavy shader/blur effects) |
| **`Mod + Shift + R`** | Hot-Reload Umbriel Configuration |

---

## 3. Quick Compositor, Shell & Git Commands

| Task | Command |
| :--- | :--- |
| **Validate Umbriel config** | `umbriel config validate` |
| **Hot-reload Umbriel** | `umbriel msg config-reload` |
| **Restart iNiR / Quickshell** | `qs kill -c ii && qs -c ii` |
| **Check Quickshell logs** | `qs log -c ii` |
| **Update community shaders** | `git -C ~/.config/umbriel/shaders/community pull --ff-only` |
| **Sync iNiR + Umbriel** | `inir update && inir compositor sync` |
| **Render WS logo in terminal** | `chafa --size=40x20 ~/.config/fastfetch/WS-logo.png` |
| **Generate ASCII banner** | `figlet -f slant "WehttamSnaps"` |
