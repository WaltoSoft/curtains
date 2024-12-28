executeScript() {
  local grubScriptFile=/boot/grub/grub.cfg
  local grubConfigFile=/etc/default/grub
  local grubThemesFolder=/usr/share/grub/themes

  if $(isPackageInstalled grub) && [ -f $grubScriptFile ] ; then
    if [ ! -f "${grubConfigFile}.curtains.bkp" ] && [ ! -f "${grubScriptFile}.curtains.bkp" ]; then
      echoText -fc $COLOR_INSTALL "Grub"
      echoText "Configuring Grub"

      cp $grubConfigFile "${grubConfigFile}.curtains.bkp" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
      cp $grubScriptFile "${grubScriptFile}.curtains.bkp" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

      ensureFolder $grubThemesFolder/arch-linux

      echoText "Setting grub theme to arch-linux"
      tar -C $grubThemesFolder/arch-linux -xf $REPO_DIR/archives/grub/arch-linux.tar 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
      
      sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
      /^GRUB_GFXMODE=/c\GRUB_GFXMODE=1920x1080
      /^GRUB_TERMINAL_OUTPUT=console/c\#GRUB_TERMINAL_OUTPUT=console
      /^GRUB_THEME=/c\GRUB_THEME=\"${grubThemesFolder}/arch-linux/theme.txt\"
      /^#GRUB_THEME=/c\GRUB_THEME=\"${grubThemesFolder}/arch-linux/theme.txt\"
      /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" $grubConfigFile 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

      echoText "Making the new grub script file"
      grub-mkconfig -o $grubScriptFile 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

      echoText -c $COLOR_SUCCESS "Grub configuration complete!"
    fi
  fi
}

executeScript
