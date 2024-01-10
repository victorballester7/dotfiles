#!/bin/bash

# Remember to previously install firefox and git and also reboot at the end of the execution of this file.
# You can execute this file from anywhere.
# This is for Archlinux + KDE with X11 ideally.

# Remember to insall the pipwire drivers for audio, not the pulseaudio ones (I had problems with the pulseaudio ones).
# After the installation, import manually the profile for thunderbird: Tools > Import. It is in the others/ folder.


# TODO
# check in history if it's missing some packages that has to be installed manually
# check if all is backed up correctly from kde. Things to check: themes, icons, fonts, shortcuts, latte-dock,...
# pensar si intal·lar els paquets tots junts per evitar que cada cop actualitzi el kernel.


# ANSI escape codes for color formatting
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# update & upgrade
echo -e "${YELLOW}Updating and upgrading...${RESET}"
sudo pacman -Syyu --noconfirm --needed --quiet
if [ $? -ne 0 ]; then
    echo -e "${RED}Error updating and upgrading.${RESET}"
    notify-send "Error updating and upgrading" "There was a problem updating and upgrading. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Updated and upgraded successfully.${RESET}"
fi

# reflector (to update mirrors). I do it here to have good mirrors for the whole installation
echo -e "${YELLOW}Installing reflector...${RESET}"
sudo pacman -S --noconfirm --needed --quiet reflector
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing reflector.${RESET}"
    notify-send "Error installing reflector" "There was a problem installing reflector. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Reflector installed successfully.${RESET}"
fi
cd
echo -e "${YELLOW}Configuring reflector...${RESET}"
sudo cp Desktop/dotfiles/others/reflector.conf /etc/xdg/reflector/
sudo systemctl enable reflector.timer # in order to run reflector weekly instead of at each boot
sudo systemctl start reflector.timer
sudo systemctl enable reflector.service
sudo systemctl start reflector.service
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring reflector.${RESET}"
    notify-send "Error configuring reflector" "There was a problem configuring reflector. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Reflector configured successfully.${RESET}"
fi

# scripts
cd
echo -e "${YELLOW}Moving scripts...${RESET}"
cd Desktop/dotfiles/
chmod +x move_scripts.sh
./move_scripts.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}Error moving scripts.${RESET}"
    notify-send "Error moving scripts" "There was a problem moving scripts. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Scripts moved successfully.${RESET}"
fi




# Git + Github keys
cd
echo -e "${YELLOW}Installing and configuring git...${RESET}"
sudo pacman -S --noconfirm --needed --quiet git
cp Desktop/dotfiles/others/.gitconfig ~/
echo -e "${BLUE}Press enter when promted to 'Enter a file in which to save the key', and in 'add passphrase'${RESET}"
ssh-keygen -t ed25519 -C "victor.ballester.ribo@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo -e "${BLUE}Now copy the following key to your Github account in Settings/Access/Ssh keys...${RESET}"
cat ~/.ssh/id_ed25519.pub
echo -e "${BLUE}Press enter to continue once copied the key to Github${RESET}"
read ans
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing and configuring git.${RESET}"
    notify-send "Error installing and configuring git" "There was a problem installing and configuring git. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Git installed and configured successfully.${RESET}"
fi

# yay (AUR helper)
cd
echo -e "${YELLOW}Installing yay...${RESET}"
sudo pacman -S --noconfirm --needed --quiet base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing yay.${RESET}"
    notify-send "Error installing yay" "There was a problem installing yay. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Yay installed successfully.${RESET}"
fi

# PROBLEM - SOLVING
# Audio drivers:
cd
echo -e "${YELLOW}Installing audio drivers...${RESET}"
yay -S --noconfirm --needed --quiet sof-firmware alsa-ucm-conf
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing audio drivers.${RESET}"
    notify-send "Error installing audio drivers" "There was a problem installing audio drivers. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Audio drivers installed successfully.${RESET}"
fi

# If it take too long to reboot and/or shutdown then is may be a problem of sddm
# To solve this, install a newer version of sddm from AUR: sddm-git
# yay -S sddm-git


