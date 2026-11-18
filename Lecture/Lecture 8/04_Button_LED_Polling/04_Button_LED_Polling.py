# CSS452 Lecture 8 - Example 4 — LED follows the switch, polling (HW5-Q3). Button GPIO2 to GND (internal pull-up), LED GPIO18.
# Run on the Pi in Thonny (Run) or: python3 04_Button_LED_Polling.py  (Ctrl+C to stop)

from gpiozero import Button, LED

button = Button(18, pull_up=True)
led = LED(22)

while True:
    if button.is_pressed:
        led.on()
    else:
        led.off()
