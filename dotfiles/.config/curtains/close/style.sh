#!/bin/bash

# Command line arguments
path="$(dirname "$(realpath "$0")")"
css_path="${path}/style.css"
settings_path="${path}/settings.json"

# Get screen dimensions and scale
x_mon=$(($(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')))
y_mon=$(($(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')))
hypr_scale=$(echo $(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' ) | bc)
half_x_mon=$(($x_mon / 2))

# Calculate button dimensions based on monitor dimensions and scale
buttons_per_row=$(jq -r '.buttons_per_row' $settings_path)
button_size=$(echo "scale=2; $half_x_mon / $buttons_per_row " | bc)
button_size=$(printf "%.0f" $button_size) # Round to the nearest integer

# Calculate font sizes
text_font_size=$((y_mon * 2 / 100))
icon_font_size=30
text_font_size_hover=$(echo "$text_font_size * 1.2 / 1" | bc)
icon_font_size_hover=$(echo "$icon_font_size * 1.2 / 1" | bc)

# Export variables used by wlogout style.css
export background_image="file:${path}/curtains-close.jpg"
export button_size="${button_size}px"
export text_font_size="${text_font_size}px"
export text_font_size_hover="${text_font_size_hover}px"
export icon_font_size="${icon_font_size}pt"
export icon_font_size_hover="${icon_font_size_hover}pt"

envsubst <$css_path
