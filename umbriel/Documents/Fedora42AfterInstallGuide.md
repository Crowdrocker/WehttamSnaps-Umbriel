# !/bin/bash
# dnf install
sudo dnf install dnf5 dnf-pluginsy
sudo dnf update


###### Tweak the Update Process ########
sudo dnf copr enable solopasha/hyprland

sudo nano /etc/dnf/dnf.conf
## Copy and paste the following line into dnf.conf.
[main]
gpgcheck=1 
installonly_limit=3 
clean_requirements_on_remove=True 
best=False 
skip_if_unavailable=True 
max_parallel_downloads=10 
fastestmirror=True

[copr:copr.fedorainfracloud.org:solopasha:hyprland]
name=Copr repo for hyprland owned by solopasha
baseurl=https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/fedora-$releasever-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1


###### Update the System ########
sudo dnf -y upgrade --refresh

###### Update Firmware ########
sudo fwupdmgr get-devices 
sudo fwupdmgr refresh --force 
sudo fwupdmgr get-updates 
sudo fwupdmgr update


###### Enable RPM Fusion ########
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf upgrade --refresh
sudo dnf -y groupupdate core
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y rpmfusion-nonfree-release-tainted 
sudo dnf install -y dnf-plugins-core

sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf group upgrade core
sudo dnf4 group install core



###### Flatpak and Snap ########
sudo dnf install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update

sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap 
# for classic snap support

###### Multimedia ########
sudo dnf install -y libdvdcss 
sudo dnf groupupdate multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf groupupdate sound-and-video
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
sudo dnf group install Multimedia

###### H/W Video Acceleration ########
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264

sudo dnf install ffmpeg ffmpeg-libs libva libva-utils -y --allowerasing --skip-broken
###### Custom DNS Servers ########
## For people that want to setup custom DNS servers for better privacy
sudo mkdir -p '/etc/systemd/resolved.conf.d' && sudo -e '/etc/systemd/resolved.conf.d/99-dns-over-tls.conf'

[Resolve]
DNS=1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com 2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com
DNSOverTLS=yes

sudo grubby --update-kernel=ALL --args="mitigations=off"

###### Improved Fonts ########
sudo dnf install -y fira-code-fonts 'mozilla-fira*' 'google-roboto*'
sudo dnf install curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

## List all installed packages
rpm -qa --qf "%{NAME}\n" | sort > all-packages.txt

## List explicit-packages
dnf repoquery --userinstalled --qf "%{name}" | sort > explicit-packages.txt

###### Install Apps via Command Line ########

