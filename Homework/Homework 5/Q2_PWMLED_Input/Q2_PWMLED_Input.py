# CSS452 Homework 5 - Q2 (Lecture Note 8, Example 3)
# Type a brightness value (0.0 to 1.0) and the LED intensity follows it.
#
# Circuit (same as Q1):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Run on the Pi: open in Thonny and click Run (type values in the Shell),
#   or in a terminal: python3 Q2_PWMLED_Input.py   (Ctrl+C to stop)
#
# Note: a value outside 0.0-1.0 or a non-number stops the program with an
# error, exactly as in the lecture code.

from gpiozero import PWMLED

led = PWMLED(22)

while True:
    brightness_s = input("Enter Brightness (0.0 to 1.0):")
    brightness = float(brightness_s)
    led.value = brightness
