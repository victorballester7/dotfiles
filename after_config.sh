#!/bin/bash

# Remember to previously install firefox and git and reboot at the end.


# update & upgrade
sudo pacman -Syyu

# scripts
cd Desktop/dotfiles
chmod +x move_scripts.sh
./move_scripts 

# Remove Gnome-games
sudo pacman -Rsu gnome-books gnome-boxes gedit vim -y


# Git + Github keys
sudo pacman -S --needed git
cp git/.gitconfig ~/
echo "Press enter when promted to 'Enter a file in which to save the key', and in 'add passphrase'"
ssh-keygen -t ed25519 -C "victor.ballester.ribo@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "Now copy the following key to your Github account in Settings/Access/Ssh keys..."
cat ~/.ssh/id_ed25519.pub


# Gnome (and gnome-tweaks) settings
sudo pacman -S --needed gnome-browser-connector
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf
cp -r ~/Desktop/dotfiles/gnome-settings/extensions ~/.local/share/gnome-shell/ 
cd Desktop/dotfiles/gnome-settings
chmod +x gnome-look.sh
./gnome-look.sh


# paru (AUR helper)
sudo pacman -S --noconfirm --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru

# Installation of programs

cd 
paru -S --noconfirm --needed autorandr gcc gimp jupyter-notebook kdenlive libreoffice-fresh neofetch ntfs-3g python qbittorrent rclone sagemath tlp teams-for-linux texlive-most visual-studio-code-bin vlc zsh 

# autorandr: for automatically change monitor display configuration (https://github.com/phillipberndt/autorandr)

# firefox
sudo cp -r ~/Desktop/dotfiles/firefox/.mozilla ~/

# grub
sudo cp Desktop/dotfiles/grub/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

# kdenlive
# add config files
paru -S breeze # for colors

# neofetch
sudo cp Desktop/dotfiles/neofetch/neofetch /usr/bin/

# nvidia-settings
paru -S --noconfirm --needed nvidia nvidia-utils nvidia-settings xorg-server-devel opencl-nvidia

# rclone (OneDrive sync: mount at startup)
rclone config
mkdir -p ~/.config/systemd/user/
mkdir -p ~/OneDrive
sudo cp Desktop/dotfiles/onedrive_sync/rclone-onedrive.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now rclone-onedrive

# sagemath
mkdir -p ~/.sage
sudo cp Desktop/dotfiles/sage/init.sage ~/.sage/

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


# to change between power modes (integrated, hybrid, nvidia)
# paru -S envycontrol