#!/bin/bash

# ANSI escape codes for color formatting
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

CONFIG_DIR=$HOME/.config
FILES_DIR=$(pwd)/others
RULES_DIR=$(pwd)/rules
MYCONFIG_DIR=$(pwd)/config
THEME_DIR=$HOME/.themes

# BETTER NOT TO USE rsync (it changes premissions)

# activate sudo rights from the beginning
sudo echo -e "${GREEN}Sudo rights activated.${RESET}"

function messagePresentation {
  echo -e "${YELLOW}Copying $1 configs...${RESET}"
}

function messageError {
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error copying $1 configs.${RESET}"
    notify-send "Error copying $1 configs" "There was a problem copying configuration files of $1. Please check the configs folder." --urgency=critical
  else
    echo -e "${GREEN}$1 configs copied successfully.${RESET}"
  fi
}
function backupHyprpanel {
    # first copy hyprpanel config form .config directory to my dotfiles just as a backup (when editing the settings from the GUI it will be saved in the .config directory)
    messagePresentation "hyprpanel"
    rm -r $MYCONFIG_DIR/hyprpanel
    cp -r $CONFIG_DIR/hyprpanel $MYCONFIG_DIR
    messageError "hyprpanel"
}

function copyThemesConfigsFolders {
    # I put themes before config just in case.
    cd themes
    for f in *; do
        # rm -r $THEME_DIR/$f
        cp -r $f $THEME_DIR
    done

    cd ../config
    for f in *; do
        # rm -r $CONFIG_DIR/$f
        cp -r $f $CONFIG_DIR
    done
}

function copyRandomFiles {
    sudo mkdir -p $HOME/.oh-my-zsh/custom/ && sudo cp -r $FILES_DIR/oh-my-zsh/custom/* $HOME/.oh-my-zsh/custom/

    cp $FILES_DIR/.zshrc $HOME
    # cp $FILES_DIR/.p10k.zsh $HOME
    cp $FILES_DIR/.aliases $HOME
    cp $FILES_DIR/.vars $HOME
    sudo cp $FILES_DIR/grub /etc/default/
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    sudo cp $FILES_DIR/pacman.conf /etc/
    sudo cp $FILES_DIR/reflector.conf /etc/xdg/reflector/
    sudo cp $FILES_DIR/sudoers /etc/
    sudo cp $FILES_DIR/tlp.conf /etc/
}

function copySpotify {
    messagePresentation "spotify"
    sudo cp $FILES_DIR/spotify-adblock.desktop /usr/share/applications/
    sudo rm -f /usr/share/applications/spotify.desktop
    messageError "spotify"
}

function copyPath {
    # Copy my custom PATH variables
    messagePresentation "profile"
    sudo cp $FILES_DIR/profile /etc/
    messageError "profile"
}

function copyRules {
    # Copy rules (that will be executed at the startup of the system):
    messagePresentation "rules"
    sudo cp $RULES_DIR/* /etc/udev/rules.d/
    messageError "rules"
}


backupHyprpanel

copyThemesConfigsFolders

copyRandomFiles

copySpotify

copyPath

copyRules

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
# hyprctl reload # gives problems with win key and also inhabilitates the shortcuts

echo -e "${GREEN}All configurations copied successfully.${RESET}"

