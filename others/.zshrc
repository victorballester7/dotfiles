# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export LC_ALL=en_US.UTF-8

ZSH_THEME="victorballester7"
# ZSH_THEME="victorballester7_ssh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 5

plugins=(
  git
  history
  sudo
  ssh
  zsh-autosuggestions
  zsh-history-substring-search
  fzf
)

source $ZSH/oh-my-zsh.sh

# Use nvim for man pages
export MANPAGER='nvim +Man!'

# For fzf (fuzzy finding)
export FZF_DEFAULT_OPTS_FILE="/home/victor/.config/fzf/config"

# for gnome applications to work
export GSK_RENDERER='ngl'

# My custom keymaps
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# My custom PATH
source $HOME/.path

# My custom aliases taken from a file
source $HOME/.aliases

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# add exported colors to the shell
source $HOME/.config/hypr/wallpapers/colors.sh

colorASCII="38;2;$r;$g;$b"

# neofetch
fastfetch --logo-color-1 $colorASCII --logo-color-2 $colorASCII --color-keys $colorASCII --color-title $colorASCII
