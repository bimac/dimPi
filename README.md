# dimPi
dimPi is a simple shell script for controlling a Raspberry Pi's onboard LEDs (ACT, PWR, LNK, SPD and SND).
It contains `lan951x-led-ctl` [1] and `lan7800-led-ctl` [2] by Dominic Radermacher as git modules.

Use `git clone --recursive https://github.com/poulet-lab/dimPi.git` to obtain a local clone of the repository, including the submodules.

The script will try to compile `lan951x-led-ctl` / `lan7800-led-ctl` as necessary.

# Dependencies
* `gcc`
* `usbutils`
* `libusb-1.0-0-dev`.

# Usage
dimPi takes a single argument:
  * `0` - disable all LEDs,
  * `1` - enable all LEDs, or
  * `s` - return all LEDs to their default state.

# Warning
So far, I have only tested the script on a _Raspberry Pi Model 3B_ running _Raspbian_. I expect it to run on all RaspberryPis using a _LAN951x_ or _LAN7800_ Ethernet controller and running a Debian derivative (_rasbian_, _Noobs_, ...). However, dimPi will currently **not** work correctly on a _Pi Zero_ board (this may be addressed at a later point).

# References
[1] https://mockmoon-cybernetics.ch/computer/raspberry-pi/lan951x-led-ctl/  
[2] https://mockmoon-cybernetics.ch/computer/raspberry-pi/lan7800-led-ctl/
