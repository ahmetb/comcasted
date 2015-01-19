# comcasted

Sometimes Comcast is too fast, you feel a need to measure your speed and save to a CSV
so you can prove you are getting the speed you are paying for.

This script is designed of OS X and periodically runs a speed test when you are
are connected to a wireless network (or a specific wireless network).

## Installation

Clone this repository locally, go into the directory and install using `osx.sh` script.

Once installed, the speed test script will be ran every 5 minutes and place a
`comcasted.csv` on your desktop.

	Usage: ./osx.sh <command> [<ssid>]

	Arguments:
	<command>	'install' or 'uninstall' to set up the program to run in the background
	<ssid>		(optional) run speed test only when running on this wireless network

	Examples:
	  $ ./osx.sh install ahmet-home-wifi
	  $ ./osx.sh install # (runs on all connected wireless networks, use at caution)
	  $ ./osx.sh uninstall

## Visualizing

[[TODO]]

## Tweaking

If you want to run the speed test once, you can use the `comcasted.sh`. If you like to
configure the periodic job interval, you need to modify the .plist file and re-install
the launch agent using `osx.sh` command.

If you configure your computer to not to go sleep when plugged and leave the lid open,
it can run over the nights while you're sleeping as well.

## Author

[Ahmet Alp Balkan](http://ahmetalpbalkan.com)
