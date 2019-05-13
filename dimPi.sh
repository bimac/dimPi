#!/bin/bash

# This script needs to be run as root ...
if [[ "$EUID" -ne 0 ]]; then
	echo "Please run as root."
	exit
fi

# Check argument
VALIDARGS="Valid arguments are:\n\t0 - disable all LEDs\n\t1 - enable all LEDs\n\ts - set LEDs to default behavior\n"
if [[ $# -eq 0 ]]; then
	echo "No argument supplied."
	printf "$VALIDARGS"
	exit
elif [[ ! $1 =~ ^[01s]$ ]]; then
	echo "Wrong argument supplied."
	printf "$VALIDARGS"
	exit
fi

# Check for usbutils
PKG_USB=$(dpkg-query -W --showformat='${Status}\n' usbutils|grep "install ok installed")
if [[ "" == "$PKG_USB" ]]; then
	echo "dimPi depends on the usbutils package - please provide it."
	exit
fi

# Obtain base directory of this BASH script
BASEDIR=$(cd `dirname $0` && pwd)

# Obtain hardware ID of Ethernet adapter
REGEXP_ID="[[:alnum:]]{4}:[[:alnum:]]{4}(?=.*Ethernet)"
HWID=$(lsusb | grep -o -P -m1 $REGEXP_ID)

# Set name of LEDCTL program
if [[ $HWID == "0424:ec00" ]]; then
	LEDCTL="lan951x-led-ctl"
elif [[ $HWID == "0424:7800" ]]; then
	LEDCTL="lan7800-led-ctl"
else
	LEDCTL=""
fi

# Compile LEDCTL if necessary
if [[ ! -z $LEDCTL && ! -x $BASEDIR/$LEDCTL/$LEDCTL ]]; then

	# Check for necessary packages
	PKG_GCC=$(dpkg-query -W --showformat='${Status}\n' gcc|grep "install ok installed")
	PKG_USB=$(dpkg-query -W --showformat='${Status}\n' libusb-1.0-0-dev|grep "install ok installed")
	if [[ "" == "$PKG_GCC" || "" == "$PKG_USB" ]]; then
		echo "Missing dependencies. Compilation of $LEDCTL requires gcc and libusb-1.0-0-dev."
		exit
		# echo "Installing dependencies ..."
		# (apt-get install gcc libusb-1.0-0-dev -y -qq)
	fi

	# Compile LEDCTL
	echo "Compiling $LEDCTL ..."
	(cd "$BASEDIR/$LEDCTL" && make)
fi

# Execute LEDCTL
if [[ ! -z $LEDCTL ]]; then
	($BASEDIR/$LEDCTL/$LEDCTL --fdx=$1 --lnk=$1 --spd=$1 &>/dev/null)
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
