from gpiozero import PWMLED, LED, Button
from guizero import App, Slider, Text

led1 = PWMLED(18)               # brightness 0.0 - 1.0
led2 = LED(22)                  # on / off
sw = Button(17, pull_up=True)   # pressed = connected to GND

# LED2 follows the switch: pressed -> off, released -> on
sw.when_pressed = led2.off
sw.when_released = led2.on
if sw.is_pressed:               # set the correct state at start-up
    led2.off()
else:
    led2.on()

def slider_changed(value):
    led1.value = int(value) / 100

app = App(title="A1 - Slider bar for LED1", width=500, height=200)
Text(app, text="Slider bar for LED1", size=18)
slider = Slider(app, start=0, end=100, command=slider_changed, width="fill", height=50)
slider.text_size = 20
app.display()
