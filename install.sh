#!/bin/bash

TIME_FORMAT="[%Y-%m-%d][%H:%I:%S]"
#LOGFILE=subuntu-setup.log

source './include/repos.sh'

# Declare arrays to hold package lists
declare -a BASE_PKGS
declare -a LIB_PKGS
declare -a TOOLS_PKGS

### === HELPER FUNCTIONS === ###

function package_selection() { # !! NOT IN USE (YET)
	# $1 - CSV input file
	# $2 - list type ("checklist" or "radiolist")
	# $3 - window text
	#TODO: Figure out how to properly use dialog within a function
	#TODO2: Find a way to dinamically scale the item list

	input=$1
	while IFS=',' read -r col1 col2 col3 dummy
	do
   		array+=("$col1")
   		array+=("$col2")
   		array+=("$col3")
	done < <(tail -n +2 "$input")

	option=$(dialog --checklist --backtitle "System Configuration" --output-fd 1 "Choose packages:" 14 80 8 "${array[@]}")

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    		return $option
	else
    		return 1
	fi

}

function run_cmd() { # Runs a command and deals with the exit code
    # Code snippet found here: 
    # https://stackoverflow.com/questions/372116/what-is-the-best-way-to-write-a-wrapper-function-that-runs-commands-and-logs-thei
    "$@" > /dev/null 
    ret=$?
    if [[ $ret -eq 0 ]]
    then
        echo "`date +$TIME_FORMAT`[INFO]Successfully ran [ $@ ]" >> $LOGFILE
    else
        echo "`date +$TIME_FORMAT`[ERROR]Command [ $@ ] returned $ret" >> $LOGFILE
	echo "ERROR!"
        return $ret
    fi
}

function install_scim() { # Build and install sc-im
	dialog --title "Setup" --infobox "Installing sc-im.." 3 40; sleep 2
	cd $SU_SCRIPT_ROOT/$REPO_FOLDER
	dialog --title "sc-im setup" --infobox "==> Setting up libxlsxwriter..." 3 40
	run_cmd git clone $GIT_XLSXWRITER &>> $LOGFILE
	cd libxlsxwriter/ &>>$LOGFILE
	run_cmd make &>> $LOGFILE
	run_cmd make install &>> $LOGFILE
	run_cmd ldconfig &>> $LOGFILE

	dialog --title "sc-im setup" --infobox "==> Setting up sc-im..." 3 40
	cd $SU_SCRIPT_ROOT/$REPO_FOLDER
	run_cmd git clone $GIT_SCIM &>> $LOGFILE
	cd sc-im/src
	run_cmd make &>> $LOGFILE
	run_cmd make install &>> $LOGFILE

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
			BASE_PKGS+=($name)
		elif [ "$type" = "lib" ]
		then
			LIB_PKGS+=($name)
		elif [ "$type" = "tools" ]
		then
			TOOLS_PKGS+=($name)
		fi

	done < $PKG_LIST
}

