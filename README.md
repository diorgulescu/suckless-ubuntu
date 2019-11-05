Suckless Ubuntu
===============

This project aims at setting up a minimal Ubuntu installation built around tools provided by suckless.org, together with other options that will make the operating system functional. The main goal of the project is to achieve an Ubuntu-derived Linux distribution that has the concepts of deep work & focused attention at its core. The project was initially forked from Michael Staal-Olsens' i3buntu repository, but eventually became something different as I switched from using i3 to dwm. However, i3 was shortly added back as a window manager option, simply because I figured some users would love the look & feel any of these two provide, but find i3 to be more friendly and customizable.

Current goals:
* provide a selection of useful software, avoiding apps that may not be relevant for most users (in the end, additional packages can be installed acording to the user's wishes) while also trying to stick to simple & stable tools
* test support for Bluetooth devices, WiFi and power management, graphics and network drivers, including printers
* refine and 



# Requirements
* A version of Ubuntu Minimal (Ubuntu NetBoot). The latest version is to be located here: https://help.ubuntu.com/community/Installation/MinimalCD.
* An internet connection.
* A computer which supports the network drivers that come with the Ubuntu Minimal image (wireless adapters work, too).

# Known issues
## No 'settings.json' for Min
This seems more like an edge case, but it was reported. If the browser fails to start, just make sure the appropriate permissions are set for the .config folders. To make sure, one may also create the file:
*chown $(whoami):$(whoami) -R .config/
touch ~/.config/Min/settings.json*

However, this should not happen since the install script does this beforehand. TODO: investigate if this behaviour keeps reappearing.

# Installation

##### 1. Download and install Ubuntu Minimal (NetBoot)

Simply use the Ubuntu Minimal CD image to create a bootable device (a USB flash or a CD/DVD). Run through the installation wizzard and do NOT select any additional packages when prompted. This way, only the default base system will be installed. 

Once the installation finishes, reboot into your new system (console only, for now)

##### 2. Download and prepare the Suckless Ubuntu installation files

Once logged in, download the "install files"
```
wget https://github.com/suckless-ubuntu/setup-tool/archive/master.tar.gz
```
and hit `ENTER`. This will download the most recent version from this GitHub account. Now type the following:
```
tar -xvzf master.tar.gz
```
and hit `ENTER`. This will extract the installation package.

##### 3. Install Suckless Ubuntu

Now type the following in the terminal:
```
cd setup-tool-master
sudo chmod +x install.sh
sudo ./install.sh
```
It is very important that you remember to include `sudo`. At some point you will be prompted to type your user password. Do this and hit `ENTER`. When the setup is complete, reboot.

# Feedback
This is a personal effort in building a Linux distribution that suits me and the way I like to work and interact with technology: in a simple, straightforward and efficient manner. This means all other "eye candy" & apps that are generally preinstalled are considered nothing but noise and stuff that do nothing than distract me.

I will write more on this as time goes by, as I also aim at providing a friendly & detailed guide for this approach, along with more philosophical topics that regard a balanced and peaceful life.

All suggestions are appreciated - and people may of course also fork the project.

# Acknowledgment
Many thanks to Michael Staal-Olsen for his efforts. This project was initially based on his work for i3buntu.
