#!/bin/bash
dialog --title "Welcome!" --msgbox "Hey, there! This is the Suckless Ubuntu setup script.\\nIt will guide you through the setup process in order to gather relevant data." 10 60
name=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit

echo $name

dialog --checklist "Choose:" 15 40 5 \
	1 Linux off \
	2 Solaris on \
	3 'HP UX' off \
	4 AIX off

dialog --backtitle "suckless.org tools selection" \
	--radiolist "Select which tools you want to include (by default, the whole Suckless Ubuntu set is selected):" 20 80 10 \
	 1 "dwm" on \
	 2 "st (Luke Smith's build)" on \
	 3 "surf" off \
	 4 "sent" on \
	 5 "slock" on \
	 6 "slstatus" on \
	 7 "farbfeld" on \
	 8 "tabbed" on 

dialog --infobox "Processing, please wait" 3 34 ; sleep 3

xlogin=$(dialog --backtitle "System Configuration" --title "Graphical login"  --yesno "Do you want to use a graphical login (using lightdm)?" 10 30) || exit
