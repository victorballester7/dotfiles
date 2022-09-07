sudo pacman -Syyu

# Gnome (and gnome-tweaks) settings
# To copy settings: dconf dump / > Desktop/dotfiles/gnome-settings/saved_settings.dconf
cd ~
dconf load / < Desktop/dotfiles/gnome-settings/saved_settings.dconf
cp -r ~/.local/share/gnome-shell/extensions ~/Desktop/dotfiles/gnome-settings

cd Desktop/dotfiles

# Git
cp ~/.gitconfig  git/

# OneDrive sync
# cp onedrive_sync/config ~/.config/onedrive/

# terminal 
cp ~/.bashrc terminal/