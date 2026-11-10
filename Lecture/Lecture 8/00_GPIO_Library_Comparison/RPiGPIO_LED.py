# CSS452 Lecture Note 8 - 1.4 Code Comparison (RPi.GPIO version)
# Turn an LED on for 5 seconds, then off, using the low-level RPi.GPIO library.
# Compare with GPIOZero_LED.py in this folder.
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO18 [pin 12] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Run on the Pi: open in Thonny and click Run, or: python3 RPiGPIO_LED.py

import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.OUT)
GPIO.output(18, GPIO.HIGH)
time.sleep(5)
GPIO.output(18, GPIO.LOW)
