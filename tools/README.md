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
./pi.sh find                 # search for the Pi again (see below)
```

**Services** (`start`, `stop`, `restart`, `status`, `log`):

```bash
./pi.sh nodered restart      # same as node-red-restart on the Pi
./pi.sh nodered log          # live Node-RED log (Ctrl+C to leave)
./pi.sh mosquitto restart
./pi.sh influxdb status
./pi.sh grafana start
```

**Which Pi:** the script finds it for you and remembers it in `~/.css452_pi_host`.

- **First run, or when the saved Pi doesn't answer:** it searches by itself. It tries the default `raspberrypi.local`, every `.local` name and Internet Sharing address (`192.168.2.x`) this Mac has SSH'd to before, and `192.168.2.2–10` if Internet Sharing is on. It lists each Pi that answers, with its real hostname. If more than one answers, for example a classmate's Pi on the same Wi-Fi, you pick yours.
- **Renamed your Pi or changed network?** Run `./pi.sh find`.

```bash
./pi.sh find                    # search again and pick
./pi.sh use peanut-pi.local     # set it yourself (a name or an IP)
./pi.sh where                   # show which Pi is being used
./pi.sh --host 192.168.1.109 status   # one-off, without changing the saved one
```

**Several Pis on one Wi-Fi?** At school every Pi is called `raspberrypi.local` by default, so SSH may reach a classmate's Pi and warn "REMOTE HOST IDENTIFICATION HAS CHANGED". Give yours a unique name once, then run `./pi.sh find`:

```bash
ssh pi@<your Pi's IP> "sudo hostnamectl set-hostname my-pi && sudo sed -i 's/raspberrypi/my-pi/g' /etc/hosts && sudo reboot"
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
