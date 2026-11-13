# Homework 7 – MQTT broker + SQLite

| Part | Folder | Lecture example |
|---|---|---|
| P1 | `P1_Example5_Insert` | Example 5: insert from inject |
| P2 | `P2_Example6_MQTT_to_SQLite` | Example 6, with the ESP32 running `Local_NodeRed_PubNode.ino` |
| P3 | `P3_Example7_JSON_TwoSensors` | Example 7, with the ESP32 running `Local_NodeRed_PubNode_JSON.ino` |

First create `SensorData` in `Database1` (Example 4) and `TwoSensors` in `Database2`. To check the data, run `sqlite3 Database1` and then `select * from SensorData;`. Setup notes are in `Lecture/Lecture 10/README.md`.
