#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# WehttamSnaps-Umbriel Automated Deployment Script (openSUSE Tumbleweed + Noctalia)
# Hardware Target: AMD Ryzen 5 9600X + Radeon RX 7600
# ==============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "🦎 Starting WehttamSnaps-Umbriel + Noctalia deployment on openSUSE Tumbleweed..."

# ── 1. Create Pre-Deployment Snapper Snapshot ─────────────────────────────────
if command -v snapper &>/dev/null; then
    echo "📸 Creating pre-deployment Snapper Btrfs snapshot..."
    sudo snapper create --description "Before WehttamSnaps-Umbriel deployment" || true
fi

# ── 2. Add OBS Repository (Umbriel), Packman & Flathub ───────────────────────
echo "🛰️  Adding home:neifua:Noctalia OBS repo, Packman Essentials, and Flathub..."
sudo zypper addrepo --refresh --priority 90 \
    "https://opensuse.org" || true

sudo zypper addrepo --refresh --priority 90 \
    "https://gwdg.de" packman-essentials || true

sudo zypper --gpg-auto-import-keys refresh

flatpak remote-add --if-not-exists flathub https://flathub.org

# ── 3. Upgrade System & Install Packages from pkglists/opensuse.txt ──────────
echo "⬆️  Syncing Tumbleweed snapshot and installing packages from pkglists/opensuse.txt..."
sudo zypper dup -y --allow-vendor-change
sudo zypper install -y -t pattern devel_basis

if [[ -f "$REPO_DIR/pkglists/opensuse.txt" ]]; then
    mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$REPO_DIR/pkglists/opensuse.txt")
    sudo zypper install -y --no-recommends --ignore-unknown "${PKGS[@]}"
else
    echo "⚠️  pkglists/opensuse.txt not found; installing minimal Umbriel + Noctalia core..."
    sudo zypper install -y umbriel noctalia ghostty yazi starship fastfetch btop bat eza fzf zoxide zsh stow git
fi

sudo usermod -aG render,video "$USER"

# ── 4. Switch Multimedia Codecs to Packman ───────────────────────────────────
echo "🎬 Installing full FFmpeg and Mesa codecs from Packman..."
sudo zypper dup -y --from packman-essentials --allow-vendor-change || true

# ── 5. Install Flatpak Applications from pkglists/flatpak.txt ────────────────
if [[ -f "$REPO_DIR/pkglists/flatpak.txt" ]]; then
    echo "📥 Installing Flatpak apps from pkglists/flatpak.txt..."
    mapfile -t FLATPAKS < <(grep -vE '^\s*(#|$)' "$REPO_DIR/pkglists/flatpak.txt")
    flatpak install -y flathub "${FLATPAKS[@]}"
    flatpak --user override --filesystem="$HOME/.icons:ro"
fi

# ── 6. Global AMD RADV & Smart Access Memory Environment Fixes ───────────────
mkdir -p "$HOME/.config/environment.d"
cat << 'EOF' > "$HOME/.config/environment.d/99-game-fixes.conf"
RADV_PERFTEST=sam,aco
VK_EXT_graphics_pipeline_library=1
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
EOF

# ── 7. Back Up Existing Configs & Link via GNU Stow ──────────────────────────
echo "🔗 Backing up existing configs to $BACKUP_DIR and linking via GNU Stow..."
mkdir -p "$BACKUP_DIR" "$HOME/.config"

TARGETS=(
    "$HOME/.config/umbriel"
    "$HOME/.config/MangoHud"
    "$HOME/.config/snapsos"
    "$HOME/.bashrc"
    "$HOME/.bash"
    "$HOME/.zsh"
    "$HOME/.zshrc"
)

for target in "${TARGETS[@]}"; do
    if [[ -e "$target" && ! -L "$target" ]]; then
        mv "$target" "$BACKUP_DIR/"
    elif [[ -L "$target" ]]; then
        rm -f "$target"
    fi
done

cd "$REPO_DIR"
stow -v umbriel mangohud bash zsh snapsos

if [[ -f "$HOME/.zsh/.zshrc" && ! -e "$HOME/.zshrc" ]]; then
    ln -sf "$HOME/.zsh/.zshrc" "$HOME/.zshrc"
fi

# Activate Noctalia v5 shell config template for Tumbleweed
if [[ -f "$REPO_DIR/templates/95-shell-noctalia.toml" ]]; then
    cp "$REPO_DIR/templates/95-shell-noctalia.toml" "$HOME/.config/umbriel/config.d/95-shell-noctalia.toml"
fi

find "$HOME/.config/umbriel" "$HOME/.config/snapsos" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

# ── 8. Optional Persistent /etc/fstab Drive Setup ───────────────────────────
read -rp "💾 Configure /etc/fstab auto-mounts for your 5 data drives? [y/N]: " SETUP_FSTAB
if [[ "${SETUP_FSTAB,,}" == "y" ]]; then
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
        grep -q "$uuid" /etc/fstab || echo "$entry" | sudo tee -a /etc/fstab >/dev/null
    done
    sudo systemctl daemon-reload
    sudo mount -a
fi

if [[ ! -d "$HOME/.config/umbriel/shaders/community" ]]; then
    echo "✨ Cloning community Umbriel shaders..."
    mkdir -p "$HOME/.config/umbriel/shaders"
    git clone https://github.com/noctalia-dev/community-umbriel-shaders.git \
        "$HOME/.config/umbriel/shaders/community"
fi

if command -v umbriel &>/dev/null; then
    echo "✅ Validating merged Umbriel + Noctalia configuration..."
    umbriel config validate
fi

echo ""
echo "🎉 openSUSE Tumbleweed + Umbriel + Noctalia deployment complete!"
