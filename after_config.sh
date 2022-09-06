# update & upgrade
sudo pacman -Syyu

# Remove Gnome-games
sudo pacman -R gnome-2048 aisleriot atomix gnome-chess five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex -y


# Firefox: enter username and password

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf

cd Desktop/dotfiles

# Git
cp git/.gitconfig ~/

# Vscode: installation. Then enter username and password to restore your settings
git clone https://AUR.archlinux.org/visual-studio-code-bin.git
cd visual-studio-code-bin/
makepkg -s
sudo pacman -U visual-studio-code-bin-*.pkg.tar.zst
cd ../ && sudo rm -rfv visual-studio-code-bin/

# OneDrive sync
# cp onedrive_sync/config ~/.config/onedrive/

# terminal (oh my bash)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
cp terminal/.bashrc ~/