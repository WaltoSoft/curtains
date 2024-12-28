executeScript() {
  set -e

  SCRIPT_DIR=$(dirname "$(realpath "$0")")

  source ./library.sh

  echoText -c $COLOR_INSTALL "Installation Starting"
  source $SCRIPT_DIR/validateSudoUser.sh
  source $SCRIPT_DIR/start.sh
  source $SCRIPT_DIR/packageInstall.sh
  source $SCRIPT_DIR/dotfiles.sh
  source $SCRIPT_DIR/bashrc.sh
  source $SCRIPT_DIR/sddm.sh
  source $SCRIPT_DIR/services.sh
  source $SCRIPT_DIR/grub.sh
  source $SCRIPT_DIR/reboot.sh

  echoText -c $COLOR_SUCCESS "Installation complete!"
}
executeScript