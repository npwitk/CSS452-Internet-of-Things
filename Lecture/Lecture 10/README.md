# Lecture 10 – Raspberry Pi: Local MQTT Broker & SQL Database

## Arduino sketches (ESP32)

Put your Wi-Fi SSID and password, and the Pi's IP from `hostname -I`, into the sketch before uploading.

| File | What it does |
|---|---|
| `Local_RaspberryPi_PubSub.ino` | Examples 1–2: publishes the potentiometer value (`/IoT/PotenValue`) and subscribes to the same topic. Above 500, LED2 on GPIO26 turns on. |
| `Local_NodeRed_PubNode.ino` | Example 6: publishes a random value to `/IoT/Test1` every 5 s |
| `Local_NodeRed_PubNode_JSON.ino` | Example 7: publishes `{"Sensor1":x,"Sensor2":y}` to `/IoT/Test2` |

## Pi setup (once)

```bash
sudo apt install mosquitto
sudo nano /etc/mosquitto/mosquitto.conf
```

Add these two lines at the end of `mosquitto.conf`, then restart Mosquitto:

```
listener 1883
allow_anonymous true
```

```bash
sudo systemctl restart mosquitto
```

In Node-RED (`http://<Pi IP>:1880`, login `pi` / `raspberry`), install `node-red-node-sqlite` and `node-red-dashboard` from **Manage palette**.

## Node-RED flows

To use a flow, open **Main menu → Import**, paste the `flow.json`, then click **Deploy**.

| Folder | Flow |
|---|---|
| `Example2_Gauge_LED1` | `mqtt in /IoT/PotenValue_YOUR_ID` → `range` (0–4095 to 0–100) → LED1 PWM on GPIO22, and → a dashboard gauge at `/ui` |
| `Example4_Create_Table` | `inject` → `sqlite`: `create table SensorData (TheTime Timestamp, TheValue integer)` in `/home/pi/Database1`. Click inject once only. |
| `Example5_Insert` | inject `10` → function (`msg.params`) → prepared `insert into SensorData …` |
| `Example6_MQTT_to_SQLite` | `mqtt in /IoT/Test1_YOUR_ID` → function → insert into `SensorData` |
| `Example7_JSON_TwoSensors` | `mqtt in /IoT/Test2_YOUR_ID` → `json` → function → insert into `TwoSensors` in `/home/pi/Database2`. Create that table first: `create table TwoSensors(TheTime Timestamp, Sen1Val integer, Sen2Val integer);` |

## Notes

- **Topics:** change `YOUR_ID` in the topics so they match the topic in your sketch exactly.
- **Pin numbers:** the `pin` field is the **BCM GPIO number**, so LED1 is `22` (physical pin 15).
- **Tested on:** Node-RED 5.0.9 and Mosquitto on a Raspberry Pi 4, with MQTT test messages published from a laptop in place of the ESP32.
