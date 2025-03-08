# Explanation:
# PROMPT: The left-hand side of the prompt.
PROMPT='%F{2}$(_pwd_short)%f %B%F{4}[%f%b '
# %F{2}: Sets the text color (green in this case).
# $(_pwd_short): Calls the _pwd_short function to display a shortened version of the current path.
# %f: Resets the text color.
# %B / %b: Starts and ends bold text.
# %F{4}[ ... %f: Displays a blue [, preparing to close it in RPROMP

# RPROMPT: The right-hand side of the prompt.
RPROMPT='$(gitprompt zsh) %B%F{4}]%f %(?:%F{6}:%F{1})%T%f%b'
# $(gitprompt zsh): Displays Git status if inside a Git repository.
# %B%F{4}]%f%b: Closes the [ ... ] with blue ] and resets formatting.
# %(?:%F{6}:%F{1}):
#     ? checks the exit status of the last command:
#         Success: %F{6} (cyan).
#         Failure: %F{1} (red).
# %T: Displays the current time.

ZSH_GIT_PROMPT_SHOW_STASH=1
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_SEPARATOR=" "
ZSH_THEME_GIT_PROMPT_DETACHED="%F{5}:"
ZSH_THEME_GIT_PROMPT_BRANCH="%F{3}"
ZSH_THEME_GIT_PROMPT_STAGED="%F{4}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{1}✖"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%F{1}✚"
ZSH_THEME_GIT_PROMPT_BEHIND="%F{3}|↓"
ZSH_THEME_GIT_PROMPT_AHEAD="%F{3}|↑"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{4}…"
ZSH_THEME_GIT_PROMPT_STASHED="%F{4}⚑"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{2}✓"


function _pwd_short {
  if [[ $PWD == "$HOME" ]]; then
    echo -n "~"
  else
    echo -n ${${${:-/${(j:/:)${(M)${(s:/:)${(D)PWD:h}}#(|.)[^.]##}}/${PWD:t}}//\/~/\~}/\/\//\/}
  fi
}


# vim: ft=zsh
