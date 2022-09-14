#!/bin/bash
sudo pacman -Syyu

# firefox
sudo cp -r ~/.mozilla ~/Desktop/dotfiles/firefox/

# Gnome (and gnome-tweaks) settings
cd ~
dconf dump / > ~/Desktop/dotfiles/gnome-settings/saved_settings.dconf
cp -r ~/.local/share/gnome-shell/extensions ~/Desktop/dotfiles/gnome-settings

cd Desktop/dotfiles

# Git
cp ~/.gitconfig  git/

# grub
sudo cp -f /etc/default/grub grub/

# neofetch
sudo cp /usr/bin/neofetch neofetch/ 

# OneDrive sync
cp ~/.config/systemd/user/rclone-onedrive.service onedrive_sync/

# Sagemath
cp ~/.sage/init.sage sage/

# tlp (battery management)
cp /etc/tlp.conf tlp/

# vlc
cp ~/.config/vlc/vlcrc vlc/

# zsh 
cp ~/.zshrc terminal/