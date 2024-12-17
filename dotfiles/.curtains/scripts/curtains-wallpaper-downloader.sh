#!/bin/bash
set -e

TARGET_HOUR=0
TARGET_MINUTE=0
FIRST_RUN=true
START=false

mkdir -p $CURTAINS_WALLPAPER_DIR

while getopts ":h:m:s" option; do
  case $option in
    h)  TARGET_HOUR="${OPTARG}"
        ;;
    m)  TARGET_MINUTE="${OPTARG}"
        ;;
    s)  START=true
        ;;
    :)  echo "Option -${OPTARG} requires an argument."
        exit 1;;
    ?)  echo "Invalid option: -${OPTARG}." 
        exit 1
        ;;
  esac
done

downloadBingImage() {
  mkdir -p $CURTAINS_WALLPAPER_DIR

  local bingUrl="https://www.bing.com"
  local jsonUrl="${bingUrl}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"

  local json_data=$(curl -s $jsonUrl)
  local imageUrlParams=$(echo $json_data | grep -oP '(?<="url":")[^"]*') 
  local imageUrl="${bingUrl}${imageUrlParams}&rf=LaDigue_UHD.jpg"

  local title=$(echo $json_data | grep -oP '(?<="title":")[^"]*')
  local location=$(echo $json_data | grep -oP '(?<="copyright":")[^,]*' | sed 's/^[^()]* (\([^)]*\)).*$/\1/')

  local fileName="${title// /_}_${location// /_}.jpg"
  local filePath="$CURTAINS_WALLPAPER_DIR/$fileName"

  if [ ! -f "$filePath" ]; then
    curl -so "${filePath}" $imageUrl
    echo "${filePath}"
  fi  
}

if $START ; then
  if ! systemctl is-enabled --quiet curtains-wallpaper-downloader.service ; then
    systemctl --user enable curtains-wallpaper-downloader.service
  fi

  if ! systemctl is-active --quiet curtains-wallpaper-downloader.service ; then
    systemctl --user start curtains-wallpaper-downloader.service
  fi
else
  while true; do
    CURRENT_HOUR=$(date +%H)
    CURRENT_MINUTE=$(date +%M)
    NEW_IMAGE_FILE=""
    SLEEP_TIMEOUT=1

    if ! swww query &>/dev/null; then
      SLEEP_TIMEOUT=1
    else    
      if $FIRST_RUN || ([ "$CURRENT_HOUR" -eq "$TARGET_HOUR" ] && [ "$CURRENT_MINUTE" -eq "$TARGET_MINUTE" ]); then
        echo "Downloading a new image file"
        FIRST_RUN=false
        NEW_IMAGE_FILE=$(downloadBingImage)
        echo "Image filed downloaded: ${NEW_IMAGE_FILE}"
	
	      if [ -n $NEW_IMAGE_FILE ] ; then 
	        swww img "${NEW_IMAGE_FILE}"
	      fi
      fi
      SLEEP_TIMEOUT=60
    fi

    sleep $SLEEP_TIMEOUT
  done
fi
