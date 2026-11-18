# Exercise 8 – InfluxDB and Grafana

- **P1 (Example 1):** in the `influx` shell, insert 4 more rows for room1 and 4 for room2, waiting at least 2 s between inserts. Then run `select * from home`.
- **P2 (Example 2):** build two Grafana dashboards, Room1 and Room2, each with 4 gauges (Last value, min 0, max 100, time range Last 1 year).

All the commands are in `Lecture/Lecture 11/README.md`.

## Wiring

None. The ESP32 sketches send random values, so the ESP32 only needs USB power and the same Wi-Fi as the Pi.
