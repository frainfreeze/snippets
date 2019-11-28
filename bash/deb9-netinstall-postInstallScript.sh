#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
clear

apt install -y menu obmenu obsession openbox xorg network-manager xfce4-panel xfce4-cpugraph-plugin 
mkdir -p /home/frain/.config/openbox/
cp /var/lib/openbox/debian-menu.xml /home/frain/.config/openbox/debian-menu.xml
cp /etc/xdg/openbox/menu.xml /home/frain/.config/openbox/menu.xml
cp /etc/xdg/openbox/rm.xml /home/frain/.config/openbox/rc.xml
cp /home/frain/.bashrc /tmp/.bashrc && \awk '/force_color_prompt=/ { gsub(/#force/, "force") }; { print }' /tmp/.bashrc > /home/frain/.bashrc
chown -R frain:frain /home/frain/
echo "xset b off" >> /home/frain/.config/openbox/autostart
echo "(sleep 1s && xfce4-panel) &" >> /home/frain/.config/openbox/autostart
echo "(sleep 1s && nitrogen --restore) &" >> /home/frain/.config/openbox/autostart
#after using nitrogen manually, the above command will restore the last used wallpaper on reboot/login.
openbox --reconfigure

clear
apt install -y mousepad thunar \
curl feh nitrogen rsync vim vlc \
gparted imagemagick build-essential \
git p7zip-full p7zip-rar screen sshfs xfce-terminal

cp /home/frain/.Xresources /home/frain/.Xdefaults
