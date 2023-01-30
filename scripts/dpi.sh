#!/usr/bin/env bash

if [ "$3" = "0" ]; then
    xrandr --output HDMI-A-2 --mode 3840x2160 --output DisplayPort-1 --off
else
    xrandr --output DisplayPort-1 --mode 3440x1440 --output HDMI-A-2 --off
fi

sed -i -E "s/^Xft.dpi:$1/Xft.dpi:$2/" ~/.Xresources && \
  xrdb ~/.Xresources && \
  xrandr --dpi "$2" && \
  echo 'awesome.restart()' | awesome-client
