#!/bin/sh

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"& disown
  fi
}

run easyeffects --gapplication-service
run nm-applet
run numlockx
# run pasystray
run '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'
run '/usr/bin/instantmouse' '0.19500'
run 'ntfy' 'sub' '--poll' 'ntfy.sh/mind_alert' 'notify-send "$t" "$m"'
run "$HOME/.config/awesome/scripts/sound.sh"

