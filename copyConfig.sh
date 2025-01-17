#!/bin/bash

# ANSI escape codes for color formatting
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"


CONFIG_DIR=$HOME/.config
FILES_DIR=$(pwd)/others
MYCONFIG_DIR=$(pwd)/config
THEME_DIR=$HOME/.themes

# BETTER NOT TO USE rsync (it changes premissions)

# first copy hyprpanel config form .config directory to my dotfiles just as a backup (when editing the settings from the GUI it will be saved in the .config directory)
echo -e "${YELLOW}Copying hyprpanel config...${RESET}"
rm -r $MYCONFIG_DIR/hyprpanel
cp -r $CONFIG_DIR/hyprpanel $MYCONFIG_DIR
if [ $? -ne 0 ]; then
    echo -e "${RED}Error copying hyprpanel config.${RESET}"
    notify-send "Error copying hyprpanel config" "There was a problem copying hyprpanel config. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Hyprpanel config copied successfully.${RESET}"
fi


# I put themes before config just in case.
cd themes

for f in *; do
    rm -r $THEME_DIR/$f
    cp -r $f $THEME_DIR
  # rsync -az $f $THEME_DIR
done

cd ../config

for f in *; do
    rm -r $CONFIG_DIR/$f
    cp -r $f $CONFIG_DIR
  # rsync -az $f $CONFIG_DIR
done


sudo mkdir -p $HOME/.oh-my-zsh/custom/ && sudo rsync -az $FILES_DIR/oh-my-zsh/custom/* $HOME/.oh-my-zsh/custom/

rsync -az $FILES_DIR/.zshrc $HOME
sudo cp $FILES_DIR/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo cp $FILES_DIR/pacman.conf /etc/
sudo cp $FILES_DIR/reflector.conf /etc/xdg/reflector/
sudo cp $FILES_DIR/sudoers /etc/
sudo cp $FILES_DIR/tlp.conf /etc/

# copy spotify.desktop file
cd
echo -e "${YELLOW}Configuring spotify...${RESET}"
sudo cp $FILES_DIR/spotify-adblock.desktop /usr/share/applications/
sudo rm -f /usr/share/applications/spotify.desktop
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring spotify.${RESET}"
    notify-send "Error configuring spotify" "There was a problem configuring spotify. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Spotify configured successfully.${RESET}"
fi

# Copy my custom PATH variables
cd
echo -e "${YELLOW}Copying profile...${RESET}"
sudo cp $FILES_DIR/profile /etc/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error copying profile.${RESET}"
    notify-send "Error copying profile" "There was a problem copying profile. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Profile copied successfully.${RESET}"
fi

# Copy rules (that will be executed at the startup of the system):
cd
echo -e "${YELLOW}Copying rules...${RESET}"
sudo cp $FILES_DIR/../rules/* /etc/udev/rules.d/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error copying rules.${RESET}"
    notify-send "Error copying rules" "There was a problem copying rules. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Rules copied successfully.${RESET}"
fi



# tlp (battery management)
# echo -e "${YELLOW}Configuring tlp...${RESET}"
# systemctl mask systemd-rfkill.service
# systemctl mask systemd-rfkill.socket
# systemctl enable tlp.service
# sudo tlp start
# sudo cp Desktop/dotfiles/others/tlp.conf /etc/
# if [ $? -ne 0 ]; then
#     echo -e "${RED}Error configuring tlp.${RESET}"
#     notify-send "Error configuring tlp" "There was a problem configuring tlp. Please check the installation process." --urgency=critical
# else
#     echo -e "${GREEN}Tlp configured successfully.${RESET}"
# fi

${CONFIG_DIR}/hypr/scripts/get_bing_image.sh

sleep 1
# reload hyprctl and gtk configs
gsettings set org.gnome.desktop.interface gtk-theme victorballester7
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
hyprctl reload

echo 'Done!'

