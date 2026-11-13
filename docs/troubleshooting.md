# 🛠️ Hardware & Linux Troubleshooting Log

Solutions to hardware, driver, and compositor issues solved on this **CachyOS + AM5 + Umbriel** build.

---

## 🌐 Realtek RTL8125 2.5GbE Ethernet Drops / Missing Interface

* **Symptom:** Ethernet intermittently disconnects while Wi-Fi stays stable, or the Ethernet interface disappears after blacklisting `r8169`.
* **Cause:** The generic `r8169` kernel driver negotiates aggressive PCIe power-saving states with the Realtek RTL8125 controller on the ASUS TUF Gaming B650E-PLUS WiFi motherboard.
* **Fix:**
  1. Install matching kernel headers and the dedicated `r8125-dkms` driver:
     ```bash
     sudo pacman -S --needed linux-cachyos-headers r8125-dkms
     ```
  2. Blacklist `r8169` and disable NetworkManager power-saving:
     ```bash
     echo "blacklist r8169" | sudo tee /etc/modprobe.d/blacklist-r8169.conf
     sudo bash -c 'cat << EOF > /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
     [connection]
     ethernet.wake-on-lan=magic
     wifi.powersave=2
     EOF'
     ```
  3. Rebuild initramfs, load `r8125`, and restart NetworkManager:
     ```bash
     sudo mkinitcpio -P
     sudo modprobe r8125
     sudo systemctl restart NetworkManager
     ```
  4. Verify with `lspci -k | grep -A 3 -i ethernet` that **`Kernel driver in use: r8125`** is active.

---

## 🖥️ Dual GPU Detection (RX 7600 + Radeon 610M)

* **Symptom:** `fastfetch` lists both `AMD Radeon RX 7600` and `Radeon 610M`.
* **Explanation:** The Ryzen 5 9600X includes a built-in RDNA2 iGPU (`Radeon 610M`) alongside the discrete RX 7600. Vulkan/RADV and Umbriel automatically prioritize the discrete RX 7600 (`/dev/dri/renderD128`) for gaming and desktop rendering.

---

## 🌫️ Umbriel Scratchpad Screen Stays Blurry After Exiting TUI App

* **Symptom:** Exiting `game-launcher` inside a named scratchpad leaves the full-screen backdrop dim/blur active.
* **Fix:** Disable full-screen backdrop blur/dim on scratchpads in `umbriel/.config/umbriel/config.d/90-user-extra.toml` while keeping per-window blur enabled:
  ```toml
  [animation.scratchpad]
  enabled = true
  blur = false
  dim = 0.0
  ```

---

## 🔊 `sound-system` Not Found or Not Executable After Stow

* **Fix:** Restore executable permissions and refresh the `/usr/bin/sound-system` symlink:
  ```bash
  sudo chmod +x /usr/local/bin/sound-system
  sudo ln -sf /usr/local/bin/sound-system /usr/bin/sound-system
  ```

---

## 🎨 Zsh Startup Prints `File: .../sequences.txt`

* **Cause:** `cat` is aliased to `bat`, which prints a file header banner when loading iNiR's terminal color escape sequences.
* **Fix:** Call `/usr/bin/cat` directly in `~/.zshrc`:
  ```zsh
  if [ -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt ]; then
    /usr/bin/cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
  fi
  ```
