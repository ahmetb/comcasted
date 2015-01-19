#!/bin/bash
set -e

if [ "`uname -s`" != "Darwin" ]; then
	echo >&2 "This script currently only works on Mac OS X."
	exit 1
fi

: ${1?"Need to pass a path argument output CSV report."}
CSV=$1
SSID_FILTER=$2

SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
if  [ -z "$SSID" ]; then
	echo >&2 "Not connected to a wireless network. Skipping."
	exit 1
fi

if [[ -n "${SSID_FILTER}" && "$SSID" != "${SSID_FILTER}" ]]; then
	echo >&2 "Running on wireless access point '$SSID' not '${SSID_FILTER}. Skipping the test.'"
	exit 1
fi

echo "Connected to wireless network '$SSID'."
# Download speedtest-cli
tmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'speedtest'`
curl -sSL -o $tmpdir/speedtest https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
chmod +x $tmpdir/speedtest
echo "Running speedtest..."

TEST_RESULT=`$tmpdir/speedtest --simple --share`
DOWNLOAD=`echo "$TEST_RESULT" | grep -i download | awk '{print $2}'`
UPLOAD=`echo "$TEST_RESULT" | grep -i upload | awk '{print $2}'`
PING=`echo "$TEST_RESULT" | grep -i ping | awk '{print $2}'`
SHARE=`echo "$TEST_RESULT" | grep -i share | awk '{print $3}'`

echo "Test results: Download=$DOWNLOAD Mbps, Upload=$UPLOAD Mbps, PING=$PING ms $SHARE."
if [ ! -f $CSV ]; then
	echo "Creating CSV..."
	echo "DATE,SSID,DOWNLOAD,UPLOAD,PING,SHARE" >> $CSV
fi
echo "`date +"%Y-%m-%d %H:%M:%S"`,\"$SSID\",$DOWNLOAD,$UPLOAD,$PING,\"$SHARE\"" >> $CSV
echo "Done."

if [ -d "$tmpdir" ]; then
	rm -rf $tmpdir
fi
