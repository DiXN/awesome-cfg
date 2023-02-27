#!/usr/bin/env bash

shopt -s nocasematch

# Terminate already running bar instances
killall -q picom

# Wait until the processes have been shut down
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done

GLX_INFO=$(glxinfo -B)

DIRECT=$(echo "$GLX_INFO" | awk '/direct rendering:/{ print tolower($3) }')

ACCELERATED=$(echo "$GLX_INFO" | awk '/Accelerated:/{ print $2 }')

if [ "$ACCELERATED" = "yes" ] && [ "$DIRECT" = "yes" ] || echo "$GLX_INFO" | grep -q 'OpenGL vendor string: NVIDIA Corporation'; then
  picom --config "$HOME/.config/picom/conf"
 else
  picom --backend xrender --config "$HOME/.config/picom/conf"
fi

