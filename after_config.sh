# update & upgrade
sudo pacman -Syyu

# Remove Gnome-games
sudo pacman -R gnome-2048 aisleriot atomix gnome-chess five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex -y


# Firefox: enter username and password

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf
cp -r ~/Desktop/dotfiles/gnome-settings/extensions ~/.local/share/gnome-shell/ 
cd Desktop/dotfiles/gnome-settings
./gnome-look.sh


# paru (AUR helper)
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru

cd Desktop/dotfiles

# Git
cp git/.gitconfig ~/

# Installation of programs

cd 
paru -S visual-studio-code-bin vlc kdenlive jupyter-notebook sagemath qbittorrent gimp  	libreoffice-fresh

# OneDrive sync
# cp onedrive_sync/config ~/.config/onedrive/

# terminal (oh my bash)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
cp terminal/.bashrc ~/