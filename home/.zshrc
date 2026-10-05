# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export LC_ALL=en_US.UTF-8

# My own oh-my-zsh custom functions live in the dotfiles (stowed to ~/.config/zsh/custom)
ZSH_CUSTOM="$HOME/.config/zsh/custom"

# powerlevel10k is sourced directly below (installed by install.sh), not through oh-my-zsh
ZSH_THEME=""

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

# order is important, do not change it unless you know what you are doing
plugins=(
  git
  history
  sudo
  ssh
  fzf
  zbell
)


source $ZSH/oh-my-zsh.sh

# Third-party plugins (pacman: zsh-autosuggestions, zsh-history-substring-search) and the
# powerlevel10k prompt (cloned by install.sh). Missing ones are skipped so the shell still starts.
for _f in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh \
  "${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k/powerlevel10k.zsh-theme"; do
  [[ -r $_f ]] && source $_f || print -u2 "zshrc: missing $_f (run ./install.sh shell)"
done
unset _f

# My custom keymaps
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[^?" backward-kill-word
bindkey "^[[3;3~" kill-word

# My custom variables and PATH
source $HOME/.vars

# My custom aliases taken from a file
source $HOME/.aliases

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Set up zoxide for directory navigation
eval "$(zoxide init zsh)"
####################################
# For fastfetch configuration
# add exported colors to the shell
# source $HOME/.config/hypr/wallpapers/colors.sh

# colorASCII="38;2;$r;$g;$b"

# fastfetch --logo-color-1 $colorASCII --logo-color-2 $colorASCII --color-keys $colorASCII --color-title $colorASCII
####################################

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
