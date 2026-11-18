# Exercise 6 – Physical switches control LEDs (Lecture 9, Example 4)

Import `Switches_LEDs/flow.json` into Node-RED (Main menu → Import), then Deploy.

After Deploy, both LEDs are on. Holding SW1 turns LED1 off, and holding SW2 turns LED2 off. The switches use the internal pull-up, so pressed = 0.

Wiring and notes are in `Lecture/Lecture 9/README.md`.

## Wiring

![Two switches and two LEDs](../../Lecture/Lecture%209/wiring/example4_two_switches_two_leds.png)

LED1 on GPIO22 (pin 15) and LED2 on GPIO18 (pin 12), each through 330 Ω to GND. SW1 goes from GPIO3 (pin 5) to GND and SW2 from GPIO4 (pin 7) to GND.
