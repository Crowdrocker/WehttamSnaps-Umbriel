# 🪐 WehttamSnaps-Umbriel

Modular, GPU-accelerated Wayland desktop dotfiles for **CachyOS**, built around the **Umbriel** scrolling compositor, **Noctalia** shell, **Ghostty**, and **GNU Stow**.

---

## 🖥️ Hardware & System Stack

* **OS:** CachyOS Linux (BORE Low-Latency Scheduler Kernel)
* **Compositor:** [Umbriel](https://github.com) + [Noctalia Shell](https://github.com)
* **CPU:** AMD Ryzen 5 9600X (6-Core / 12-Thread, Zen 5)
* **GPU:** XFX Speedster SWFT210 Radeon RX 7600 (8GB VRAM, RADV + Smart Access Memory)
* **Motherboard:** ASUS TUF Gaming B650E-PLUS WiFi
* **RAM & Storage:** 16GB DDR5-6000MHz | Dual 1TB NVMe SSDs
* **Terminal & File Manager:** Ghostty + Zsh/Bash + Yazi (`nano`-first workflow)

---

## ✨ Visual & Shader Features

* **Dynamic Borders:** Community `spectrum` GLSL border shader with Catppuccin/Cyberpunk neon cyan (`#89dceb`) and green (`#a6e3a1`) accents.
* **Window Animations:** `tv-glitch` open/close shaders paired with custom `appleSpring` physics curves.
* **Glassmorphism:** Optimized background blur and live wallpaper reflections across Noctalia panels, docks, and OSDs.
* **Telemetry:** Custom vertical **MangoHUD** profile tuned for 1080p high-FPS gaming (*The Division 2*, *Horizon Forbidden West*, *Cyberpunk 2077*, *Fallout 4*).

---

## ⌨️ Core Keybind Highlights (`Super` = `Mod`)

### 🪟 Window & Workspace Management

| Keybind | Action |
| :--- | :--- |
| `Mod + Return` | Launch Ghostty Terminal (with J.A.R.V.I.S. audio trigger) |
| `Mod + E` | Open Yazi File Manager |
| `Mod + Q` | Close Active Window |
| `Mod + F` / `Mod + Shift + F` | Toggle Maximize / Maximize to Edges |
| `Mod + V` | Toggle Floating Window |
| `Mod + R` / `Mod + D` | Cycle Primary / Secondary Column Widths |
| `Mod + 1..0` | Switch Named Workspaces (`Browser`, `Term`, `Gaming`, `Photo`, `Media`, `Stream`, `Comm`, `Music`, `Files`, `Misc`) |
| `Ctrl + Tab` / `Mod + O` | Toggle Workspace Overview |
| `Ctrl + Mod + R` | Hot-Reload Umbriel Configuration |

### 🎮 Scratchpads, Gaming & Streaming

| Keybind | Action |
| :--- | :--- |
| `Mod + Space` | Toggle Dropdown Terminal Scratchpad |
| `Mod + Alt + G` | Toggle **Game Launcher TUI** Scratchpad |
| `Alt + Shift + P` | Toggle **Spotify** Scratchpad |
| `Mod + Alt + S` | Launch Steam (with J.A.R.V.I.S. audio hook) |
| `Mod + Shift + O` | Launch OBS Studio (with `background_render = true`) |
| `Mod + Ctrl + Y / S / D` | Launch Isolated Webapps (YouTube, Spotify, Discord) |

### 📸 Screenshots & Media

| Keybind | Action |
| :--- | :--- |
| `Print` | Interactive Region Screenshot |
| `Shift + Print` | Fullscreen Monitor Screenshot |
| `Ctrl + Print` | Active Window Screenshot |
| `Mod + Shift + S` | Open Screenshot Submap (`R` Region, `F` Fullscreen, `W` Widgets) |

---

## 🚀 Quick Deployment (GNU Stow)

Clone the repository and symlink all configuration modules into `$HOME`:

```bash
git clone https://github.com ~/Documents/GitHub/WehttamSnaps-Umbriel
cd ~/Documents/GitHub/WehttamSnaps-Umbriel
stow -v umbriel mangohud bash zsh
```

Validate the compositor configuration after linking:

```bash
umbriel config validate
```

---

## 📜 License

Released under the [MIT License](LICENSE).

 
