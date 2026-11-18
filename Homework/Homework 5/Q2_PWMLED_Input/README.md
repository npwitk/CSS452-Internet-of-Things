# Q2 – PWMLED Brightness from Input (Lecture Note 8, Example 3)

Type a value from 0.0 to 1.0, and the LED brightness follows it (`PWMLED.value`).

## Circuit

![GPIO22 → LED → 330 Ω → GND](../../../Lecture/Lecture%208/wiring/led_gpio22.png)


Same as Q1:

| From | To |
|---|---|
| GPIO22 (physical pin 15) | LED anode (long leg) |
| LED cathode (short leg) | 330 Ω resistor |
| 330 Ω resistor | GND (physical pin 14) |

## Run

1. Open `Q2_PWMLED_Input.py` in Thonny on the Pi and click **Run**,
   or run `python3 Q2_PWMLED_Input.py` in a terminal.
2. At `Enter Brightness (0.0 to 1.0):` type values such as `0.1`, `0.5`, `1.0`, `0`.
3. Stop with the **Stop** button in Thonny, or Ctrl+C.

As in the lecture code, a value outside 0.0–1.0 or a non-number stops the program with an error.

## Video "Q2" must show

- the circuit connection
- the Python code
- the demo: typing a value changes the LED intensity
