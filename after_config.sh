#!/bin/bash
# update & upgrade
sudo pacman -Syyu

# Remove Gnome-games
sudo pacman -Rs gnome-2048 aisleriot atomix gnome-chess five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex gnome-books gnome-boxes gedit vim -y


# Firefox: enter username and password

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf
cp -r ~/Desktop/dotfiles/gnome-settings/extensions ~/.local/share/gnome-shell/ 
cd Desktop/dotfiles/gnome-settings
./gnome-look.sh


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

# Installation of programs

cd 
paru -S --noconfirm --needed autorandr gimp jupyter-notebook kdenlive libreoffice-fresh neofetch qbittorrent sagemath rclone tlp teams-for-linux visual-studio-code-bin vlc zsh

# autorandr: for automatically change monitor display configuration (https://github.com/phillipberndt/autorandr)

# grub
sudo cp Desktop/dotfiles/grub/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

# rclone (OneDrive sync: mount at startup)
cp Desktop/dotfiles/onedrive_sync/rclone-onedrive.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now rclone-dropbox

# sagemath
cp Desktop/dotfiles/sage/init.sage ~/.sage/

# tlp (battery management)
cp Desktop/dotfiles/tlp/tlp.conf /etc/

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
cp Desktop/dotfiles/vlc/vlcrc ~/.config/vlc/

# zsh 
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
cp Desktop/dotfiles/terminal/.zshrc ~/






# graphics nvidia-intel
# see 1) https://wiki.archlinux.org/title/NVIDIA_Optimus
#     2) https://wiki.archlinux.org/title/PRIME#PRIME_render_offload
#     3) https://github.com/Askannz/optimus-manager

# # Once configured optimus-manager, add this to the grub menu if desired:
# git clone https://github.com/hakasapl/optimus-manager-grub.git && cd optimus-manager-grub
# sudo ./install.sh --uninstall
# sudo grub-mkconfig -o /boot/grub/grub.cfg
# cd ..
# rm -rf optimus-manager-grub