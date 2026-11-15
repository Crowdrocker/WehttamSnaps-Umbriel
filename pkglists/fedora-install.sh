REPO_DIR="/home/wehttamsnaps/Documents/GitHub/WehttamSnaps-Umbriel"
mkdir -p "$REPO_DIR/pkglists"

# Move existing Arch pkglist into pkglists/arch.txt
if [[ -f "$REPO_DIR/pkglist.txt" ]]; then
    mv "$REPO_DIR/pkglist.txt" "$REPO_DIR/pkglists/arch.txt"
fi

cat << 'EOF' > "$REPO_DIR/pkglists/flatpak.txt"
com.obsproject.Studio
com.discordapp.Discord
dev.vencord.Vesktop
com.vysp3r.ProtonPlus
net.davidotek.pupgui2
com.github.tchx84.Flatseal
io.missioncenter.MissionCenter
com.dec05eba.gpu_screen_recorder
md.obsidian.Obsidian
org.signal.Signal
org.telegram.desktop
org.qbittorrent.qBittorrent
com.spotify.Client
io.github.shiftey.Desktop
EOF

echo "✅ Created pkglists/ directory."
