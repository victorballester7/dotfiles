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

function messagePresentation {
  echo -e "${YELLOW}Installing and configuring $1...${RESET}"
}

function messageError {
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error installing and configuring $1.${RESET}"
    notify-send "Error installing and configuring $1" "There was a problem installing and configuring $1. Please check the installation process." --urgency=critical
  else
    echo -e "${GREEN}$1 installed and configured successfully.${RESET}"
  fi
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
  ags-hyprpanel-git
  hyprcursor-git
  hypridle
  hyprland
  hyprland-monitor-attached
  hyprland-protocols
  hyprlock
  hyprpaper
  hyprshot
  hyprsunset-git
  hyprswitch
  hyprutils-git
  xdg-desktop-portal-hyprland
)

typeset -a hypr_req=(
  baobab
  blueman
  brightnessctl
  gammastep
  gitprompt
  gnome-power-manager
  gnome-system-monitor
  gvfs
  gvfs-mtp
  gvfs-gphoto2
  light
  nwg-wrapper
  pavucontrol
  playerctl
  python
  ranger
  rofi-calc-git
  rofi
  socat
  sway-audio-idle-inhibit-git
  thunar
  thunar-archive-plugin
  thunar-volman
  tlp
  tzupdate
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
  bc
  bibclean
  biber
  chromium
  clang
  dbus-python
  firefox
  fzf
  gcc
  gdb
  gimp
  gnuplot
  imagemagick
  libreoffice-fresh
  linux-zen
  linux-zen-headers
  lsd
  make
  man-db
  man-pages
  mpv
  fastfetch
  pass
  python-pandas
  python-matplotlib
  python-pyquery
  rclone
  reflector
  spotify
  spotify-adblock
  sshfs
  sshpass
  teams-for-linux
  teams-for-linux-wayland-hook
  texlive-full
  thunderbird
  trash-cli
  unrar
  unzip
  uv
  vimix-cursors
  zoxide
)

function configGit {
  # Git + Github keys
  cd
  messagePresentation "git"
  sudo pacman -S --noconfirm --needed --quiet git
  echo -e "${BLUE}Press enter when promted to 'Enter a file in which to save the key', and in 'add passphrase'${RESET}"
  ssh-keygen -t ed25519 -C "victor.ballester.ribo@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  echo -e "${BLUE}Now copy the following key to your Github account in Settings/Access/Ssh keys...${RESET}"
  cat ~/.ssh/id_ed25519.pub
  echo -e "${BLUE}Press enter to continue once copied the key to Github${RESET}"
  read ans
  messageError "git"

  # Git config
  git config --global user.name "Victor Ballester Ribo"
  git config --global user.email "victor.ballester.ribo@gmail.com"
}

function configureYay {
  # yay (AUR helper)
  cd
  messagePresentation "yay"
  sudo pacman -S --noconfirm --needed --quiet base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ..
  rm -rf yay
  messageError "yay"
}


function configureReflector {
  cd
  messagePresentation "reflector"
  sudo cp dotfiles/others/reflector.conf /etc/xdg/reflector/
  sudo systemctl enable reflector.timer # in order to run reflector weekly instead of at each boot
  sudo systemctl start reflector.timer
  sudo systemctl enable reflector.service
  sudo systemctl start reflector.service
  messageError "reflector"
}

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

function configureBluetooth {
  # configure blueman
  messagePresentation "bluetooth"
  sudo systemctl enable bluetooth.service
  sudo systemctl start bluetooth.service
  messageError "bluetooth"
}

function configureRclone {
  # rclone
  cd
  messagePresentation "rclone"
  echo -e "${BLUE}Name the remote as 'OneDrive'${RESET}"
  rclone config
  mkdir -p ~/.config/systemd/user/
  mkdir -p ~/OneDrive
  sudo cp Desktop/dotfiles/others/rclone-onedrive.service ~/.config/systemd/user/
  systemctl --user daemon-reload
  systemctl --user enable --now rclone-onedrive
  messageError "rclone"
}

function configureTLP {
  # tlp
  cd
  messagePresentation "tlp"
  sudo systemctl enable tlp.service
  sudo systemctl start tlp.service
  messageError "tlp"
}

function configureZsh {
  # configure zsh
  cd
  messagePresentation "zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
  sudo cp dotfiles/others/.zshrc ~/
  # change to zsh default shell
  if [[ ! $SHELL =~ zsh$ ]]; then
    echo "Changing default shell"
    chsh -s /bin/zsh
  fi
  messageError "zsh"
}

function configureLoginTTY {
  sudo systemctl set-default multi-user.target
  sudo systemctl daemon-reexec
}

# Function to check if packages are installed and display status
function check_packages() {
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

configGit
configureYay

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
# remove directories aquamarine, otherwise it will fail to install all the packages "hyprSomething-git"
sudo rm -rf /usr/include/aquamarine/ /usr/lib/libaquamarine.so* /usr/lib/pkgconfig/aquamarine.pc /usr/share/licenses/aquamarine/

yay -S --needed "${hypr_conf[@]}"
yay -S --noconfirm --needed "${hypr_req[@]}"

# other packages
yay -S --noconfirm --needed "${other_packages[@]}"

# # install ohmyzsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "Installation completed!"

configureReflector
configureBluetooth
configureRclone
configureTLP

echo "Copying config files..."
./copyConfig.sh
configureLoginTTY
echo "You may want to reboot your computer!"

echo "Checking installation..."

# Check each group
check_packages "needed_req" needed_req
check_packages "shell_req" shell_req
check_packages "nvim_req" nvim_req
check_packages "hypr_conf" hypr_conf
check_packages "hypr_req" hypr_req
check_packages "other_packages" other_packages

configureZsh

