#!/usr/bin/python

import plistlib
import csv
import json
import urllib2
import webbrowser
from urllib import quote
from sys import exit, argv
from os import environ, path
from time import strptime, mktime
from datetime import datetime, timedelta

usage = """
usage: {0} <days-back> [<csv-path>]

Options:
  days-back	required. number of days to get back, default:7
  csv-path	optional. path to the data file, finds from installed LaunchAgent by default

Example:
  {0} 5 ~/Desktop/comcasted.csv
"""

CSV_DELIM = ','
CSV_QUOTE = '\"'


def main():
    days_back = 5
    agent_path = _launch_agent_path()
    csv_path = ""

    # days-back
    if len(argv) < 2:
        print usage.format(argv[0])
        exit(1)
    days_back = int(argv[1])
    if days_back < 1:
        print "Invalid days-back argument"
        exit(1)

    # csv-path
    if len(argv) >= 3:
        csv_path = argv[2]
    else:
        agent_path = _launch_agent_path()
        if path.exists(agent_path):
            csv_path = _get_data_path(agent_path)
    if not csv_path:
        print "Could not locate launch agent. Specify an existing path."
    elif not path.exists(csv_path):
        print "Path not found: {0}".format(csv_path)
        exit(1)
    print "Using '{0}'.".format(csv_path)

    done = visualize(csv_path, days_back)
    print 'Done.'


def visualize(csv_path, days_back):
    data = _filter_csv(csv_path, days_back)
    new_csv = _create_csv(data)
    gist_url, raw_url = _upload_to_gist(new_csv)
    print 'CSV uploaded to {0}'.format(gist_url)
    chart_url = _chart_url(raw_url)
    print 'Showing chat at {0}'.format(chart_url)
    print 'Opening web browser...'
    if webbrowser.open(chart_url):
    	print 'Link opened in web browser.'
    	return True
    else:
    	print 'Cannot launch web browser'
    	return False

def _launch_in_browser(url):
	return webbrowser.open(url)

def _chart_url(csv_url):
    j = {
        "dataUrl": csv_url,
        "charts": [
            {
                "title": "Speed Test",
                "note": "Download and upload speed over time. Created by comcasted: https://github.com/ahmetalpbalkan/comcasted"
            }
        ]}
    return 'http://www.charted.co/?{0}'.format(quote(json.dumps(j)))


def _upload_to_gist(s):
    fn = 'file1.csv'
    jj = json.dumps({"files": {fn: {"content": s}}})
    try:
        resp = urllib2.urlopen('https://api.github.com/gists', jj)
    except Exception as e:
        print "Some HTTP Error Occurred. Please try after some time."
        print e
        exit(1)
    body = resp.read()
    resp_json = json.loads(body)
    return resp_json['html_url'], resp_json['files'][fn]['raw_url']


def _create_csv(data):
    csvfile = stringWriter()
    csvwriter = csv.writer(csvfile, delimiter=CSV_DELIM, quotechar=CSV_QUOTE,
                           quoting=csv.QUOTE_MINIMAL)
    csvwriter.writerow(["Date", "Download (Mbps)", "Upload (Mbps)"])
    for r in data:
        csvwriter.writerow(r)
    return csvfile.s


def _filter_csv(csv_path, days_back):
    cut_date = datetime.now() - timedelta(days=days_back)
    data = []
    with open(csv_path, 'rb') as csv_file:
        r = csv.reader(csv_file, delimiter=CSV_DELIM, quotechar=CSV_QUOTE)
        for row in r:
            date_str, ssid, download, upload, ping, link = row
            if date_str == "DATE":  # first line
                continue
            date = datetime.fromtimestamp(
                mktime(strptime(date_str, "%Y-%m-%d %H:%M:%S")))
            if date >= cut_date:
                data.append((date, download, upload))
    return data


def _launch_agent_path():
    return path.join(environ["HOME"], "Library", "LaunchAgents",
                     "com.comcasted.speedtest.plist")


def _get_data_path(agent_path):
    pl = plistlib.readPlist(agent_path)
    # ProgramArguments': ['.../comcasted.sh',
    # '/Users/alp/Desktop/comcasted.csv', 'wifi-name']
    return pl['ProgramArguments'][1]


class stringWriter(object):

    def __init__(self):
        self.s = ""

    def write(self, s):
        if str:
            self.s += s

if __name__ == "__main__":
    main()
