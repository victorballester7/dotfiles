#!/usr/bin/env bash
# Dotfiles installer. Every step is idempotent: re-running it only changes what differs.
#
#   ./install.sh                 run everything (fresh install)
#   ./install.sh link            symlink home/ into $HOME (what copyConfig.sh used to do)
#   ./install.sh <step> ...      run only some steps
#   ./install.sh packages latex  install only some package groups (packages/<group>.txt)
#   ./install.sh check           report drift (packages, links, /etc files)
#
# Steps: ssh packages shell link system services check

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(cat /etc/hostname 2>/dev/null || hostname)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Package groups installed by default (optional.txt is opt-in)
DEFAULT_GROUPS=(base shell desktop dev apps latex nektar)

# Directories that must stay real directories in $HOME. Their children get symlinked
# (whole sub-directories at once), so files apps create here never end up in the repo.
NOFOLD=(
  .config .config/systemd .config/systemd/user
  .local .local/bin .local/share .local/share/applications .local/share/themes
  .ssh
)

RED='\e[31m' GREEN='\e[32m' YELLOW='\e[33m' BLUE='\e[34m' RESET='\e[0m'
step() { echo -e "\n${BLUE}==> $*${RESET}"; }
info() { echo -e "${GREEN}  $*${RESET}"; }
warn() { echo -e "${YELLOW}  ! $*${RESET}"; }
die()  { echo -e "${RED}  x $*${RESET}" >&2; exit 1; }

# Packages listed in the given group files, without comments/blank lines
read_packages() {
  local g
  for g in "$@"; do
    [[ -f $REPO/packages/$g.txt ]] || die "no package group '$g' (see packages/)"
    sed -e 's/#.*//' -e 's/[[:space:]]//g' "$REPO/packages/$g.txt" | grep -v '^$' || true
  done
}

