executeScript() {
  local GIT_DIR=/home/$SUDO_USER/Git
  local REPO_BRANCH=$1
  local REPO_NAME="curtains"
  local REPO_DIR="${GIT_DIR}/${REPO_NAME}"
  local RPEO_URL="https://github.com/waltosoft/${REPO_NAME}.git"
  local LOGS_DIR=/var/log/$REPO_NAME
  local LOG_FILE="${LOGS_DIR}/$(date '+%Y%m%d%H%M%S').log"

  displayHeader
  installPackages
  cloneRepo
  startInstallation
}

cloneRepo() {
  if [ ! -d "${GIT_DIR}" ]; then
    sudo -u $SUDO_USER mkdir -p "${GIT_DIR}"
  fi

  if [ -d "${REPO_DIR}" ]; then
    rm -rf "${REPO_DIR}"
  fi

  echo "Cloning ${REPO_NAME} git repo."
  sudo -u $SUDO_USER git clone -q --no-progress --depth 1 $RPEO_URL "${REPO_DIR}" > /dev/null 2>&1
  echo "Clone complete."
  cd $REPO_DIR

  if [ ! -z "${REPO_BRANCH}" ]; then
    sudo -u $SUDO_USER git config --get remote.origin.fetch > /dev/null 2>&1
    sudo -u $SUDO_USER git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" > /dev/null 2>&1
    sudo -u $SUDO_USER git config --get remote.origin.fetch > /dev/null 2>&1
    sudo -u $SUDO_USER git remote update > /dev/null 2>&1
    sudo -u $SUDO_USER git fetch > /dev/null 2>&1
    sudo -u $SUDO_USER git checkout "${REPO_BRANCH}" > /dev/null 2>&1
    echo "Switched to branch '${REPO_BRANCH}'"
  fi
}

displayDefault() { echo -e "\033[0m"; }
displayAqua() { echo -e "\033[36m"; }

displayHeader() {
  clear

  displayAqua
cat << "EOF"
  ____           _        _             ____       _               
 / ___|   _ _ __| |_ __ _(_)_ __  ___  / ___|  ___| |_ _   _ _ __  
| |  | | | | '__| __/ _` | | '_ \/ __| \___ \ / _ \ __| | | | '_ \ 
| |__| |_| | |  | || (_| | | | | \__ \  ___) |  __/ |_| |_| | |_) |
 \____\__,_|_|   \__\__,_|_|_| |_|___/ |____/ \___|\__|\__,_| .__/ 
                                                            |_|                                                                                       
EOF
  displayDefault

  read -p "First we need to download the installation scripts.  Do you want to continue? (y/n): " answer

  case $answer in
    [Yy]* ) 
        echo "Continuing..."
        ;;
    [Nn]* ) 
        echo "Exiting..."
        exit 0
        ;;
    * ) 
        echo "Invalid response."
        exit 0
        ;;
  esac  
}

installPackages() {
  pacman -Syyu > /dev/null 2>&1
  pacman -Fy > /dev/null 2>&1

  pacman -Sq --noconfirm git gum rsync figlet > /dev/null 2>&1
}

startInstallation() {
  echo "Starting Installation."    
  cd "${REPO_DIR}/scripts"
  mkdir -p $LOGS_DIR
  ./install.sh 2>&1 | tee  >(sed -r "s/\x1B \[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" > $LOG_FILE)
}

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please use sudo when running this script"
  exit 1
fi

while getopts ":b:" option; do
  case $option in
    b)  executeScript "${OPTARG}"
        exit 0
        ;;
    :)  echo "Option -${OPTARG} requires an argument."
        exit 1;;
    ?)  echo "Invalid option: -${OPTARG}." 
        exit 1
        ;;
  esac
done

executeScript
