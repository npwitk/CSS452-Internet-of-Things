# CSS452 Lecture Note 8 - Example 2: To Blink an LED
# blink() runs in the background: on 2 s, off 4 s, forever (period 6 s).
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Run on the Pi: open in Thonny and click Run,
#   or: python3 02_LED_Blink.py   (Ctrl+C to stop)

from gpiozero import LED
from signal import pause

LED_PIN = 22
led = LED(LED_PIN)
led.blink(on_time=2, off_time=4)

pause()  # not on the slide: keeps the script alive when run with python3
