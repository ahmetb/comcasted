#!/bin/bash
set -e

function log {
    echo -e "[$(date)]: $*"
}

function logerr {
	red='\033[0;31m'
	nc='\033[0m'
	if [[ -t 1 ]]; then printf "${red}";fi
	log "$*" 1>&2
	if [[ -t 1 ]]; then printf "${nc}";fi
}

if [ "`uname -s`" != "Darwin" ]; then
	logerr "This script currently only works on Mac OS X."
	exit 1
fi

: ${1?"Need to pass a path argument output CSV report."}
CSV=$1
SSID_FILTER=$2

SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
if  [ -z "$SSID" ]; then
	logerr "Not connected to a wireless network. Skipping."
	exit 1
fi

if [[ -n "${SSID_FILTER}" && "$SSID" != "${SSID_FILTER}" ]]; then
	logerr "Running on wireless access point '$SSID' not '${SSID_FILTER}. Skipping the test.'"
	exit 1
fi

log "Connected to wireless network '$SSID'."
# Download speedtest-cli
tmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'speedtest'`
curl -sSL -o $tmpdir/speedtest https://raw.github.com/sivel/speedtest-cli/master/speedtest.py
chmod +x $tmpdir/speedtest
log "Running speedtest..."

TEST_RESULT=`$tmpdir/speedtest --simple --share`
DOWNLOAD=`echo "$TEST_RESULT" | grep -i download | awk '{print $2}'`
UPLOAD=`echo "$TEST_RESULT" | grep -i upload | awk '{print $2}'`
PING=`echo "$TEST_RESULT" | grep -i ping | awk '{print $2}'`
SHARE=`echo "$TEST_RESULT" | grep -i share | awk '{print $3}'`

log "Test results: Download=$DOWNLOAD Mbps, Upload=$UPLOAD Mbps, PING=$PING ms $SHARE."
if [[ ! -z "`stat $CSV 2>&1 >/dev/null`" ]]; then
	log "Creating CSV..."
	echo "DATE,SSID,DOWNLOAD,UPLOAD,PING,SHARE" >> $CSV
fi
echo "`date +"%Y-%m-%d %H:%M:%S"`,\"$SSID\",$DOWNLOAD,$UPLOAD,$PING,\"$SHARE\"" >> $CSV
log "Done."

if [ -d "$tmpdir" ]; then
	rm -rf $tmpdir
fi
