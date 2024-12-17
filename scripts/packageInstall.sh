source ./packageList.sh

executeScript() {
  local yayPackage=yay-bin
  local yayUrl="https://aur.archlinux.org/${yayPackage}"
  local yayGitFolder="${GIT_DIR}/${yayPackage}"

  echoText -fc $COLOR_INSTALL "Packages"
  configurePacman
  installYay
  installPackages "Core Packages" "${CORE_PACKAGE_LIST[*]}"
  installPackages "Additional Packages" "${ADDITIONAL_PACKAGE_LIST[*]}"
  configureTextEditor
}

configurePacman() {
  if [ -f /etc/pacman.conf ] && [ ! -f /etc/pacman.conf.ahi.bkp ]; then
    echoText "Configuring pacman"

    doit() {  
      cp /etc/pacman.conf /etc/pacman.conf.ahi.bkp 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

      sed -i "/^#Color/c\Color\nILoveCandy
      /^#VerbosePkgLists/c\VerbosePkgLists
      /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
      
      sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

      echoText "Updating pacman packages"
      pacman -Syyu 2>&1 | formatOutput -C $COLOR_PACMAN -p $PREFIX_PACMAN
      pacman -Fy 2>&1 | formatOutput -C $COLOR_PACMAN -p $PREFIX_PACMAN

      echoText -c $COLOR_SUCCESS "pacman configured"
    }

    if doit ; then
      echoText -c $COLOR_SUCCESS "pacman successfully configured"
    else
      echoText -c $COLOR_ERROR "ERROR: An error occurred configuring pacman"
    fi
  else
    echoText -c $COLOR_SUCCESS "pacman already configured"
  fi
}

installPackages() {
  existsOrExit $1, "installPackages was called without a package list description"
  existsOrExit $2, "installPackages was called without a list of packages"

  local listDescription=$1
  local packageList=($2)
  local packagesToInstall=()
  local aursToInstall=()

  if [ ${#packageList[@]} -gt 0 ] ; then
    echoText "Beginning installation for the '${listDescription}' group"
  fi

  for package in "${packageList[@]}"; do
    if $( isPackageInstalled $package ) ; then
      echoText "Package '${package}' is already installed"
    elif $( isPackageAvailable $package ) ; then
      echoText "Queuing package '${package}' to be installed with pacman"
      packagesToInstall+=("${package}")
    elif $( isAurAvailable $package ) ; then
      echoText "Queuing package '${package}' to be installed with yay"
      aursToInstall+=("${package}")
    else
      echoText -c $COLOR_ERROR "Unknown package '${package}'"
      exit 1
    fi
  done

  installPacmanPackages() {
    if [[ ${#packagesToInstall[@]} -gt 0 ]] ; then
      echoText "Installing pacman pacakges: ${packagesToInstall[*]}"
      pacman -S --noconfirm "${packagesToInstall[@]}" 2>&1 | formatOutput -C $COLOR_PACMAN -p $PREFIX_PACMAN
    else
      echoText "No pacman packages to install"
    fi
  }

  installYayPackages() {
    if [[ ${#aursToInstall[@]} -gt 0 ]] ; then
      echoText "Installing yay packages: ${aursToInstall[*]}"
      sudo -u $SUDO_USER yay -S --noconfirm "${aursToInstall[@]}" 2>&1 | formatOutput -C $COLOR_YAY -p $PREFIX_YAY
    else
      echoText "No yay packages to install"
    fi
  }

  local hasErrors=false

  if ! installPacmanPackages ; then
    echoText -c $COLOR_ERROR "ERROR: An error occurred installing pacman packages"
    exit 1
  fi

  if ! installYayPackages ; then 
    echoText -c $COLOR_ERROR "ERROR: An error occurred installing yay packages"
    exit 1
  fi

  for package in "${packageList[@]}"; do
    if $( isPackageInstalled $package ) ; then
      echoText "Package '${package}' installed successfully"
    else
      echoText "Package '${package}' was not installed"
      exit 1
    fi
  done

  echoText -c $COLOR_SUCCESS "All packages for the ${listDescription} group installed successfully"
}

installYay() {
  if ! $(isPackageInstalled $yayPackage) ; then
    echoText "Installing yay"
    removeExistingFolder $yayGitFolder
    cloneRepo $yayUrl $yayGitFolder "${yayGitFolder}/PKGBUILD"

    cd $yayGitFolder

    local yayVersion=$(grep '^pkgver=' ./PKGBUILD | cut -d'=' -f2)
    local yayRelease=$(grep '^pkgrel=' ./PKGBUILD | cut -d'=' -f2)
    local installFile="${yayPackage}-${yayVersion}-${yayRelease}-x86_64.pkg.tar.zst"

    buildIt() {
      echoText "Building the '${yayPackage}' package"
      sudo -u $SUDO_USER makepkg -s --noconfirm 2>&1 | formatOutput -C $COLOR_YAY -p $PREFIX_YAY

      if [ ! -f $installFile ] ; then
        echoText -c $COLOR_ERROR "ERROR: Installation file '${installFile}' could not be found for '${yayPackage}'"
        exit 1
      fi

      echoText "'${yayPackage}' was successfully built"
    }

    installIt() {
      echoText "Installing '${yayPackage}'"
      pacman -U $installFile --noconfirm 2>&1 | formatOutput -C $COLOR_YAY -p $PREFIX_YAY
    }

    if buildIt && installIt ; then
      if $(isPackageInstalled $yayPackage) ; then
        echoText -c $COLOR_SUCCESS "YAY!!! '${yayPackage}' installed successfully"
        cd $GIT_DIR
        rm -rf $yayGitFolder 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
      else
        echoText -c $COLOR_ERROR "ERROR: '${yayPackage}' is not installed"
        exit 1
      fi
    else
      echoText -c $COLOR_ERROR "ERROR: '${yayPackage}' could not be built and installed"
      exit 1
    fi

  else
    echoText -c $COLOR_SUCCESS "YAY!!! yay is already installed!"
  fi
}

isPackageInstalled() {
  existsOrExit $1 "isPackageInstalled was called with no package name"  
  local package="$1"

  if pacman -Qi $package &> /dev/null; then
    echo true
  else
    echo false
  fi
}

isPackageAvailable() {
  existsOrExit $1 "isPackageAvailable was called with no package name"
  local package="$1"

  if pacman -Si $package &> /dev/null; then
    echo true
  else
    echo false
  fi
}

isAurAvailable() {
  existsOrExit $1 "isAurAvailable was called with no package name"

  local package="$1"

  if yay -Si $package &> /dev/null; then
    echo true
  else
    echo false
  fi
}

configureTextEditor() {
  if $(isPackageInstalled nautilus) && $(isPackageInstalled xdg-utils) ; then
    echoText "Nautilus file manager detected"
    xdg-mime default org.gnome.Nautilus.desktop inode/directory
    local defaultValue=$(xdg-mime query default "inode/directory")
    echoText -c $COLOR_SUCCESS "Successfully set '${defaultValue}' as default file explorer..."
  fi
}

executeScript