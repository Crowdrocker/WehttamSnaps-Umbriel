#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# WehttamSnaps-Umbriel Automated Deployment Script (Fedora 45+)
# Hardware Target: AMD Ryzen 5 9600X + Radeon RX 7600
# ==============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
FEDORA_VER="$(rpm -E %fedora)"

echo "🪐 Starting WehttamSnaps-Umbriel deployment on Fedora $FEDORA_VER..."

# ── 1. Optimize DNF 5 Speed & Parallel Downloads ───────────────────────────────
echo "⚡ Configuring DNF 5 parallel downloads..."
sudo dnf install -y dnf5-plugins
sudo dnf config-manager setopt max_parallel_downloads=10 fastestmirror=True || true

# ── 2. Enable RPM Fusion (Free & Nonfree) + Flathub ──────────────────────────
echo "📦 Enabling RPM Fusion repositories and Flathub..."
sudo dnf install -y \
    "https://rpmfusion.org{FEDORA_VER}.noarch.rpm" \
    "https://rpmfusion.org{FEDORA_VER}.noarch.rpm"

sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 || true
flatpak remote-add --if-not-exists flathub https://flathub.org

# ── 3. Enable Terra Repo (Umbriel) & Copr Repos (Ghostty, Yazi, Starship) ────
echo "🛰️  Adding Terra and Copr repositories..."
sudo dnf install -y --nogpgcheck \
    --repofrompath "terra,https://fyralabs.com{FEDORA_VER}" \
    terra-release

sudo dnf copr enable -y scottames/ghostty
sudo dnf copr enable -y lihaohong/yazi
sudo dnf copr enable -y atim/starship

# ── 4. Full System Update & Core Packages ────────────────────────────────────
echo "⬆️  Updating system and installing compositor, shell, creative & gaming apps..."
sudo dnf upgrade --refresh -y

sudo dnf install -y --skip-unavailable \
    stow git gcc-c++ make cmake jq ripgrep fd-find \
    umbriel-nightly \
    ghostty yazi nano starship fastfetch btop bat eza fzf zoxide zsh \
    wl-clipboard cliphist grim slurp polkit-gnome \
    pipewire pipewire-pulseaudio pipewire-jack-audio-connection-kit wireplumber \
    pavucontrol qpwgraph helvum easyeffects lsp-plugins-lv2 calf rnnoise \
    steam gamescope mangohud gamemode vkBasalt \
    mesa-vulkan-drivers mesa-vulkan-drivers.i686 vulkan-tools \
    rocm-opencl rocminfo \
    darktable rawtherapee gimp inkscape krita exiftool imagemagick kdenlive \
    ntfs-3g smartmontools kde-connect libnotify \
    fira-code-fonts jetbrains-mono-fonts google-noto-color-emoji-fonts

# Add user to render and video groups for GPU compute/acceleration
sudo usermod -aG render,video "$USER"

# ── 5. Full Multimedia Codecs & AMD Hardware Video Acceleration ──────────────
echo "🎬 Installing full FFmpeg and AMD Mesa freeworld hardware codecs..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf group upgrade -y multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin || true
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld || true
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld || true

# ── 6. Optional CachyOS Kernel & Schedulers on Fedora ────────────────────────
read -rp "🚀 Install CachyOS BORE kernel & scx-scheds via Copr? [y/N]: " INSTALL_CACHY
if [[ "${INSTALL_CACHY,,}" == "y" ]]; then
    echo "🔧 Enabling bieszczaders/kernel-cachyos Copr repositories..."
    sudo dnf copr enable -y bieszczaders/kernel-cachyos
    sudo dnf copr enable -y bieszczaders/kernel-cachyos-addons
    sudo dnf install -y kernel-cachyos kernel-cachyos-devel-matched cachyos-settings scx-scheds
    sudo setsebool -P domain_kernel_load_modules on
    sudo dracut -f
fi

# ── 7. Flatpak Applications ──────────────────────────────────────────────────
echo "📥 Installing Flatpak apps (OBS Studio, Discord, ProtonPlus, Flatseal)..."
flatpak install -y flathub \
    com.obsproject.Studio \
    com.discordapp.Discord \
    com.vysp3r.ProtonPlus \
    com.github.tchx84.Flatseal
flatpak --user override --filesystem="$HOME/.icons:ro"

# ── 8. Global AMD RADV & Smart Access Memory Environment Fixes ───────────────
echo "🎮 Applying global AMD RADV & Smart Access Memory variables..."
mkdir -p "$HOME/.config/environment.d"
cat << 'EOF' > "$HOME/.config/environment.d/99-game-fixes.conf"
# Mitigate driver leaks over long play sessions
RADV_PERFTEST=sam,aco
VK_EXT_graphics_pipeline_library=1
# Prevent shader cache eviction stutters
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
EOF

# ── 9. Back Up Existing Configs & Link via GNU Stow ──────────────────────────
echo "🔗 Backing up existing configs to $BACKUP_DIR and linking via GNU Stow..."
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

if [[ -f "$HOME/.zsh/.zshrc" && ! -e "$HOME/.zshrc" ]]; then
    ln -sf "$HOME/.zsh/.zshrc" "$HOME/.zshrc"
fi

# ── 10. Clone iNiR Shell & Validate Umbriel Config ───────────────────────────
if [[ ! -d "$HOME/.config/quickshell/inir" && ! -d "$HOME/inir" ]]; then
    echo "🧩 Cloning iNiR desktop shell to ~/inir..."
    git clone https://github.com "$HOME/inir"
fi

find "$HOME/.config/umbriel" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

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
echo "🎉 Fedora $FEDORA_VER deployment complete! Backup saved at: $BACKUP_DIR"
echo "➡️  Next steps:"
echo "   1. Run 'cd ~/inir && ./setup install' (select Umbriel)"
echo "   2. Run 'inir compositor add umbriel && inir compositor sync'"
echo "   3. Reboot and select Umbriel from your login screen!"
