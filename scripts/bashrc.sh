executeScript() {
  echoText -fc $COLOR_INSTALL "bashrc"

  doit() {
    echoText "Backing up existing .bashrc scripts"
    sudo -u $SUDO_USER cp /home/$SUDO_USER/.bashrc /home/$SUDO_USER/.bashrc.curtains.bkp 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
    sudo -u $SUDO_USER cp /home/$SUDO_USER/.bashrc_custom /home/$SUDO_USER/.bashrc_custom.curtains.bkp 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

    echoText "Copying new bashrc configuration scripts"
    sudo -u $SUDO_USER cp $REPO_DIR/dotfiles/.bashrc /home/$SUDO_USER/.bashrc 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
    sudo -u $SUDO_USER cp $REPO_DIR/dotfiles/.bashrc_custom /home/$SUDO_USER/.bashrc_custom 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  }

  if ! doit ; then
    echoText -c $COLOR_ERROR "ERROR: An error occured copying bashrc scripts"
    exit 1
  fi

  echoText -c $COLOR_SUCCESS "bashrc scripts successfully copied"
}

executeScript
