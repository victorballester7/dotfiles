sudo pacman -Syyu

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd Desktop/dotfiles/gnome-settings
./gnome-look.sh

cd Desktop/dotfiles

# Git
cp git/.gitconfig ~/

# OneDrive sync
# cp onedrive_sync/config ~/.config/onedrive/

# terminal 
cp ~/.bashrc terminal/