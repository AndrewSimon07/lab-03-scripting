#!/usr/bin/env python3

import os
import json
import requests

GHUSER = os.getenv('GITHUB_USER')
url = f'https://api.github.com/users/{GHUSER}/events'

def retrieve_events(url):
    "Download event data from a URL and convert the JSON text to Python."
    response = requests.get(url).text
    events = json.loads(response)
    return events

def print_events(events, n=5):
    "Print the first n events from a list of events."
    for x in events[:n]:
        event = x['type'] + ' :: ' + x['repo']['name']
        print(event)

def main():
    print(GHUSER)
    print(url)
    events = retrieve_events(url)
    print_events(events)
if __name__ == '__main__':
    main()










