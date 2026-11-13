# 🧩 iNiR Desktop Shell Setup & Maintenance

Guide for installing, updating, and syncing the **iNiR** Quickshell desktop environment (`inir.space`) with the **Umbriel** Wayland compositor on **CachyOS**.

---

## 📦 Fresh Installation

Clone the upstream repository and run the setup wizard (select **Umbriel** when prompted):

```bash
git clone https://github.com ~/inir
cd ~/inir
./setup install
```

* **Runtime Path:** `~/.config/quickshell/inir`
* **Systemd Service:** Ensure the user service is active so iNiR restarts automatically if interrupted:
  ```bash
  inir service enable
  ```

---

## 🔄 Updating iNiR & Syncing Umbriel

Run these commands whenever a new iNiR release drops:

```bash
# 1. Pull the latest iNiR release, CLI, and Hub families (Material ii, iRiS, Waffle)
inir update

# 2. Regenerate managed Umbriel compositor configs (10-input.toml through 80-misc.toml)
inir compositor sync

# 3. Validate merged TOML configuration
umbriel config validate

# 4. Hot-reload Umbriel live
umbriel msg config-reload
```

### Checking Installed Version & Hub Plugins
```bash
inir version
inir compositor status
```

---

## 🛡️ Override Architecture (`90-user-extra.toml`)

`inir compositor sync` manages and overwrites files **`10-input.toml`** through **`80-misc.toml`** inside `~/.config/umbriel/config.d/`.

* **Never edit `10`–`80` directly.**
* Put all custom settings, shaders, monitor positions, scratchpads, environment variables, and keybind overrides inside **`~/.config/umbriel/config.d/90-user-extra.toml`**.
* `90-user-extra.toml` is created once, loads last, and is never overwritten by `inir update` or `inir compositor sync`.

---

## ⌨️ Core iNiR Shell Hotkeys (`Super` = `Mod`)

| Keybind | Action |
| :--- | :--- |
| `Mod + Comma` | Open **iNiR Settings** (includes native Umbriel layout, glass & workspace controls) |
| `Mod + Space` | Toggle Overview / Launcher |
| `Mod + V` | Toggle Clipboard History |
| `Mod + X` | Toggle Session / Power Menu |
| `Mod + Slash` | Toggle Keybind Cheatsheet |
| `Alt + Space` | Toggle Quick Overlay |
| `Mod + Alt + L` | Lock Screen (`inir lock activate`) |

---

## 🔗 Upstream Links

* **Official Website & Changelog:** [inir.space](https://inir.space)
* **Source Repository:** [://github.com](https://://github.com)
