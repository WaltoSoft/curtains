#!/bin/bash

if [[ "$1" == "exit" ]]; then
  killall -9 Hyprland 
fi

if [[ "$1" == "lock" ]]; then
  loginctl lock-session
fi

if [[ "$1" == "reboot" ]]; then
    if [[ -f "$FILE" ]]; then
        rm $FILE
    fi
    systemctl reboot
fi

if [[ "$1" == "shutdown" ]]; then
    if [[ -f "$FILE" ]]; then
        rm $FILE
    fi
    systemctl poweroff
fi

if [[ "$1" == "suspend" ]]; then
    systemctl suspend    
fi

if [[ "$1" == "hibernate" ]]; then
    systemctl hibernate    
fi