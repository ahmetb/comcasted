# comcasted

Sometimes Comcast is too fast, you feel a need to measure your speed and save to a CSV
so you can prove you are getting the speed you are paying for.

This script is designed for OS X and periodically runs a speed test when you are
are connected to a wireless network (or a specific wireless network). It is also
not Comcast-specific but I decided to name it so because they're such a great ISP and
they're a big supporter of [Net Neutrality](https://www.youtube.com/watch?v=fpbOEoRrHyU)
movement.

## Installation

Clone this repository locally and go into the source directory

	git clone git@github.com:ahmetalpbalkan/comcasted.git
	cd comcasted

Install the periodical job using `osx.sh` script. Once installed, the speed test script will
be executed every 5 minutes and place a file called `comcasted.csv` on your desktop to report the
test results.

	Usage: ./osx.sh <command> [<ssid>]

	Arguments:
	<command>	'install' or 'uninstall' to set up the program to run in the background
	<ssid>		(optional) run speed test only when connected to this wireless network

	Examples:
	  $ ./osx.sh install ahmet-home-wifi
	  $ ./osx.sh install # (runs on all connected wireless networks, use at caution)
	  $ ./osx.sh uninstall

## Visualizing

You can use the nice `./visualize.py` script to upload the CSV file to
[charted.io](http://www.charted.co) and get a visualization like this:

(If you already installed using osx.sh script, it will find where the
data is located automatically)

    ./visualize.py 4

![](http://cl.ly/image/1w0D392e1Q1I/Image%202015-01-21%20at%2011.36.39%20PM.png)

## Tweaking

If you want to run the speed test once, you can use the `comcasted.sh`.

If you like to configure the periodic speed test interval or where te results are saved,
you need to modify the .plist file and re-install the launch agent using `osx.sh` command.

If you configure your computer to not to go sleep when plugged and leave the lid open,
it can run over the nights while you're sleeping as well.

## Author

[Ahmet Alp Balkan](http://ahmetalpbalkan.com) ([@ahmetalpbalkan](https://twitter.com/ahmetalpbalkan))
