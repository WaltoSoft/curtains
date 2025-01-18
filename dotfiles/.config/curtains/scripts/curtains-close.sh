#!/bin/bash

if pgrep -x "curtains-leave" >/dev/null; then
  pkill -x "curtains-leave"
  exit 0
fi

# Variables
buttons_per_row=6
column_spacing=10
row_spacing=10
delay_before_closing=500
css_path="${CURTAINS_DIR}/halt/style.css"
buttons_path="${CURTAINS_DIR}/halt/buttons.json"

# Get screen dimensions and scale
x_mon=$(($(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')))
y_mon=$(($(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')))
hypr_scale=$(echo $(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' ) | bc)
half_x_mon=$(($x_mon / 2))

# Calculate button dimensions based on monitor dimensions and scale
button_size=$(echo "scale=2; $half_x_mon / $buttons_per_row " | bc)
button_size=$(printf "%.0f" $button_size) # Round to the nearest integer

# Calculate font sizes
text_font_size=$((y_mon * 2 / 100))
icon_font_size=30
text_font_size_hover=$(echo "$text_font_size * 1.2 / 1" | bc)
icon_font_size_hover=$(echo "$icon_font_size * 1.2 / 1" | bc)

# Export variables used by wlogout style.css
export text_font_size="${text_font_size}px"
export text_font_size_hover="${text_font_size_hover}px"
export icon_font_size="${icon_font_size}pt"
export icon_font_size_hover="${icon_font_size_hover}pt"

# Build the css content with variables substituted
cssContent="$(envsubst <$css_path)"

# Launch curtains-close
# This needs to be changed to the install location for curtains close
$CURTAINS_SCRIPTS_DIR/curtains-close -n $buttons_per_row -s $button_size -X $column_spacing -Y $row_spacing -d $delay_before_closing -b "${CURTAINS_DIR}/halt/buttons.json" -C "${cssContent}"
