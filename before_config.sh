#!/bin/bash
sudo pacman -Syyu

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cp -r ~/.local/share/gnome-shell/extensions ~/Desktop/dotfiles/gnome-settings

cd Desktop/dotfiles

# Git
cp ~/.gitconfig  git/

# grub
sudo cp -f /etc/default/grub grub/

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