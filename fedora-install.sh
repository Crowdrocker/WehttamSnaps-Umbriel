#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# WehttamSnaps-Umbriel Automated Deployment Script (Fedora 45+)
# Hardware Target: AMD Ryzen 5 9600X + Radeon RX 7600
# ==============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
FEDORA_VER="$(rpm -E %fedora)"

echo "🪐 Starting WehttamSnaps-Umbriel deployment on Fedora $FEDORA_VER..."

# ── 1. Enable RPM Fusion (Free & Nonfree) + Flathub ──────────────────────────
echo "📦 Enabling RPM Fusion repositories and Flathub..."
sudo dnf install -y \
    "https://rpmfusion.org{FEDORA_VER}.noarch.rpm" \
    "https://rpmfusion.org{FEDORA_VER}.noarch.rpm"

sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 || true
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ── 2. Enable Terra Repo (Umbriel) & Copr Repos (Ghostty, Yazi, Starship) ────
echo "🛰️  Adding Terra and Copr repositories..."
sudo dnf install -y --nogpgcheck \
    --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_VER}" \
    terra-release

sudo dnf copr enable -y scottames/ghostty
sudo dnf copr enable -y lihaohong/yazi
sudo dnf copr enable -y atim/starship

# ── 3. Full System Update & Core Packages ────────────────────────────────────
echo "⬆️  Updating system and installing core compositor, shell & gaming tools..."
sudo dnf upgrade --refresh -y

sudo dnf install -y \
    stow git gcc-c++ make \
    umbriel-nightly \
    ghostty yazi nano starship fastfetch btop bat eza fzf zoxide zsh \
    wl-clipboard cliphist grim slurp \
    pipewire pipewire-pulseaudio pipewire-jack-audio-connection-kit wireplumber \
    pavucontrol qpwgraph \
    steam gamescope mangohud gamemode \
    mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
    kde-connect libnotify

# ── 4. Full Multimedia Codecs & AMD Hardware Video Acceleration ──────────────
echo "🎬 Installing full FFmpeg and AMD Mesa freeworld hardware codecs..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld || true
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld || true

# ── 5. Flatpak Applications (OBS Studio & Discord) ───────────────────────────
echo "📥 Installing Flatpak apps..."
flatpak install -y flathub com.obsproject.Studio com.discordapp.Discord
flatpak --user override --filesystem="$HOME/.icons:ro"

# ── 6. Global AMD RADV & Smart Access Memory Environment Fixes ───────────────
echo "🎮 Applying global AMD RADV & Smart Access Memory variables..."
mkdir -p "$HOME/.config/environment.d"
cat << 'EOF' > "$HOME/.config/environment.d/99-game-fixes.conf"
# Mitigate driver leaks over long play sessions
RADV_PERFTEST=sam,aco
VK_EXT_graphics_pipeline_library=1
# Prevent shader cache eviction stutters
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
EOF

# ── 7. Back Up Existing Configs & Link via GNU Stow ──────────────────────────
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

# ── 8. Install iNiR Shell (Optional Automated Clone) ─────────────────────────
if [[ ! -d "$HOME/.config/quickshell/inir" ]]; then
    echo "🧩 Cloning iNiR desktop shell to ~/inir..."
    git clone https://github.com "$HOME/inir"
    echo "➡️  Run 'cd ~/inir && ./setup install' and select Umbriel to finish shell setup."
fi

# ── 9. Restore Script Permissions & Validate Config ──────────────────────────
find "$HOME/.config/umbriel" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

if command -v umbriel &>/dev/null; then
    echo "✅ Validating Umbriel configuration..."
    umbriel config validate
fi

echo ""
echo "🎉 Fedora $FEDORA_VER deployment complete! Backup saved at: $BACKUP_DIR"
echo "➡️  Next steps:"
echo "   1. Run 'cd ~/inir && ./setup install' (choose Umbriel)"
echo "   2. Run 'inir compositor add umbriel && inir compositor sync'"
echo "   3. Reboot and select Umbriel from your login manager!"