sudo dnf5 install -y --skip-unavailable --skip-broken NetworkManager
sudo dnf5 install -y --skip-unavailable --skip-broken NetworkManager-wifi
sudo dnf5 install -y --skip-unavailable --skip-broken bat
sudo dnf5 install -y --skip-unavailable --skip-broken btop
sudo dnf5 install -y --skip-unavailable --skip-broken bzip2
sudo dnf5 install -y --skip-unavailable --skip-broken cliphist
sudo dnf5 install -y --skip-unavailable --skip-broken cmake
sudo dnf5 install -y --skip-unavailable --skip-broken code
sudo dnf5 install -y --skip-unavailable --skip-broken curl
sudo dnf5 install -y --skip-unavailable --skip-broken darktable
sudo dnf5 install -y --skip-unavailable --skip-broken dunst
sudo dnf5 install -y --skip-unavailable --skip-broken exa
sudo dnf5 install -y --skip-unavailable --skip-broken exiftool
sudo dnf5 install -y --skip-unavailable --skip-broken fastfetch
sudo dnf5 install -y --skip-unavailable --skip-broken fd-find
sudo dnf5 install -y --skip-unavailable --skip-broken ffmpeg
sudo dnf5 install -y --skip-unavailable --skip-broken file-roller
sudo dnf5 install -y --skip-unavailable --skip-broken fira-code-fonts
sudo dnf5 install -y --skip-unavailable --skip-broken fuzzel
sudo dnf5 install -y --skip-unavailable --skip-broken gamemode
sudo dnf5 install -y --skip-unavailable --skip-broken gamescope
sudo dnf5 install -y --skip-unavailable --skip-broken gcc
sudo dnf5 install -y --skip-unavailable --skip-broken gimp
sudo dnf5 install -y --skip-unavailable --skip-broken git
sudo dnf5 install -y --skip-unavailable --skip-broken google-noto-color-emoji-fonts
sudo dnf5 install -y --skip-unavailable --skip-broken google-noto-fonts
sudo dnf5 install -y --skip-unavailable --skip-broken google-noto-sans-fonts
sudo dnf5 install -y --skip-unavailable --skip-broken google-noto-serif-fonts
sudo dnf5 install -y --skip-unavailable --skip-broken grim
sudo dnf5 install -y --skip-unavailable --skip-broken gzip
sudo dnf5 install -y --skip-unavailable --skip-broken htop
sudo dnf5 install -y --skip-unavailable --skip-broken hypridle
sudo dnf5 install -y --skip-unavailable --skip-broken hyprpaper
sudo dnf5 install -y --skip-unavailable --skip-broken hyprpicker
sudo dnf5 install -y --skip-unavailable --skip-broken imagemagick
sudo dnf5 install -y --skip-unavailable --skip-broken inkscape
sudo dnf5 install -y --skip-unavailable --skip-broken iwd
sudo dnf5 install -y --skip-unavailable --skip-broken jetbrains-mono-fonts
sudo dnf5 install -y --skip-unavailable --skip-broken kitty
sudo dnf5 install -y --skip-unavailable --skip-broken krita
sudo dnf5 install -y --skip-unavailable --skip-broken libva-mesa-driver
sudo dnf5 install -y --skip-unavailable --skip-broken lm_sensors
sudo dnf5 install -y --skip-unavailable --skip-broken lutris
sudo dnf5 install -y --skip-unavailable --skip-broken make
sudo dnf5 install -y --skip-unavailable --skip-broken mako
sudo dnf5 install -y --skip-unavailable --skip-broken mangohud
sudo dnf5 install -y --skip-unavailable --skip-broken mesa-dri-drivers
sudo dnf5 install -y --skip-unavailable --skip-broken mesa-libGL
sudo dnf5 install -y --skip-unavailable --skip-broken mesa-vdpau-drivers
sudo dnf5 install -y --skip-unavailable --skip-broken mesa-vulkan-drivers
sudo dnf5 install -y --skip-unavailable --skip-broken neofetch
sudo dnf5 install -y --skip-unavailable --skip-broken neovim
sudo dnf5 install -y --skip-unavailable --skip-broken nodejs
sudo dnf5 install -y --skip-unavailable --skip-broken npm
sudo dnf5 install -y --skip-unavailable --skip-broken obs-studio
sudo dnf5 install -y --skip-unavailable --skip-broken obs-studio-plugin-browser
sudo dnf5 install -y --skip-unavailable --skip-broken p7zip
sudo dnf5 install -y --skip-unavailable --skip-broken pamixer
sudo dnf5 install -y --skip-unavailable --skip-broken pavucontrol
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-alsa
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-jack-audio-connection-kit
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-pulse
sudo dnf5 install -y --skip-unavailable --skip-broken playerctl
sudo dnf5 install -y --skip-unavailable --skip-broken psensor
sudo dnf5 install -y --skip-unavailable --skip-broken python3
sudo dnf5 install -y --skip-unavailable --skip-broken python3-pip
sudo dnf5 install -y --skip-unavailable --skip-broken rawtherapee
sudo dnf5 install -y --skip-unavailable --skip-broken ripgrep
sudo dnf5 install -y --skip-unavailable --skip-broken rofi-wayland
sudo dnf5 install -y --skip-unavailable --skip-broken sddm
sudo dnf5 install -y --skip-unavailable --skip-broken sddm-themes
sudo dnf5 install -y --skip-unavailable --skip-broken slurp
sudo dnf5 install -y --skip-unavailable --skip-broken starship
sudo dnf5 install -y --skip-unavailable --skip-broken steam
sudo dnf5 install -y --skip-unavailable --skip-broken swww
sudo dnf5 install -y --skip-unavailable --skip-broken tar
sudo dnf5 install -y --skip-unavailable --skip-broken thunar
sudo dnf5 install -y --skip-unavailable --skip-broken thunar-archive-plugin
sudo dnf5 install -y --skip-unavailable --skip-broken thunar-media-tags-plugin
sudo dnf5 install -y --skip-unavailable --skip-broken thunar-volman
sudo dnf5 install -y --skip-unavailable --skip-broken unrar
sudo dnf5 install -y --skip-unavailable --skip-broken unzip
sudo dnf5 install -y --skip-unavailable --skip-broken v4l2loopback
sudo dnf5 install -y --skip-unavailable --skip-broken vim
sudo dnf5 install -y --skip-unavailable --skip-broken vulkan-tools
sudo dnf5 install -y --skip-unavailable --skip-broken waybar
sudo dnf5 install -y --skip-unavailable --skip-broken wget
sudo dnf5 install -y --skip-unavailable --skip-broken wl-clipboard
sudo dnf5 install -y --skip-unavailable --skip-broken wofi
sudo dnf5 install -y --skip-unavailable --skip-broken x264
sudo dnf5 install -y --skip-unavailable --skip-broken x265
sudo dnf5 install -y --skip-unavailable --skip-broken xdg-desktop-portal-gtk
sudo dnf5 install -y --skip-unavailable --skip-broken xdg-desktop-portal-hyprland
sudo dnf5 install -y --skip-unavailable --skip-broken xz
sudo dnf5 install -y --skip-unavailable --skip-broken zip
sudo dnf5 install -y --skip-unavailable --skip-broken zsh
sudo dnf5 install -y --skip-unavailable --skip-broken hyprland
sudo dnf5 install -y --skip-unavailable --skip-broken hyprlock
sudo dnf5 install -y --skip-unavailable --skip-broken unzip p7zip p7zip-plugins unrar
sudo dnf5 install -y --skip-unavailable --skip-broken steam
sudo dnf5 install -y --skip-unavailable --skip-broken gawk
sudo dnf5 install -y --skip-unavailable --skip-broken git
sudo dnf5 install -y --skip-unavailable --skip-broken unzip
sudo dnf5 install -y --skip-unavailable --skip-broken wget
sudo dnf5 install -y --skip-unavailable --skip-broken xdotool
sudo dnf5 install -y --skip-unavailable --skip-broken xprop
sudo dnf5 install -y --skip-unavailable --skip-broken xrandr
sudo dnf5 install -y --skip-unavailable --skip-broken vim-common
sudo dnf5 install -y --skip-unavailable --skip-broken xwininfo
sudo dnf5 install -y --skip-unavailable --skip-broken GameMode
sudo dnf5 install -y --skip-unavailable --skip-broken GameScope
sudo dnf5 install -y --skip-unavailable --skip-broken GDB
sudo dnf5 install -y --skip-unavailable --skip-broken ImageMagick
sudo dnf5 install -y --skip-unavailable --skip-broken jq
sudo dnf5 install -y --skip-unavailable --skip-broken libnotify
sudo dnf5 install -y --skip-unavailable --skip-broken MangoHud
sudo dnf5 install -y --skip-unavailable --skip-broken net-tools
sudo dnf5 install -y --skip-unavailable --skip-broken p7zip
sudo dnf5 install -y --skip-unavailable --skip-broken rsync
sudo dnf5 install -y --skip-unavailable --skip-broken scummvm
sudo dnf5 install -y --skip-unavailable --skip-broken scummvm-tools
sudo dnf5 install -y --skip-unavailable --skip-broken strace
sudo dnf5 install -y --skip-unavailable --skip-broken usbutils
sudo dnf5 install -y --skip-unavailable --skip-broken vkBasalt
sudo dnf5 install -y --skip-unavailable --skip-broken playonlinux
sudo dnf5 install -y --skip-unavailable --skip-broken winetricks
sudo dnf5 install -y --skip-unavailable --skip-broken q4wine
sudo dnf5 install -y --skip-unavailable --skip-broken wine-mono
sudo dnf5 install -y --skip-unavailable --skip-broken bottles
sudo dnf5 install -y --skip-unavailable --skip-broken xdg-utils
sudo dnf5 install -y --skip-unavailable --skip-broken yad
sudo dnf5 install -y --skip-unavailable --skip-broken protontricks
sudo dnf5 install -y --skip-unavailable --skip-broken kdenlive
sudo dnf5 install -y --skip-unavailable --skip-broken lutris
sudo dnf5 install -y --skip-unavailable --skip-broken qbittorrent
sudo dnf5 install -y --skip-unavailable --skip-broken kate
sudo dnf5 install -y --skip-unavailable --skip-broken meld
sudo dnf5 install -y --skip-unavailable --skip-broken mpv
sudo dnf5 install -y --skip-unavailable --skip-broken shotwell
sudo dnf5 install -y --skip-unavailable --skip-broken Carla
sudo dnf5 install -y --skip-unavailable --skip-broken ardour7
sudo dnf5 install -y --skip-unavailable --skip-broken jacktrip
sudo dnf5 install -y --skip-unavailable --skip-broken guitarix
sudo dnf5 install -y --skip-unavailable --skip-broken giada
sudo dnf5 install -y --skip-unavailable --skip-broken hydrogen
sudo dnf5 install -y --skip-unavailable --skip-broken qpwgraph
sudo dnf5 install -y --skip-unavailable --skip-broken qsynth
sudo dnf5 install -y --skip-unavailable --skip-broken qtractor
sudo dnf5 install -y --skip-unavailable --skip-broken muse
sudo dnf5 install -y --skip-unavailable --skip-broken fmit
sudo dnf5 install -y --skip-unavailable --skip-broken blender
sudo dnf5 install -y --skip-unavailable --skip-broken darktable
sudo dnf5 install -y --skip-unavailable --skip-broken hexchat
sudo dnf5 install -y --skip-unavailable --skip-broken inkscape
sudo dnf5 install -y --skip-unavailable --skip-broken --allowerasing --skip-broken dnf5dragora
sudo dnf5 install -y --skip-unavailable --skip-broken unrar
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire
sudo dnf5 install -y --skip-unavailable --skip-broken rnnoise
sudo dnf5 install -y --skip-unavailable --skip-broken calf
sudo dnf5 install -y --skip-unavailable --skip-broken lsp-plugins-lv2
sudo dnf5 install -y --skip-unavailable --skip-broken easyeffects
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-jack-audio-connection-kit
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-v4l2
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-alsa
sudo dnf5 install -y --skip-unavailable --skip-broken wireplumber
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-plugin-jack
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-utils
sudo dnf5 install -y --skip-unavailable --skip-broken pipewire-gstreamer
sudo dnf5 install -y --skip-unavailable --skip-broken helvum
sudo dnf5 install -y --skip-unavailable --skip-broken qjackctl
sudo dnf install zsh -y --skip-unavailable --skip-broken
sudo dnf5 install util-linux-user -y --skip-unavailable --skip-broken
sudo dnf5 install rclone -y --skip-unavailable --skip-broken
sudo dnf5 install openssl -y --skip-unavailable --skip-broken
sudo dnf5 install sqlite-devel tk-devel -y --skip-unavailable --skip-broken
sudo dnf5 install java -y --skip-unavailable --skip-broken
curl https://pyenv.run | bash
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf5 install -y --skip-unavailable --skip-broken  nodejs
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo dnf5 install yarn -y --skip-unavailable --skip-broken
sudo dnf5 install ruby-devel -y --skip-unavailable --skip-broken
gem install travis --no-document
gem install colorls
sudo dnf install rocm-opencl -y --skip-unavailable --skip-broken
sudo usermod -a -G render,video $wehttamsnaps
sudo dnf install rocminfo -y --skip-unavailable --skip-broken
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed 's/robbyrussell/powerlevel10k\/powerlevel10k/g' -i ~/.zshrc
sudo dnf install tmux-powerline vim-powerline powerline-fonts
wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
sudo mv -v PowerlineSymbols.otf /usr/share/fonts/
sudo mv -v MesloLGS*.ttf /usr/share/fonts/
sudo fc-cache -vf
sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/
sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && sudo chmod +x ./dotnet-install.sh && ./dotnet-install.sh --version latest && ./dotnet-install.sh --version latest --runtime aspnetcore && ./dotnet-install.sh --channel 7.0
flatpak install flathub com.github.tchx84.Flatseal --assumeyes  --or-update --system
flatpak install flathub com.brave.Browser --assumeyes  --or-update --system
flatpak install flathub net.davidotek.pupgui2 --assumeyes  --or-update --system
flatpak install flathub com.discordapp.Discord --assumeyes  --or-update --system
flatpak install flathub org.telegram.desktop --assumeyes  --or-update --system
flatpak install flathub com.obsproject.Studio --assumeyes  --or-update --system
flatpak install flathub com.spotify.Client --assumeyes  --or-update --system
flatpak install flathub org.videolan.VLC --assumeyes  --or-update --system
flatpak install flathub com.heroicgameslauncher.hgl --assumeyes  --or-update --system
flatpak install flathub io.github.celluloid_player.Celluloid --assumeyes  --or-update --system
flatpak install flathub com.github.gi-lom.dialect --assumeyes  --or-update --system
flatpak install flathub org.gnome.meld --assumeyes  --or-update --system
flatpak install flathub org.blender.Blender --assumeyes  --or-update --system
flatpak install flathub com.adobe.Flash-Player-projector --assumeyes  --or-update --system
flatpak install flathub org.dupot.easyflatpak --assumeyes  --or-update --system
flatpak install flathub com.vysp3r.ProtonPlus --assumeyes  --or-update --system
systemctl --user start pipewire-pulse.service pipewire-pulse.socket
sudo dnf5 upgrade --refresh
sudo dnf5 groupupdate core
sudo dnf5 update && sudo dnf5 upgrade


