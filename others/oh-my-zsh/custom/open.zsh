# Description: Opens a file using the default application.

open() {
  if [[ -z "$1" ]]; then
    echo "Usage: open <file>"
    return 1
  fi

  case "$1" in
    *.ods|*.odt|*.odp)
      libreoffice "$1" >/dev/null 2>&1 & disown
      ;;
    *)
      xdg-open "$1" >/dev/null 2>&1 & disown
      ;;
  esac
}


