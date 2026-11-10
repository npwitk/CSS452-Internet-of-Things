# CSS452 Lecture Note 8 - Example 7
# A guizero slider (0-100) sets the LED brightness: led.value = percent / 100.
#
# Circuit (BCM numbering in code, physical pin in brackets):
#   GPIO22 [pin 15] -> LED anode (long leg)
#   LED cathode (short leg) -> 330 ohm -> GND [pin 14]
#
# Needs guizero: sudo apt install python3-guizero   (or: sudo pip3 install guizero)
# Run on the Pi desktop (e.g. through VNC): open in Thonny and click Run,
#   or: python3 07_GUI_Slider_PWM.py   (close the window to stop)

from gpiozero import PWMLED
from guizero import App, Slider

led = PWMLED(22)

def slider_changed(percent):
    led.value = int(percent) / 100

app = App(title='PWM', width=500, height=150)
slider = Slider(app, command=slider_changed, width='fill', height=50)
slider.text_size = 30
app.display()
