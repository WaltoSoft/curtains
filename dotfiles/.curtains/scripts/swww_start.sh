if ! swww query &>/dev/null; then
  swww clear-cache
  swww-daemon --format xrgb &
  disown
  swww query && swww restore
fi