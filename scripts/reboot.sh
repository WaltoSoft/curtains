executeScript() {
  echoText -fc $COLOR_INSTALL "Reboot"
  echoText "A reboot of your system is recommended."
  echoText

  if $(askUser -c "Would you like to reboot now?") ; then
    echoText "Rebooting..."
    systemctl reboot
  elif [ $? -eq 130 ]; then
    exit 130
  else
    echoText -c $COLOR_ERROR "Reboot skipped"
  fi

  echoText ""
  echoText -c $COLOR_SUCCESS "Installation Complete!"
}

executeScript
