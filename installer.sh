#!/bin/zsh

trap "exit" INT

function check_req {
  command -v "$@" >/dev/null 2>&1
}

typeset -a needed_req=(
  curl
  git
  rustup
  yarn
  zsh
)

typeset -a shell_req=(
  bat
  dust
  kitty
  ripgrep
  ttf-cascadia-mono-nerd
  ttf-nerd-fonts-symbols
  zathura
  zathura-djvu
  zathura-pdf-mupdf
)

typeset -a nvim_req=(
  bat
  fswatch
  luarocks
  neovim
  python-pynvim
  ripgrep
  tree-sitter
  tree-sitter-cli
)

typeset -a hypr_req=(
  brightnessctl
  gammastep
  gnome-power-manager
  gnome-system-monitor
  hyprcursor-git
  hypridle-git
  hyprland-git
  hyprpaper-git
  hyprshot-git
  hyprutils-git
  light
  mako
  nwg-wrapper
  pavucontrol
  python
  python-pywal
  python-pywalfox
  rofi-calc-git
  rofi-wayland
  sddm-git
  sway-audio-idle-inhibit-git
  thunar
  thunar-archive-plugin
  thunar-volman
  waybar
  wl-clipboard
  wlr-randr
wlogout
  xdg-desktop-portal-hyprland-git
)

typeset -a other_packages=(
  android-sdk-platform-tools
  bibclean
  biber
  chromium
  clang
  firefox
  fzf
  gcc
  gdb
  libreoffice-fresh
  linux-zen
  linux-zen-headers
  make
  man-db
  man-pages
  python-pandas
  python-matplotlib
  reflector
  spotify
  spotify-adblock
  texlive-full
  thunderbird
  unrar
  unzip
)

# Git + Github keys
cd
echo -e "${YELLOW}Installing and configuring git...${RESET}"
sudo pacman -S --noconfirm --needed --quiet git
cp Desktop/dotfiles/others/.gitconfig ~/
echo -e "${BLUE}Press enter when promted to 'Enter a file in which to save the key', and in 'add passphrase'${RESET}"
ssh-keygen -t ed25519 -C "victor.ballester.ribo@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo -e "${BLUE}Now copy the following key to your Github account in Settings/Access/Ssh keys...${RESET}"
cat ~/.ssh/id_ed25519.pub
echo -e "${BLUE}Press enter to continue once copied the key to Github${RESET}"
read ans
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing and configuring git.${RESET}"
    notify-send "Error installing and configuring git" "There was a problem installing and configuring git. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Git installed and configured successfully.${RESET}"
fi

# yay (AUR helper)
cd
echo -e "${YELLOW}Installing yay...${RESET}"
sudo pacman -S --noconfirm --needed --quiet base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing yay.${RESET}"
    notify-send "Error installing yay" "There was a problem installing yay. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Yay installed successfully.${RESET}"
fi

# needed stuff
if ! check_req yay; then
  echo "Make sure you have yay installed!"
  return 1
fi

# setup yay and upgrade all packages
yay -Syyuu

# important stuff
yay -S --noconfirm --needed "${needed_req[@]}"

# shell requirements
yay -S --noconfirm --needed "${shell_req[@]}"

# neovim requirements
yay -S --noconfirm --needed "${nvim_req[@]}"
yarn global add neovim

# hyprland requirements
yay -S --noconfirm --needed "${hypr_req[@]}"

# other packages
yay -S --noconfirm --needed "${other_packages[@]}"

# # install ohmyzsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "Installation completed!"

systemctl enable sddm.service

# configure zsh
echo -e "${YELLOW}Configuring zsh...${RESET}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo cp Desktop/dotfiles/others/.zshrc ~/
# change to zsh default shell
if [[ ! $SHELL =~ zsh$ ]]; then
  echo "Changing default shell"
  chsh -s /bin/zsh
fi
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring zsh.${RESET}"
    notify-send "Error configuring zsh" "There was a problem configuring zsh. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Zsh configured successfully.${RESET}"
fi

cd
echo -e "${YELLOW}Configuring reflector...${RESET}"
sudo cp Desktop/dotfiles/others/reflector.conf /etc/xdg/reflector/
sudo systemctl enable reflector.timer # in order to run reflector weekly instead of at each boot
sudo systemctl start reflector.timer
sudo systemctl enable reflector.service
sudo systemctl start reflector.service
if [ $? -ne 0 ]; then
    echo -e "${RED}Error configuring reflector.${RESET}"
    notify-send "Error configuring reflector" "There was a problem configuring reflector. Please check the installation process." --urgency=critical
else
    echo -e "${GREEN}Reflector configured successfully.${RESET}"
fi

echo "Copying config files..."
./copyConfig.sh
echo "You may want to reboot your computer!"
