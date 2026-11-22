# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Hyprland dotfiles for an Arch Linux desktop (RTX 2060, one `HDMI-A-1` monitor at 2560x1080@75, br-abnt2 keyboard). The OS and the packages are installed by a separate repo, `arch-install` (github.com/DSanches92/arch-install). Its `install-hyprland.sh` clones this repo from GitHub and runs `install.sh`.

Commit messages follow Conventional Commits written in Portuguese (`feat: ...`, `fix: ...`). Comments inside configs and scripts are in pt-BR, so keep new text in Portuguese.

## Layout

- Each top-level folder maps to `~/.config/<folder>`. Paths inside configs assume that location (for example, waybar runs `~/.config/waybar/scripts/arch_updates.sh`).
- `zsh/` is the exception. `zsh/danilo.zsh` goes to `~/.oh-my-zsh/custom/`, and Oh My Zsh sources every `custom/*.zsh` after its plugins. It holds PATH, TERMINAL, zsh-histdb, `podman-nuke`, nvm, Go and bun. `~/.zshrc` stays the Oh My Zsh default except for `ZSH_THEME` and `plugins=(...)`, which must be set before Oh My Zsh loads.
- `sddm/` is copied to `~/.config/sddm` like the other folders, but SDDM runs as another user and cannot read `$HOME`. `sddm/install.sh` (run with sudo) installs the theme, the avatar and `/etc/sddm.conf.d/10-theme.conf` system-wide.
- `.gitignore` ignores everything (`*`) and whitelists each folder and top-level file. **A new app's config folder must be added as `!dir/` and `!dir/**`, and a new top-level file as `!file`, or it won't be tracked.** `*.bak` stays ignored.

## install.sh

- It copies files, it never symlinks. Every file under each top-level folder (except `.git` and `zsh`) is copied to `~/.config` with `cp -p`, which keeps the executable bits.
  - Identical files are skipped.
  - A different file is renamed to `<file>.bak-<date>` first.
  - Files that apps create on their own and that are not in the repo are left alone.
- It copies `zsh/danilo.zsh`, then edits `ZSH_THEME`/`plugins` in `~/.zshrc` with a backup. It warns about missing plugins.
- It ends with `sudo sddm/install.sh`. `--no-sddm` skips that.
- It is idempotent: a second run copies nothing.

Because files are copied, an edit made in `~/.config` does not reach the repo by itself. To change a config, edit it here and run `./install.sh --no-sddm`. If you edited it live, copy it back into the repo. Compare the two with `diff -r <folder> ~/.config/<folder>`.

## Hyprland

- `hypr/hyprland.lua` is the central config. It is Lua (Hyprland moved from `hyprland.conf` to Lua), with `hl.monitor`, `hl.env`, `hl.exec_cmd`, `hl.bind` and `hl.dsp.*`. It holds:
  - the monitor;
  - env vars, including `QT_QPA_PLATFORMTHEME=qt6ct`;
  - autostart: waybar, hyprpaper, hypridle, dunst, dex, gnome-keyring, nm-applet, blueman, cliphist, hyprpolkitagent;
  - the br layout and keybinds (`mainMod = SUPER`, `terminal = alacritty`).
- `hyprpaper.conf`, `hypridle.conf` and `hyprlock.conf` keep their own formats.
- When a keybind or autostart entry needs a new program, add the package to `arch-install/install-hyprland.sh` too.
- Apply changes live with `hyprctl reload` (SUPER+SHIFT+C). Waybar needs a restart (`pkill waybar && waybar &`).

## Theme

Catppuccin Macchiato everywhere: mauve `c6a0f6` borders, the GTK theme `Catppuccin-Macchiato-Standard-Blue-Dark` with Papirus-Dark icons (`gtk-3.0`/`gtk-4.0`), qt6ct, rofi, waybar, alacritty, the yazi flavor in `yazi/flavors/`, and the SDDM theme `macchiato`.
