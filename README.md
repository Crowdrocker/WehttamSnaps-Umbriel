# 🪐 WehttamSnaps-Umbriel

Modular, GPU-accelerated Wayland desktop dotfiles for **CachyOS**, built around the **Umbriel** scrolling compositor, **iNiR / Noctalia** shell, **Ghostty**, and **GNU Stow**.

---

## 📸 Desktop & Terminal Preview

![Ghostty Terminal, Fastfetch & Cyberpunk MOTD](assets/terminal-motd.png)

* **Terminal Stack:** Ghostty + Zsh + Fastfetch + custom Cyberpunk MOTD
* **Dynamic Colors:** Live ANSI palette generation synced with desktop wallpapers

---

## 🖥️ Hardware & System Stack

* **OS:** CachyOS Linux (Low-Latency Kernel)
* **Compositor:** Umbriel + iNiR / Noctalia Shell
* **Hardware:** AMD Ryzen 5 9600X | Radeon RX 7600 | 16GB DDR5

---

## 🚀 Quick Deployment (GNU Stow)

Clone and install via script or GNU Stow:

```bash
git clone https://github.com ~/Documents/GitHub/WehttamSnaps-Umbriel
cd ~/Documents/GitHub/WehttamSnaps-Umbriel && chmod +x install.sh && ./install.sh
stow -v umbriel mangohud bash zsh
```

---

## 📚 Documentation & Guides

* [🚀 Steam Launch Options & In-Game Graphics Profiles](docs/steam-launch-options.md)
* [📊 MangoHUD Telemetry & Hotkeys](docs/mangohud.md)
* [🛠️ Hardware, Ethernet & Compositor Troubleshooting Log](docs/troubleshooting.md)
* [🔊 Adaptive Sound System (J.A.R.V.I.S. & iDroid)](docs/sound-system.md)

---

## 📜 License

Released under the [MIT License](LICENSE).