## VS Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' && \
sudo dnf check-update && \
sudo dnf install code -y

## sublime text
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg && \
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo && \
sudo dnf install sublime-text -y

###### Flatpaks installs ####
flatpak install flathub com.brave.Browser --assumeyes  --or-update --system
flatpak install flathub net.davidotek.pupgui2 --assumeyes  --or-update --system
flatpak install flathub com.discordapp.Discord --assumeyes  --or-update --system
flatpak install flathub org.telegram.desktop --assumeyes  --or-update --system
flatpak install flathub com.obsproject.Studio --assumeyes  --or-update --system
flatpak install flathub com.spotify.Client --assumeyes  --or-update --system
flatpak install flathub org.videolan.VLC --assumeyes  --or-update --system
flatpak install flathub com.heroicgameslauncher.hgl --assumeyes  --or-update --system
flatpak install flathub io.github.celluloid_player.Celluloid --assumeyes  --or-update --system
flatpak install flathub com.github.gi-lom.dialect --assumeyes  --or-update --system
flatpak install flathub org.gnome.meld --assumeyes  --or-update --system
flatpak install flathub org.blender.Blender --assumeyes  --or-update --system
flatpak install flathub com.adobe.Flash-Player-projector --assumeyes  --or-update --system
flatpak install flathub org.dupot.easyflatpak --assumeyes  --or-update --system
flatpak install flathub com.vysp3r.ProtonPlus --assumeyes  --or-update --system




