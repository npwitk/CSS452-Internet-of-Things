# CSS452 Practical Final (example) - Q1
# guizero window: "On"/"Off" push buttons control LED1, a slider sets LED2 brightness.
#
# Circuit (any pins allowed; these match Lecture 8/9):
#   LED1: GPIO22 (pin 15) -> LED long leg; short leg -> 330 ohm -> GND
#   LED2: GPIO18 (pin 12) -> LED long leg; short leg -> 330 ohm -> GND
#
# Run on the Pi: open in Thonny and click Run, or  python3 Q1_GUI_Buttons_Slider.py

from gpiozero import LED, PWMLED
from guizero import App, PushButton, Slider, Text

led1 = LED(22)       # on/off only
led2 = PWMLED(18)    # brightness 0.0-1.0

def led1_on():
    led1.on()
    on_button.disable()
    off_button.enable()

def led1_off():
    led1.off()
    on_button.enable()
    off_button.disable()

def slider_changed(percent):
    led2.value = int(percent) / 100   # slider 0-100 -> PWMLED 0.0-1.0

app = App(title="Practical Final Q1", width=500, height=300)
Text(app, text="LED1")
on_button = PushButton(app, command=led1_on, text="On")
off_button = PushButton(app, command=led1_off, text="Off", enabled=False)
on_button.text_size = 24
off_button.text_size = 24
Text(app, text="LED2 brightness")
slider = Slider(app, start=0, end=100, command=slider_changed, width="fill", height=50)
slider.text_size = 20
app.display()
