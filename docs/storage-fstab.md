# 💾 Storage Drives, Mounting & `/etc/fstab` Reference

Quick reference for mounting and auto-mounting your `ext4` and `ntfs-3g` drives across **CachyOS** and **Fedora 45**.

---

## 🎯 Persistent `/etc/fstab` Configuration

Always mount by **UUID** rather than `/dev/sdX` device letters (which can shift between reboots). Including `nofail` ensures the system still boots normally if an external or secondary drive is disconnected.

### 1. Create Mount Directories
```bash
sudo mkdir -p /mnt/{LINUXDRIVE,EXTRA1TB,GAMEDRIVE,WettamSnapsMain,512GB}
```

### 2. Append UUID Entries to `/etc/fstab`
```bash
sudo tee -a /etc/fstab << 'EOF'

# --- WehttamSnaps Data Drives ---
UUID=2be94340-fe0c-464c-9afc-fde6ddc300cc  /mnt/LINUXDRIVE      ext4    defaults,noatime,nofail  0 2
UUID=d3283959-c9d3-494a-b832-72f961ea7a92  /mnt/EXTRA1TB        ext4    defaults,noatime,nofail  0 2
UUID=3f996c97-b699-4208-b9fc-1a64bc65b478  /mnt/GAMEDRIVE       ext4    defaults,noatime,nofail  0 2
UUID=2C66D88566D850E6                      /mnt/WettamSnapsMain ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=111,nofail  0 0
UUID=47780A83503AF675                      /mnt/512GB           ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=111,nofail  0 0
EOF
```

### 3. Apply Without Rebooting
```bash
sudo systemctl daemon-reload
sudo mount -a
```

---

## ⚠️ Steam / Proton Storage Rule

* **Use `ext4` for Steam Libraries:** Keep your Steam and Proton game libraries on **`/mnt/GAMEDRIVE`**, **`/mnt/LINUXDRIVE`**, or **`/mnt/EXTRA1TB`**.
* **Use `ntfs-3g` for Media & Archives Only:** Keep **`/mnt/WettamSnapsMain`** and **`/mnt/512GB`** for photos, video footage, and backups, as running Proton/Wine prefixes on `ntfs-3g` causes file-locking and permission errors.

---

## 🛠️ Quick Disk Commands

| Task | Command |
| :--- | :--- |
| List all drives, labels & UUIDs | `lsblk -f` |
| Check mounted drive space | `df -h \| grep -E '(/dev/sd\|/dev/nvme\|/mnt/)'` |
| Mount drive without `sudo` | `udisksctl mount -b /dev/sdXY` |
| Unmount drive cleanly | `sudo umount /mnt/MOUNTPOINT` (or `udisksctl unmount -b /dev/sdXY`) |
| Check drive SMART health | `sudo smartctl -a /dev/sdX` |
