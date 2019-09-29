#!/bin/sh

### PACKAGE LISTS ###
base_pkgs = (
	"openssh-client"
	"lightdm"
	"x11-xserver-utils"
	"python-gconf"
	"vim"
	"vim-common"
	"network-manager"
	"network-manager-openvpn"
	"wireless-tools"
	"lightdm-gtk-greeter"
	"lightdm-gtk-greeter-settings"
	"libbluetooth3"
	"pulseaudio-module-bluetooth"
	"pulseaudio-module-x11"
	"xserver-xorg-video-intel"
	"acpi-support"
	"cups"
	"cups-bsd"
	"cups-client"
	"cups-filters"
	"openprinting-ppds"
	"xfonts-base"
	"xfonts-encodings"
	"xfonts-scalable"
	"xfonts-utils"
	"fontconfig"
	"fontconfig-config"
	"dmz-cursor-theme"
	"xcursor-themes"
	"laptop-detect"

)

lib_pkgs = (
	"libssh-4"
	"libnm-glib-vpn1"
	"libxfont1"
	"libfont-afm-perl"
	"libfontconfig1"
	"libfontembed1"
	"libfontenc1"
	"libxcursor1"
	"libwayland-cursor0"
	"libbluetooth3"
	"libx11-xcb-dev"
	"libx11-dev"
	"libxinerama-dev"
	"libxft-dev"
	"libwebkitgtk-3.0-dev"
	"libgtk-3-dev"
	"libwebkit2gtk-4.0-dev"
	"libgcr-3-dev"
)

tools_pkgs = (
	"pactl xbacklight redshift git"
	"feh"
	"abiword gnumeric"
	"lynx xterm python3-pip python-pip"
)

#------------------------------------------------------------------#
#                          INSTALL Focused                     #
#------------------------------------------------------------------#


###### Place the default wallpaper in $HOME directory
cp wallpaper.jpg ~/.wallpaper.jpg

apt-get update # To get the latest package lists

### Installing basic packages
for file in ${base_pkgs[@]}
do
	apt-get install -y $file
done

for file in ${lib_pkgs[@]}
do
	apt-get install -y $file
done

for file in ${tools_pkgs[@]}
do
	apt-get install -y $file
done

###### Set appropriate user permissions
chown $(whoami):$(whoami) -R /home/$(whoami)/
chmod g+s /home/$(whoami)/
setfacl -d -m g::rwx /home/$(whoami)/
setfacl -d -m o::rx /home/$(whoami)/

###### Make config directories
mkdir ~/.config
mkdir ~/.config/gtk-3.0

###### Create the folder in which sources from suckless.org will be saved
mkdir ~/suckless-sources

###### Fetch the latest sources
cd ~/suckless-sources
git clone git://git.suckless.org/dmenu
git clone git://git.suckless.org/st
git clone git://git.suckless.org/surf
git clone git://git.suckless.org/dwm

##### COMPILE SUCKLESS.ORG SOFTWARE #####
for FOLDER in $(ls -d ~/suckless-sources/*/)
do
	cd $FOLDER; make clean install
done

###### Apply GTK theme, fonts, icon theme, login greeter
###### and i3
cp -f Ubuntu-Focused/configs/gtk/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
cp -f Ubuntu-Focused/configs/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

##### Install the Min browser
wget https://github.com/minbrowser/min/releases/download/v1.11.0/min_1.11.0_amd64.deb
sudo dpkg -i min_1.11.0_amd64.deb
rm -rf min_1.11.0_amd64.deb



###### Set wallpaper
echo "feh --bg-fill ~/.wallpaper.jpg" >> ~/.profile
