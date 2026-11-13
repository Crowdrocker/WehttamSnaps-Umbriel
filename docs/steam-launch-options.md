# 🚀 Steam Launch Options & In-Game Settings

Optimized launch strings and graphics settings tuned for **CachyOS**, **Umbriel**, **AMD Ryzen 5 9600X**, and **Radeon RX 7600 (8GB VRAM)** at **1080p**.

---

## 🎮 Steam Launch Options

### Tom Clancy's The Division 2 & Online Ubisoft Titles
Wraps the game in an isolated 1080p Gamescope container to prevent compositor focus drops and long-session memory leaks:
```bash
mangohud gamescope -f -W 1920 -H 1080 -r 60 -- %command%
```
* **Benchmark Tip:** Enable **DirectX 12 Renderer**, save video settings, restart the game, and run the benchmark directly from the **Character Selection** screen (not inside the live world).

### Horizon Forbidden West
Uses Gamescope isolation while keeping textures safely within the 8GB VRAM pool:
```bash
mangohud gamescope -f -W 1920 -H 1080 -r 60 -- %command%
```
* **Recommended 1080p Graphics Settings:**
  * **Texture Quality:** High (avoids 8GB VRAM overflow stutters on Very High)
  * **Texture Filtering:** 16x Anisotropic
  * **Crowd Quality:** High (leverages Ryzen 5 9600X single-core performance)
  * **Ambient Occlusion & Screen Space Shadows:** On / High
  * **Upscaling:** AMD FSR 3 (Quality or Native AA)

### Cyberpunk 2077
Prioritizes CPU thread scheduling with GameMode and optimizes VKD3D host-visible VRAM uploads:
```bash
mangohud gamemoderun VKD3D_CONFIG=no_upload_hvv %command%
```
* **Recommended 1080p Graphics Settings:** Crowd Density High, Textures High, Screen Space Reflections High (avoid Psycho), Ray Tracing Off, FSR Quality.

### Fallout 4 (Modded / Tactical Load Order)
Enables Smart Access Memory (`sam`) and GameMode for heavy custom asset streaming:
```bash
mangohud gamemoderun RADV_PERFTEST=sam %command%
```
* **Critical AMD INI Fixes (`Fallout4Prefs.ini`):**
  * Set `bNVFlexEnable=0`, `bNVFlexDrawDebris=0`, and `bNVFlexInstanceDebris=0` under `[NVFlex]` (Nvidia Weapon Debris causes instant crashes on AMD GPUs).
  * Set `iVolumetricLightingQuality=1` (Low/Medium Godrays saves 30+ FPS on RDNA3).
  * Set `iPresentInterval=0` and pair with the **High FPS Physics Fix** mod (`UntieSpeedFromFPS=true`).

---

## 📊 Verified 1080p Benchmark Results (CachyOS + Umbriel)

Tested on **AMD Ryzen 5 9600X** + **Radeon RX 7600** at **1920x1080 High Settings**:

| Game | Average FPS | Min FPS | Max FPS | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Tom Clancy's The Division 2** | **215 FPS** | — | — | DirectX 12 + Gamescope (`1920x1080`) |
| **Horizon Forbidden West** | **132 FPS** | — | — | High Textures + 16x AF + FSR 3 Quality |
| **Cyberpunk 2077 (v2.5)** | **113.35 FPS** | **93.30 FPS** | **139.30 FPS** | Custom High + FSR 2.1 Quality + RT Off |
