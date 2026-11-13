# ⚖️ Fedora 45 vs. CachyOS Migration Checklist

A summarized decision matrix and pre-migration guide for transitioning between the rolling-release **CachyOS** and the point-release **Fedora 45** while preserving the **Umbriel + iNiR + Ghostty** environment.

---

## 🔍 1. Decision Matrix Summary

* **CachyOS:** Offers higher maintenance with rolling updates (`pacman -Syu`), peak 1% low gaming frame rates via custom schedulers (`znver5`), and out-of-the-box gaming/codec packages.
* **Fedora 45:** Provides a lower-maintenance 6-month release cycle, reliable `dnf` rollbacks, near-identical gaming performance (100+ FPS on Linux 7.2 / Mesa RADV), and native support for Umbriel via Terra or Copr repositories.

---

## 💾 2. Essential Pre-Migration Backup Items

Before wiping and reinstalling, back up your local system files and configurations that live outside your tracked dotfiles:

- [ ] **Custom Audio & Binaries:** `/usr/share/wehttamsnaps/sounds/` and `/usr/local/bin/sound-system`.
- [ ] **State & Tips:** `~/.config/snapsos/tips/tips.list` and uncommitted git changes in `~/Documents/GitHub/WehttamSnaps-Umbriel`.
- [ ] **Gaming & Apps:** Local Wine prefixes, mod folders, and OBS Studio configurations (`~/.var/app/com.obsproject.Studio/config/obs-studio/`).
- [ ] **Credentials:** `~/.ssh/` and `~/.gnupg/` keys for GitHub access.

---

## 🚀 3. Post-Install Recovery Steps

1. **Clone Dotfiles:** Re-clone your repository to `~/Documents/GitHub/WehttamSnaps-Umbriel`.
2. **Execute Setup:** Run `./fedora-install.sh` to configure RPM Fusion, media codecs, and repository hooks.
3. **Sync iNiR & Umbriel:** Re-run `inir` setup and compositor synchronization.
4. **Restore Assets:** Copy back your backed-up sound packs and custom system binaries, validate via `umbriel config validate`, and reboot.
