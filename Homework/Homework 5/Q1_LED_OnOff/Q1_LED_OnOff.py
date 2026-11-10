# CSS452 Homework 5 - Q1 (Lecture Note 8, Example 1)
# Turn an LED on for 2 s and off for 2 s, repeatedly.
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Run on the Pi: open in Thonny and click Run,
#   or in a terminal: python3 Q1_LED_OnOff.py   (Ctrl+C to stop)

from gpiozero import LED
from time import sleep
LED_PIN = 22
led = LED(LED_PIN)

while True:
    print("on")
    led.on()
    sleep(2)
    print("off")
    led.off()
    sleep(2)
