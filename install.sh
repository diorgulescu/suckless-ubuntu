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
	"git"
	"feh" 
	"setfacl"
)

function install_scim() {
	echo "==> Installing sc-im.."
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
	cd ..

}

function display_help() {
	echo "TODO"
}

function install_min() {
	echo "==> Installing the Min browser..."
	wget https://github.com/minbrowser/min/releases/download/v1.11.1/min_1.11.1_amd64.deb
	dpkg -i min_1.11.1_amd64.deb
	apt-get install -f -y
	rm min_1.11.1_amd64.deb
}

function install_additional_tools() {
	array=("$@")

	IFS=' '
	read -ra TMPTOOLSET <<< $array
	for tool in "${TMPTOOLSET[@]}"
	do
		if [ "$tool" = "min" ]
		then
			install_min
		elif [ "$tool" = "scim" ]
		then
			install_scim
		else
			apt-get install -y $tool
		fi
	done

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
	install_additional_tools "${TOOLS[@]}"
	
	echo "==> Setting up suckless.org tools..."
	suckless_tools_setup "${SUCKLESS_TOOLS[@]}"

	if [ "$XLOGIN" = "0" ]
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

	# Clean things up
	cleanup

	# Done
	dialog --title "ALL DONE!" --msgbox "Your new Suckless Ubuntu 18.04 has been prepared, based on the options you've selected.\\n\\n Just reboot and enjoy!" 10 60
}

function setup_gui_login() {
	apt-get install -y lightdm
        apt-get install -y lightdm-gtk-greeter 
	apt-get install -y lightdm-gtk-greeter-settings
	
	cd $SU_SCRIPT_ROOT
	###### Apply GTK theme, fonts, icon theme, login greeter
	cp -f configs/gtk/gtk-3.0/settings.ini /home/$USER/.config/gtk-3.0/settings.ini
	cp -f configs/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

	echo "Creating XSessions folder and session entry for DWM..."
	mkdir /usr/share/xsessions

	echo "#!/bin/sh
	feh --bg-fill \"/home/$USER/.wallpaper.jpg\"
        slstatus&
	dmenu&
	st&
	exec /usr/local/bin/dwm > /dev/null" >> /usr/local/bin/dwm-start

	echo "[Desktop Entry]
	background = /home/$USER/.wallpaper.jpg
	Encoding=UTF-8
	Name=dwm
	Comment=This session starts dwm
    	Exec=/usr/local/bin/dwm-start
        Type=Application" >> /usr/share/xsessions/dwm-greeter.desktop

	chmod a+x /usr/local/bin/dwm-start

}

function install_packages() {
        array=("$@")
	for pkg in "${array[@]}"
	do
		echo "===>>>Now installing $pkg and its dependencies. Please wait..." 
		apt-get install -y $pkg
	done
}

function suckless_tools_setup() {
	tool_array=("$@")
	dialog --infobox "Will now fetch & build suckless.org tools..." 3 80; sleep 4

	###### Create the folder in which sources from suckless.org will be saved
	mkdir /home/$USER/suckless-sources

	###### Fetch the latest sources
	cd /home/$USER/suckless-sources
	IFS=' '
	read -ra TMPTOOLSET <<< $tool_array
	for tool in "${TMPTOOLSET[@]}"
	do
		echo "[--------------------------------- $tool ]"
		git clone git://git.suckless.org/$tool
	done
	# Using Luke Smith's ST build, since he added nice handy customizations
	#git clone https://github.com/LukeSmithxyz/st.git

	# Go back to the setup script folder
	cd $SU_SCRIPT_ROOT

	# Copy dwm & slstatus configs
	cp -f configs/dwm-config.h /home/$USER/suckless-sources/dwm/config.h
	cp -f configs/slstatus-config.h /home/$USER/suckless-sources/slstatus/config.h

	# Now, back to the suckless-sources folder...
	#cd -

	##### COMPILE SUCKLESS.ORG SOFTWARE #####
	#for FOLDER in $(ls -d /home/$USER/suckless-sources/*/)
	for tool in "${TMPTOOLSET[@]}"
	do
		echo "[ --------------- compiling $tool ]"
		cd /home/$USER/suckless-sources/$tool 
		make clean install
		echo "                       [ DONE ]"
	done

	# Update .xinitrc
	echo "feh --bg-fill .wallpaper.jpg
	slstatus &
	st&
	exec dwm" >> /home/$USER/.xinitrc
}

function cleanup() {
	rm -rf $SU_SCRIPT_ROOT/sc-im
	rm -rf $SU_SCRIPT_ROOT/libxlsxwriter
}

dialog --title "Welcome!" --msgbox "Hey, there! \\n\\nThis is the Suckless Ubuntu setup script.\\nIt will guide you through the setup process in order to gather relevant data. It won't take long ;)" 10 60

USER=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit

TOOLS=$(dialog --backtitle "Suckless Ubuntu Setup" --checklist "Additional tools:" 16 70 6 \
	min "A minimal & focused browser built on Electron" on \
	lftp "A very powerful command line FTP/FTPS client" on \
	scim "Versatile vim-like spreadsheet program (CLI)" on \
	xbacklight "Control screen brightness" on \
	redshift "Night mode for your screen" on \
	cups "Utilities for using printers" on \
	3>&1 1>&2 2>&3 3>&1)

SUCKLESS_TOOLS=$(dialog --backtitle "suckless.org tools selection" \
	--checklist "Select which tools you want to include \\n(by default, the whole Suckless Ubuntu set is selected):" 17 80 12 \
	 dwm "Fast, lightweight and minimalist tiling window manager" on \
	 dmenu "Easy to use keyboard application launcher" on \
	 st "Simple terminal (Luke Smith's build)" on \
	 surf "Minimalist GUI web browser based on WebKit2/GTK+" on \
	 sent "Create slick presentations using Markdown" on \
	 slock "A simple screen locker" on \
	 slstatus "Customizable status bar for dwm" on \
	 farbfeld "Lossless image format" on \
	 tabbed "Create tabs for app windows" on \
	 3>&1 1>&2 2>&3 3>&1)

SU_SCRIPT_ROOT=`pwd`
dialog --infobox "Options gathered. Moving on..." 3 34 ; sleep 1

dialog --backtitle "System Configuration" --title "Graphical login"  --yesno "Do you want to use a graphical login (using lightdm)?" 10 30
XLOGIN=$?

configure_system