###### Browsers ########
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser
sudo dnf install fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome
sudo dnf install -y google-chrome-stable




###### rocm-opencl ########
sudo dnf install rocm-opencl -y
sudo usermod -a -G render,video $wehttamsnaps
sudo dnf install rocminfo -y
rocminfo



###### Change the Desktop Environment ########
#### Available desktop environments can be found with this command:
dnf grouplist -v
#### The command will yield a list similar to this:

#### Fedora Custom Operating System (custom-environment)
Minimal Install (minimal-environment)
Fedora Server Edition (server-product-environment)
Fedora Workstation (workstation-product-environment)
Fedora Cloud Server (cloud-server-environment)
KDE Plasma Workspaces (kde-desktop)
Xfce Desktop (xfce-desktop)
LXDE Desktop (lxde-desktop)
LXQt Desktop (lxqt-desktop)
Cinnamon Desktop (cinnamon-desktop)
MATE Desktop (mate-desktop)
Sugar Desktop Environment (sugar-desktop)
Deepin Desktop (deepin-desktop)
Development and Creative Workstation (developer-workstation)
Web Server (web-server-environment)
Infrastructure Server (infrastructure-server-environment)
Basic Desktop (basic-desktop-environment)
Using the package name from the list above, install the desktop enviroment with a simple dnf install substituting kde-desktop-environment with the preferred DE. ########

