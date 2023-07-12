#!/bin/bash

# .config folder (copy KDE configs files)
rm ~/Desktop/dotfiles/config/*.tar.gz
cd ~/Desktop
git clone https://gitlab.com/cscs/transfuse.git
cd transfuse
chmod +x transfuse.sh
./transfuse.sh -b victor
./transfuse.sh -p
cp *.tar.gz ../dotfiles/config
cp *.txt ../dotfiles/config

# Copy history
cd ~/Desktop/dotfiles
history > history/history.txt

# Git
cp ~/.gitconfig  others/

# grub
sudo cp -f /etc/default/grub others/

# neofetch
sudo cp /usr/bin/neofetch others/ 

# OneDrive sync
cp ~/.config/systemd/user/rclone-onedrive.service others/


# Pacman conf
sudo cp /etc/pacman.conf others/

# qbittorrent 

# Sagemath
# cp ~/.sage/init.sage others/

# tlp (battery management)
cp /etc/tlp.conf others/

# vlc
cp ~/.config/vlc/vlcrc others/

# zsh 
cp ~/.zshrc others/

## NOTES
# 1. Consider backing up the file /etc/profile (where there are my curstom PATH variables)