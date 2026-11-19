# CSS452 – Internet of Things

Code, Node-RED flows, wiring diagrams and notes from **CSS452 Internet of Things** at the Sirindhorn International Institute of Technology (SIIT), Thammasat University, Semester 1/2026.

The course has two halves:

- **ESP32 (Arduino):** GPIO, analog input and PWM, touch, Wi-Fi, NTP, `millis()` multitasking, interrupts, dual-core tasks, deep sleep and wake-up, web servers and clients (ThingSpeak), and MQTT with the public HiveMQ broker.
- **Raspberry Pi:** Python with `gpiozero` and `guizero`, Node-RED and its dashboard, a local Mosquitto MQTT broker, SQLite, InfluxDB and Grafana, with ESP32 boards publishing sensor data to the Pi.

## Repository layout

| Folder | Contents |
|---|---|
| [`Lecture/`](Lecture/) | Lecture examples, one folder per lecture |
| [`Exercise/`](Exercise/) | In-class exercises 1–8 |
| [`Homework/`](Homework/) | Homework 1–8 |
| [`Exam/`](Exam/) | Practical midterm and final exam solutions, plus the example final questions |
| [`Setup/`](Setup/) | Using the Pi from a Mac: Screen Sharing and clipboard sync |
| [`tools/`](tools/) | `pi.sh` (open Node-RED, the dashboard and Grafana, control services) and `check_pi_ready.sh` (a full check before the exam) |
| [`Testing/`](Testing/) | A minimal serial-counter sketch to check that a board uploads |

### Lectures

| Lecture | Platform | Topic |
|---|---|---|
| [Lecture 3](Lecture/Lecture%203/) | ESP32 | Digital I/O, analog input, PWM, touch, Hall effect, Wi-Fi station and soft AP, NTP date and time |
| [Lecture 4](Lecture/Lecture%204/) | ESP32 | `millis()`, interrupts, multitasking, dual cores, deep sleep, timer/touch/ext0/ext1 wake-up |
| [Lecture 5](Lecture/Lecture%205/) | ESP32 | Web server (monitor a sensor, control outputs) and web client (ThingSpeak) |
| [Lecture 6](Lecture/Lecture%206/) | ESP32 | MQTT publish and subscribe with public HiveMQ |
| [Lecture 8](Lecture/Lecture%208/) | Raspberry Pi | Python GPIO with `gpiozero`, GUIs with `guizero`, ThingSpeak |
| [Lecture 9](Lecture/Lecture%209/) | Raspberry Pi | Node-RED, dashboard, GPIO and MQTT nodes |
| [Lecture 10](Lecture/Lecture%2010/) | Pi + ESP32 | Local Mosquitto broker on the Pi, SQLite from Node-RED, JSON sensor data |
| [Lecture 11](Lecture/Lecture%2011/) | Pi + ESP32 | InfluxDB and Grafana dashboards fed by the ESP32 through Node-RED |

The ESP32 lectures have no README; each example is one Arduino sketch named after its folder. The Pi lectures (8–11) each have a README with setup commands, wiring and how to run every example.

### Exams

| Exam | Contents |
|---|---|
| [Practical Midterm Exam](Exam/Practical%20Midterm%20Exam/) | ESP32: switch and LEDs (A1), MQTT over HiveMQ (A2), web server with a potentiometer and outputs (A3) |
| [Practical Final Exam (Example)](Exam/Practical%20Final%20Exam%20(Example)/) | The three example questions: Python GUI, Node-RED dashboard, ESP32 → MQTT → SQLite |
| [Practical Final Exam](Exam/Practical%20Final%20Exam/) | Python slider and switch with two LEDs, and ESP32 → MQTT → Node-RED → InfluxDB → Grafana |

## Hardware and software

- **ESP32** dev board, programmed with the Arduino IDE and the ESP32 board package. MQTT sketches need the **PubSubClient** library (Nick O'Leary).
- **Raspberry Pi** running Raspberry Pi OS Bookworm with Desktop, with Python 3, Thonny, Node-RED, Mosquitto, SQLite, InfluxDB v1 and Grafana. The Lecture 10 and 11 READMEs have the install commands.
- LEDs, 330 Ω resistors, push switches and a potentiometer on a breadboard.

## Getting started

```bash
gh repo clone npwitk/CSS452-Internet-of-Things
```

- **ESP32 sketch:** open the `.ino` file in the Arduino IDE, set your Wi-Fi SSID and password (2.4 GHz only) and, for local MQTT, the Pi's Wi-Fi IP. Then upload.
- **Python on the Pi:** run it in Thonny or with `python3 <file>.py`. For ThingSpeak, copy `config_example.py` to `config.py` and add your Write API key; `config.py` is git-ignored.
- **Node-RED flow:** in the editor at `http://<Pi IP>:1880`, choose **Main menu → Import**, paste the `flow.json`, then **Deploy**. The dashboard is at `/ui`.
- **Check the Pi:** run [`tools/check_pi_ready.sh`](tools/README.md), or `./tools/pi.sh status` from a Mac.

Pin numbers follow the lecture notes. If you wire to a different pin, change it in the code or flow too.
