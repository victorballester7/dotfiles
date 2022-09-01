# update & upgrade
sudo pacman -Syyu

# Remove Gnome-games
sudo apt purge gnome-2048 aisleriot atomix gnome-chess five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex -y & sudo apt autoremove -y



# Firefox: enter username and password

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf

# Git
cp git/.gitconfig ~/

# Vscode: enter username and password

# OneDrive sync
cp onedrive_sync/config ~/.config/onedrive/