# Copy rules (that will be executed at the startup of the system):
cd
echo -e "${YELLOW}Copying rules...${RESET}"
sudo cp Desktop/dotfiles/rules/* /etc/udev/rules.d/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error copying rules.${RESET}"
    notify-send "Error copying rules" "There was a problem copying rules. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Rules copied successfully.${RESET}"
fi

# Copy wallpapers
cd
# echo -e "${YELLOW}Copying wallpapers...${RESET}"
# cp -r Desktop/dotfiles/wallpapers ~/Pictures/
# if [ $? -ne 0 ]; then
#     echo -e "${RED}Error copying wallpapers.${RESET}"
#     notify-send "Error copying wallpapers" "There was a problem copying wallpapers. Please check the installation process." --urgency=critical
# else
#     echo -e "${GREEN}Wallpapers copied successfully.${RESET}"
# fi


# To solve a problem with the google calendar widget:
# source: https://github.com/Zren/plasma-applet-eventcalendar/issues/331
# cd 
# git clone https://github.com/gaganpreet/plasma-applet-eventcalendar.git eventcalendar
# cd eventcalendar
# git checkout google-calendar-fix
# sh ./install
# cd
# rm -rf eventcalendar


# Restore KDE backup
# old version ------------------
# cd Desktop
# git clone https://gitlab.com/cscs/transfuse.git
# cd transfuse
# chmod +x transfuse.sh
# cp ../dotfiles/config/*.tar.gz ./
# ./transfuse.sh
# 
# new version ------------------
cd 
cd Desktop/dotfiles/config/
echo -e "${YELLOW}Restoring KDE backup...${RESET}"
yay -S --noconfirm --needed konsave
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing konsave.${RESET}"
    notify-send "Error installing konsave" "There was a problem installing konsave. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Konsave installed successfully.${RESET}"
fi
konsave -i victor-config.knsv
if [ $? -ne 0 ]; then
    echo -e "${RED}Error restoring KDE backup.${RESET}"
    notify-send "Error restoring KDE backup" "There was a problem restoring KDE backup. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}KDE backup restored successfully.${RESET}"
fi
konsave -a victor-config

# To solve a problem with the google calendar widget:
# source: https://github.com/Zren/plasma-applet-eventcalendar/issues/331
cd 
git clone https://github.com/gaganpreet/plasma-applet-eventcalendar.git eventcalendar
cd eventcalendar
git checkout google-calendar-fix
sh ./install
cd
rm -rf eventcalendar



# Necessary packages (already included in the list below):
# for weather widget: qt5-xmlpatterns qt5-xmlpatterns
# for kde-connect transfer protocol: sshfs
# for rclone: fuse2
# for vscode: perl cpanminus cmake make

# Necessary packages (already included in the list below):
# for freefem: parmetis-git
# for kde-connect transfer protocol: sshfs
# for rclone: fuse2
# for touchegg: xdotool
# for vscode: perl cpanminus cmake make
# for weather widget: qt5-xmlpatterns
# ethool: needed for disabling wake-on-lan (used by tlp)


# Packages removed from the list:
# gnome-screenshot, gnome-terminal, julia

# Other interesting but not included packages:
# howdy (face recognition)



# Packages to delete that are installed by default:
delete_programs="kate vim"

# Delete programs
cd
echo -e "${YELLOW}Deleting programs...${RESET}"
yay -Rsn --noconfirm --quiet $delete_programs
if [ $? -ne 0 ]; then
    echo -e "${RED}Error deleting programs.${RESET}"
    notify-send "Error deleting programs" "There was a problem deleting programs. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Programs deleted successfully.${RESET}"
fi


# Installation of programs
cd 

# List of programs to install
programs="autopep8 kwin-bismuth cheese chromium clang cmake cpanminus dbus-python discord docker docker-compose ethtool evince firefox freefem fuse2 gcc gdb gimp inkscape jdk-openjdk jekyll jupyter-notebook kde-graphics-meta kdeconnect kdenlive krunner-vscodeprojects kwalletmanager kwin-bismuth latte-dock libreoffice-fresh linux-zen linux-zen-headers make man-db man-pages mkinitcpio-firmware neofetch noto-fonts-emoji ntfs-3g octave parmetis-git partitionmanager perl python python-pandas python-matplotlib qbittorrent qt5-xmlpatterns rclone rsync ruby spotify spotify-adblock sshfs teams-for-linux texlive-full thunderbird tlp tlp-rdw touchegg unzip unrar visual-studio-code-bin vlc xdotool xorg-xrandr zsh"

# All packages at once
echo -e "${YELLOW}Installing all programs...${RESET}"
yay -S --noconfirm --needed --quiet $programs
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing all programs.${RESET}"
    notify-send "Error installing all programs" "There was a problem installing all programs. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}All programs installed successfully.${RESET}"
fi

# Loop through each program and install it
# for program in $programs; do
#     echo -e "${YELLOW}Installing $program...${RESET}"
#     yay -S --noconfirm --needed "$program"

#     # Check the exit status of the previous command
#     if [ $? -ne 0 ]; then
#         # If an error occurred, display an alert in red
#         echo -e "${RED}Error installing $program${RESET}"
#         notify-send "Error installing $program" "There was a problem installing $program. Please check the installation process." --urgency=critical
#     else
#         # If successful, display a success message in green
#         echo -e "${GREEN}$program installed successfully.${RESET}"
#     fi
# done

# Copy my custom PATH variables
cd
echo -e "${YELLOW}Copying profile...${RESET}"
sudo cp Desktop/dotfiles/others/profile /etc/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error copying profile.${RESET}"
    notify-send "Error copying profile" "There was a problem copying profile. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Profile copied successfully.${RESET}"
fi

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

# dbus-python (for configuring eduroam wifi)

# firefox
# sudo cp -r ~/Desktop/dotfiles/firefox/.mozilla ~/


# gdb = GNU debugger

# grub
# Note the following: I changed the line 

# # GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"

# with the line

# in order to mask the interupt /sys/firmware/interupt/gpe6E because it was causing many interupts when the laptop was plugged in. Now it goes like a charm! :)
# GRUB_CMDLINE_LINUX_DEFAULT="acpi_mask_gpe=0x6E loglevel=3 quiet"

sudo cp Desktop/dotfiles/others/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

# inskcape (vector graphics editor)
echo -e "${YELLOW}Configuring inkscape...${RESET}"
mkdir -p ~/.config/inkscape/

# jekyll (for my personal website)

# kdeconnect

# kde-graphics-meta
# some interesting programs for kde

# kdenlive
# missing adding config files

# krunner-vscodeprojects (for searching vscode projects with krunner)
# We need to have the extension "Project Manager" installed in vscode.

# kwalletmanager (for managing passwords)
# In order to disable the prompt for the password when logging in, go to KDE Wallet Manager -> Settings -> Configure Wallet -> uncheck "Prompt when an application accesses the wallet"

# kwin-bismuth (window tile manager for KDE)

# latte-dock (my dock for linux)

# man-db, man-pages: implement man pages on Arch

# mkinitcpio-firmware
# needed for disabling warnings when compiling the kernel
sudo cp Desktop/dotfiles/others/mkinitcpio.conf /etc/

# mpv (it's missing to copy and update the scripts in .config/mpv)
# yay -S --needed trash-cli # in order to use delete property
# yay -S --needed mediainfo # in order to use all the properties of comand-palette (source: https://github.com/stax76/mpv-scripts/tree/main)

# neofetch
sudo cp -r Desktop/dotfiles/others/neofetch ~/.config/

# ntfs-3g: for read/write acces to Microsoft NTFS partitions.

# nvidia-settings
# yay -S --noconfirm --needed nvidia nvidia-utils nvidia-settings xorg-server-devel opencl-nvidia

# pacman config
sudo cp Desktop/dotfiles/others/pacman.conf /etc/

# parmetis-git (needed for FreeFem++)

# partitionmanager (disk / partition manager for KDE)

# spotify-adblock
# sudo cp Desktop/dotfiles/others/spotify-adblock.desktop ~/.local/share/applications/

# rclone (OneDrive sync: mount at startup)
# Notes: Name the remote as "OneDrive".
#        Do not change the folder to /etc/systemd/system/ because otherwise it will compile as root and we don't want this (because we would have to change other things too).
#        If an error about fusermount is prompt, install fuse2.
cd
echo -e "${YELLOW}Installing rclone...${RESET}"
echo -e "${BLUE}Name the remote as 'OneDrive'${RESET}"
rclone config
mkdir -p ~/.config/systemd/user/
mkdir -p ~/OneDrive
sudo cp Desktop/dotfiles/others/rclone-onedrive.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now rclone-onedrive
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing rclone.${RESET}"
    notify-send "Error installing rclone" "There was a problem installing rclone. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Rclone installed successfully.${RESET}"
fi

# rsync (necessary for the backup script: https://gitlab.com/cscs/transfuse)

# rstudio-desktop

# rsync (automated backup)
# cp /usr/local/bin/syncOneDrive.sh /etc/cron.daily

# ruby (necessary for jekyll and/or my personal website)

# ruby-fusuma (for gestures, KDE gestures are not working properly by default in X11)
# sudo gpasswd -a $USER input
# newgrp input
# sudo cp -r Desktop/dotfiles/others/fusuma/config.yml ~/.config/

# sagemath
# mkdir -p ~/.sage
# sudo cp Desktop/dotfiles/sage/init.sage ~/.sage/

# copy spotify.desktop file
cd 
echo -e "${YELLOW}Configuring spotify...${RESET}"
sudo cp Desktop/dotfiles/others/spotify.desktop /usr/share/applications/
sudo mv /usr/share/applications/spotify-adblock.desktop /usr/share/applications/spotify-adblock.desktop.backup
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring spotify.${RESET}"
    notify-send "Error configuring spotify" "There was a problem configuring spotify. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Spotify configured successfully.${RESET}"
fi

# supergfxctl (for exchanging power mode: Hybrid and Integrated)
# sudo systemctl enable supergfxd.service --now
# sudo usermod -a -G users $USER

# tlp (battery management)
echo -e "${YELLOW}Configuring tlp...${RESET}"
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable tlp.service
sudo tlp start
sudo cp Desktop/dotfiles/others/tlp.conf /etc/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring tlp.${RESET}"
    notify-send "Error configuring tlp" "There was a problem configuring tlp. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Tlp configured successfully.${RESET}"
fi

# touchegg (for gestures)
echo -e "${YELLOW}Configuring touchegg...${RESET}"
sudo systemctl enable touchegg.service
sudo systemctl start touchegg
cp -r ~/Desktop/dotfiles/others/touchegg ~/.config/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring touchegg.${RESET}"
    notify-send "Error configuring touchegg" "There was a problem configuring touchegg. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Touchegg configured successfully.${RESET}"
fi


# vscode (latexindent formatter configuration)
cd 
echo -e "${YELLOW}Configuring vscode...${RESET}"
git clone git@github.com:cmhughes/latexindent.pl.git
cd latexindent.pl
sudo perl helper-scripts/latexindent-module-installer.pl
cmake path-helper-files
# TODO
# check in history if it's missing some packages that has to be installed manually
# check if all is backed up correctly from kde. Things to check: 
sudo make install
cd 
rm -rf latexindent.pl
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring vscode.${RESET}"
    notify-send "Error configuring vscode" "There was a problem configuring vscode. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Vscode configured successfully.${RESET}"
fi

# vlc
cd
echo -e "${YELLOW}Configuring vlc...${RESET}"
mkdir ~/.config/vlc/
sudo cp Desktop/dotfiles/others/vlcrc ~/.config/vlc/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring vlc.${RESET}"
    notify-send "Error configuring vlc" "There was a problem configuring vlc. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Vlc configured successfully.${RESET}"
fi

# xrandr (for changing display configuration)
cd 
echo -e "${YELLOW}Configuring xrandr...${RESET}"
sudo cp Desktop/dotfiles/others/10-monitor.conf /etc/X11/xorg.conf.d/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring xrandr.${RESET}"
    notify-send "Error configuring xrandr" "There was a problem configuring xrandr. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Xrandr configured successfully.${RESET}"
fi

# zsh 
echo -e "${YELLOW}Configuring zsh...${RESET}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo cp Desktop/dotfiles/others/.zshrc ~/
chsh -s /bin/zsh
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring zsh.${RESET}"
    notify-send "Error configuring zsh" "There was a problem configuring zsh. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Zsh configured successfully.${RESET}"
fi
echo -e "${BLUE}Remember to install Maple after rebooting.${RESET}"
# wait for 5 seconds
sleep 5
# reboot
echo -e "${YELLOW}Rebooting...${RESET}"
sleep 1
reboot
