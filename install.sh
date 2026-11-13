#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# WehttamSnaps-Umbriel Automated Deployment Script (CachyOS / Arch)
# Hardware Target: AMD Ryzen 5 9600X + Radeon RX 7600
# ==============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "🪐 Starting WehttamSnaps-Umbriel deployment from $REPO_DIR..."

# ── 1. System Update & Core Packages ─────────────────────────────────────────
echo "📦 Installing core compositor, shell, and utility packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
    stow git base-devel \
    ghostty yazi nano starship fastfetch btop bat eza fzf zoxide zsh \
    wl-clipboard cliphist polkit-gnome \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    pavucontrol qpwgraph \
    steam gamescope mangohud lib32-mangohud gamemode lib32-gamemode \
    mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
    libva-mesa-driver lib32-libva-mesa-driver

# ── 2. AUR Packages (paru / yay) ─────────────────────────────────────────────
AUR_HELPER=""
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
fi

if [[ -n "$AUR_HELPER" ]]; then
    echo "🎨 Installing AUR packages using $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm \
        umbriel-git noctalia-shell-git \
        spotify-launcher protonup-qt steamtinkerlaunch-git \
        bibata-cursor-theme-bin
else
    echo "⚠️ No AUR helper (paru/yay) found. Install umbriel-git and noctalia-shell-git manually."
fi

# ── 3. Flatpak Applications ──────────────────────────────────────────────────
if command -v flatpak &>/dev/null; then
    echo "📥 Installing Flatpak apps (OBS Studio & Discord)..."
    flatpak install -y flathub com.obsproject.Studio com.discordapp.Discord
    flatpak --user override --filesystem="$HOME/.icons:ro"
fi

# ── 4. Systemd Global AMD RADV & Gaming Environment Fixes ────────────────────
echo "🎮 Applying global AMD RADV & Smart Access Memory variables..."
mkdir -p "$HOME/.config/environment.d"
cat << 'EOF' > "$HOME/.config/environment.d/99-game-fixes.conf"
# Mitigate driver leaks over long play sessions
RADV_PERFTEST=sam,aco
VK_EXT_graphics_pipeline_library=1
# Prevent shader cache eviction stutters
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
EOF

# ── 5. Back Up Existing Configs & Link via GNU Stow ──────────────────────────
echo "🔗 Backing up conflicting configs to $BACKUP_DIR and linking via GNU Stow..."
mkdir -p "$BACKUP_DIR" "$HOME/.config"

TARGETS=(
    "$HOME/.config/umbriel"
    "$HOME/.config/MangoHud"
    "$HOME/.bashrc"
    "$HOME/.bash"
    "$HOME/.zsh"
    "$HOME/.zshrc"
)

for target in "${TARGETS[@]}"; do
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "   -> Moving existing $target to backup..."
        mv "$target" "$BACKUP_DIR/"
    elif [[ -L "$target" ]]; then
        rm -f "$target"
    fi
done

cd "$REPO_DIR"
stow -v umbriel mangohud bash zsh

# Ensure ~/.zshrc resolves properly if stored inside zsh/.zsh/.zshrc
if [[ -f "$HOME/.zsh/.zshrc" && ! -e "$HOME/.zshrc" ]]; then
    ln -sf "$HOME/.zsh/.zshrc" "$HOME/.zshrc"
fi

# ── 6. Restore Script Executable Permissions ─────────────────────────────────
echo "⚡ Ensuring custom scripts are executable..."
find "$HOME/.config/umbriel" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

# ── 7. Validate Umbriel Configuration ────────────────────────────────────────
if command -v umbriel &>/dev/null; then
    echo "✅ Validating Umbriel configuration..."
    umbriel config validate
fi

# ── Optional Persistent /etc/fstab Drive Setup ───────────────────────────────
read -rp "💾 Configure /etc/fstab auto-mounts for your 5 data drives? [y/N]: " SETUP_FSTAB
if [[ "${SETUP_FSTAB,,}" == "y" ]]; then
    echo "📁 Creating mount directories under /mnt/..."
    sudo mkdir -p /mnt/{LINUXDRIVE,EXTRA1TB,GAMEDRIVE,WettamSnapsMain,512GB}

    FSTAB_ENTRIES=(
        "UUID=2be94340-fe0c-464c-9afc-fde6ddc300cc  /mnt/LINUXDRIVE      ext4    defaults,noatime,nofail  0 2"
        "UUID=d3283959-c9d3-494a-b832-72f961ea7a92  /mnt/EXTRA1TB        ext4    defaults,noatime,nofail  0 2"
        "UUID=3f996c97-b699-4208-b9fc-1a64bc65b478  /mnt/GAMEDRIVE       ext4    defaults,noatime,nofail  0 2"
        "UUID=2C66D88566D850E6                      /mnt/WettamSnapsMain ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=111,nofail  0 0"
        "UUID=47780A83503AF675                      /mnt/512GB           ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=111,nofail  0 0"
    )

    for entry in "${FSTAB_ENTRIES[@]}"; do
        uuid="${entry%% *}"
        if ! grep -q "$uuid" /etc/fstab; then
            echo "$entry" | sudo tee -a /etc/fstab >/dev/null
            echo "   -> Added $uuid"
        else
            echo "   -> Skipped $uuid (already in /etc/fstab)"
        fi
    done

    sudo systemctl daemon-reload
    sudo mount -a
    echo "✅ Drives mounted and verified."
fi

echo ""
echo "🎉 Deployment complete! Backup saved at: $BACKUP_DIR"
echo "➡️  Reboot or log into Umbriel to start your session."
