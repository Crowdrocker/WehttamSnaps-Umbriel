sudo mkdir -p /mnt/LINUXDRIVE
sudo mkdir -p /mnt/EXTRA1TB
sudo mkdir -p /mnt/GAMEDRIVE
sudo mkdir -p /mnt/WettamSnapsMain

sudo mount /dev/sdc1 /mnt/LINUXDRIVE
sudo mount /dev/sdf1 /mnt/EXTRA1TB
sudo mount /dev/sde1 /mnt/GAMEDRIVE
sudo mount -t ntfs-3g /dev/sdd1 /mnt/WettamSnapsMain

sudo unmount /dev/sdb1 /mnt/LINUXDRIVE-1
sudo udiskie-umount /dev/sdd1 /mnt/PC-EXTRA-2
sudo udiskie-umount /dev/sde1 /mnt/GAMEDRIVE
sudo udiskie-umount /dev/sdj1 /mnt/Wettam-Snaps-Main

echo "========================================"
echo "Arch Linux Disk Mounting Cheat Sheet"
echo "========================================"

echo -e "\n📋 QUICK MOUNT COMMANDS:"
echo "# Mount drive: udisksctl mount -b /dev/sdXY"
echo "# Unmount: udisksctl unmount -b /dev/sdXY"
echo "# List drives: lsblk -f"

echo -e "\n🎯 YOUR DRIVES CHEAT SHEET:"
echo "PC-EXTRA-2:      udisksctl mount -b /dev/sdd1"
echo "Wettam Snaps Main: udisksctl mount -b /dev/sde1"
echo "GAMEDRIVE:       udisksctl mount -b /dev/sdj1"
echo "LINUXDRIVE-1:    udisksctl mount -b /dev/sdb1"

echo -e "\n🔍 CHECK DRIVE STATUS:"
echo "# See all drives: lsblk -f"
echo "# See mounted drives: df -h | grep -E '(/dev/sd|/mnt/)'"
echo "# Check drive health: sudo smartctl -a /dev/sdX"

# --- WehttamSnaps Data Drives ---

# /dev/sdc1 -> LINUXDRIVE
UUID=c0f59cf7-9437-4ee3-be68-e27e7b1e52ae  /mnt/LINUXDRIVE       ext4    defaults,noatime,nofail    0>

# /dev/sdf1 -> EXTRA1TB
UUID=d3283959-c9d3-494a-b832-72f961ea7a92  /mnt/EXTRA1TB         ext4    defaults,noatime,nofail    0>

# /dev/sdd1 -> GAMEDRIVE
UUID=3f996c97-b699-4208-b9fc-1a64bc65b478  /mnt/GAMEDRIVE        ext4    defaults,noatime,nofail    0>

# /dev/sde1 -> WettamSnapsMain (4.5TB NTFS)
UUID=2C66D88566D850E6                      /mnt/WettamSnapsMain  ntfs-3g defaults,uid=1000,gid=1000,d>


echo -e "\n📁 AUTO-MOUNT AT BOOT (fstab):"
echo "# Edit fstab: sudo nano /etc/fstab"
echo "# Example entry:"
echo "/dev/sdd1 /mnt/PC-EXTRA-2 ntfs-3g defaults,uid=1000,gid=1000,umask=002 0 0"

echo ""
echo "# Apply changes:"
echo "sudo systemctl daemon-reload"
echo "sudo mount -a"

sudo systemctl daemon-reload
sudo mount -a

2. Clean /etc/fstab Block for Your Void Reinstall

Before you wipe and reinstall Void, save this exact block to append to /etc/fstab after creating the mount directories (sudo mkdir -p /mnt/{LINUXDRIVE,EXTRA1TB,GAMEDRIVE,WettamSnapsMain}). Make sure ntfs-3g is installed via sudo xbps-install -S ntfs-3g so WettamSnapsMain mounts without halting boot:

# --- WehttamSnaps Data Drives ---
UUID=c0f59cf7-9437-4ee3-be68-e27e7b1e52ae  /mnt/LINUXDRIVE      ext4     defaults,noatime,nofail  0  2
UUID=d3283959-c9d3-494a-b832-72f961ea7a92  /mnt/EXTRA1TB        ext4     defaults,noatime,nofail  0  2
UUID=3f996c97-b699-4208-b9fc-1a64bc65b478  /mnt/GAMEDRIVE       ext4     defaults,noatime,nofail  0  2
UUID=2C66D88566D850E6                      /mnt/WettamSnapsMain ntfs-3g  defaults,uid=1000,gid=1000,dmask=022,fmask=133,nofail  0  0


(After mounting, run sudo chown -R $USER:$USER /mnt/LINUXDRIVE /mnt/EXTRA1TB /mnt/GAMEDRIVE once to verify your new Void UID/GID owns all existing Steam and mod folders).




Your secondary drives are all showing up cleanly—you just need to add them to /etc/fstab so they auto-mount at boot (especially GAMEDRIVE so Steam and Faugus Launcher can immediately find your existing game libraries without hanging).

1. Install ntfs-3g for Your NTFS Drives (512GB & WettamSnapsMain)

Void's base install does not include ntfs-3g by default, which is needed for read/write mounting on sdc1 and sde1:
bash
sudo xbps-install -S ntfs-3g
Use code with caution.

2. Create Your Mount Directories

bash
sudo mkdir -p /mnt/LINUXDRIVE /mnt/512GB /mnt/GAMEDRIVE /mnt/WettamSnapsMain /mnt/EXTRA1TB
Use code with caution.

3. Add All Drives to /etc/fstab by UUID

Run this block to append your drives safely using their exact UUIDs (nofail prevents boot hangs if a drive is ever disconnected):
bash
cat << 'EOF' | sudo tee -a /etc/fstab
UUID=2be94340-fe0c-464c-9afc-fde6ddc300cc  /mnt/LINUXDRIVE       ext4     defaults,noatime,nofail  0  2
UUID=47780A83503AF675                      /mnt/512GB            ntfs-3g  defaults,uid=1000,gid=1000,nofail  0  0
UUID=3f996c97-b699-4208-b9fc-1a64bc65b478  /mnt/GAMEDRIVE        ext4     defaults,noatime,nofail  0  2
UUID=2C66D88566D850E6                      /mnt/WettamSnapsMain  ntfs-3g  defaults,uid=1000,gid=1000,nofail  0  0
UUID=d3283959-c9d3-494a-b832-72f961ea7a92  /mnt/EXTRA1TB         ext4     defaults,noatime,nofail  0  2
EOF
Use code with caution.

4. Mount Everything & Grant Flatpak Faugus Access

Mount all drives immediately, ensure your user owns the ext4 mount folders, and give Flatpak Faugus access to /mnt so it can launch games stored on GAMEDRIVE:
bash
sudo systemctl daemon-reload 2>/dev/null || true
sudo mount -a
sudo chown -R $USER:$USER /mnt/LINUXDRIVE /mnt/GAMEDRIVE /mnt/EXTRA1TB
sudo flatpak override io.github.Faugus.faugus-launcher --filesystem=/mnt
Use code with caution.
(Note: If you run chown on large folders, use sudo chown $USER:$USER /mnt/LINUXDRIVE /mnt/GAMEDRIVE /mnt/EXTRA1TB without -R first so it finishes instantly while keeping your existing file permissions intact).
Once sudo mount -a finishes without errors, let me know if Steam and Faugus pick up your existing libraries on /mnt/GAMEDRIVE and launch cleanly!
















