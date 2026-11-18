#!/usr/bin/env bash
# CSS452 – "Is my Raspberry Pi ready for the practical exam?"
#
# Checks everything used in Lectures 8–11: Python GPIO libraries, Node-RED and its palettes,
# Mosquitto, SQLite, InfluxDB and Grafana. It only READS and TESTS; it changes nothing
# (the one test database it creates lives in /tmp and is deleted).
#
# Run on the Pi:
#   bash check_pi_ready.sh
# or straight from GitHub:
#   curl -fsSL https://raw.githubusercontent.com/npwitk/CSS452-Internet-of-Things/main/tools/check_pi_ready.sh | bash

PASS=0; FAIL=0; WARN=0
if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; D=$'\e[2m'; N=$'\e[0m'; else G=; R=; Y=; B=; D=; N=; fi
ok()   { PASS=$((PASS+1)); printf "  ${G}✔${N} %s\n" "$1"; }
bad()  { FAIL=$((FAIL+1)); printf "  ${R}✘ %s${N}\n" "$1"; [ -n "$2" ] && printf "    ${D}fix: %s${N}\n" "$2"; }
warn() { WARN=$((WARN+1)); printf "  ${Y}! %s${N}\n" "$1"; [ -n "$2" ] && printf "    ${D}tip: %s${N}\n" "$2"; }
section() { printf "\n${B}%s${N}\n" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
active() { systemctl is-active --quiet "$1" 2>/dev/null; }
enabled() { systemctl is-enabled --quiet "$1" 2>/dev/null; }
listening() { ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE "[:.]$1\$"; }
NR_DIR="${NODE_RED_DIR:-$HOME/.node-red}"

printf "${B}CSS452 Raspberry Pi exam check${N}  ${D}(%s, user %s)${N}\n" "$(date '+%Y-%m-%d %H:%M')" "$(whoami)"

# ---------------------------------------------------------------- system
section "1. System and network"
if [ -r /etc/os-release ]; then . /etc/os-release; ok "OS: ${PRETTY_NAME:-unknown}"; fi
GLIBC=$(ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$'); [ -n "$GLIBC" ] && ok "glibc $GLIBC"
ok "hostname: $(hostname)  (reach it as $(hostname).local)"
ETH=$(ip -4 -o addr show eth0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
WLAN=$(ip -4 -o addr show wlan0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
[ -n "$ETH" ] && ok "LAN (eth0) IP: $ETH" || warn "no LAN (eth0) address" "fine if you work over Wi-Fi"
if [ -n "$WLAN" ]; then
  SSID=$(iwgetid -r 2>/dev/null)
  ok "Wi-Fi (wlan0) IP: $WLAN${SSID:+  on \"$SSID\"}  ← use this as mqtt_server in ESP32 sketches"
else
  warn "Wi-Fi not connected" "ESP32 questions need the Pi on the SAME Wi-Fi as the ESP32: sudo raspi-config → System Options → Wireless LAN (or join your phone hotspot)"
fi
if ping -c1 -W2 8.8.8.8 >/dev/null 2>&1; then ok "internet reachable"; else warn "no internet" "only needed to install things; local MQTT/Node-RED/Grafana work without it"; fi
YEAR=$(date +%Y); if [ "$YEAR" -ge 2025 ]; then ok "clock looks right ($(date '+%d %b %Y %H:%M %Z'))"; else warn "clock looks wrong ($(date))" "timestamps in SQLite/InfluxDB will be off: connect to the internet so NTP fixes it"; fi
FREE=$(df -Pm / | awk 'NR==2{print $4}'); if [ "${FREE:-0}" -gt 1024 ]; then ok "free disk: $((FREE/1024)) GB"; else warn "only ${FREE} MB free" "free some space before the exam"; fi
if active ssh; then ok "SSH server running"; else bad "SSH server not running" "sudo raspi-config → Interface Options → SSH → Yes"; fi
if active vncserver-x11-serviced || active wayvnc || pgrep -x wayvnc >/dev/null || pgrep -f vncserver >/dev/null; then ok "VNC server running"; else warn "VNC not running" "needed for the guizero window (Q1): sudo raspi-config → Interface Options → VNC → Yes"; fi

# ---------------------------------------------------------------- python (Lecture 8)
section "2. Python + GPIO (Lecture 8 / Practical Q1)"
if have python3; then ok "python3 $(python3 -c 'import sys;print(sys.version.split()[0])')"; else bad "python3 missing" "sudo apt install -y python3"; fi
for m in gpiozero guizero; do
  if python3 -c "import $m" 2>/dev/null; then ok "python module $m"; else bad "python module $m missing" "sudo apt install -y python3-$m"; fi
done
if python3 -c "import lgpio" 2>/dev/null || python3 -c "import RPi.GPIO" 2>/dev/null; then ok "GPIO back-end (lgpio / RPi.GPIO)"; else bad "no GPIO back-end for gpiozero" "sudo apt install -y python3-lgpio"; fi
if id -nG | grep -qw gpio; then ok "user $(whoami) is in the gpio group"; else warn "user not in the gpio group" "sudo usermod -aG gpio $(whoami)  then log out/in"; fi
if have thonny; then ok "Thonny installed"; else warn "Thonny not installed" "sudo apt install -y thonny (or run scripts with python3 file.py)"; fi
if have pinout; then ok "pinout tool available (type: pinout)"; fi

# ---------------------------------------------------------------- node-red (Lecture 9)
section "3. Node-RED (Lecture 9 / Practical Q2, Q3)"
if have node; then ok "Node.js $(node -v)"; else bad "Node.js missing" "install Node-RED with the official script (it installs Node.js too)"; fi
if have node-red || [ -d /usr/lib/node_modules/node-red ] || [ -d /usr/local/lib/node_modules/node-red ]; then
  ok "Node-RED installed"
  if active nodered; then ok "Node-RED running"; else bad "Node-RED not running" "node-red-start"; fi
  if enabled nodered; then ok "Node-RED starts at boot"; else warn "Node-RED does not start at boot" "sudo systemctl enable nodered.service"; fi
  if listening 1880; then ok "editor on port 1880 → http://${WLAN:-${ETH:-<Pi IP>}}:1880"; else bad "nothing listening on port 1880" "node-red-start, then wait ~20 s"; fi
  if [ -f "$NR_DIR/settings.js" ] && grep -qE '^\s*adminAuth' "$NR_DIR/settings.js"; then ok "editor login enabled (course default pi / raspberry)"; fi
else
  bad "Node-RED not installed" "bash <(curl -sL https://github.com/node-red/linux-installers/releases/latest/download/update-nodejs-and-node-red)"
fi
for pkg in node-red-node-pi-gpio node-red-dashboard node-red-node-sqlite node-red-contrib-influxdb; do
  if [ -d "$NR_DIR/node_modules/$pkg" ] || [ -d "/usr/lib/node_modules/node-red/node_modules/$pkg" ] || [ -d "/usr/local/lib/node_modules/node-red/node_modules/$pkg" ]; then
    ok "palette $pkg"
  else
    bad "palette $pkg missing" "Node-RED → Main menu → Manage palette → Install → $pkg"
  fi
done
# the GLIBC_2.38 trap: sqlite installed but its native binary cannot load
if [ -d "$NR_DIR/node_modules/sqlite3" ]; then
  if (cd "$NR_DIR" && node -e "require('sqlite3')" >/dev/null 2>&1); then
    ok "sqlite3 native module loads"
  else
    bad "sqlite3 native module does NOT load (\"missing node types: sqlitedb, sqlite\")" "sudo apt install -y build-essential python3 python3-setuptools && cd ~/.node-red && npm rebuild sqlite3 --build-from-source && node-red-restart   (see Lecture 10 README → Troubleshooting)"
  fi
fi
if have journalctl && journalctl -u nodered --no-pager -n 200 2>/dev/null | grep -q "missing node types"; then
  warn "the Node-RED log mentions \"missing node types\" recently" "check the palette lines above, then node-red-restart"
fi

# ---------------------------------------------------------------- mosquitto (Lecture 10)
section "4. Mosquitto MQTT broker (Lecture 10 / Practical Q3)"
if have mosquitto || [ -x /usr/sbin/mosquitto ]; then
  ok "Mosquitto installed"
  if active mosquitto; then ok "Mosquitto running"; else bad "Mosquitto not running" "sudo systemctl start mosquitto"; fi
  if enabled mosquitto; then ok "Mosquitto starts at boot"; else warn "Mosquitto does not start at boot" "sudo systemctl enable mosquitto"; fi
  CONF=$(cat /etc/mosquitto/mosquitto.conf /etc/mosquitto/conf.d/*.conf 2>/dev/null)
  if echo "$CONF" | grep -qE '^\s*listener\s+1883'; then ok "config: listener 1883"; else bad "config missing \"listener 1883\" (ESP32 gets connection refused)" "sudo nano /etc/mosquitto/mosquitto.conf → add: listener 1883 → sudo systemctl restart mosquitto"; fi
  if echo "$CONF" | grep -qE '^\s*allow_anonymous\s+true'; then ok "config: allow_anonymous true"; else bad "config missing \"allow_anonymous true\" (rc=5 not authorized)" "add: allow_anonymous true → sudo systemctl restart mosquitto"; fi
  if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE '^(0\.0\.0\.0|\*|\[::\]):1883$'; then ok "port 1883 open to the network"; elif listening 1883; then bad "port 1883 only on localhost" "add the listener line above"; else bad "nothing listening on port 1883" "sudo systemctl restart mosquitto"; fi
  if have mosquitto_pub && have mosquitto_sub; then
    T="/css452/selftest/$$"; OUT=$( (timeout 4 mosquitto_sub -h localhost -t "$T" -C 1 &) ; sleep 1; mosquitto_pub -h localhost -t "$T" -m ping; wait)
    if echo "$OUT" | grep -q ping; then ok "publish → subscribe round trip works"; else bad "MQTT round trip failed" "check the broker log: sudo journalctl -u mosquitto -n 30"; fi
  fi
else
  bad "Mosquitto not installed" "sudo apt install -y mosquitto, then add listener 1883 + allow_anonymous true"
fi

# ---------------------------------------------------------------- sqlite (Lecture 10)
section "5. SQLite (Lecture 10 / Practical Q3)"
if have sqlite3; then
  ok "sqlite3 $(sqlite3 --version | awk '{print $1}')"
  TMPDB=$(mktemp /tmp/css452_check_XXXX.db)
  if sqlite3 "$TMPDB" "create table t(a integer); insert into t values (42); select a from t;" 2>/dev/null | grep -q 42; then ok "create / insert / select works"; else bad "sqlite3 test failed"; fi
  rm -f "$TMPDB"
else
  bad "sqlite3 command missing" "sudo apt install -y sqlite3"
fi
for db in "$HOME/Database1" "$HOME/Database2"; do
  [ -f "$db" ] && ok "$(basename "$db") exists (tables: $(sqlite3 "$db" .tables 2>/dev/null | xargs echo))"
done

# ---------------------------------------------------------------- influxdb (Lecture 11)
section "6. InfluxDB (Lecture 11)"
if have influx || have influxd; then
  ok "InfluxDB installed ($(influx -version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1))"
  if active influxdb; then ok "InfluxDB running"; else bad "InfluxDB not running" "sudo systemctl unmask influxdb && sudo systemctl enable --now influxdb"; fi
  if awk '/^\[http\]/{h=1;next} /^\[/{h=0} h && /^[[:space:]]*enabled[[:space:]]*=[[:space:]]*true/{f=1} END{exit !f}' /etc/influxdb/influxdb.conf 2>/dev/null; then ok "[http] enabled = true"; else bad "HTTP endpoint not enabled" "sudo nano /etc/influxdb/influxdb.conf → in [http] remove # before enabled = true → sudo systemctl restart influxdb"; fi
  if curl -s -o /dev/null -w '%{http_code}' http://localhost:8086/ping 2>/dev/null | grep -q 204; then ok "port 8086 answers (/ping)"; else bad "port 8086 does not answer" "check [http] above, then sudo systemctl restart influxdb"; fi
  DBS=$(influx -execute "show databases" 2>/dev/null)
  if echo "$DBS" | grep -qx InfluxTest; then ok "database InfluxTest"; else bad "database InfluxTest missing" "influx -execute \"create database InfluxTest\""; fi
  if influx -execute "show users" 2>/dev/null | grep -q InfluxUser; then ok "user InfluxUser"; else warn "user InfluxUser missing" "influx -execute \"create user InfluxUser with password 'InfluxPW' with all privileges\""; fi
else
  bad "InfluxDB not installed" "see Lecture 11 README → Pi setup"
fi

# ---------------------------------------------------------------- grafana (Lecture 11)
section "7. Grafana (Lecture 11)"
if [ -x /usr/sbin/grafana-server ] || [ -x /usr/share/grafana/bin/grafana ] || have grafana-server; then
  ok "Grafana installed"
  if active grafana-server; then ok "grafana-server running"; else bad "grafana-server not running" "sudo /bin/systemctl enable --now grafana-server"; fi
  H=$(curl -s http://localhost:3000/api/health 2>/dev/null)
  if echo "$H" | grep -q '"database": *"ok"'; then ok "port 3000 answers → http://${WLAN:-${ETH:-<Pi IP>}}:3000  (version $(echo "$H" | grep -oE '"version": *"[^"]+"' | grep -oE '[0-9][0-9.]+'))"; else bad "Grafana not answering on port 3000" "wait ~30 s after boot, or sudo systemctl restart grafana-server"; fi
  if curl -s -u admin:admin http://localhost:3000/api/org 2>/dev/null | grep -q '"id"'; then
    ok "login admin / admin works"
    if curl -s -u admin:admin http://localhost:3000/api/datasources 2>/dev/null | grep -q '"type":"influxdb"'; then ok "InfluxDB data source configured"; else warn "no InfluxDB data source yet" "Connections → Add new connection → InfluxDB: http://localhost:8086, InfluxTest, InfluxUser/InfluxPW, POST"; fi
  else
    warn "admin / admin does not log in" "sudo grafana-cli admin reset-admin-password admin  (or use your own password)"
  fi
else
  bad "Grafana not installed" "see Lecture 11 README → Pi setup"
fi

# ---------------------------------------------------------------- summary
printf "\n${B}Summary:${N} ${G}%d passed${N}, ${Y}%d warnings${N}, ${R}%d failed${N}\n" "$PASS" "$WARN" "$FAIL"
if [ "$FAIL" -eq 0 ]; then
  printf "${G}${B}Ready for the practical exam.${N}\n"
else
  printf "${R}${B}Fix the ✘ items above before the exam.${N}\n"
fi
printf "${D}Before the exam also: wire LEDs/switch from the README diagrams, keep only ONE GPIO tab enabled in Node-RED, and put the ESP32 on the same Wi-Fi as the Pi.${N}\n"
exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
