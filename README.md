# dotfiles

My Arch Linux + [Hyprland](https://hyprland.org) setup (noctalia shell, walker, yazi, kitty, neovim, zsh).

## Fresh install

On a fresh Arch install (e.g. from `archinstall`, with your user in `wheel`):

```sh
sudo pacman -S --needed git
git clone https://github.com/victorballester7/dotfiles.git ~/Desktop/dotfiles
~/Desktop/dotfiles/install.sh
```

This runs every step below in order, then reboot. Every step is safe to re-run.

## Day to day

Configs are **symlinked**, not copied: editing `~/.config/hypr/...` edits the repo directly, so
`git status` always shows what changed. There is no "copy config" step anymore.

| Command | What it does |
| --- | --- |
| `./install.sh link` | Symlink `home/` into `~` (needed after adding a new top-level config) |
| `./install.sh check` | Show drift: packages not in the lists, broken/replaced links, `/etc` files that differ |
| `./install.sh system` | Install `system/` (+ `hosts/<hostname>/system/`) into `/etc` |
| `./install.sh packages [group...]` | Install package groups from `packages/` (default: all but `optional`) |
| `./install.sh shell` | oh-my-zsh, powerlevel10k, zsh as login shell |
| `./install.sh services` | Enable system and user services |
| `./install.sh ssh` | Create an SSH key for GitHub if missing |

Anything that was in the way when linking is moved to `~/.dotfiles-backup/<date>/`, never deleted.

## Layout

```
home/              mirrors ~ ; symlinked with GNU stow
  .config/<app>/   one directory per app
  .local/bin/      my scripts (on PATH)
system/            mirrors / ; installed with sudo by `install.sh system`
hosts/<hostname>/  machine-specific files
  system/          extra /etc files for that machine only (e.g. LG gram udev rules, tlp)
packages/*.txt     package lists, one per line, `#` comments allowed
private/           gitignored; stowed into ~ if present (e.g. .ssh/config)
```

- **Adding a config**: move it into `home/.config/<app>` and run `./install.sh link`.
- **Adding a package**: add it to the right `packages/*.txt`. `./install.sh check` lists installed packages that are missing from the lists.
- **Per-machine monitors**: `home/.config/hypr/hosts/<hostname>.lua` is loaded automatically (see `hypr/hyprland/13_output.lua`).
- **System templates**: files ending in `.in` have `@USER@` replaced with your username. `sudoers.d` files are checked with `visudo` before being installed.
- **Generated files** (wallpapers, colours made from the wallpaper, noctalia's generated Lua) are gitignored.
- If an app replaces one of the symlinks with a regular file (some apps do when saving settings), `./install.sh check` reports it. Diff the file against the repo, copy it back, then run `./install.sh link`.

## Private files

`private/` is not committed (this repo is public). Keep a copy somewhere safe (e.g. in `pass` or a private repo) and drop it into `private/` on a new machine before running `install.sh link`.

> [!NOTE]
> In order to access certain recursive-browser features from a folder inside OneDrive, create a link from that folder to `~/Desktop` or another folder that is not inside `~/OneDrive`.
