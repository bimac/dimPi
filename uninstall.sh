#!/bin/bash

# Check for root
if [[ "$EUID" -ne 0 ]]; then
	echo "Please run as root."
	exit 1
fi

# Stop and disable systemd service
if `systemctl list-units --full -all | grep -Fq "dimPi.service"`; then
	systemctl stop dimPi.service
	systemctl disable dimPi.service
fi

# Remove systemd service
TMP="/etc/systemd/system/dimPi.service"
if test -f "$TMP"; then
	rm "$TMP"
	echo "Removed $TMP."
fi

# Remove dimPi directory
TMP="/opt/dimPi"
if test -d "$TMP"; then
	rm -R "$TMP"
	echo "Removed $TMP/."
fi

# Remove symlink to dimPi
TMP="/usr/local/bin/dimPi"
if test -h "$TMP"; then
	unlink "$TMP"
	echo "Removed $TMP."
fi

echo "Done."
