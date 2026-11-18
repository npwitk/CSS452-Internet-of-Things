# Practical Final Exam – Example Questions (CSS452)

Worked solutions for the three example questions, with wiring diagrams. The pins follow the lectures, but the exam allows any pins: if you change a pin, change it in the code or flow too.

| Question | Topic | Tools | Wiring |
|---|---|---|---|
| [Q1](Q1_GUI_Buttons_Slider/) | On/Off buttons → LED1, slider → LED2 brightness | Python: gpiozero + guizero (Lecture 8) | 2 LEDs |
| [Q2](Q2_NodeRED_Switch_Slider/) | SW1 turns LED1 off; dashboard slider → LED2 brightness | Node-RED + dashboard (Lecture 9) | 2 LEDs + 1 switch |
| [Q3](Q3_ESP32_5Values_SQLite/) | ESP32 sends 5 random values every 5 s → Pi stores them in SQLite | Arduino + MQTT + Node-RED + SQLite (Lecture 10) | none |

Each question folder has the code or flow, the wiring, the run steps, and what your demo should show.

**Check your Pi first:** run [`tools/check_pi_ready.sh`](../../tools/README.md) on the Pi. It checks Python GPIO, Node-RED and its palettes, Mosquitto, SQLite, InfluxDB and Grafana, and prints the fix for anything missing.

**Before you start:**

- **One GPIO flow at a time in Node-RED.** If another tab already uses GPIO22 or GPIO18, you get "GPIO pin 18 already set as type: PWM output". Disable the other tab, then Deploy.
- **ESP32 and Pi on the same Wi-Fi** (Q3). The Pi's cable address `192.168.2.x` can't be reached from Wi-Fi, so use the Pi's Wi-Fi IP from `hostname -I`.
- **SQLite nodes "missing"?** See [Lecture 10 → Troubleshooting](../../Lecture/Lecture%2010/README.md) for the `GLIBC_2.38` fix.

*Wiring diagrams are redrawn in the same style as the Peanut Cheat Sheets lecture videos. The SVG sources are in `wiring/`.*
