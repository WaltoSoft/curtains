#The sleep statements are necessary to ensure that the portals are not started until
#enough time has passed for things to be processed in order and that other 
#applications started in the autostart.conf file are executed

sleep 1
#kill running instances if they exist
killall -e xdg-desktop-portal-hyprland
killall xdg-desktop-portal

#start the portals
sleep 1
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &