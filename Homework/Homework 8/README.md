# Homework 8 – InfluxDB and Grafana

| Part | Folder | Lecture example |
|---|---|---|
| P1 | `P1_Example3_Insert` | Example 3: insert from Node-RED, then check the Room1 and Room2 dashboards |
| P2 | `P2_Example4_Room1` | Example 4: the ESP32 runs `Home_Sensors_PubNode_JSON.ino`, and the Room1 dashboard updates live |
| P3 | `P3_Example5_Room2` | Example 5: same flow, but the sketch sends `"room2"` |

Setup is in `Lecture/Lecture 11/README.md`.

## Wiring

None. The ESP32 sketches send random values, so the ESP32 only needs USB power and the same Wi-Fi as the Pi.