sudo dnf install @kde-desktop
DEs can be switched at the login screen or alternatively, with the Desktop Switcher tool.

sudo dnf -y install switchdesk switchdesk-gui
Open the Desktop Switcher and select the preferred DE.


# ZSH

## core
sudo dnf install zsh -y

## provides the chsh command to change the SHELL for current user
sudo dnf5 install util-linux-user -y

## ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed 's/robbyrussell/powerlevel10k\/powerlevel10k/g' -i ~/.zshrc

## powerline fonts
sudo dnf install tmux-powerline vim-powerline powerline-fonts
wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
sudo mv -v PowerlineSymbols.otf /usr/share/fonts/
sudo mv -v MesloLGS*.ttf /usr/share/fonts/
sudo fc-cache -vf
sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/

## zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## rclone
sudo dnf5 install rclone

# openSSL
sudo dnf5 install openssl

## youtube-dl
sudo -H pip3 install youtube-dl

# virtualenvwrapper
sudo -H pip3 install virtualenvwrapper
export WORKON_HOME=~/Env
mkdir -p "$WORKON_HOME"

# TODO: add a couple of lines here that update ~/.zshrc with virtualenvwrapper config

# pyenv
sudo dnf5 install sqlite-devel tk-devel
curl https://pyenv.run | bash

