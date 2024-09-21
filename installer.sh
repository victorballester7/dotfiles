#!/bin/zsh

###############################################
# EXECUTE THIS SCRIPT FROM THE home DIRECTORY #
###############################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

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
  npm
  python-pynvim
  ripgrep
  tree-sitter
  tree-sitter-cli
)

typeset -a hypr_conf=(
  hyprcursor-git
  hypridle-git
  hyprland-git
  hyprpaper-git
  hyprshot-git
  hyprutils-git
  xdg-desktop-portal-hyprland-git
  sddm-git
  texlive-full
)

typeset -a hypr_req=(
  brightnessctl
  gammastep
  gnome-power-manager
  gnome-system-monitor
  gvfs
  light
  mako
  nwg-wrapper
  pavucontrol
  python
  python-pywal
  python-pywalfox
  rofi-calc-git
  rofi-wayland
  sway-audio-idle-inhibit-git
  thunar
  thunar-archive-plugin
  thunar-volman
  waybar
  wl-clipboard
  wlr-randr
  wlogout
  xarchiver
)

typeset -a other_packages=(
  acestream-engine
  acestream-launcher
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
  mpv-git
  neofetch
  python-pandas
  python-matplotlib
  python-pyquery
  reflector
  spotify
  spotify-adblock
  thunderbird
  trash-cli
  unrar
  unzip
  vimix-cursors
)

# Git + Github keys
cd
echo -e "${YELLOW}Installing and configuring git...${RESET}"
sudo pacman -S --noconfirm --needed --quiet git
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

rustup default stable # in order to install properly spotify-adblock

# neovim requirements
yay -S --noconfirm --needed "${nvim_req[@]}"
yarn global add neovim

# hyprland requirements
yay -S --needed "${hypr_conf[@]}"
yay -S --noconfirm --needed "${hypr_req[@]}"

# other packages
yay -S --noconfirm --needed "${other_packages[@]}"

# # install ohmyzsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "Installation completed!"

# systemctl enable sddm.service

# configure zsh
echo -e "${YELLOW}Configuring zsh...${RESET}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo cp dotfiles/others/.zshrc ~/
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
sudo cp dotfiles/others/reflector.conf /etc/xdg/reflector/
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

# copy thunderbird profile
# echo -e "${YELLOW}Copying Thunderbird profile...${RESET}"
# cp -r 
# mkdir -p .thunderbird
# sudo cp -r dotfiles/others/*.default-release .thunderbird/
# if [ $? -ne 0 ]; then
#     echo -e "${RED}Error copying Thunderbird profile.${RESET}"
#     notify-send "Error copying Thunderbird profile" "There was a problem copying Thunderbird profile. Please check the installation process." --urgency=critical
# else
#     echo -e "${GREEN}Thunderbird profile copied successfully.${RESET}"
# fi


echo "Copying config files..."
./copyConfig.sh
echo "You may want to reboot your computer!"

echo "Checking installation..."

# Function to check if packages are installed and display status
check_packages() {
  local group_name=$1
  local packages=$2  # Use nameref to pass the array by reference

  echo -e "\nChecking group: ${group_name}"
  eval "local package_array=(\"\${${packages}[@]}\")"
  for package in "${package_array[@]}"; do
    if pacman -Qi $package &> /dev/null; then
      echo -e "${GREEN}$package is installed${RESET}"
    else
      echo -e "${RED}$package is NOT installed${RESET}"
    fi
  done
}

# Check each group
check_packages "needed_req" needed_req
check_packages "shell_req" shell_req
check_packages "nvim_req" nvim_req
check_packages "hypr_conf" hypr_conf
check_packages "hypr_req" hypr_req
check_packages "other_packages" other_packages
