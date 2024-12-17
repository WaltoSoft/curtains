source ./serviceList.sh

executeScript() {
  echoText -fc $COLOR_INSTALL "Services"
  echoText "Enabling Services"

  for service in "${SERVICE_LIST[@]}"; do
    if enableService $service ; then
      echoText "Service '${service}' has been enabled"
    else
      echoText -c $COLOR_ERROR "ERROR: Error occurred enabling '${service}' service"
      exit 1
    fi
  done

  for service in "${USER_SERVICE_LIST[@]}"; do
    if enableService $service ; then
      echoText "User Service '${service}' has been enabled"
    else
      echoText -c $COLOR_ERROR "ERROR: Error occurred enabling user '${service}' service"
      exit 1
    fi
  done

  echoText -c $COLOR_SUCCESS "All services enabled successfully"
}

enableService() {
  existsOrExit $1, "enableService was called with no service name"
  local service=$1
  systemctl enable "${service}.service" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL
}

enableUserService() {
  existsOrExit $1, "enableUserService was called with no service name"
  local service=$1
  systemctl --user enable "${service}.service" 2>&1 | formatOutput -C $COLOR_INSTALL -p $PREFIX_INSTALL

}

executeScript
