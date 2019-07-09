#!/bin/bash

# This script needs to be run as root ...
if [[ "$EUID" -ne 0 ]]; then
	echo "Please run as root."
	exit 1
fi

# Check argument
VALIDARGS="Valid arguments are:\n\t0 - disable all LEDs\n\t1 - enable all LEDs\n\ts - set LEDs to default behavior\n"
if [[ $# -eq 0 ]]; then
	echo "No argument supplied."
	printf "$VALIDARGS"
	exit 1
elif [[ ! $1 =~ ^[01s]$ ]]; then
	echo "Wrong argument supplied."
	printf "$VALIDARGS"
	exit 1
fi

# Execute LEDCTL (if available)
LEDCTL="/usr/local/bin/lan-led-ctl"
if [[ -x $LEDCTL ]]; then
	($LEDCTL --fdx=$1 --lnk=$1 --spd=$1 &>/dev/null)
fi

# Toggle ACT & PWR LEDs
if [[ $1 == "0" || $1 == "1" ]]; then
	(echo gpio | sudo tee /sys/class/leds/led0/trigger) &>/dev/null
	(echo gpio | sudo tee /sys/class/leds/led1/trigger) &>/dev/null
	(echo $1 | sudo tee /sys/class/leds/led0/brightness) &>/dev/null
	(echo $1 | sudo tee /sys/class/leds/led1/brightness) &>/dev/null
elif [[ $1 == "s" ]]; then
	(echo cpu0 | sudo tee /sys/class/leds/led0/trigger) &>/dev/null
	(echo input | sudo tee /sys/class/leds/led1/trigger) &>/dev/null
fi
