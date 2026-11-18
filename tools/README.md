# Tools

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
