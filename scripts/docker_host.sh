#!/usr/bin/env bash

set -euo pipefail
shopt -s nocasematch


if [[ -f /.dockerenv && ! -f "/tmp/docker_run" ]]; then
  echo "XDG_RUNTIME_DIR=/run/user/1000" | sudo tee -a /etc/environment

  # DISABLE GPU for Alacritty
  ACCELERATED=$(glxinfo -B | awk '/direct rendering:/{ print tolower($3) }')

  if [ "$ACCELERATED" = "no" ]; then
    ! grep "LIBGL_ALWAYS_SOFTWARE=1" /etc/environment && echo "LIBGL_ALWAYS_SOFTWARE=1" | sudo tee -a /etc/environment
  fi

  readonly DOTFILES_ROOT="$HOME/Documents/repos/dotfiles"
  git -C "$DOTFILES_ROOT" pull

  PASSWD="$(zenity --password)"

  PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"

  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"
  fi

  touch /tmp/docker_run
fi

