# CSS452 Homework 5 - Q5 (Lecture Note 8, Example 8)
# Send a random integer (0-100) to ThingSpeak field1 every 60 seconds.
#
# Circuit: none. The Pi must be connected to the Internet.
#
# ThingSpeak channel: Name "Lect8 - Ex8", Field 1 "Random Integer".
# Write API Key: copy config_example.py to config.py and paste your key there.
# config.py is git-ignored, so the key never gets committed.
#
# Run on the Pi: open in Thonny and click Run,
#   or in a terminal: python3 Q5_ThingSpeak_Random.py   (Ctrl+C to stop)

import time, requests
from random import randint
from config import KEY  # lecture code: KEY = 'Your Write API Key'

PERIOD = 60 #seconds
BASE_URL = 'https://api.thingspeak.com/update.json'

def send_data(Value):
    data = {'api_key': KEY, 'field1': Value}
    response = requests.post(BASE_URL, json=data)

while True:
    Number = randint(0, 100)
    print('Number: ' + str(Number))
    send_data(Number)
    time.sleep(PERIOD)
