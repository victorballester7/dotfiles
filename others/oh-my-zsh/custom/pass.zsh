# Description: Zsh function to show metadata at the same time as copying a password to the clipboard using pass

function pass() {
  if [[ "$1" == "-c" && -n "$2" ]]; then
    command pass -c "$2" && command pass show "$2" | tail -n +2
  else
    command pass "$@"
  fi
}

