#!/bin/bash

# Remember to previously install firefox and git and also reboot at the end of the execution of this file.
# This is for Archlinux + KDE


# update & upgrade
sudo pacman -Syyu

# scripts
chmod +x move_scripts.sh
./move_scripts.sh


# Git + Github keys
sudo pacman -S --needed git
cp others/.gitconfig ~/
echo "Press enter when promted to 'Enter a file in which to save the key', and in 'add passphrase'"
ssh-keygen -t ed25519 -C "victor.ballester.ribo@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "Now copy the following key to your Github account in Settings/Access/Ssh keys..."
cat ~/.ssh/id_ed25519.pub
printf "%s " "Press enter to continue once copied the key to Github"
read ans

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
paru -S --noconfirm --needed sof-firmware alsa-ucm-conf

# If it take too long to reboot and/or shutdown then is may be a problem of sddm
# To solve this, install a newer version of sddm from AUR: sddm-git
paru -S sddm-git


# Copy rules (that will be executed at the startup of the system):
cd
sudo cp Desktop/dotfiles/Rules/* /etc/udev/rules.d/

# Restore KDE backup
cd Desktop
git clone https://gitlab.com/cscs/transfuse.git
cd transfuse
chmod +x transfuse.sh
cp ../dotfiles/config/*.tar.gz ./
./transfuse.sh


# Installation of programs
cd 
# Others: autorandr
paru -S --noconfirm --needed autopep8 cheese chromium clang discord ethtool gcc gdb gimp gnome-screenshot gnome-terminal howdy inkscape jdk-openjdk jupyter-notebook kdeconnect kde-graphics-meta latte-dock libreoffice-fresh man-db man-pages neofetch ntfs-3g octave partitionmanager python qbittorrent rclone rsync teams-for-linux texlive tlp visual-studio-code-bin vlc zsh


# Modules necessary:
# for weather widget
paru -S --noconfirm --needed qt5-xmlpatterns qt5-xmlpatterns 

# for kde-connect transfer protocol
paru -S --noconfirm --needed sshfs


# # auto-cpufreq (battery powersave) (use either this or tlp; NOT both)
# systemctl start auto-cpufreq
# systemctl enable auto-cpufreq

# autopep8: to format documents in python

# autorandr: for automatically change monitor display configuration (https://github.com/phillipberndt/autorandr)

# breeze: it's the default KDE style (like Adwaita for GNOME)

# cheese0 (gnome camera app)

# chromium (open source alternative to google chrome)

# # cronie
# sudo systemctl enable cronie

# ethtool
# needed for disabling wake-on-lan (used by tlp)

# firefox
# sudo cp -r ~/Desktop/dotfiles/firefox/.mozilla ~/

# gdb = GNU debugger

# grub
# Note the following: I changed the line 

# # GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"

# with the line

# GRUB_CMDLINE_LINUX_DEFAULT="acpi_mask_gpe=0x6E loglevel=3 quiet"

# in order to mask the interupt /sys/firmware/interupt/gpe6E because it was causing many interupts when the laptop was plugged in. Now it goes like a charm! :)
sudo cp Desktop/dotfiles/others/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

# inskcape (vector graphics editor)

# kdeconnect

# kde-graphics-meta
# some interesting programs for kde

# kdenlive
# missing adding config files

# latte-dock (my dock for linux)

# man-db, man-pages: implement man pages on Arch

# neofetch
sudo cp Desktop/dotfiles/others/neofetch /usr/bin/

# ntfs-3g: for read/write acces to Microsoft NTFS partitions.

# nvidia-settings
# paru -S --noconfirm --needed nvidia nvidia-utils nvidia-settings xorg-server-devel opencl-nvidia

# pacman config
sudo cp Desktop/dotfiles/others/pacman.conf /etc/

# partitionmanager (disk / partition manager for KDE)

# rclone (OneDrive sync: mount at startup)
# Notes: Name the remote as "OneDrive".
#        Do not change the folder to /etc/systemd/system/ because otherwise it will compile as root and we don't want this (because we would have to change other things too).
#        If an error about fusermount is prompt, install fuse2.
paru -S --noconfirm --needed fuse2
rclone config
mkdir -p ~/.config/systemd/user/
mkdir -p ~/OneDrive
sudo cp Desktop/dotfiles/others/rclone-onedrive.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now rclone-onedrive

# rsync (necessary for the backup script: https://gitlab.com/cscs/transfuse)

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
sudo cp Desktop/dotfiles/others/tlp.conf /etc/

# vscode (latexindent formatter configuration)
cd ~/Desktop 
git clone git@github.com:cmhughes/latexindent.pl.git
cd latexindent.pl
sudo paru -S --noconfirm --needed perl cpanminus cmake make
sudo perl helper-scripts/latexindent-module-installer.pl
cmake path-helper-files
sudo make install
cd 
rm -rf Desktop/latexindent.pl

# vlc
mkdir ~/.config/vlc/
sudo cp Desktop/dotfiles/others/vlcrc ~/.config/vlc/

# zsh 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo cp Desktop/dotfiles/others/.zshrc ~/
chsh -s /bin/zsh
