#!/bin/bash

# Declare arrays to hold package lists
declare -a BASE_PKGS
declare -a LIB_PKGS
declare -a TOOLS_PKGS

### === HELPER FUNCTIONS === ###

function install_scim() { # Build and install sc-im
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

function load_pkg_list() { # Read the packages defined in pkg-list.csv
	PKG_LIST=$1
	
	while IFS=, read -r type name
	do
		if [ "$type" = "base" ]
		then
			BASE_PKGS+=('$name')
		elif [ "$type" = "lib" ]
		then
			LIB_PKGS+=('$name')
		elif [ "$type" = "tools" ]
		then
			TOOLS_PKGS+=('$name')
		fi

	done < $PKG_LIST
}

function install_min() { # Install the Min browser
	if [ "$(`uname -m`)" = "x86_64" ]
	then
		echo "==> Installing the Min browser..."
		wget https://github.com/minbrowser/min/releases/download/v1.11.1/min_1.11.1_amd64.deb
		dpkg -i min_1.11.1_amd64.deb
		apt-get install -f -y
		rm min_1.11.1_amd64.deb
	else
		dialog --infobox "Sorry, but the Min browser is only available for 64-bit platforms.\\nMoving on..." 4 80
		sleep 5
	fi
}

function install_additional_tools() { # Install additional tools
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
function configure_system() { # The main function, executing the steps in order
	###### Place the default wallpapers in $HOME directory
	echo "-------======== [ SUCKLESS UBUNTU SETUP SCRIPT ] ========-------"
	echo "Copying the included wallpapers..."
	mkdir -p /home/$USER/Photos/Wallpapers/
	cp wallpapers/* /home/$USER/Photos/Wallpapers/

	echo "Updating the available packages list..."
	apt-get update # To get the latest package lists

	echo "==> Installing base packages..."
	install_packages "${BASE_PKGS[@]}"

	echo "==> Installing libraries..."
	install_packages "${LIB_PKGS[@]}"

	echo "==> Installing additional tools..."
	install_packages "${TOOLS_PKGS[@]}"
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

	if [ "$HOURLY_WALL" = "0"]
	then
		set_hourly_wallpaper
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

function setup_gui_login() { # Setup LightDM and XSession entries
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
	feh --bg-fill \"`ls /home/$USER/Photos/Wallpapers/ | shuf -n 1`\"
        slstatus&
	exec /usr/local/bin/dwm > /dev/null" >> /usr/local/bin/dwm-start

	echo "[Desktop Entry]
	background = /home/$USER/Photos/Wallpapers/login.jpg
	Encoding=UTF-8
	Name=dwm
	Comment=This session starts dwm
    	Exec=/usr/local/bin/dwm-start
        Type=Application" >> /usr/share/xsessions/dwm-greeter.desktop

	chmod a+x /usr/local/bin/dwm-start

}

function set_hourly_wallpaper() {
	echo "#!/bin/bash
	feh --bg-fill \"`ls /home/dragos/Photos/wallpaper/ | shuf -n 1`\"" >> /etc/cron.hourly/wallpaper
}

function install_packages() { # Generic function for installing a package
        array=("$@")
	for pkg in "${array[@]}"
	do
		echo "===>>>Now installing $pkg and its dependencies. Please wait..." 
		apt-get install -y $pkg
	done
}

function suckless_tools_setup() { # Fetch, build & install suckless tools
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
		if [ "$tool" = "st" ]
		then
			git clone https://github.com/LukeSmithxyz/st.git 
		else
			git clone git://git.suckless.org/$tool
		fi
	done
	# Using Luke Smith's ST build, since he added nice handy customizations
	#git clone https://github.com/LukeSmithxyz/st.git

	# Go back to the setup script folder
	cd $SU_SCRIPT_ROOT

	# Copy dwm & slstatus configs
	cp -f configs/dwm-config.h /home/$USER/suckless-sources/dwm/config.h
	cp -f configs/slstatus-config.h /home/$USER/suckless-sources/slstatus/config.h

	##### COMPILE SUCKLESS.ORG SOFTWARE #####
	for tool in "${TMPTOOLSET[@]}"
	do
		echo "[ --------------- compiling $tool ]"
		cd /home/$USER/suckless-sources/$tool 
		make clean install
		echo "                       [ DONE ]"
	done

	# Update .xinitrc
	echo "feh --bg-fill \"/home/$USER/.wallpaper.jpg\"
	slstatus&
	exec dwm" >> /home/$USER/.xinitrc
}

function cleanup() {
	rm -rf $SU_SCRIPT_ROOT/sc-im
	rm -rf $SU_SCRIPT_ROOT/libxlsxwriter
}

# === SCRIPT EXECUTION STARTS HERE ===

# Get the absolute path of the current script
SU_SCRIPT_ROOT=`pwd`

# Read the packages from the CSV file
load_pkg_list $SU_SCRIPT_ROOT/packages/pkg-list.csv

sleep 5
# A nice, warm welcome
dialog --title "Welcome!" --msgbox "Hey, there! \\n\\nThis is the Suckless Ubuntu setup script.\\nIt will guide you through the setup process in order to gather relevant data. It won't take long ;)" 10 60

# Get the user name
USER=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit

# Get the additional tools that will be installed
TOOLS=$(dialog --backtitle "Suckless Ubuntu Setup" --checklist "Additional tools:" 16 70 6 \
	min "A minimal & focused browser built on Electron" on \
	lftp "A very powerful command line FTP/FTPS client" on \
	scim "Versatile vim-like spreadsheet program (CLI)" on \
	xbacklight "Control screen brightness" on \
	redshift "Night mode for your screen" on \
	cups "Utilities for using printers" on \
	3>&1 1>&2 2>&3 3>&1)

# Get a list of the suckless.org tools that will be installed
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

# Notify the user
dialog --infobox "Options gathered. Moving on..." 3 34 ; sleep 1

# Is graphical system login desired?
dialog --backtitle "System Configuration" --title "Graphical login"  --yesno "Do you want to use a graphical login (using lightdm)?" 10 30
XLOGIN=$?

# Does the user want to have a new wallpaper each hour?
dialog --backtitle "System Configuration" --title "Random hourly wallpaper"  --yesno "Do you want a different desktop wallpaper each hour?" 10 30
HOURLY_WALL=$?


# Start the process & enjoy the ride!
configure_system
cleanup
