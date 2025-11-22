#!/bin/bash
set -e

echo "=== Arch Linux Cyberdeck Backup Script ==="

# Step 1: Choose backup folder
read -p "Step 1: Enter backup folder path (default: ~/arch-clone): " BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-$HOME/arch-clone}
echo "[*] Backup folder will be: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Step 2: Save package list
read -p "Step 2: Export installed packages list? (y/n) " RESP
if [[ $RESP =~ ^[Yy]$ ]]; then
    echo "[*] Saving package list..."
    pacman -Qqe > "$BACKUP_DIR/pkglist.txt"
    echo "[+] Package list saved."
fi

# Step 3: Backup pacman config
read -p "Step 3: Backup pacman configuration? (y/n) " RESP
if [[ $RESP =~ ^[Yy]$ ]]; then
    echo "[*] Saving pacman config..."
    mkdir -p "$BACKUP_DIR/etc"
    cp /etc/pacman.conf "$BACKUP_DIR/etc/"
    rsync -av --exclude='gnupg' /etc/pacman.d/ "$BACKUP_DIR/etc/pacman.d/"
    echo "[+] Pacman config saved."
fi


# Step 4: Backup systemd enabled services
read -p "Step 4: Backup enabled systemd services? (y/n) " RESP
if [[ $RESP =~ ^[Yy]$ ]]; then
    echo "[*] Saving systemd services..."
    mkdir -p "$BACKUP_DIR/systemd"
    systemctl list-unit-files --state=enabled > "$BACKUP_DIR/systemd/enabled.txt"
    systemctl --user list-unit-files --state=enabled > "$BACKUP_DIR/systemd/user-enabled.txt"
    echo "[+] Systemd services saved."
fi

# Step 5: Backup home directory and dotfiles
read -p "Step 5: Backup your home directory and dotfiles? (y/n) " RESP
if [[ $RESP =~ ^[Yy]$ ]]; then
    echo "[*] Backing up home directory..."
    mkdir -p "$BACKUP_DIR/home"
    rsync -av --progress \
        --exclude=".cache" \
        --exclude="Downloads" \
        --exclude="*.log" \
        $HOME/. "$BACKUP_DIR/home/"
    echo "[+] Home directory saved."
fi

# Step 6: Create restore script
read -p "Step 6: Create restore script for the new machine? (y/n) " RESP
if [[ $RESP =~ ^[Yy]$ ]]; then
    echo "[*] Creating restore.sh..."
    cat << 'EOF' > "$BACKUP_DIR/restore.sh"
#!/bin/bash
set -e
echo "[*] Installing packages..."
sudo pacman -Syu --needed - < pkglist.txt
echo "[*] Restoring dotfiles..."
rsync -av home/ $HOME/
echo "[*] Restoring pacman config..."
sudo cp -r etc/pacman.conf /etc/
sudo cp -r etc/pacman.d /etc/
echo "[*] Restoring systemd services..."
while read -r svc; do
    sudo systemctl enable "$svc"
done < <(awk '{print $1}' systemd/enabled.txt)
echo "[*] Done! Reboot recommended."
EOF
    chmod +x "$BACKUP_DIR/restore.sh"
    echo "[+] restore.sh created."
fi

# Step 7: Compress backup folder
read -p "Step 7: Compress backup folder into a zip file? (y/n) " RESP
if [[ $RESP =~ ^[Yy]$ ]]; then
    ZIP_FILE="$HOME/arch-clone.zip"
    echo "[*] Compressing..."
    if ! command -v zip &> /dev/null; then
        echo "[!] zip not found. Installing..."
        sudo pacman -S --needed zip
    fi
    cd "$HOME"
    zip -r "$ZIP_FILE" "$(basename "$BACKUP_DIR")"
    echo "[+] Backup compressed to $ZIP_FILE"
fi

echo "=== Backup Complete! Your system is intact. ==="
