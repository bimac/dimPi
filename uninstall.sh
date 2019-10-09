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
