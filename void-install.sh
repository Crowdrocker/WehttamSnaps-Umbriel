REPO_DIR="$HOME/Documents/GitHub/WehttamSnaps-Umbriel"

cat << 'EOF' > "$REPO_DIR/void-install.sh"
#!/usr/bin/env bash
# ==============================================================================
#   ██╗    ██╗   ╭───╮   ███████╗   │  WehttamSnaps (Matthew / Crowdrocker)
#   ██║    ██║  ╭╯ ╱╲ ╰╮ ██╔════╝   │  Photography · Gaming · Content Creation
#   ██║ █╗ ██║  │ ◀ ○ ▶│ ███████╗   │  GitHub : ://github.com
#   ██║███╗██║  ╰╮ ╲╱ ╭╯ ╚════██║   │  Twitch : twitch.tv/WehttamSnaps
#   ╚███╔███╔╝   ╰───╯   ███████║   │  Target : Void Linux (glibc + runit)
#    ╚══╝╚══╝       ━    ╚══════╝   │
# ==============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BUILD_DIR="/tmp/wehttamsnaps-void-build"

echo "🪐 Starting WehttamSnaps-Umbriel deployment on Void Linux..."

# ── 1. Enable Nonfree & Multilib Repositories ────────────────────────────────
echo "📦 Enabling Void nonfree and multilib repositories..."
sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sudo xbps-install -Syu

# ── 2. Install Core Toolchain, Wayland, Audio, Gaming & Creative Apps ────────
echo "🛠️  Installing core Void packages via xbps..."
sudo xbps-install -Sy \
    git stow curl wget jq ripgrep fd fzf zoxide bat eza btop fastfetch nano \
    gcc pkg-config meson ninja cmake just python3-devel portaudio-devel cargo rust \
    wayland-devel wayland-protocols libxkbcommon-devel libinput-devel seatd-devel \
    pixman-devel libxcb-devel libdrm-devel MesaLib-devel vulkan-loader-devel glslang \
    qt6-base-devel qt6-declarative-devel qt6-wayland-devel qt6-shadertools-devel qt6-svg-devel \
    pipewire wireplumber alsa-pipewire libjack-pipewire pavucontrol qpwgraph easyeffects \
    mesa-dri mesa-vulkan-radeon mesa-vulkan-radeon-32bit vulkan-loader vulkan-loader-32bit vulkan-tools \
    dbus elogind seatd polkit polkit-kde-agent qt6ct kvantum \
    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    wl-clipboard cliphist grim slurp swaybg swayidle swaylock \
    brightnessctl playerctl wlr-randr wlsunset ydotool libnotify \
    ghostty yazi zsh fish-shell starship zsh-autosuggestions zsh-syntax-highlighting \
    papirus-icon-theme breeze-icons font-fira-ttf noto-fonts-emoji \
    dolphin kate ark gwenview darktable gimp krita inkscape exiftool ImageMagick kdenlive \
    steam lutris gamemode MangoHud goverlay flatpak ntfs-3g smartmontools deskflow

sudo usermod -aG _seatd,video,render,audio "$USER"

# ── 3. Enable Runit Services (dbus, seatd, NetworkManager, Ollama) ───────────
echo "⚙️  Configuring runit services..."
for svc in dbus seatd NetworkManager; do
    if [[ -d "/etc/sv/$svc" && ! -e "/var/service/$svc" ]]; then
        sudo ln -s "/etc/sv/$svc" /var/service/
        echo "   -> Enabled runit service: $svc"
    fi
done

sudo mkdir -p /etc/pipewire/pipewire.conf.d /etc/alsa/conf.d
sudo ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/ || true
sudo ln -sf /usr/share/examples/wireplumber/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/ || true
sudo ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/ || true
sudo ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/ || true

if ! command -v ollama &>/dev/null; then
    echo "🧠 Installing Ollama..."
    curl -fsSL https://ollama.com | sh
fi

if [[ ! -d /etc/sv/ollama ]]; then
    sudo mkdir -p /etc/sv/ollama
    printf '#!/bin/sh\nexec ollama serve 2>&1\n' | sudo tee /etc/sv/ollama/run >/dev/null
    sudo chmod +x /etc/sv/ollama/run
    sudo ln -s /etc/sv/ollama /var/service/
    echo "   -> Created & enabled runit service: ollama"
