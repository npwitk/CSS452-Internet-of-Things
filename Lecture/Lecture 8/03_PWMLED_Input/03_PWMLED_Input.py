# CSS452 Lecture 8 - Example 3 — LED brightness from keyboard input 0-100 (HW5-Q2). LED on GPIO18 (PWM).
# Run on the Pi in Thonny (Run) or: python3 03_PWMLED_Input.py  (Ctrl+C to stop)

from gpiozero import PWMLED

led = PWMLED(22)

while True:
    brightness_s = input("Enter Brightness (0.0 to 1.0):")
    brightness = float(brightness_s)   # input() returns a STRING
    led.value = brightness
