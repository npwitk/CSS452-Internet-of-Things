# Q1 – LED On/Off (Lecture Note 8, Example 1)

Turn the LED on for 2 seconds and off for 2 seconds, repeatedly.

## Circuit

![GPIO22 → LED → 330 Ω → GND](../../../Lecture/Lecture%208/wiring/led_gpio22.png)


| From | To |
|---|---|
| GPIO22 (physical pin 15) | LED anode (long leg) |
| LED cathode (short leg) | 330 Ω resistor |
| 330 Ω resistor | GND (physical pin 14) |

## Run

1. Open `Q1_LED_OnOff.py` in Thonny on the Pi and click **Run**,
   or run `python3 Q1_LED_OnOff.py` in a terminal.
2. Stop with the **Stop** button in Thonny, or Ctrl+C.

## Video "Q1" must show

- the circuit connection
- the Python code
- the demo: the LED is on for 2 seconds, then off for 2 seconds, again and again (the Shell prints `on` / `off` with it)
