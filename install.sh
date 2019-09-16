#!/bin/sh

#------------------------------------------------------------------#
#                          INSTALL Focused                     #
#------------------------------------------------------------------#


###### Place the default wallpaper in $HOME directory
cp wallpaper.jpg ~/.wallpaper.jpg

###### Setup Ubuntu main and unofficial repositories as well as
###### other repositories which will simplify further installations
cp -f sources.list ~/.sources.list

###### Update to the last package lists
apt-get update # To get the latest package lists

###### Install main apps, drivers and dependencies
apt-get install -y ubuntu-drivers-common
# apt-get install -y ubuntu-restricted-extras
apt-get install -y ubuntu-docs
apt-get install -y ttf-ubuntu-font-family
apt-get install -y libnm-gtk-common
apt-get install -y openssh-client
apt-get install -y evince evince-common
apt-get install -y lightdm
apt-get install -y x11-xserver-utils
apt-get install -y arandr
apt-get install -y dconf dconf-tools
apt-get install -y python-gconf
apt-get install -y vim vim-common
apt-get install -y gnome-system-monitor gnome-system-tools
apt-get install -y network-manager
apt-get install -y network-manager-gnome
apt-get install -y network-manager-openvpn
apt-get install -y network-manager-openvpn-gnome
apt-get install -y wireless-tools
apt-get install -y lightdm-gtk-greeter
apt-get install -y lightdm-gtk-greeter-settings
apt-get install -y overlay-scrollbar overlay-scrollbar-gtk2
apt-get install -y brasero
apt-get install -y gnome-bluetooth
apt-get install -y libbluetooth3 libgnome-bluetooth13
apt-get install -y pulseaudio-module-bluetooth
apt-get install -y pulseaudio-module-x11
apt-get install -y pactl xbacklight
apt-get install -y rofi compton
apt-get install -y git
apt-get install -y i3 i3-wm i3blocks i3lock i3status
apt-get install -y xserver-xorg-video-intel
apt-get install -y acpi-support
apt-get install -y apport-gtk
apt-get install -y cups cups-bsd cups-client cups-filters
apt-get install -y foomatic-db-compressed-ppds
apt-get install -y openprinting-ppds
apt-get install -y bluez
apt-get install -y bluez-cups
apt-get install -y hplip
apt-get install -y system-config-printer-gnome
apt-get install -y indicator-printers
apt-get install -y python3-aptdaemon.pkcompat
apt-get install -y libssh-4 libnm-glib-vpn1
apt-get install -y xfonts-base xfonts-encodings
apt-get install -y xfonts-scalable xfonts-utils
apt-get install -y libxfont1 libfont-afm-perl
apt-get install -y libfontconfig1 libfontembed1
apt-get install -y libfontenc1 gnome-font-viewer
apt-get install -y fontconfig fontconfig-config
apt-get install -y dmz-cursor-theme libwayland-cursor0
apt-get install -y libxcursor1 xcursor-themes
apt-get install -y laptop-detect
apt-get install -y update-inetd update-notifier
apt-get install -y update-notifier-common
apt-get install -y usb-creator-common usb-creator-gtk
apt-get install -y gnome-power-manager
apt-get install -y libgsettings-qt1
apt-get install -y libproxy1-plugin-gsettings
apt-get install -y libappindicator3-1
apt-get install -y gir1.2-appindicator3-0.1 gdebi
apt-get install -y feh
apt-get install -y abiword gnumeric

###### Get and install playerctl
wget 'https://github.com/acrisci/playerctl/releases/download/v0.5.0/playerctl-0.5.0_amd64.deb'
dpkg -i playerctl-0.5.0_amd64.deb
rm -rf playerctl-0.5.0_amd64.deb

###### Set appropriate user permissions
chown $(whoami):$(whoami) -R /home/$(whoami)/
chmod g+s /home/$(whoami)/
setfacl -d -m g::rwx /home/$(whoami)/
setfacl -d -m o::rx /home/$(whoami)/

###### Make config directories
mkdir ~/.config
mkdir ~/.config/gtk-3.0
mkdir ~/.config/i3

###### Apply GTK theme, fonts, icon theme, login greeter
###### and i3
cp -f Ubuntu-Focused/configs/gtk/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
#cp -f Ubuntu-Focused/configs/gtk/.gtkrc-2.0 ~/.gtkrc-2.0
cp -f Ubuntu-Focused/configs/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
cp -f Ubuntu-Focused/configs/i3/config ~/.config/i3/config

##### Install the Min browser
wget https://github.com/minbrowser/min/releases/download/v1.11.0/min_1.11.0_amd64.deb
sudo dpkg -i min_1.11.0_amd64.deb
rm dpkg -i min_1.11.0_amd64.deb

###### Set wallpaper
echo "feh --bg-fill ~/.wallpaper.jpg" >> ~/.profile