# Node.js
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf5 install -y nodejs

## To install the Yarn package manager, run:
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo dnf5 install yarn -y

## ruby plus some gems

sudo dnf5 install ruby-devel -y

### https://github.com/travis-ci/travis.rb
gem install travis --no-document

### https://github.com/athityakumar/colorls
gem install colorls

## Android Development

### install KVM to have hardware acceleration for the better performance of Android Studio
### if your machine supports VT technology.

### check your CPU supports Intel VT / AMD SVM or not:
egrep --color 'vmx|svm' /proc/cpuinfo | wc -l
###  If the above output is non-zero, then your machine has Intel or AMD virtualization support.
sudo dnf5 install qemu-kvm bridge-utils libvirt virt-install -y

### install 32-bit libraries for Android Studio installation
sudo dnf5 install -y zlib.i686 ncurses-libs.i686 bzip2-libs.i686 -y

### JDK
sudo dnf5 install java-1.8.0-openjdk -y

###### Fonts and Wine ########
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
sudo dnf5 config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/42/winehq.repo
sudo dnf install winehq-staging -y
sudo dnf5 install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts

###### dotnet-install ########
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && sudo chmod +x ./dotnet-install.sh && ./dotnet-install.sh --version latest && ./dotnet-install.sh --version latest --runtime aspnetcore && ./dotnet-install.sh --channel 7.0
sudo dnf update && sudo dnf upgrade

###### xfce4-docklike-plugin ########
git clone https://github.com/nsz32/docklike-plugin &&  cd docklike-plugin
./autogen.sh
make
sudo make install
cd
###### CachyOS COPR Repository for Fedora ########
##Installation Instructions
##Make sure your CPU supports the higher target x86-64 architectures.

/lib64/ld-linux-x86-64.so.2 --help | grep "(supported, searched)"
##Next, enable the COPR repository hosting the kernels.

sudo dnf copr enable bieszczaders/kernel-cachyos # For GCC built kernels
# or
sudo dnf copr enable bieszczaders/kernel-cachyos-lto # For LLVM-ThinLTO build kernels
##Now you can install the kernels##

sudo dnf install kernel-cachyos kernel-cachyos-devel-matched # For GCC built kernels
# or
sudo dnf install kernel-cachyos-lto kernel-cachyos-lto-devel-matched # For LLVM-ThinLTO built kernels

## LTS Kernel
sudo dnf install kernel-cachyos-lts kernel-cachyos-lts-devel-matched
# or
sudo dnf install kernel-cachyos-lts-lto kernel-cachyos-lts-lto-devel-matched

# Lastly if you use SELinux, you need to enable the necessary policy to be able to load kernel modules.

sudo setsebool -P domain_kernel_load_modules on

###### CachyOS COPR Repository for Fedora ADDONS ########
We provide a few addons that supplement the kernel packages and system.

# ////CachyOS-Settings - Settings used in CachyOS (includes modprobe config, udev rules, etc) packaged for Fedora.
# ////scx-scheds - sched-ext schedulers. Provides both scx-scheds releases and scx-scheds-git package.
# ////uksmd - Userspace KSM helper daemon.
# ////ananicy-cpp & cachyos-ananicy-rules - Auto nice daemon with rules support.
# Installation instructions# 
# First, enable the COPR repository hosting addon packages.

sudo dnf copr enable bieszczaders/kernel-cachyos-addons

# Now you can install the addon packages.

# CachyOS-Settings # 
sudo dnf install cachyos-settings
sudo dracut -f

# scx-scheds
sudo dnf install scx-scheds
#or
sudo dnf install scx-scheds-git # For -git package

# Choose which scx scheduler to use by editting `/etc/default/scx`
sudo nano /etc/default/scx

# Then enable the systemd service to make it persistent across boots
sudo systemctl enable --now scx.service

# uksmd
sudo dnf install uksmd
sudo systemctl enable --now uksmd.service

# ananicy-cpp
sudo dnf install ananicy-cpp
sudo systemctl enable --now ananicy-cpp




sudo dnf5 update && sudo dnf5 upgrade
sudo dnf5 -y upgrade --refresh





















































































































