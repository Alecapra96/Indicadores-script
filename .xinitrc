#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi
sudo x11vnc -rfbauth /etc/x11vnc.passwd
xset s off -dpms
google-chrome --kiosk --app="https://www.lavoz.com.ar" &
exec bspwm
    