function install_min() { # Install the Min browser
	if [ "`uname -m`" = "x86_64" ]
	then
		dialog --title "Setup" --infobox "Installing the Min browser..." 3 40
		# TODO: Automatically fetch the latest stable package
		wget https://github.com/minbrowser/min/releases/download/v1.11.1/min_1.11.1_amd64.deb &>> $LOGFILE
		dpkg -i min_1.11.1_amd64.deb &>> $LOGFILE
		dialog --title "Setup" --infobox "Adding dependencies required by the Min browser..." 3 60
		apt-get install -f -y &>> $LOGFILE
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
			dialog --title "Setup" --infobox "Installing $tool..." 3 50
			apt-get install -y $tool &>> $LOGFILE
		fi
	done

}
function configure_system() { # The main function, executing the steps in order
	###### Place the default wallpapers in $HOME directory
	dialog --title "Configuring system" --infobox "Copying the included wallpapers..." 3 40
	mkdir -pv /home/$USERNAME/Photos/Wallpapers/ &>> $LOGFILE
	cp -v wallpapers/* /home/$USERNAME/Photos/Wallpapers/ &>> $LOGFILE

	dialog --title "Configuring system" --infobox "Updating the available packages list..." 3 50
	apt-get update >> $LOGFILE

	dialog --title "Configuring system" --infobox "Installing base packages..." 3 40; sleep 2
	install_packages "${BASE_PKGS[@]}"

	dialog --title "Configuring system" --infobox "Installing libraries..." 3 40; sleep 2
	install_packages "${LIB_PKGS[@]}"

	dialog --title  "Configuring system" --infobox "Installing additional tools..." 3 40; sleep 2
	install_packages "${TOOLS_PKGS[@]}"

	install_additional_tools "${TOOLS[@]}"

	suckless_tools_setup "${SUCKLESS_TOOLS[@]}"

	if [ "$XLOGIN" = "0" ]
	then
		dialog --title "GUI login" --infobox "Setting up graphical login..." "3 50"
		###### Make config directories
  		mkdir -v /home/$USERNAME/.config &>> $LOGFILE 
		mkdir -v /home/$USERNAME/.config/gtk-3.0 &>> $LOGFILE
		setup_gui_login
	fi

	if [ "$HOURLY_WALL" = "0"]
	then
		dialog --title "Misc" --infobox "Setting up hourly wallpapers..." "3 50"
		set_hourly_wallpaper
	fi

	dialog --title "Wrapping up" --infobox "Setting user permissions..." 3 40
	chown $USERNAME:$USERNAME -R /home/$USERNAME/
	chmod g+s /home/$USERNAME/
	setfacl -d -m g::rwx /home/$USERNAME/
	setfacl -d -m o::rx /home/$USERNAME/

	# Clean things up
	cleanup

	# Done
	dialog --title "ALL DONE!" --msgbox "Your new Suckless Ubuntu 18.04 has been prepared, based on the options you've selected.\\n\\n Just reboot and enjoy!" 10 60
}

function setup_gui_login() { # Setup LightDM and XSession entries
	dialog --title "Setup" --infobox "Installing lightdm and its dependencies..." 3 60
	apt-get install -y lightdm &>> $LOGFILE
        apt-get install -y lightdm-gtk-greeter &>> $LOGFILE
	apt-get install -y lightdm-gtk-greeter-settings &>> $LOGFILE
	
	dialog --title "Setup" --infobox "Configuring lightdm, XSession and desktop entries..." 3 80
	cd $SU_SCRIPT_ROOT
	###### Apply GTK theme, fonts, icon theme, login greeter
	cp -f configs/gtk/gtk-3.0/settings.ini /home/$USERNAME/.config/gtk-3.0/settings.ini
	cp -f configs/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

	mkdir /usr/share/xsessions
	echo "#!/bin/sh
	feh --bg-fill \"/home/$USERNAME/Photos/Wallpapers/`ls /home/$USERNAME/Photos/Wallpapers/ | shuf -n 1`\"
        slstatus&
	exec /usr/local/bin/dwm > /dev/null" > /usr/local/bin/dwm-start

	echo "[Desktop Entry]
	background = /home/$USERNAME/Photos/Wallpapers/login.jpg
	Encoding=UTF-8
	Name=dwm
	Comment=This session starts dwm
    	Exec=/usr/local/bin/dwm-start
        Type=Application" > /usr/share/xsessions/dwm-greeter.desktop

	chmod a+x /usr/local/bin/dwm-start

}

function set_hourly_wallpaper() {
	echo "#!/bin/bash
	feh --bg-fill \"/home/$USERNAME/Photos/Wallpapers/`ls /home/dragos/Photos/wallpaper/ | shuf -n 1`\"" >> /etc/cron.hourly/wallpaper
}

function install_packages() { # Generic function for installing a package
        array=("$@")
	for pkg in "${array[@]}"
	do
		dialog --backtitle "Software Setup" --infobox "Installing $pkg..." 3 60
		apt-get install -y $pkg &> $LOGFILE
	done
}

function suckless_tools_setup() { # Fetch, build & install suckless tools
	tool_array=("$@")
	dialog --infobox "Will now fetch & build suckless.org tools..." 3 80; sleep 2

	###### Fetch the latest sources
	cd $SU_SCRIPT_ROOT/$REPO_FOLDER
	IFS=' '
	read -ra TMPTOOLSET <<< $tool_array
	for tool in "${TMPTOOLSET[@]}"
	do
		dialog --title "Suckless tools" --infobox "Getting sources for $tool..." 3 60
		if [ "$tool" = "st" ]
		then
			git clone $GIT_LUKE_ST &>> $LOGFILE
		else
			git clone $GIT_SUCKLESS/$tool &>> $LOGFILE
		fi
	done

	# Go back to the setup script folder
	cd $SU_SCRIPT_ROOT

	# Copy dwm & slstatus configs
	cp -f configs/suckless/dwm-config.h $REPO_FOLDER/dwm/config.h
	cp -f configs/suckless/slstatus-config.h $REPO_FOLDER/slstatus/config.h

	##### COMPILE SUCKLESS.ORG SOFTWARE #####
	for tool in "${TMPTOOLSET[@]}"
	do
		dialog --title "Suckless tools" --infobox "Compiling $tool..." 3 60
		cd $SU_SCRIPT_ROOT/$REPO_FOLDER/$tool 
		make clean install &>> $LOGFILE
	done

	# Update .xinitrc
	echo "feh --bg-fill \"/home/$USERNAME/Photos/Wallpapers/login.jpg\"
	slstatus&
	exec dwm" >> /home/$USERNAME/.xinitrc
}

function cleanup() {
	dialog --title "Wrapping up" --infobox "Cleaning up..." 3 60; sleep 2
	rm -rf $SU_SCRIPT_ROOT/$REPO_FOLDER
}

# === SCRIPT EXECUTION STARTS HERE ===

echo "Loading, please wait..."
# Get the absolute path of the current script
SU_SCRIPT_ROOT=`pwd`

# Temporary source file storage
REPO_FOLDER=git
mkdir $SU_SCRIPT_ROOT/$REPO_FOLDER

CHOSEN_WM="dwm"
TERM_EMULATOR=st
ST_OPTION="default"
SURF_OPTION="default"
LOGFILE=$SU_SCRIPT_ROOT/suckless-ubuntu-setup.log
# Make sure dialog is installed
run_cmd apt-get install -y dialog
# Read the packages from the CSV file
load_pkg_list $SU_SCRIPT_ROOT/packages/pkg-list.csv

sleep 5
# A nice, warm welcome
dialog --title "Welcome!" --msgbox "Hey, there! \\n\\nThis is the Suckless Ubuntu setup tool.\\nIt will guide you through the setup process in order to gather relevant data. It won't take long ;)" 10 60

# Get the user name
USERNAME=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit

# Get the additional tools that will be installed
TOOLS=$(dialog --backtitle "Suckless Ubuntu Setup" --checklist "Additional tools:" 16 70 7 \
	min "A minimal & focused browser built on Electron" on \
	lf "Clean & innovative console file manager, written in Go" on \
	lftp "A very powerful command line FTP/FTPS client" on \
	scim "Versatile vim-like spreadsheet program (CLI)" on \
	xbacklight "Control screen brightness" on \
	redshift "Night mode for your screen" on \
	cups "Utilities for using printers" on \
	3>&1 1>&2 2>&3 3>&1)
#$TOOLS=$(package_selection "./include/tools.csv")

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
