# Q4 – GUI On/Off Buttons (Lecture Note 8, Example 6)

A small guizero window has two push buttons. **On** turns the LED on and greys itself out. **Off** turns the LED off. **Off** starts greyed out.

## Circuit

![GPIO22 → LED → 330 Ω → GND](../../../Lecture/Lecture%208/wiring/led_gpio22.png)


Same as Q1:

| From | To |
|---|---|
| GPIO22 (physical pin 15) | LED anode (long leg) |
| LED cathode (short leg) | 330 Ω resistor |
| 330 Ω resistor | GND (physical pin 14) |

## Run

1. Install guizero once, if it is missing:
   `sudo apt install python3-guizero` (or `sudo pip3 install guizero`).
2. On the Pi desktop (for example through VNC), open `Q4_GUI_OnOff.py` in Thonny and click **Run**,
   or run `python3 Q4_GUI_OnOff.py` in a terminal on the desktop.
3. Close the window to stop.

## Video "Q4" must show

- the circuit connection
- the Python code
- the demo:
  - pressing the **On** button turns the LED on
  - pressing the **Off** button turns the LED off
