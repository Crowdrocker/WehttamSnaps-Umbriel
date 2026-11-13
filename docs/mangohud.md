# 📊 MangoHUD Telemetry & Controls

Configuration and hotkey reference for the custom vertical **MangoHUD** overlay (`mangohud/.config/MangoHud/MangoHud.conf`).

---

## 📦 Installation (CachyOS)

Install both 64-bit and 32-bit multilib libraries so native Vulkan and Proton/Wine games display the overlay:

```bash
sudo pacman -S --needed mangohud lib32-mangohud
```

---

## ⌨️ Hotkeys & Aliases

| Trigger | Action |
| :--- | :--- |
| `Right Shift + F12` | Toggle MangoHUD visibility on/off in-game |
| `Left Shift + F4` | Reload `MangoHud.conf` live without restarting the game |
| `Mod + Alt + M` | Send `USR1` toggle signal from Umbriel |
| `Mod + Alt + F12` | Cycle MangoHUD layout presets (`USR2`) |
| `hud-full` | Switch shell profile to full vertical Cyberpunk specs |
| `hud-fps` | Switch shell profile to compact minimal FPS counter |

---

## ⚙️ Key Config Parameters

* **GPU Label & Clocks:** `gpu_text=RX 7600`, `gpu_temp`, `gpu_core_clock`, `gpu_vram`
* **CPU Label & Clocks:** `cpu_text=9600X`, `cpu_temp`, `cpu_mhz`
* **Frame Pacing:** `fps`, `frame_times`, `frame_timing=1`
