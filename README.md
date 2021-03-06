# dimPi
dimPi is a simple shell script for controlling a Raspberry Pi's onboard LEDs (ACT, PWR, LNK, SPD and SND).
By default, it disables all LEDs directly after boot-up.
It contains `lan951x-led-ctl` [1] and `lan7800-led-ctl` [2] by Dominic Radermacher as git modules.

Use `git clone --recursive https://github.com/poulet-lab/dimPi.git` to obtain a local clone of the repository, including the submodules.
Change to the cloned `dimPi` directory and execute `install.sh` as root.
The install script will fetch the necessary dependencies, compile the sources and move everything in its place.
It will also enable `dimPi.service` to automatically disable all LEDs after booting up.

# Dependencies
* `gcc`
* `usbutils`
* `libusb-1.0-0-dev`

The dependencies are only necessary for compilation and installation.
The install script will try to fetch them automatically.

# Usage
dimPi takes a single argument:
  * `dimPi 0` - disable all LEDs,
  * `dimPi 1` - enable all LEDs, or
  * `dimPi s` - return all LEDs to their default state.
  
Alternatively, use the supplied systemd service:
  * `systemctl start dimPi` - disable all LEDs, or
  * `systemctl stop dimPi` - return all LEDs to their default state.

# Warning
So far, I have only tested the script on _Raspberry Pi Models 3B and 3B+_ running _Raspbian_. I expect it to run on all RaspberryPis using a _LAN951x_ or _LAN7800_ Ethernet controller and running a Debian derivative (_rasbian_, _Noobs_, ...). However, dimPi will currently **not** work correctly on a _Pi Zero_ board (this may be addressed at a later point).

# References
[1] https://mockmoon-cybernetics.ch/cgi/cgit/linux/lan951x-led-ctl.git  
[2] https://mockmoon-cybernetics.ch/cgi/cgit/linux/lan7800-led-ctl.git
