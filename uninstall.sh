#!/bin/bash

# Check for root
if [[ "$EUID" -ne 0 ]]; then
	echo "Please run as root."
	exit 1
fi

systemctl stop dimPi.service
systemctl disable dimPi.service
rm /etc/systemd/system/dimPi.service
rm -R /opt/dimPi
unlink /usr/local/bin/dimPi