fi

# ── 4. Build Umbriel & Quickshell from Source into /usr/local ────────────────
mkdir -p "$BUILD_DIR"

if ! command -v umbriel &>/dev/null; then
    echo "🏗️  Building Umbriel from source..."
    git clone --depth 1 https://github.com "$BUILD_DIR/umbriel"
    cd "$BUILD_DIR/umbriel"
    just configure release /usr/local
    just release
    sudo meson install -C build-release --no-rebuild
fi

if ! command -v qs &>/dev/null; then
    echo "🏗️  Building Quickshell from source..."
    git clone --depth 1 https://outfoxxed.me "$BUILD_DIR/quickshell"
    cmake -B "$BUILD_DIR/quickshell/build" -S "$BUILD_DIR/quickshell" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
    cmake --build "$BUILD_DIR/quickshell/build"
    sudo cmake --install "$BUILD_DIR/quickshell/build"
fi

echo "🦀 Installing matugen and xwayland-satellite via Cargo..."
cargo install --locked matugen xwayland-satellite || true
rm -rf "$BUILD_DIR"

# ── 5. Install Material Symbols Fonts & Flathub Apps ─────────────────────────
echo "🔤 Installing Material Symbols variable fonts..."
mkdir -p "$HOME/.local/share/fonts"
curl -fsSL "https://github.com" \
    -o "$HOME/.local/share/fonts/MaterialSymbolsRounded.ttf"
curl -fsSL "https://github.com" \
    -o "$HOME/.local/share/fonts/MaterialSymbolsOutlined.ttf"
fc-cache -fv

flatpak remote-add --if-not-exists flathub https://flathub.org
flatpak install -y flathub com.obsproject.Studio com.discordapp.Discord com.github.tchx84.Flatseal || true

# ── 6. Back Up Existing Configs & Link via GNU Stow ──────────────────────────
echo "🔗 Linking dotfiles via GNU Stow..."
mkdir -p "$BACKUP_DIR" "$HOME/.config"

TARGETS=(
    "$HOME/.config/umbriel"
    "$HOME/.config/MangoHud"
    "$HOME/.config/pipewire"
    "$HOME/.config/fastfetch"
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
stow -v umbriel mangohud pipewire fastfetch bash zsh
[[ -f "$HOME/.zsh/.zshrc" && ! -e "$HOME/.zshrc" ]] && ln -sf "$HOME/.zsh/.zshrc" "$HOME/.zshrc"

# ── 7. Clone iNiR, Community Shaders & Setup J.A.R.V.I.S. Voice Control ──────
if [[ ! -d "$HOME/inir" ]]; then
    git clone https://github.com "$HOME/inir"
fi

if [[ ! -d "$HOME/.config/umbriel/shaders/community" ]]; then
    mkdir -p "$HOME/.config/umbriel/shaders"
    git clone https://github.com \
        "$HOME/.config/umbriel/shaders/community"
fi

if [[ -x "$REPO_DIR/jarvis-voice/setup-jarvis.sh" ]]; then
    "$REPO_DIR/jarvis-voice/setup-jarvis.sh"
fi

# ── 8. Create Void Wayland Session Wrapper (Starts D-Bus + PipeWire) ─────────
mkdir -p "$HOME/.local/bin"
cat << 'INNER_EOF' > "$HOME/.local/bin/start-umbriel-void"
#!/usr/bin/env bash
export XDG_CURRENT_DESKTOP=umbriel
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

exec dbus-run-session -- sh -c '
    pipewire &
    pipewire-pulse &
    wireplumber &
    sleep 0.5
    exec umbriel
'
INNER_EOF
chmod +x "$HOME/.local/bin/start-umbriel-void"

echo ""
echo "🎉 Void Linux deployment complete!"
echo "➡️  To launch Umbriel from a TTY (or display manager), run: start-umbriel-void"
EOF

chmod +x "$REPO_DIR/void-install.sh"
cd "$REPO_DIR"
git add void-install.sh
git commit -m "feat(void): add Void Linux (glibc + runit) deployment script"
git push
