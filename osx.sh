#!/bin/bash
set -e

USAGE="
Usage: $0 <command> [<ssid>]

Arguments:
<command>	'install' or 'uninstall' to set up the program to run in the background
<ssid>		(optional) run speed test only when running on this wireless network

Examples:
  \$ $0 install "ahmet-home-wifi"
  \$ $0 uninstall"


LABEL=com.comcasted.speedtest
PLIST=$LABEL.plist
: ${1?"$USAGE"}

CMD=$1
SSID_FILTER=$2

if [ ! -f "$PLIST" ]; then
	echo >&2 "LaunchAgent plist ($PLIST) is not found in this directory"
	exit 1
fi

AGENT_PATH=$HOME/Library/LaunchAgents/$LABEL.plist
if [ "uninstall" = "$CMD" ]; then
	echo "Uninstalling the '$LABEL' launch agent..."
	
	if [[ -z $(launchctl list | grep -i $LABEL) ]]; then
		echo >&2 "It seems launch agent $LABEL is not loaded to launchctl. Nothing to uninstall."
		exit 1
	fi

	if [ -f $AGENT_PATH ]; then 
		launchctl unload $AGENT_PATH 
	else
		echo >&2 "Agent not found at path ${AGENT_PATH}. Could not unload."	
		exit 1
	fi
	
	rm $AGENT_PATH
	echo "Launch agent uninstalled."
elif [ "install" = "$CMD" ]; then
	echo "Installing the speed test launch agent..."
	
	if [[ -n $(launchctl list | grep -i $LABEL) ]]; then
		echo >&2 "It seems the '$LABEL' launch agent is installed. Try uninstalling and installing again."
		exit 1
	fi

	cat $PLIST | sed "s/\$USER/$USER/g" | sed "s,\$PWD,$PWD,g" | sed "s/\$SSID/$SSID_FILTER/g" > $AGENT_PATH
	launchctl load $AGENT_PATH
	echo "Launch agent is installed."
else
	echo >&2 "Unknown command '$CMD'"
	exit 1	
fi

