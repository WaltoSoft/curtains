if ! swww query &>/dev/null; then
  swww-daemon --format xrgb &
  disown
  swww query && swww restore
fi