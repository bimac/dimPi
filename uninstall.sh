#!/bin/bash

# Check for root
if [[ "$EUID" -ne 0 ]]; then
	echo "Please run as root."
	exit 1
fi

if `systemctl is-active --quiet dimPi.service`; then
	systemctl stop dimPi.service
fi

if `systemctl list-units --full -all | grep -Fq "dimPi.service"`; then
	systemctl disable dimPi.service
fi

TMP="/etc/systemd/system/dimPi.service"
if test -f "$TMP"; then
	rm "$TMP"
	echo "Removed $TMP."
fi

TMP="/opt/dimPi"
if test -d "$TMP"; then
	rm -R "$TMP"
	echo "Removed $TMP/."
fi

TMP="/usr/local/bin/dimPi"
if test -h "$TMP"; then
	unlink "$TMP"
	echo "Removed $TMP."
fi

echo "Done."
