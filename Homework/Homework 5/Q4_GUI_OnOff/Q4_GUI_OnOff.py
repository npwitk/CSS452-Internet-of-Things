# CSS452 Homework 5 - Q4 (Lecture Note 8, Example 6)
# Two GUI push buttons (guizero): "On" turns the LED on, "Off" turns it off.
#
# Circuit (same as Q1):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Needs guizero: sudo apt install python3-guizero   (or: sudo pip3 install guizero)
# Run on the Pi desktop (e.g. through VNC) so the window is visible:
#   open in Thonny and click Run, or: python3 Q4_GUI_OnOff.py
# Close the window to stop.

from gpiozero import LED
from guizero import App, PushButton

led = LED(22)

def start():
    start_button.disable()
    stop_button.enable()
    led.on()

def stop():
    start_button.enable()
    stop_button.disable()
    led.off()

app = App(width=100, height=150)
start_button = PushButton(app, command=start, text="On")
start_button.text_size = 30
stop_button = PushButton(app, command=stop, text="Off", enabled=False)
stop_button.text_size = 30
app.display()
