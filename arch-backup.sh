#!/bin/bash
set -e

cat << "EOF"
▓█████   ██████▓██   ██▓▒██   ██▒
▓█   ▀ ▒██    ▒ ▒██  ██▒▒▒ █ █ ▒░
▒███   ░ ▓██▄    ▒██ ██░░░  █   ░
▒▓█  ▄   ▒   ██▒ ░ ▐██▓░ ░ █ █ ▒ 
░▒████▒▒██████▒▒ ░ ██▒▓░▒██▒ ▒██▒
░░ ▒░ ░▒ ▒▓▒ ▒ ░  ██▒▒▒ ▒▒ ░ ░▓ ░
 ░ ░  ░░ ░▒  ░ ░▓██ ░▒░ ░░   ░▒ ░
   ░   ░  ░  ░  ▒ ▒ ░░   ░    ░  
   ░  ░      ░  ░ ░      ░    ░  
                ░ ░              
EOF

echo "Arch Desktop Cloner - by esyx"
echo "======================================="

BACKUP_DIR="$HOME/arch-clone"
echo "[*] Backup folder: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

echo "[*] Exporting installed packages..."
pacman -Qqe > "$BACKUP_DIR/pkglist.txt"
echo "[+] Package list saved."

echo "[*] Backing up pacman configuration..."
mkdir -p "$BACKUP_DIR/etc"
cp /etc/pacman.conf "$BACKUP_DIR/etc/"
rsync -av --exclude='gnupg' /etc/pacman.d/ "$BACKUP_DIR/etc/pacman.d/"
echo "[+] Pacman config saved."

echo "[*] Saving systemd enabled services..."
mkdir -p "$BACKUP_DIR/systemd"
systemctl list-unit-files --state=enabled > "$BACKUP_DIR/systemd/enabled.txt"
systemctl --user list-unit-files --state=enabled > "$BACKUP_DIR/systemd/user-enabled.txt"
echo "[+] Systemd services saved."

echo "[*] Backing up home directory..."
mkdir -p "$BACKUP_DIR/home"
rsync -ah --info=progress2 --exclude=".cache" --exclude="Downloads" --exclude="*.log" "$HOME/" "$BACKUP_DIR/home/"
echo "[+] Home directory saved."

echo "[*] Creating restore.sh..."
cat << 'EOF' > "$BACKUP_DIR/restore.sh"
#!/bin/bash
set -e
echo "[*] Installing packages..."
sudo pacman -Syu --needed - < pkglist.txt
echo "[*] Restoring home directory..."
rsync -ah home/ "$HOME/"
echo "[*] Restoring pacman config..."
sudo cp -r etc/pacman.conf /etc/
sudo cp -r etc/pacman.d/ /etc/
echo "[*] Restoring systemd services..."
while read -r svc; do
    sudo systemctl enable "$svc"
done < <(awk '{print $1}' systemd/enabled.txt)
echo "[*] Done! Reboot recommended."
EOF

chmod +x "$BACKUP_DIR/restore.sh"
echo "[+] restore.sh created."

ZIP_FILE="$HOME/arch-clone.zip"
echo "[*] Compressing backup to $ZIP_FILE..."
if ! command -v zip &> /dev/null; then
    echo "[!] zip not found. Installing..."
    sudo pacman -S --needed zip -y
fi

cd "$HOME"
zip -r --progress "$ZIP_FILE" "$(basename "$BACKUP_DIR")"
echo "[+] Backup compressed successfully."

read -p "Do you want to delete the original backup folder? (y/n): " DEL
if [[ $DEL =~ ^[Yy]$ ]]; then
    rm -rf "$BACKUP_DIR"
    echo "[+] Backup folder deleted, keeping only zip."
fi

echo "======================================="
echo "[+] Backup complete! You can transfer arch-clone.zip to another machine."
