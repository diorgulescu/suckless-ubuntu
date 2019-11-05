#!/bin/bash

TIME_FORMAT="[%Y-%m-%d][%H:%I:%S]"

function log_info() {
	logger "[INFO] $1" -tsuckless-ubuntu
}

function log_error() {
	logger -s "[ERROR] $1" -tsuckless-ubuntu
}

function msg(){ # Displays a message box with the given attributes
	dialog --backtitle "$1" --msgbox "$2" $3
}

function run() { # Runs a command in a controlled fashion, with logging
	log_info $2 && exec $1 2>> log_error >> /dev/null
}
