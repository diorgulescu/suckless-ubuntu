Focused Linux
=============

This project is for setting up a minimal Ubuntu installation built around the i3 window manager, together with other options that will make the operating system functional. The main goal of the project is to achieve an Ubuntu-derived Linux distribution that has the concepts of deep work & focused attention at its core. The project was initially forked from Michael Staal-Olsens' i3buntu repository.

A minimal operating system aims at providing:
* a selection of useful software, avoiding apps that may not be relevant for most users (in the end, additional packages can be installed acording to the user's wishes)
* support for Bluetooth devices, WiFi and power management, graphics and network drivers, printers and media keys
* the i3 window manager as the default and only (preinstalled) window manager on the system. A number of customizations should be made in order for it to be both visually attractive and allow for productive workflows.
* the Min browser as the default graphical tools for surfing the Internet

# Requirements
* A version of Ubuntu Minimal (Ubuntu NetBoot). The latest version is to be located here: https://help.ubuntu.com/community/Installation/MinimalCD.
* An internet connection.
* A computer which supports the network drivers that come with the Ubuntu Minimal image.


# Installation

In the future, I aim at providing a distinct ISO that makes use of the official Ubuntu repositories. This way, it will be very easy for individuals to run through the installation process and boot directly into a working system.

Until then, the process described below is to be used..

##### 1. Download and install Ubuntu Minimal (NetBoot)

Simply use the Ubuntu Minimal CD image to create a bootable device (a USB flash or a CD/DVD). Run through the installation wizzard and do NOT select any additional packages when prompted. This way, only the default base system will be installed. 

Once the installation finishes, reboot into your new system (console only, for now)

##### 2. Download and prepare the i3buntu installation files

Once logged in, download the Focused Linux "install files"
```
wget https://github.com/diorgulescu/Focused-Linux/archive/master.tar.gz
```
and hit `ENTER`. This will download the most recent version of Focused Linux from this GitHub account. Now type the following:
```
tar -xvzf master.tar.gz
```
and hit `ENTER`. This will extract the installation package.

##### 3. Install Focused Linux

Now type the following in the terminal:
```
cd Focused-Linux-master
sudo chmod +x install.sh
sudo ./install.sh
```
It is very important that you remember to include `sudo`. At some point you will be prompted to type your user password. Do this and hit `ENTER`. When the setup is complete, reboot.

# Feedback
This is a personal effort in building a Linux distribution that suits me and the way I like to work and interact with technology: in a simple, straightforward and efficient manner. This means all other "eye candy" & apps that are generally preinstalled are considered nothing but noise and stuff that do nothing than distract me.

I will write more on this as time goes by, as I also aim at providing a friendly & detailed guide for this "OS", along with more philosophical topics that regard a balanced and peaceful life.

All suggestions are appreciated - and people may of course also fork the project.

# Acknowledgment
Many thanks to Michael Staal-Olsen for his efforts. This project is based on his work on i3buntu.