# --------------------------------------------------------------------------- ssh
do_ssh() {
  step "SSH key for GitHub"
  if [[ -f $HOME/.ssh/id_ed25519 ]]; then
    info "~/.ssh/id_ed25519 already exists"
  else
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$(git config --file "$REPO/home/.gitconfig" user.email)" -f "$HOME/.ssh/id_ed25519"
    echo -e "${BLUE}Add this key to GitHub (Settings > SSH and GPG keys):${RESET}"
    cat "$HOME/.ssh/id_ed25519.pub"
    read -rp "Press enter once it is added... "
  fi
  # Repo cloned over https on a fresh machine: switch to ssh so it can be pushed
  local url
  url="$(git -C "$REPO" remote get-url origin 2>/dev/null || true)"
  if [[ $url == https://github.com/* ]]; then
    git -C "$REPO" remote set-url origin "git@github.com:${url#https://github.com/}"
    info "origin switched to ssh"
  fi
}

# ---------------------------------------------------------------------- packages
ensure_yay() {
  command -v yay >/dev/null && return
  info "installing yay"
  sudo pacman -S --needed --noconfirm base-devel git
  local tmp
  tmp="$(mktemp -d)"
  git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
}

do_packages() {
  local groups=("$@")
  ((${#groups[@]})) || groups=("${DEFAULT_GROUPS[@]}")
  step "Packages: ${groups[*]}"
  ensure_yay
  # spotify-adblock and other AUR builds need a rust toolchain
  if command -v rustup >/dev/null && ! rustup default >/dev/null 2>&1; then
    rustup default stable
  fi
  local pkgs
  mapfile -t pkgs < <(read_packages "${groups[@]}")
  yay -Syu --needed --noconfirm "${pkgs[@]}"
}

# ------------------------------------------------------------------------- shell
do_shell() {
  step "Shell (oh-my-zsh, powerlevel10k, default shell)"
  if [[ -d $HOME/.oh-my-zsh ]]; then
    info "oh-my-zsh already installed"
  else
    # --keep-zshrc: never overwrite the stowed ~/.zshrc; RUNZSH=no: don't drop into a new shell
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  fi

  local p10k="${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"
  if [[ -d $p10k/.git ]]; then
    git -C "$p10k" pull --ff-only --quiet && info "powerlevel10k updated"
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k"
  fi

  if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
    chsh -s /usr/bin/zsh
  fi
}

# -------------------------------------------------------------------------- link
# Everything stow will create a symlink for: children of NOFOLD dirs that aren't NOFOLD themselves
link_units() {
  local pkg=$1 d entry rel
  for d in "" "${NOFOLD[@]}"; do
    [[ -d $pkg/$d ]] || continue
    for entry in "$pkg/${d:+$d/}".[!.]* "$pkg/${d:+$d/}"*; do
      [[ -e $entry ]] || continue
      rel="${entry#"$pkg"/}"
      [[ " ${NOFOLD[*]} " == *" $rel "* ]] && continue
      echo "$rel"
    done
  done
}

do_link() {
  step "Linking dotfiles into $HOME"
  command -v stow >/dev/null || die "stow is not installed (sudo pacman -S stow)"

  local pkgs=(home) pkg rel target d
  [[ -d $REPO/private ]] && pkgs+=(private)

  for d in "${NOFOLD[@]}"; do
    # A previous run may have folded one of these into a single symlink: unfold it
    [[ -L $HOME/$d ]] && rm "$HOME/$d"
    mkdir -p "$HOME/$d"
  done
  chmod 700 "$HOME/.ssh"

  # Move whatever is in the way (old copies from copyConfig.sh) to the backup dir
  for pkg in "${pkgs[@]}"; do
    while read -r rel; do
      target="$HOME/$rel"
      if [[ -L $target ]]; then
        [[ $(readlink -f "$target") == "$REPO/$pkg/$rel" ]] && continue
      elif [[ ! -e $target ]]; then
        continue
      fi
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
      warn "moved existing ~/$rel to $BACKUP/"
    done < <(link_units "$REPO/$pkg")
  done

  stow --dir="$REPO" --target="$HOME" --restow "${pkgs[@]}"
  info "linked: ${pkgs[*]}"
}

# ------------------------------------------------------------------------ system
# Files under system/ and hosts/<host>/system/ are installed to the same path under /.
# *.in files are templates: @USER@ is replaced with the current user.
do_system() {
  step "System files (/etc) for host '$HOST'"
  local roots=("$REPO/system") root src rel dest tmp mode
  [[ -d $REPO/hosts/$HOST/system ]] && roots+=("$REPO/hosts/$HOST/system")
  local changed=()

  sudo -v
  tmp="$(mktemp)"

  for root in "${roots[@]}"; do
    while IFS= read -r -d '' src; do
      rel="${src#"$root"/}"
      dest="/${rel%.in}"
      if [[ $src == *.in ]]; then
        sed "s/@USER@/$USER/g" "$src" >"$tmp"
      else
        cp "$src" "$tmp"
      fi

      if sudo cmp -s "$tmp" "$dest" 2>/dev/null; then
        continue
      fi

      mode=644
      if [[ $dest == /etc/sudoers.d/* ]]; then
        mode=440
        # A broken sudoers file locks you out of sudo: never install one that doesn't parse
        sudo visudo -cf "$tmp" >/dev/null || die "$rel does not pass visudo -c, not installed"
      fi

      if sudo test -e "$dest"; then
        mkdir -p "$BACKUP/system$(dirname "$dest")"
        sudo cat "$dest" >"$BACKUP/system$dest"
      fi
      sudo install -Dm"$mode" -o root -g root "$tmp" "$dest"
      changed+=("$dest")
      info "installed $dest"
    done < <(find "$root" -type f -print0)
  done
  rm -f "$tmp"

  ((${#changed[@]})) || { info "everything up to date"; return; }

  local f
  for f in "${changed[@]}"; do
    case $f in
      /etc/default/grub) sudo grub-mkconfig -o /boot/grub/grub.cfg ;;
      /etc/udev/rules.d/*) sudo udevadm control --reload-rules && sudo udevadm trigger ;;
      /etc/systemd/*) sudo systemctl daemon-reload ;;
    esac
  done
}

# ---------------------------------------------------------------------- services
do_services() {
  step "Services"
  sudo systemctl enable --now NetworkManager bluetooth systemd-timesyncd power-profiles-daemon
  if [[ -f $REPO/hosts/$HOST/system/etc/tlp.conf ]]; then
    sudo systemctl enable --now tlp
  fi
  # Boot to the tty (autologin + .zprofile starts Hyprland)
  [[ $(systemctl get-default) == multi-user.target ]] || sudo systemctl set-default multi-user.target

  systemctl --user daemon-reload
  if rclone listremotes 2>/dev/null | grep -qx 'OneDrive:'; then
    mkdir -p "$HOME/OneDrive"
    systemctl --user enable --now rclone-onedrive
  else
    warn "rclone remote 'OneDrive' not configured: run 'rclone config', then ./install.sh services"
  fi
}

# ------------------------------------------------------------------------- check
do_check() {
  step "Check"
  local listed installed missing extra
  listed="$(read_packages "${DEFAULT_GROUPS[@]}" optional | sort -u)"
  installed="$(pacman -Qqe | sort)"
  missing="$(comm -23 <(read_packages "${DEFAULT_GROUPS[@]}" | sort -u) <(pacman -Qq | sort))"
  extra="$(comm -13 <(echo "$listed") <(echo "$installed") | grep -vx 'yay\|yay-bin' || true)"
  [[ -n $missing ]] && warn "listed but not installed: $(echo $missing)"
  [[ -n $extra ]] && warn "installed but not in packages/*.txt: $(echo $extra)"

  local pkg rel target bad=0
  for pkg in home private; do
    [[ -d $REPO/$pkg ]] || continue
    while read -r rel; do
      target="$HOME/$rel"
      if [[ ! -L $target ]]; then
        warn "~/$rel is not linked to the repo (if an app replaced the link: diff, copy back, ./install.sh link)"
        bad=1
      elif [[ $(readlink -f "$target") != "$REPO/$pkg/$rel" ]]; then
        warn "~/$rel points to $(readlink "$target")"
        bad=1
      fi
    done < <(link_units "$REPO/$pkg")
  done
  # Dangling links left behind after deleting something from the repo
  while IFS= read -r target; do
    warn "broken symlink: $target"
    bad=1
  done < <(find "$HOME" "$HOME/.config" "$HOME/.local/bin" -maxdepth 1 -xtype l 2>/dev/null)

  local root src dest
  for root in "$REPO/system" "$REPO/hosts/$HOST/system"; do
    [[ -d $root ]] || continue
    while IFS= read -r -d '' src; do
      dest="/${src#"$root"/}"
      dest="${dest%.in}"
      [[ $src == *.in ]] && continue # templates: compared by ./install.sh system
      if [[ ! -r $dest ]]; then
        [[ -e $dest ]] || warn "$dest is missing (run ./install.sh system)"
      elif ! cmp -s "$src" "$dest"; then
        warn "$dest differs from the repo"
      fi
    done < <(find "$root" -type f -print0)
  done

  ((bad)) || info "links OK"
}

# -------------------------------------------------------------------------- main
main() {
  [[ $EUID -ne 0 ]] || die "run as your user, not root (sudo is used where needed)"

  if (($# == 0)); then
    do_ssh
    do_packages
    do_shell
    do_link
    do_system
    do_services
    do_check
    echo -e "\n${GREEN}Done. Reboot to start from a clean session.${RESET}"
    return
  fi

  case $1 in
    packages) shift; do_packages "$@" ;;
    -h | --help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//' ;;
    *)
      local s
      for s in "$@"; do
        case $s in
          ssh | shell | link | system | services | check) "do_$s" ;;
          *) die "unknown step '$s' (try --help)" ;;
        esac
      done
      ;;
  esac
}

main "$@"
