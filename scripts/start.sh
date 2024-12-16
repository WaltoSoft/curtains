executeScript() {
  clear
  confirmStart
}

confirmStart() {
  echoText -fc $COLOR_INSTALL "Installation"
  echoText

  if $(askUser -c "DO YOU WANT TO START THE INSTALLATION?"); then
    echoText -c $COLOR_SUCCESS "Installation Starting"
  elif [ $? -eq 130 ] ; then
    echoText -c $COLOR_ERROR "Installation Cancelled"
    exit 130
  else
    echoText -c $COLOR_ERROR "Installation Cancelled"
    exit
  fi
}

executeScript