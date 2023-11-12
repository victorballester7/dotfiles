#!/bin/bash

# ANSI escape codes for color formatting
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# .config folder (copy KDE configs files)
# rm ~/Desktop/dotfiles/config/*.tar.gz
# cd ~/Desktop
# git clone https://gitlab.com/cscs/transfuse.git
# cd transfuse
# chmod +x transfuse.sh
# ./transfuse.sh -b victor
# ./transfuse.sh -p
# cp *.tar.gz ../dotfiles/config
# cp *.txt ../dotfiles/config

echo -e "${YELLOW}Copying KDE config files...${RESET}"
yay -S --noconfirm --needed --quiet konsave
konsave -s victor-config
konsave -e victor-config -d ~/Desktop/dotfiles/config
if [ $? -eq 0 ]; then
    echo -e "${GREEN}KDE config files copied successfully!${RESET}"
else
    echo -e "${RED}Error copying KDE config files!${RESET}"
fi

# Copy current rules to rules/ folder
cd ~/Desktop/dotfiles
echo -e "${YELLOW}Copying udev rules...${RESET}"
cp /etc/udev/rules.d/* rules/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Udev rules copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Udev rules!${RESET}"
fi 

# Copy history
cd ~/Desktop/dotfiles
echo -e "${YELLOW}Copying history...${RESET}"
history > history/history.txt
if [ $? -eq 0 ]; then
    echo -e "${GREEN}History copied successfully!${RESET}"
else
    echo -e "${RED}Error copying History!${RESET}"
fi

# Git
cp ~/.gitconfig others/
echo -e "${YELLOW}Copying Git config file...${RESET}"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Git config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Git config file!${RESET}"
fi

# grub
echo -e "${YELLOW}Copying Grub config file...${RESET}"
sudo cp -f /etc/default/grub others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Grub config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Grub config file!${RESET}"
fi


# mkinitcpio.conf
echo -e "${YELLOW}Copying Mkinitcpio config file...${RESET}"
sudo cp /etc/mkinitcpio.conf others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Mkinitcpio config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Mkinitcpio config file!${RESET}"
fi

# neofetch
echo -e "${YELLOW}Copying Neofetch config file...${RESET}"
sudo cp /usr/bin/neofetch others/ 
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Neofetch config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Neofetch config file!${RESET}"
fi

# OneDrive sync
echo -e "${YELLOW}Copying OneDrive sync config file...${RESET}"
cp ~/.config/systemd/user/rclone-onedrive.service others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}OneDrive sync config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying OneDrive sync config file!${RESET}"
fi

# Pacman conf
echo -e "${YELLOW}Copying Pacman config file...${RESET}"
sudo cp /etc/pacman.conf others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Pacman config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Pacman config file!${RESET}"
fi

# qbittorrent 

# reflector
echo -e "${YELLOW}Copying Reflector config file...${RESET}"
echo -e "${BLUE}Please, remember to check that the counries are the desired ones! Last time, I used: "France,Spain,", where the last comma means the WorldWide servers.${RESET}"
sudo cp /etc/xdg/reflector/reflector.conf others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Reflector config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Reflector config file!${RESET}"
fi


# Sagemath
# cp ~/.sage/init.sage others/

# tlp (battery management)
echo -e "${YELLOW}Copying TLP config file...${RESET}"
cp /etc/tlp.conf others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}TLP config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying TLP config file!${RESET}"
fi

# vlc
echo -e "${YELLOW}Copying VLC config file...${RESET}"
cp ~/.config/vlc/vlcrc others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}VLC config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying VLC config file!${RESET}"
fi

# zsh 
echo -e "${YELLOW}Copying Zsh config file...${RESET}"
cp ~/.zshrc others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Zsh config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Zsh config file!${RESET}"
fi


# custom PATH variables
echo -e "${YELLOW}Copying Custom PATH variables config file...${RESET}"
cp /etc/profile others/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Custom PATH variables config file copied successfully!${RESET}"
else
    echo -e "${RED}Error copying Custom PATH variables config file!${RESET}"
fi