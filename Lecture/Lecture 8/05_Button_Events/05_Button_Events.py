# CSS452 Lecture Note 8 - Example 5: To Turn an LED on/off by a Switch (2)
# Same result as Example 4, but event-driven: when_pressed / when_released
# are given the functions led.on / led.off (no parentheses).
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#   GPIO18 [pin 12] -> switch -> GND [pin 6 or 14]   (internal pull-up, no resistor)
#
# Run on the Pi: open in Thonny and click Run,
#   or: python3 05_Button_Events.py   (Ctrl+C to stop)

from gpiozero import Button, LED
from signal import pause

button = Button(18, pull_up=True)
led = LED(22)

button.when_pressed = led.on
button.when_released = led.off

pause()  # not on the slide: keeps the script alive when run with python3
