executeScript() {
  echoText -fc $COLOR_INSTALL "Dot files"
  echoText "Copying Hyperland Dot files"

  doit() {
    sudo -u $SUDO_USER rsync -avhp -I $REPO_DIR/dotfiles/ /home/$SUDO_USER 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  }

  if ! doit ; then
    echoText -c $COLOR_ERROR "ERROR: An error occured copying Dot files"
    exit 1
  fi

  echoText -c $COLOR_SUCCESS "Dot files successfully copied"
}

executeScript