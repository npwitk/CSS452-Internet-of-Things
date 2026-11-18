# Tools

| Script | Use it for |
|---|---|
| [`pi.sh`](#pish--open-the-pages-and-control-the-services) | opening Node-RED, the dashboard and Grafana without remembering ports, and starting or stopping services |
| [`check_pi_ready.sh`](#check_pi_readysh--is-my-raspberry-pi-ready-for-the-practical-exam) | a full check before the exam |

## `pi.sh` – open the pages and control the services

Run it **from your Mac**: it opens the pages in your Mac's browser and controls the Pi over SSH. It also works **on the Pi**, where it detects that and runs everything locally.

```bash
cd tools
./pi.sh                      # menu: ports + logins, then pick a number
./pi.sh open nodered         # Node-RED editor      http://<Pi>:1880
./pi.sh open ui              # Node-RED dashboard   http://<Pi>:1880/ui
./pi.sh open grafana         # Grafana              http://<Pi>:3000
./pi.sh open all             # all three
./pi.sh status               # which of SSH / Node-RED / MQTT / InfluxDB / Grafana are up
./pi.sh logins               # ports and default logins
./pi.sh ip                   # the Pi's IPs and Wi-Fi name (use the Wi-Fi IP in ESP32 sketches)
./pi.sh ssh                  # log in to the Pi
./pi.sh check                # run check_pi_ready.sh on the Pi
```

**Services** (`start`, `stop`, `restart`, `status`, `log`):

```bash
./pi.sh nodered restart      # same as node-red-restart on the Pi
./pi.sh nodered log          # live Node-RED log (Ctrl+C to leave)
./pi.sh mosquitto restart
./pi.sh influxdb status
./pi.sh grafana start
```

**Which Pi:** `raspberrypi.local` by default. For another address, such as a friend's Pi:

```bash
./pi.sh --host 192.168.1.109 status
export PI_HOST=192.168.1.109     # for the rest of this Terminal window
```

**Stop typing the password:** run `./pi.sh setup-key` once. It copies your Mac's SSH key to the Pi, asking for `raspberry` one last time.

## `check_pi_ready.sh` – is my Raspberry Pi ready for the practical exam?

One read-only check of everything used in Lectures 8–11. It changes nothing on the Pi; the one test database it creates goes in `/tmp` and is deleted.

**Run it on the Pi:**

```bash
curl -fsSL https://raw.githubusercontent.com/npwitk/CSS452-Internet-of-Things/main/tools/check_pi_ready.sh | bash
```

**Or from your Mac**, over SSH (password `raspberry`):

```bash
ssh pi@raspberrypi.local 'bash -s' < tools/check_pi_ready.sh
```

| Section | What it checks |
|---|---|
| 1. System and network | OS, glibc, LAN and **Wi-Fi IP** (the one to use as `mqtt_server`), internet, clock, disk space, SSH, VNC |
| 2. Python + GPIO (L8, Q1) | python3, `gpiozero`, `guizero`, the GPIO back-end, the `gpio` group, Thonny |
| 3. Node-RED (L9, Q2, Q3) | installed, running, starts at boot, port 1880, palettes (`pi-gpio`, `dashboard`, `sqlite`, `influxdb`); also checks that the **sqlite3 native module loads**, which catches the `GLIBC_2.38` problem |
| 4. Mosquitto (L10, Q3) | running, starts at boot, `listener 1883` and `allow_anonymous true`, port 1883 open to the network, and a real publish → subscribe round trip |
| 5. SQLite (L10, Q3) | `sqlite3` CLI and a create/insert/select test |
| 6. InfluxDB (L11) | running, `[http] enabled = true`, port 8086 answers, `InfluxTest` database, `InfluxUser` |
| 7. Grafana (L11) | running, port 3000 answers, `admin` / `admin` login, InfluxDB data source |

Every ✘ comes with the exact command to fix it. The script ends with a summary, and exits with code 0 when nothing failed.

```
Summary: 41 passed, 1 warnings, 0 failed
Ready for the practical exam.
```
