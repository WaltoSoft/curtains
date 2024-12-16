executeScript() {
  if [ "$EUID" -ne 0 ]; then
    echoText -c $COLOR_ERROR "ERROR: Please use sudo when running this script"
    exit 1
  fi

  doit() {
    local NO_PASSWORD_LINE="%wheel ALL=(ALL:ALL) NOPASSWD: ALL"
    local SUDOERS_FILE="/etc/sudoers"

    grep -qxF "${NO_PASSWORD_LINE}" "$SUDOERS_FILE" || echo "${NO_PASSWORD_LINE}" >> "$SUDOERS_FILE"
  }

  if ! doit ; then
    echoText -c $COLOR_ERROR "ERROR: An error occurred granting the wheel group NOPASSWORD sudo access"
    exit 1
  fi
}

executeScript