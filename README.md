# dimPi

dimPi is a simple shell script for controlling a Raspberry Pi's onboard LEDs (ACT, PWR, LNK, SPD and SND).
It contains `lan951x-led-ctl` and `lan7800-led-ctl` by Dominic Radermacher as git modules.

Use `git clone --recursive https://github.com/poulet-lab/dimPi.git` to obtain a local clone of the repository.

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
