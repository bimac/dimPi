#!/bin/bash

# Copyright (C) 2019 Florian Rau
#
# This file is part of dimPi.
#
# dimPi is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dimPi is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dimPi.  If not, see <https://www.gnu.org/licenses/>.

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

# Execute lan951x-led-ctl
if (lsusb | grep -q 0424:ec00); then
	(/opt/dimPi/bin/lan951x-led-ctl --fdx=$1 --lnk=$1 --spd=$1 &>/dev/null)
fi

# Execute lan7800-led-ctl
if (lsusb | grep -q 0424:7800); then
	(/opt/dimPi/bin/lan7800-led-ctl --led0=$1 --led1=$1 &>/dev/null)
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
