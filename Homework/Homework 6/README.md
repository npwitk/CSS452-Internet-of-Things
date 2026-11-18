# Homework 6 – Node-RED

| Part | Folder | Lecture example |
|---|---|---|
| P1 | `P1_Hello_Dashboard` | Example 2: "Hello" on the dashboard (needs `node-red-dashboard`) |
| P2 | `P2_Switch_Slider_LEDs` | Example 3: dashboard switch and slider control LED1 and LED2 |
| P3 | `P3_MQTT_Switch_LED` | Example 5: switch to HiveMQ to LED. Change `YOUR_ID` in both MQTT nodes. |

Import each `flow.json` (Main menu → Import), then Deploy. Wiring is in `Lecture/Lecture 9/README.md`.

## Wiring

- **P1:** none, it is dashboard only.
- **P2:** LED1 on GPIO22 and LED2 on GPIO18, each through 330 Ω to GND.

![P2 circuit](../../Lecture/Lecture%209/wiring/example3_two_leds.png)

- **P3:** LED1 on GPIO22 through 330 Ω to GND, plus SW1 from GPIO3 to GND.

![P3 circuit](../../Lecture/Lecture%209/wiring/example5_switch_led.png)
