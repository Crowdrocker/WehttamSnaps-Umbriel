# 🖥️ Dual-PC Streaming & GitHub CLI Setup

## 1. GitHub CLI Authentication (`gh`)
Authenticate once over HTTPS so `git push` and `dotfile-git-sync` never prompt for a username or token:

```bash
sudo pacman -S --needed github-cli
gh auth login
```
* Select **GitHub.com** → **HTTPS** → **Yes** (authenticate Git with GitHub credentials) → **Login with a web browser**.
* Copy the 8-character one-time code (`XXXX-XXXX`) printed in your terminal and paste it at `://github.com`.

---

## 2. Dual-PC Hardware Wiring (Zero-Lag Passthrough)
Links the **AM5 Linux Gaming PC** (`Ryzen 5 9600X` / `RX 7600`) to the **AM4 Windows 11 Streaming PC** (`SnapsPc`) without running OBS or network streaming on the gaming rig.

### UGREEN USB 3.0 Switch Selector (Keyboard & Mouse)
1. Plug your **keyboard**, **mouse**, and shared USB devices into the 4 front ports on the switch.
2. Connect the two rear USB-A cables to the **AM5 Linux PC** (Port 1) and **AM4 Windows 11 PC** (Port 2).
3. *(Tip)* Plug 2.4 GHz wireless mouse/headset dongles into a short USB 2.0 extension cable rather than directly into USB 3.0 ports to prevent radio interference.

### Guermok USB 3.0 HDMI Capture Card (Video & Audio)
1. **AM5 RX 7600 HDMI Out** → **Capture Card `HDMI IN`**
2. **Capture Card `HDMI OUT`** → **Primary Gaming Monitor** (1080p60 zero-lag passthrough)
3. **Capture Card `USB 3.0`** → **Blue USB 3.0 Port on Windows 11 PC**
4. **Linux Audio Split:** Use `qpwgraph` or `pavucontrol` on the AM5 PC to duplicate game audio to both your headphones and the RX 7600 HDMI audio output.
5. **Windows OBS Setup:** Add a **Video Capture Device** (`USB Video`) set to `1920x1080` @ `60 FPS`, and layer your webcam, alerts, and overlays above it.
