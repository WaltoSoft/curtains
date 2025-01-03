percentage=$(cat /sys/class/power_supply/BAT0/capacity) 
pluggedIn=$(cat /sys/class/power_supply/AC/online)

if [ $pluggedIn -eq 1 ] ; then
  if [ "$percentage" -ge "0" ] && [ "$percentage" -lt "10" ] ; then
    echo "󰢟"
  elif [ "$percentage" -ge "10" ] && [ "$percentage" -lt "20" ] ; then
    echo "󰢜"
  elif [ "$percentage" -ge "20" ] && [ "$percentage" -lt "30" ] ; then
    echo "󰂆"
  elif [ "$percentage" -ge "30" ] && [ "$percentage" -lt "40" ] ; then
    echo "󰂇"
  elif [ "$percentage" -ge "40" ] && [ "$percentage" -lt "50" ] ; then
    echo "󰂈"
  elif [ "$percentage" -ge "50" ] && [ "$percentage" -lt "60" ] ; then
    echo "󰢝"
  elif [ "$percentage" -ge "60" ] && [ "$percentage" -lt "70" ] ; then
    echo "󰂉"
  elif [ "$percentage" -ge "70" ] && [ "$percentage" -lt "80" ] ; then
    echo "󰢞"
  elif [ "$percentage" -ge "80" ] && [ "$percentage" -lt "90" ] ; then
    echo "󰂊"
  elif [ "$percentage" -ge "90" ] && [ "$percentage" -lt "100" ] ; then
    echo "󰂋"
  else
    echo "󰂄"
  fi
else
  if [ "$percentage" -ge "0" ] && [ "$percentage" -lt "10" ] ; then
    echo "󿂎"
  elif [ "$percentage" -ge "10" ] && [ "$percentage" -lt "20" ] ; then
    echo "󰁺"
  elif [ "$percentage" -ge "20" ] && [ "$percentage" -lt "30" ] ; then
    echo "󿁻"
  elif [ "$percentage" -ge "30" ] && [ "$percentage" -lt "40" ] ; then
    echo "󰁼"
  elif [ "$percentage" -ge "40" ] && [ "$percentage" -lt "50" ] ; then
    echo "󰁽"
  elif [ "$percentage" -ge "50" ] && [ "$percentage" -lt "60" ] ; then
    echo "󰁾"
  elif [ "$percentage" -ge "60" ] && [ "$percentage" -lt "70" ] ; then
    echo "󰁿"
  elif [ "$percentage" -ge "70" ] && [ "$percentage" -lt "80" ] ; then
    echo "󰂀"
  elif [ "$percentage" -ge "80" ] && [ "$percentage" -lt "90" ] ; then
    echo "󰂂"
  elif [ "$percentage" -ge "90" ] && [ "$percentage" -lt "100" ] ; then
    echo "󰂋"
  else
    echo "󰁹"
  fi
fi