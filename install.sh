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

# Check for dependencies
DEPENDENCIES='gcc libusb-1.0-0-dev usbutils'
if ! dpkg -s $DEPENDENCIES >/dev/null 2>&1; then

	echo "Installing dependencies ..."

	# Test internet connectivity
	test=google.com
	if ! nc -dzw1 $test 443 > /dev/null 2>&1 && echo |openssl s_client -connect $test:443 2>&1 |awk '
		handshake && $1 == "Verification" { if ($2=="OK") exit; exit 1 }
		$1 $2 == "SSLhandshake" { handshake = 1 }'
	then
		echo "Cannot connect to the internet."
		exit 1
	fi

	# Install dependencies
	apt-get -y install $DEPENDENCIES > /dev/null
	if [[ $? -ne 0 ]]; then
		exit 1
	fi
fi

# Get current directory, define target directory
BASEDIR=$(cd `dirname $BASH_SOURCE` && pwd)
TARGETDIR="/opt/dimPi/bin"
mkdir -p "$TARGETDIR"

# compile LEDCTL
compile_ledctl() {
	echo "Compiling $1 ..."
	(cd "$BASEDIR/$1" && make)

	cp --no-preserve=owner "$BASEDIR/$1/$1" "$TARGETDIR"
	echo "Copied $1 to $TARGETDIR."
}
compile_ledctl "lan951x-led-ctl"
compile_ledctl "lan7800-led-ctl"

# Copy dimPi.sh to target directory
cp --no-preserve=owner "$BASEDIR/dimPi.sh" "$TARGETDIR"
echo "Copied dimPi.sh to $TARGETDIR."

# Create symlink to dimPi
ln -sf "$TARGETDIR/dimPi.sh" "/usr/local/bin/dimPi"
echo "Created symlink /usr/local/bin/dimPi → $TARGETDIR/dimPi.sh."

# Copy system.d service
cp --no-preserve=owner $BASEDIR/dimPi.service /etc/systemd/system
echo "Copied dimPi.service to /etc/systemd/system."

# Enable and start dimPi service
systemctl enable dimPi.service
systemctl start dimPi.service

echo "Done."
