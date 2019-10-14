#!/bin/bash

### PACKAGE LISTS ###
base_pkgs=(
	"openssh-client" 
	"x11-xserver-utils" 
	"python-gconf" 
	"vim" 
	"vim-common" 
	"network-manager" 
	"network-manager-openvpn" 
	"wireless-tools" 
	"libbluetooth3" 
	"pulseaudio-module-bluetooth" 
	"pulseaudio-module-x11" 
	"xserver-xorg-video-intel" 
	"acpi-support" 
	"cups" 
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
        "xinit"	
)

lib_pkgs=(
	"libssh-4"
	"libnm-glib-vpn1"
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
	"libjpeg-dev"
	"libncurses-dev"
	"libncursesw5-dev libzip-dev libzip4"
)

tools_pkgs=(
	"xbacklight redshift git"
	"feh setfacl"
	"lftp curl"
)

function install_scim() {
	git clone https://github.com/jmcnamara/libxlsxwriter.git
	cd libxlsxwriter/
	make
	make install
	ldconfig
	cd ..

	git clone https://github.com/andmarti1424/sc-im.git
	cd sc-im/src
	make
	make install

}
function display_help() {
	echo "TODO"
}

function install_min() {
	wget https://github.com/minbrowser/min/releases/download/v1.11.1/min_1.11.1_amd64.deb
	dpkg -i min_1.11.1_amd64.deb
	apt-get install -f
	rm min_1.11.1_amd64.deb
}

function configure_system() {
	###### Place the default wallpaper in $HOME directory
	echo "-------======== [ SUCKLESS UBUNTU SETUP SCRIPT ] ========-------"
	echo "Copying the default wallpaper..."
	cp wallpaper.jpg /home/$USER/.wallpaper.jpg

	echo "Updating the available packages list..."
	apt-get update # To get the latest package lists

	echo "==> Installing base packages..."
	install_packages "${base_pkgs[@]}"

	echo "==> Installing libraries..."
	install_packages "${lib_pkgs[@]}"

	echo "==> Installing additional tools..."
	install_packages "${tools_pkgs[@]}"
	
	echo "==> Setting up suckless.org tools..."
	suckless_tools_setup

	if [ "$XLOGIN" = "yes" ]
	then
		###### Make config directories
  		mkdir /home/$USER/.config
		mkdir /home/$USER/.config/gtk-3.0
		setup_gui_login
	fi

	echo "==> Trying to set user permissions"
	chown $USER:$USER -R /home/$USER/
	chmod g+s /home/$USER/
	setfacl -d -m g::rwx /home/$USER/
	setfacl -d -m o::rx /home/$USER/
}

function setup_gui_login() {
	apt-get install -y "lightdm lightdm-gtk-greeter lightdm-gtkgreeter-settings"
	
	###### Apply GTK theme, fonts, icon theme, login greeter
	cp -f configs/gtk/gtk-3.0/settings.ini /home/$USER/.config/gtk-3.0/settings.ini
	cp -f configs/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

	echo "#!/bin/sh
	feh --bg-fill .wallpaper.jpg
        slstatus &
	st&
	exec /usr/local/bin/dwm > /dev/null" >> /usr/local/bin/dwm-start

	echo "[Desktop Entry]
	Encoding=UTF-8
	Name=dwm
	Comment=This session starts dwm
    	Exec=/usr/local/bin/dwm-start
        Type=Application" >> /usr/share/xsessions/dwm.desktop

}

function install_packages() {
        array=("$@")
	for pkg in "${array[@]}"
	do
		echo "==> [SETUP][INFO] Installing $pkg..."
		apt-get install -y $pkg
	done
}

function suckless_tools_setup() {
	###### Create the folder in which sources from suckless.org will be saved
	mkdir /home/$USER/suckless-sources

	###### Fetch the latest sources
	cd /home/$USER/suckless-sources
	git clone git://git.suckless.org/dmenu
	
	# Using Luke Smith's ST build, since he added nice handy customizations
	git clone https://github.com/LukeSmithxyz/st.git

	git clone git://git.suckless.org/surf
	git clone git://git.suckless.org/dwm
	git clone git://git.suckless.org/slstatus
	git clone git://git.suckless.org/tabbed
	git clone git://git.suckless.org/farbfeld
	git clone git://git.suckless.org/slock
	git clone git://git.suckless.org/sent

	# Go back to the setup script folder
	cd -

	# Copy dwm & slstatus configs
	cp -f configs/dwm-config.h /home/$USER/suckless-sources/dwm/config.h
	cp -f configs/slstatus-config.h /home/$USER/suckless-sources/slstatus/config.h

	# Now, back to the suckless-sources folder...
	cd -

	##### COMPILE SUCKLESS.ORG SOFTWARE #####
	for FOLDER in $(ls -d /home/$USER/suckless-sources/*/)
	do
		cd $FOLDER; make clean install
	done

	# Update .xinitrc
	echo "feh --bg-fill .wallpaper.jpg
	slstatus &
	st&
	exec dwm" >> /home/$USER/.xinitrc
}

while getopts u:xlogin:h option
do
	case "${option}"
		in
		u) USER=${OPTARG};;
		xlogin) XLOGIN=${OPTARG};;
		h) display_help
	esac
done


configure_system
