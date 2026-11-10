# CSS452 Homework 5 - Q3 (Lecture Note 8, Example 4)
# Pressing the switch turns the LED on; otherwise the LED is off (polling).
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#   GPIO18 [pin 12] -> switch -> GND [pin 6 or 14]
#   No resistor on the switch: pull_up=True uses the Pi's internal pull-up,
#   so not pressed = HIGH, pressed = LOW, and is_pressed is True when pressed.
#
# Run on the Pi: open in Thonny and click Run,
#   or in a terminal: python3 Q3_Button_LED.py   (Ctrl+C to stop)

from gpiozero import Button, LED

button = Button(18, pull_up=True)
led = LED(22)

while True:
    if button.is_pressed:
        led.on()
    else:
        led.off()
