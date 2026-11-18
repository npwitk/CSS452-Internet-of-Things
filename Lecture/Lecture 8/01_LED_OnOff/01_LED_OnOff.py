# CSS452 Lecture 8 - Example 1 — LED on/off every 2 s (HW5-Q1). LED on GPIO18 through 330 ohm to GND.
# Run on the Pi in Thonny (Run) or: python3 01_LED_OnOff.py  (Ctrl+C to stop)

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
