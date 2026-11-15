#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# WehttamSnaps-Umbriel Automated Deployment Script (openSUSE Tumbleweed)
# Hardware Target: AMD Ryzen 5 9600X + Radeon RX 7600
# ==============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "🪐 Starting WehttamSnaps-Umbriel deployment on openSUSE Tumbleweed..."

# ── 1. System Snapshot Update (zypper dup) ───────────────────────────────────
echo "⬆️  Updating Tumbleweed snapshot via zypper dup..."
sudo zypper --non-interactive refresh
sudo zypper --non-interactive dup --allow-vendor-change

# ── 2. Add Noctalia OBS Repo (Umbriel) & Flathub ─────────────────────────────
echo "🛰️  Adding Noctalia OBS repository and Flathub..."
sudo zypper --non-interactive addrepo --refresh --force --name "Noctalia" \
    https://download.opensuse.org/repositories/home:neifua:Noctalia/openSUSE_Tumbleweed/home:neifua:Noctalia.repo
sudo zypper --gpg-auto-import-keys refresh

flatpak remote-add --if-not-exists flathub https://flathub.org

# ── 3. Install Core Compositor, Shell, Gaming, Audio & Creative Packages ─────
echo "📦 Installing core Tumbleweed packages..."
sudo zypper --non-interactive install --no-recommends --ignore-unknown \
    stow git gcc-c++ make cmake jq ripgrep fd curl unzip opi \
    umbriel-git xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    ghostty yazi nano starship fastfetch btop bat eza fzf zoxide zsh \
    zsh-autosuggestions zsh-syntax-highlighting \
    wl-clipboard cliphist grim slurp swaybg swayidle swaylock \
    brightnessctl playerctl wlr-randr wlsunset ydotool \
    polkit-kde-agent-6 qt6ct qt5ct kvantum-manager papirus-icon-theme breeze6-icons \
    pipewire pipewire-alsa pipewire-pulseaudio pipewire-jack wireplumber \
    pavucontrol qpwgraph helvum easyeffects lsp-plugins calf \
    steam gamescope mangohud goverlay gamemode \
    Mesa-vulkan-device-select libvulkan_radeon libvulkan_radeon-32bit vulkan-tools \
    darktable rawtherapee gimp inkscape krita exiftool ImageMagick kdenlive \
    ntfs-3g smartmontools deskflow libnotify-tools \
    tesseract-ocr tesseract-ocr-traineddata-english \
    fira-code-fonts jetbrains-mono-fonts google-noto-coloremoji-fonts

# Add user to render and video groups for AMD GPU compute/acceleration
sudo usermod -aG render,video "$USER"

# ── 4. Optional Community OBS Packages via OPI (Quickshell, Matugen, Codecs) ──
echo "🧩 Installing community OBS packages (quickshell, matugen, awww) via opi..."
for pkg in quickshell matugen awww xwayland-satellite; do
    if ! command -v "$pkg" &>/dev/null; then
        opi -n "$pkg" || echo "⚠️  Skipped $pkg (install manually or via cargo if unavailable)"
    fi
done

read -rp "🎬 Install Packman multimedia codecs & AMD hardware video acceleration via opi? [y/N]: " INSTALL_CODECS
if [[ "${INSTALL_CODECS,,}" == "y" ]]; then
    opi -n codecs
fi

read -rp "🌐 Install Realtek RTL8125 2.5GbE driver (r8125-kmp-default) for bare-metal AM5? [y/N]: " INSTALL_R8125
if [[ "${INSTALL_R8125,,}" == "y" ]]; then
    opi -n r8125-kmp-default || true
fi

# ── 5. Install Material Symbols Variable Fonts for iNiR Bar ──────────────────
echo "🔤 Installing Material Symbols Rounded & Outlined fonts..."
mkdir -p "$HOME/.local/share/fonts"
curl -fsSL "https://github.com" \
    -o "$HOME/.local/share/fonts/MaterialSymbolsRounded.ttf"
curl -fsSL "https://github.com" \
    -o "$HOME/.local/share/fonts/MaterialSymbolsOutlined.ttf"
fc-cache -fv

# ── 6. Flatpak Applications (OBS + Teleport, Discord, ProtonPlus, Flatseal) ──
echo "📥 Installing Flatpak apps..."
flatpak install -y flathub \
    com.obsproject.Studio \
    com.obsproject.Studio.Plugin.Teleport \
    com.discordapp.Discord \
    com.vysp3r.ProtonPlus \
    com.github.tchx84.Flatseal
flatpak --user override --filesystem="$HOME/.icons:ro"

# ── 7. Global AMD RADV, Qt Theme & Smart Access Memory Fixes ─────────────────
echo "🎮 Applying global AMD RADV & Qt environment variables..."
mkdir -p "$HOME/.config/environment.d"
cat << 'EOF' > "$HOME/.config/environment.d/99-game-fixes.conf"
RADV_PERFTEST=sam,aco
VK_EXT_graphics_pipeline_library=1
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
QT_QPA_PLATFORMTHEME=qt6ct
EOF

# ── 8. Back Up Existing Configs & Link via GNU Stow ──────────────────────────
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

# ── 9. Clone iNiR Shell & Validate Umbriel Config ───────────────────────────
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

if [[ ! -d "$HOME/.config/umbriel/shaders/community" ]]; then
    echo "✨ Cloning community Umbriel shaders..."
    mkdir -p "$HOME/.config/umbriel/shaders"
    git clone https://github.com/noctalia-dev/community-umbriel-shaders.git \
        "$HOME/.config/umbriel/shaders/community"
fi

echo ""
echo "🎉 openSUSE Tumbleweed deployment complete! Backup saved at: $BACKUP_DIR"
echo "➡️  Next steps:"
echo "   1. Run 'cd ~/inir && ./setup install' (select Umbriel)"
echo "   2. Run 'inir compositor add umbriel && inir compositor sync'"
echo "   3. Reboot and select Umbriel at the SDDM login screen!"
