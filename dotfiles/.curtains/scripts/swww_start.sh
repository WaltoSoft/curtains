if ! swww query &>/dev/null; then
  source $CURTAINS_SCRIPTS_DIR/bing_daily_image.sh -o $CURTAINS_WALLPAPERS_DIR
  swww-daemon --format xrgb &
  disown
  swww query && swww restore
fi
