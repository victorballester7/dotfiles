main_dir=$(pwd) # initial path working directory

# cursors theme
sudo pacman -S xorg-xcursorgen python-cairosvg # required dependencies
git clone git@github.com:vinceliuice/Vimix-cursors.git
cd Vimix-cursors
./install.sh
cd "main_dir"
rm -rf Vimix-cursors


# gtk-theme
sudo pacman -S gtk-engine-murrine sassc
git clone git@github.com:vinceliuice/Colloid-gtk-theme.git
cd Colloid-gtk-theme
./install.sh
cd "main_dir"
rm -rf Colloid-gtk-theme


# icons
git clone git@github.com:bikass/kora.git
cd kora
cp -r kora/ kora-light/ kora-light-panel/ kora-pgrey/ ~/.local/share/icons/
cd "main_dir"
rm -rf kora
