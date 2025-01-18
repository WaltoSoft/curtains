#!/bin/bash
START=false

mkdir -p $CURTAINS_WALLPAPER_DIR

while getopts ":s" option; do
  case $option in
    s)  START=true
        ;;
    :)  echo "Option -${OPTARG} requires an argument."
        exit 1;;
    ?)  echo "Invalid option: -${OPTARG}." 
        exit 1
        ;;
  esac
done

purgeWallpaperDir() {
  find "${CURTAINS_WALLPAPER_DIR}" -type f -mtime +14 -exec rm -f {} \;
  echo "Deleted all files older than two weeks in ${CURTAINS_WALLPAPER_DIR}"
}

downloadBingImage() {
  local bingUrl="https://www.bing.com"
  local jsonUrl="${bingUrl}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"
  local json_data=$(curl -s $jsonUrl)

  local fileNameBase=$(echo $json_data | jq -r '.images[0].hsh')
  local filePathBase="${CURTAINS_WALLPAPER_DIR}/${fileNameBase}"

  local urlBase=$(echo $json_data | jq -r '.images[0].urlbase')
  local imageUrl="${bingUrl}${urlBase}_UHD.jpg&rf=LaDigue_UHD.jpg&pid=hp"

  if [ ! -f "$filePathBase.jpg" ]; then
    echo $json_data | jq '.' > "${filePathBase}.json"
    curl -so "${filePathBase}.jpg" $imageUrl 1>&2
    echo "${filePathBase}.jpg"
  else
    echo
  fi  
}

if $START ; then
  systemctl --user start curtains-wallpaper-service.service
else
  while true; do
    NEW_IMAGE_FILE=""
    SLEEP_TIMEOUT=1

    if ! swww query &>/dev/null; then
      #wait until the swww daemon is running
      SLEEP_TIMEOUT=1
    else    
      purgeWallpaperDir

      NEW_IMAGE_FILE=$(downloadBingImage)
	
      if [ -n "${NEW_IMAGE_FILE}" ] ; then 
        echo "New image file downloaded: '${NEW_IMAGE_FILE}'.  Sending image to swww"
      else
        NEW_IMAGE_FILE=$(find "$CURTAINS_WALLPAPER_DIR" -type f -name "*.jpg" | shuf -n 1)
        echo "No new image yet, Selected image at random: '${NEW_IMAGE_FILE}"'.  Sending image to swww'
      fi

      if [ -f "${NEW_IMAGE_FILE}" ]; then
        python3 "${CURTAINS_SCRIPTS_DIR}/hyprlock-prepare-background.py" $NEW_IMAGE_FILE $CURTAINS_HYPRLOCK_BACKGROUNDIMAGE 30 100
        echo "Created hyprlock.jpg"

        python3 "${CURTAINS_SCRIPTS_DIR}/hyprlock-prepare-background.py" $NEW_IMAGE_FILE $CURTAINS_CLOSE_BACKGROUNDIMAGE 100 25
        echo "Created wlogout.jpg"

        swww img "${NEW_IMAGE_FILE}"
        echo "Image sent to swww"
      fi

      SLEEP_TIMEOUT=300
    fi

    sleep $SLEEP_TIMEOUT
  done
fi