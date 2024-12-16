executeScript() {
  local sddmConfigFolder=/etc/sddm.conf.d
  local sddmConfigFile=$sddmConfigFolder/sddm.conf
  local defaultConfigFile=/usr/lib/sddm/sddm.conf.d/default.conf
  local iniUpdateScript=./iniupdate.py
  local themeDirectory=/usr/share/sddm/themes

  echoText -fc $COLOR_INSTALL "sddm"
  ensureFolder $sddmConfigFolder 
  copyDefaultConfiguration
  configureThemes
  selectTheme
}

copyDefaultConfiguration() {
  echoText "Copying Default SDDM Configuration '${defaultConfigFile}'->'${sddmConfigFile}'"
  cp $defaultConfigFile $sddmConfigFile 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  echoText "Default SDDM Configuration copied"
}

getInstalledThemes() {
  local themes=()

  for folder in $themeDirectory/*; do
    if [ -d $folder ]; then
      local themeName=$(basename $folder)
      themes+=("${themeName}")
    fi
  done

  echo "${themes[@]}";
}

selectTheme() {
  local themeOptions=($(getInstalledThemes))

  if [ "${#themeOptions[@]}" -eq 0 ] ; then
    echoText "There are no sddm themes installed"
  else
    local section="Theme"
    local key="Current"
    local selectedTheme=$(askUser -m  "Please select a login theme" "${themeOptions[@]}")

    echoText "Selected Theme: ${selectedTheme}"
    sed -i "/^\[$section\]/,/^\[/ s/^\($key *= *\).*/\1$selectedTheme/" "$sddmConfigFile" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  fi
}

configureThemes() {
  #These three themes are installed by SDDM but they don't
  #work on Hyprland for some reason
  rm -rf $themeDirectory/elarun 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  rm -rf $themeDirectory/maldives 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  rm -rf $themeDirectory/maya 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

  configureEucalyptusDrop
}

# Add functions to configure various theme choices
configureEucalyptusDrop() {
  local configFile=$themeDirectory/eucalyptus-drop/theme.conf
  local section="General"
  local hourFormatKey="HourFormat"
  local hourFormatValue="h:mm AP"
  local dateFormatKey="DateFormat"
  local dateFormatValue="dddd, MMMM d"

  if [ -f $configFile ]; then 
    sed -i "/^\[$section\]/,/^\[/ s/^\($hourFormatKey *= *\).*/\1$hourFormatValue/" "$configFile" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
    sed -i "/^\[$section\]/,/^\[/ s/^\($dateFormatKey *= *\).*/\1$dateFormatValue/" "$configFile" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
  else
    echoText "Eucalyptus Drop theme not found"
  fi
}

executeScript