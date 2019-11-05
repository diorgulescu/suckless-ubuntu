#!/bin/bash

function msg(){ # Displays a message box with the given attributes
	dialog --backtitle "$1" --msgbox "$2" $3
}

function run() { # Runs a command in a controlled fashion, with logging
	$1 2>> log_error >> log_info
}
