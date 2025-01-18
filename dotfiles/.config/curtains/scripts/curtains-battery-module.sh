alt=""
percentage=$(cat /sys/class/power_supply/BAT0/capacity) 
pluggedIn=$(cat /sys/class/power_supply/AC/online)
tooltip="Battery: $percentage%"
class=""

if [ "$pluggedIn" -eq "1" ] ; then
  remaining=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "time to full" | cut -d: -f2- | xargs)

  if [ -n "$remaining" ] ; then
    tooltip="${tooltip}\rEstimated ${remaining} until full"
  fi
else
  remaining=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "time to empty" | cut -d: -f2- | xargs)
  if [ -n "$remaining" ] ; then
    tooltip="${tooltip}\rEstimated ${remaining} remaining"
  fi
fi

if [ "$percentage" -ge "0" ] && [ "$percentage" -lt "10" ] ; then
  alt="Battery 0"
  class="critical"
elif [ "$percentage" -ge "10" ] && [ "$percentage" -lt "20" ] ; then
  alt="Battery 10"
  class="warning"
elif [ "$percentage" -ge "20" ] && [ "$percentage" -lt "30" ] ; then
  alt="Battery 20"
elif [ "$percentage" -ge "30" ] && [ "$percentage" -lt "40" ] ; then
  alt="Battery 40"
elif [ "$percentage" -ge "40" ] && [ "$percentage" -lt "50" ] ; then
  alt="Battery 40"
elif [ "$percentage" -ge "50" ] && [ "$percentage" -lt "60" ] ; then
  alt="Battery 50"
elif [ "$percentage" -ge "60" ] && [ "$percentage" -lt "70" ] ; then
  alt="Battery 60"
elif [ "$percentage" -ge "70" ] && [ "$percentage" -lt "80" ] ; then
  alt="Battery 70"
elif [ "$percentage" -ge "80" ] && [ "$percentage" -lt "90" ] ; then
  alt="Battery 80"
elif [ "$percentage" -ge "90" ] && [ "$percentage" -lt "100" ] ; then
  alt="Battery 90"
else
  alt="Battery 100"
fi

if [ "$pluggedIn" -eq "1" ] ; then
  alt="${alt} (Charging)"
  class=""
fi

echo "{\"alt\":\"$alt\",\"tooltip\":\"$tooltip\", \"percentage\": $percentage, \"class\": \"$class\"}"