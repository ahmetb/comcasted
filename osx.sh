#!/bin/bash
set -e

LABEL=com.comcasted.speedtest
PLIST=$LABEL.plist
: ${1?"Need to pass argument 'install' or 'uninstall'."}
CMD=$1
SSID_FILTER=$2

AGENT_PATH=$HOME/Library/LaunchAgents/$LABEL.plist
if [ "uninstall" = "$CMD" ]; then
	echo "Trying to uninstall $LABEL"
	
	if [[ -z $(launchctl list | grep -i $LABEL) ]]; then
		echo >&2 "It seems launch agent $LABEL is not loaded. No need to uninstall."
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
	echo "Trying to install the launch agent."
	cat $PLIST | sed "s/\$USER/$USER/g" | sed "s,\$PWD,$PWD,g" | sed "s/\$SSID/$SSID_FILTER/g" > $AGENT_PATH
	launchctl load $AGENT_PATH
	echo "Launch agent is installed."
else
	echo >&2 "Unknown command '$CMD'"
	exit 1	
fi

