REPO_NAME=curtains
GIT_DIR=/home/$SUDO_USER/Git
REPO_DIR=$GIT_DIR/$REPO_NAME

BOLD="\033[1m"
RESET="\033[0m"

COLOR_INSTALL="\033[1;34m"
COLOR_GIT="\033[1;32m"
COLOR_PACMAN="\033[0;33m"
COLOR_YAY="\033[1;35m"
COLOR_ERROR="\033[0;31m"
COLOR_SUCCESS="\033[0;32m"

PREFIX_GIT="GIT"
PREFIX_INSTALL="INSTALL"
PREFIX_PACMAN="PACMAN"
PREFIX_YAY="YAY"

askUser() {
  local OPTIND=1
  local command
  local choices
  local prompt

  while getopts ":c:m:" option; do
    case $option in
      c)  if [ -z $command ]; then
            command="confirm"
            prompt="${OPTARG}"
          else
            #echoText -c $COLOR_ERROR "ERROR: You can only speciy -c or -m, not both"
            exit 1
          fi
          ;;

      m)  if [ -z $command ]; then
            command="choose"
            prompt="${OPTARG}"
          else
            #echoText -c $COLOR_ERROR "ERROR: You can only speciy -c or -m, not both"
            exit 1
          fi
          ;;

      :)  #echoText -c $COLOR_ERROR "ERROR: Option -${OPTARG} requires a prompt argument."
          exit 2
          ;;

     \?)  #echoText -c $COLOR_ERROR "ERROR: Invalid option passed to askUser: -${OPTARG}"
          exit 3
          ;;
    esac
  done

  shift $((OPTIND-1))
  choices=$@

  if [ -z $"{prompt}" ]; then
    #echoText -c $COLOR_ERROR "ERROR: No prompt provided to askUser"
    exit 4
  fi

  case $command in
    "confirm")  #echoText "Confirm Prompt: '${prompt}'" 
                if gum confirm "${prompt}"; then
                  echo true
                else
                  echo false
                fi
                ;;

    "choose")   #echoText "Choose Prompt: '${prompt}', Choices: '$choices'"
                local result=$(gum choose --header "${prompt}" $choices)
                #echoText "User Chose: '${result}'" 
                echo $result
                ;;
  esac
}

cloneRepo() {
  repoUrl=$1
  repoFolder=$2
  validationFile=$3

  if [ -z $repoUrl ]; then
    echoText -c $COLOR_ERRPR "ERROR: No repo URL provided to cloneRepo"
    exit 1
  fi

  if [ -z $repoFolder ]; then
    echoText -c $COLOR_ERROR "ERROR: No repo folder provided to cloneRepo"
    exit 1
  fi

  ensureFolder $repoFolder
  echoText "Cloning the git repository at '${repoUrl}'"

  doit() {
    sudo -u $SUDO_USER git clone --depth 1 $repoUrl $repoFolder 2>&1 | formatOutput -C $COLOR_GIT -p $PREFIX_GIT
  }

  if ! doit; then
    echoText -c $COLOR_ERROR "ERROR: An error occured cloning the git repository at '${repoUrl}'"
    exit 1
  fi

  if [ -d $repoFolder ]; then
    echoText "'${repoUrl}' repo cloned successfully"
  else
    echoText -c $COLOR_ERROR "ERROR: '${repoUrl}' was not successfully cloned"
    exit 1
  fi

  if [ -n $validateFile ] && [ ! -f $validationFile ]; then
    echoText -c $COLOR_ERROR "ERROR: '${validationFile}' does not exist"
    exit 1
  fi
}

echoText() {
  local OPTIND=1
  local useFiglet=false
  local color
  local message
  local messageSet=false
  local errorExit=false

  while getopts ":c:f" option; do
    case $option in
      c)  color="${OPTARG}"
          ;;
      f)  useFiglet=true
          ;;
      :)  color=$COLOR_ERROR
          useFiglet=false
          message="ERROR: Option -${OPTARG} requires an argument."
          messageSet=true
          errorExit=true
          break
          ;;
     \?)  color=$COLOR_ERROR
          useFiglet=false
          message="ERROR: Invalid option: -${OPTARG}." 
          messageSet=true
          errorExit=true
          break
          ;;
    esac
  done  

  if ! $messageSet ; then
    shift $((OPTIND-1))
    message="$1"
  fi

  if [ -z "${message}" ]; then
    echo "" 
  else
    if $useFiglet ; then
      message=$(figlet "${message}")
    fi

    if [ -n $color ]; then
      echo "${message}" 2>&1 | formatOutput -c "${color}" -C "${COLOR_INSTALL}" -p "${PREFIX_INSTALL}" 
    else
      echo "${message}" 2>&1 | formatOutput -C "${COLOR_INSTALL}" -p "${PREFIX_INSTALL}"
    fi

    if $errorExit ; then
      exit 1
    fi
  fi
}

formatOutput() {
  local outputColor=""
  local prefixColor=""
  local prefixText=""
  local resetColor=$(tput sgr0)
  local OPTIND=1

  while getopts ":c:C:p:" option; do
    case $option in
      c)
          outputColor="${OPTARG}"
          ;;
      C)
          prefixColor="${OPTARG}"
          ;;
      p)  
          prefixText="${OPTARG}"
          ;;
      :)  echoText -c $COLOR_ERROR "ERROR: Option -${OPTARG} requires an argument."
          exit 1;;
      ?)  echoText -c $COLOR_ERROR "ERROR: Invalid option: -${OPTARG}." 
          exit 1
          ;;
    esac
  done

  shift $((OPTIND-1))

  prefixText=$(printf '%-15s' "[${prefixText}]")
  prefixText="${BOLD}${prefixText}${RESET}"
  
  while IFS= read -r line; do 
    local output=$line

    if [ -n "${outputColor}" ]; then
      output="${outputColor}${output}${resetColor}"
    fi

    if [ -n "${prefixText}" ]; then
      if [ -n "${prefixColor}" ]; then
        output="${prefixColor}${prefixText}${resetColor}${output}"
      else
        output="${prefixText}${output}"
      fi
    fi

    printf "%b\n" "$output"
  done
}

isUserFolder() {
  existsOrExit "$1" "No folder path provided to isUserFolder"
  local folderPath=$1

  if [[ $folderPath == "/home/$SUDO_USER/"* ]]; then
    echo true
  else
    echo false
  fi
}

ensureFolder() {
  local folderPath=$1
  local useSudoUser=false
  
  if $(isUserFolder $folderPath) ; then
    useSudoUser=true
  fi

  echoText "Ensuring folder '${folderPath}' exists"
   
  if [ ! -d $folderPath ] ;then
    if $useSudoUser; then
      sudo -u $SUDO_USER mkdir -p $folderPath 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
    else
      mkdir -p $folderPath 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
    fi

    echoText "Folder '${folderPath}' created"
  fi
}


existsOrExit() {
  if [ -z $1 ]; then
    echoText -c $COLOR_ERROR "ERROR: $2"
    exit 1
  fi
}

removeExistingFolder() {
  existsOrExit $1 "No folder path provided to removeFolderIfExists"

  if [ -d $1 ]; then
    rm -rf $1
    echoText "Existing folder '$1' removed"
  fi
}
