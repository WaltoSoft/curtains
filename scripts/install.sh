executeScript() {
  set -e

  source ./library.sh

  echo -c $COLOR_INSTALL "Installation Starting"
  source ./validateSudoUser.sh
  source ./start.sh
  source ./packageInstall.sh
  source ./dotfiles.sh
  source ./bashrc.sh
  source ./sddm.sh
  source ./enableServices.sh
  source ./grub.sh
  source ./reboot.sh

  echoText -c $COLOR_SUCCESS "Installation complete!"
}
executeScript