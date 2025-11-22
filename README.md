# Arch Desktop Cloner

> Effortlessly clone your Arch Linux desktop setup — perfect for migrating to another machine or keeping a portable backup of your environment.

---

# Features

- Interactive, step-by-step terminal script.  
- Back up everything you need to recreate your system:  
  - Installed packages (`pacman` + optional AUR packages)  
  - Dotfiles and configs (`~/.config`, `~/.bashrc`, etc.)  
  - Enabled systemd services  
  - Pacman configuration (`/etc/pacman.conf` and `/etc/pacman.d/`, excluding sensitive gnupg files)  
- Automatically creates a `restore.sh` script for easy restoration on a new machine.  
- Optionally compresses the backup into a `.zip` for easy transfer.  
- Completely safe — your main system remains untouched.  

---

# How It Works

1. Run the interactive script:

```bash
chmod +x ~/arch-desktop-cloner.sh
./arch-desktop-cloner.sh
```

2. Follow the prompts to select what to back up:

   - Installed packages  
   - Pacman configuration  
   - Enabled systemd services  
   - Home directory and dotfiles  
   - Create restore script  
   - Compress backup to zip  

3. Once done, you’ll have:

```
~/arch-clone/       # full backup folder
~/arch-clone.zip    # compressed backup for easy transfer
```

4. Transfer the `.zip` to another machine using USB, SCP, or other methods.

---

# Restore on Another Machine

1. Unzip the backup:

```bash
unzip arch-clone.zip
cd arch-clone
```

2. Run the restore script:

```bash
chmod +x restore.sh
./restore.sh
```

- This will reinstall your packages, restore configs, and enable services — replicating your original setup.

---

# Safety Notes

- The script **only reads and copies** files — it does not modify your main system.  
- `gnupg` is excluded to avoid permission issues.  
- Recommended to run on a **fresh Arch install** on the target machine.  

---

# Optional Cleanup

After creating the zip, you can safely delete the backup folder to save space:

```bash
rm -rf ~/arch-clone
```

---

# Requirements

- Arch Linux  
- `rsync` (usually preinstalled)  
- `zip` (for compression; the script can auto-install if missing)  

---

# Why Use Arch Desktop Cloner?

- Makes migrating your Arch setup easy and safe.  
- Keeps your desktop environment, configs, and workflow portable.  
- Step-by-step prompts are beginner-friendly.  
- Perfect for backups, new machines, or multi-device setups.

---

# License

MIT License — free to use, modify, and share.
