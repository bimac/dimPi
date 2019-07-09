#!/bin/bash

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

# Identify Ethernet adapter
REGEXP_ID="[[:alnum:]]{4}:[[:alnum:]]{4}(?=.*Ethernet)"
HWID=$(lsusb | grep -o -P -m1 $REGEXP_ID)
if [[ $HWID == "0424:ec00" ]]; then
	LEDCTL="lan951x-led-ctl"
	echo "Detected LAN9512/LAN9514-Ethernet conroller."
elif [[ $HWID == "0424:7800" ]]; then
	LEDCTL="lan7800-led-ctl"
	echo "Detected LAN7800-Ethernet controller."
else
	LEDCTL=""
	echo "No supported Ethernet controller found."
fi

# Compile and install LEDCTL
if ! [[ -z "$LEDCTL" ]]; then

	# Compile LEDCTL
	echo "Compiling $LEDCTL ..."
	(cd "$BASEDIR/$LEDCTL" && make)

	# Copy LEDCTL to /usr/local/bin
	cp --no-preserve=owner "$BASEDIR/$LEDCTL/$LEDCTL" "$TARGETDIR"
	echo "Copyied $LEDCTL to $TARGETDIR."

	# Create symlink to LEDCTL
	ln -sf "$TARGETDIR/$LEDCTL" "$TARGETDIR/led-ctl"
	echo "Created symlink $TARGETDIR/led-ctl → $TARGETDIR/$LEDCTL."
fi

# Copy dimPi.sh to target directory
echo "Copying dimPi.sh to $TARGETDIR ..."
cp --no-preserve=owner "$BASEDIR/dimPi.sh" "$TARGETDIR"

# Create symlink to dimPi
ln -sf "$TARGETDIR/dimPi.sh" "/usr/local/bin/dimPi"
echo "Created symlink /usr/local/bin/dimPi → $TARGETDIR/dimPi.sh."

# Copy system.d service
cp --no-preserve=owner $BASEDIR/dimPi.service /etc/systemd/system
echo "Copyied dimPi.service to /etc/systemd/system."

# Enable and start dimPi service
systemctl enable dimPi.service
systemctl start dimPi.service

echo "Done."
