#!/bin/bash

# Remember to previously install firefox and git and also reboot at the end of the execution of this file.
# This is for Archlinux + KDE

# update & upgrade
sudo pacman -Syyu

# scripts
cd Desktop/dotfiles
chmod +x move_scripts.sh
./move_scripts 


# Git + Github keys
sudo pacman -S --needed git
cp git/.gitconfig ~/
echo "Press enter when promted to 'Enter a file in which to save the key', and in 'add passphrase'"
ssh-keygen -t ed25519 -C "victor.ballester.ribo@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "Now copy the following key to your Github account in Settings/Access/Ssh keys..."
cat ~/.ssh/id_ed25519.pub

# paru (AUR helper)
sudo pacman -S --noconfirm --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru


# PROBLEM - SOLVING
# Audio drivers:
cd
paru -S sof-firmware alsa-ucm-conf

# If it take too long to reboot and/or shutdown then is may be a problem of sddm
# To solve this, install a newer version of sddm from AUR: sddm-git



# MISSING FILES TO BE COPIED
# .zshrc 
# /etc/pacman.conf
# latte-dock
# all kde configs files


# Modules necessary:
# - qt5-xmlpatterns (for weather widget)

# Installation of programs

cd 
# Others: autorandr
paru -S --noconfirm --needed autopep8 clang discord ethtool gcc gdb gimp gnome-screenshot gnome-terminal jdk-openjdk jupyter-notebook latte-dock libreoffice-fresh man-db man-pages neofetch python qbittorrent rclone teams-for-linux texlive-most tlp visual-studio-code-bin vlc zsh

# # auto-cpufreq (battery powersave) (use either this or tlp; NOT both)
# systemctl start auto-cpufreq
# systemctl enable auto-cpufreq

# autopep8: to format documents in python

# autorandr: for automatically change monitor display configuration (https://github.com/phillipberndt/autorandr)

# breeze: it's the default KDE style (like Adwaita for GNOME)

# # cronie
# sudo systemctl enable cronie

# ethtool
# needed for disabling wake-on-lan (used by tlp)

# firefox
# sudo cp -r ~/Desktop/dotfiles/firefox/.mozilla ~/

# gdb = GNU debugger

# grub
sudo cp Desktop/dotfiles/grub/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

# kdenlive
# missing adding config files

# man-db, man-pages: implement man pages on Arch

# neofetch
sudo cp Desktop/dotfiles/neofetch/neofetch /usr/bin/

# ntfs-3g: for read/write acces to Microsoft NTFS partitions.

# nvidia-settings
# paru -S --noconfirm --needed nvidia nvidia-utils nvidia-settings xorg-server-devel opencl-nvidia

# rclone (OneDrive sync: mount at startup)
# Notes: Name the remote as "OneDrive".
#        Do not change the folder to /etc/systemd/system/ because otherwise it will compile as root and we don't want this (because we would have to change other things too).
#        If an error about fusermount is prompt, install fuse2.
rclone config
mkdir -p ~/.config/systemd/user/
mkdir -p ~/OneDrive
sudo cp Desktop/dotfiles/onedrive_sync/rclone-onedrive.service /etc/systemd/system/
systemctl --user daemon-reload
systemctl --user enable --now rclone-onedrive

# rstudio-desktop

# rsync (automated backup)
# cp /usr/local/bin/syncOneDrive.sh /etc/cron.daily

# sagemath
# mkdir -p ~/.sage
# sudo cp Desktop/dotfiles/sage/init.sage ~/.sage/

# supergfxctl (for exchanging power mode: Hybrid and Integrated)
# sudo systemctl enable supergfxd.service --now
# sudo usermod -a -G users $USER

# tlp (battery management)
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable tlp.service
sudo tlp start
sudo cp Desktop/dotfiles/tlp/tlp.conf /etc/

# vscode (latexindent formatter configuration)
cd ~/Desktop 
git clone git@github.com:cmhughes/latexindent.pl.git
cd latexindent.pl
sudo paru -S --needed perl cpanminus cmake make
sudo perl helper-scripts/latexindent-module-installer.pl
cmake path-helper-files
sudo make install
cd 
rm -rf Desktop/latexindent.pl

# vlc
mkdir ~/.config/vlc/
sudo cp Desktop/dotfiles/vlc/vlcrc ~/.config/vlc/

# zsh 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo cp Desktop/dotfiles/terminal/.zshrc ~/
chsh -s /bin/zsh
