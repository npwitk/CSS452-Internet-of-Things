# Q3 – Switch Controls LED (Lecture Note 8, Example 4)

While the switch is pressed the LED is on; otherwise it is off. The code polls `button.is_pressed`.

## Circuit

| From | To |
|---|---|
| GPIO22 (physical pin 15) | LED anode (long leg) |
| LED cathode (short leg) | 330 Ω resistor |
| 330 Ω resistor | GND (physical pin 14) |
| GPIO18 (physical pin 12) | one side of the switch |
| other side of the switch | GND (physical pin 6 or 14) |

The switch needs no resistor. `Button(18, pull_up=True)` turns on the Pi's internal pull-up, so the pin reads HIGH when the switch is not pressed and LOW when it is pressed. gpiozero reports `is_pressed == True` when it is pressed.

## Run

1. Open `Q3_Button_LED.py` in Thonny on the Pi and click **Run**,
   or run `python3 Q3_Button_LED.py` in a terminal.
2. Stop with the **Stop** button in Thonny, or Ctrl+C.

## Video "Q3" must show

- the circuit connection
- the Python code
- the demo:
  - pressing the switch turns the LED on
  - not pressing the switch leaves the LED off
