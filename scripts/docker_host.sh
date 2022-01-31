#!/usr/bin/env bash

set -euo pipefail

if [[ -f /.dockerenv && ! -f "/tmp/docker_run" ]]; then
  readonly DOTFILES_ROOT="$HOME/Documents/repos/dotfiles"
  git -C "$DOTFILES_ROOT" pull

  alacritty -e "nvim" "$DOTFILES_ROOT" &

  PASSWD="$(zenity --password)"

  PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"


  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"
  fi

  touch /tmp/docker_run
fi

