#!/usr/bin/env bash

shopt -s nocasematch

# Terminate already running bar instances
killall -q picom

# Wait until the processes have been shut down
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done

ACCELERATED=$(glxinfo -B | awk '/Accelerated:/{ print $2 }')

if [ "$ACCELERATED" = "yes" ]; then
  picom --experimental-backends --config "$HOME/.config/picom/conf"
 else
  picom --experimental-backends --backend xrender --config "$HOME/.config/picom/conf"
fi

