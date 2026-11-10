# CSS452 Lecture Note 8 - 1.4 Code Comparison (GPIOZero version)
# Turn an LED on for 5 seconds, then off, using the high-level gpiozero library.
# No setmode/setup needed: LED(18) does both, and BCM numbering is the default.
# (The slide has a typo, "from gipozero import LED"; fixed here.)
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO18 [pin 12] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Run on the Pi: open in Thonny and click Run, or: python3 GPIOZero_LED.py

from gpiozero import LED
import time

led = LED(18)
led.on()
time.sleep(5)
led.off()
