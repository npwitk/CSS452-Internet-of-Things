#!/usr/bin/env bash
# CSS452 Pi helper – open the web pages and start/stop the services without remembering ports.
#
# Works from your Mac (opens pages in your browser, controls the Pi over SSH)
# and on the Pi itself (opens pages in the Pi's browser, runs commands locally).
#
#   ./pi.sh                     interactive menu
#   ./pi.sh open nodered        Node-RED editor      (:1880)
#   ./pi.sh open ui             Node-RED dashboard   (:1880/ui)
#   ./pi.sh open grafana        Grafana              (:3000)
#   ./pi.sh status              which services are up, which ports answer
#   ./pi.sh nodered start|stop|restart|log
#   ./pi.sh mosquitto|influxdb|grafana start|stop|restart|status|log
#   ./pi.sh ssh | ip | logins | check | setup-key | find | use <host> | where
#
# Which Pi: found automatically and remembered in ~/.css452_pi_host.
#   ./pi.sh find               search again (after renaming the Pi or changing network)
#   ./pi.sh use peanut-pi.local  set it yourself
#   ./pi.sh --host 192.168.1.109 status   or   export PI_HOST=...   (one-off override)

PI_USER="${PI_USER:-pi}"
SAVED="$HOME/.css452_pi_host"
if [ "$1" = "--host" ]; then PI_HOST="$2"; HOST_SRC=flag; shift 2
elif [ -n "$PI_HOST" ]; then HOST_SRC=env
elif [ -s "$SAVED" ]; then PI_HOST=$(head -n1 "$SAVED"); HOST_SRC=saved
else PI_HOST=raspberrypi.local; HOST_SRC=default; fi

if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; D=$'\e[2m'; N=$'\e[0m'; else G=; R=; Y=; B=; D=; N=; fi
say()  { printf "%s\n" "$*"; }
die()  { printf "${R}%s${N}\n" "$*" >&2; exit 1; }

# Are we running ON the Pi?
ON_PI=0; grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null && ON_PI=1
if [ "$ON_PI" -eq 1 ]; then HOST=localhost; else HOST="$PI_HOST"; fi

run() {   # run a shell command on the Pi (locally or via ssh -t so sudo can ask for a password)
  if [ "$ON_PI" -eq 1 ]; then bash -c "$1"; else ssh -t -o ConnectTimeout=6 "$PI_USER@$PI_HOST" "$1"; fi
}
open_url() {
  say "${B}opening${N} $1"
  if have_cmd open && [ "$(uname)" = "Darwin" ]; then open "$1"
  elif have_cmd xdg-open; then xdg-open "$1" >/dev/null 2>&1 &
  else say "open this in a browser: $1"; fi
}
have_cmd() { command -v "$1" >/dev/null 2>&1; }
port_up() {   # port_up host port
  if have_cmd nc; then nc -z -G 2 "$1" "$2" >/dev/null 2>&1 || nc -z -w 2 "$1" "$2" >/dev/null 2>&1
  else (exec 3<>"/dev/tcp/$1/$2") >/dev/null 2>&1; fi
}
resolve() {   # print the Pi's IP (best effort)
  if [ "$ON_PI" -eq 1 ]; then hostname -I | awk '{print $1}'; return; fi
  ping -c1 -t2 "$PI_HOST" 2>/dev/null | sed -n 's/.*(\([0-9.]*\)).*/\1/p' | head -n1 \
    || ping -c1 -W2 "$PI_HOST" 2>/dev/null | sed -n 's/.*(\([0-9.]*\)).*/\1/p' | head -n1
}
candidates() {   # possible Pi addresses: names/IPs this Mac has SSH'd to before + Internet Sharing range
  { [ -n "$PI_HOST" ] && echo "$PI_HOST"
    echo raspberrypi.local
    awk '{print $1}' "$HOME/.ssh/known_hosts" 2>/dev/null | tr ',' '\n' | sed 's/^\[//; s/\]:.*//' \
      | grep -E '\.local$|^192\.168\.2\.[0-9]+$' | grep -v '^|'
    if ifconfig bridge100 2>/dev/null | grep -q 'inet 192.168.2.1 '; then   # Mac Internet Sharing is on
      for i in 2 3 4 5 6 7 8 9 10; do echo "192.168.2.$i"; done
    fi
  } | awk '!seen[$0]++'
}
find_pi() {   # probe candidates for SSH, let the user pick, remember the choice
  say "${B}Looking for a Raspberry Pi…${N}"
  found=()
  while read -r h; do
    [ -z "$h" ] && continue
    if port_up "$h" 22; then
      ip=$(ping -c1 -t1 "$h" 2>/dev/null | sed -n 's/.*(\([0-9.]*\)).*/\1/p' | head -n1)
      name=$(ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "$PI_USER@$h" hostname 2>/dev/null)
      found+=("$h"); printf "  %d) %-22s %-15s %s\n" "${#found[@]}" "$h" "${ip:-}" "${name:+hostname: $name}"
    fi
  done < <(candidates)
  [ ${#found[@]} -eq 0 ] && die "No Pi found. Is it on and connected?
  • Cable to the Mac: turn on Internet Sharing, wait ~1 min after boot.
  • Wi-Fi: same network as the Mac. On the Pi run: hostname -I   then:  ./pi.sh use <IP>"
  if [ ${#found[@]} -eq 1 ]; then pick=1
  else printf "Which one is yours? [1-%d] " "${#found[@]}"; read -r pick </dev/tty
       [[ "$pick" =~ ^[0-9]+$ ]] && [ "$pick" -ge 1 ] && [ "$pick" -le ${#found[@]} ] || die "cancelled"
  fi
  PI_HOST="${found[$((pick-1))]}"; HOST="$PI_HOST"
  echo "$PI_HOST" > "$SAVED"
  say "${G}Using $PI_HOST${N} ${D}(saved in ~/.css452_pi_host; change with ./pi.sh find or ./pi.sh use <host>)${N}"
}
need_pi() {
  [ "$ON_PI" -eq 1 ] && return 0
  port_up "$PI_HOST" 22 && return 0
  if [ "$HOST_SRC" = saved ] || [ "$HOST_SRC" = default ]; then
    say "${Y}$PI_HOST doesn't answer.${N}"; find_pi; return 0
  fi
  die "Can't reach the Pi at $PI_HOST.
  • Cable to the Mac: turn on Internet Sharing, wait ~1 min after boot.
  • Wi-Fi: Mac and Pi on the same network; find the IP on the Pi with: hostname -I
  • Or let the script search:  unset PI_HOST; ./pi.sh find"
}

logins() {
  printf "${B}Ports and logins (CSS452 defaults)${N}\n"
  row() { printf "  %-13s %-36s %s\n" "$1" "$2" "$3"; }
  row "SSH"         "ssh $PI_USER@$PI_HOST"      "password: raspberry"
  row "Node-RED"    "http://$HOST:1880"          "login: pi / raspberry"
  row "Dashboard"   "http://$HOST:1880/ui"       "(needs node-red-dashboard)"
  row "MQTT broker" "$HOST:1883 (Mosquitto)"     "no login (allow_anonymous true)"
  row "InfluxDB"    "http://$HOST:8086"          "InfluxUser / InfluxPW, db InfluxTest"
  row "Grafana"     "http://$HOST:3000"          "admin / admin"
  row "ESP32"       "mqtt_server = Pi's Wi-Fi IP" "(./pi.sh ip)"
}

status() {
  need_pi
  IP=$(resolve); say "${B}Pi:${N} $HOST${IP:+  ($IP)}"
  for row in "SSH 22" "Node-RED 1880" "Mosquitto 1883" "InfluxDB 8086" "Grafana 3000"; do
    name=${row% *}; port=${row#* }
    if port_up "$HOST" "$port"; then printf "  ${G}●${N} %-10s port %-5s up\n" "$name" "$port"
    else printf "  ${R}○${N} %-10s port %-5s ${R}down${N}\n" "$name" "$port"; fi
  done
}

service() {   # service <unit> <action>
  unit="$1"; act="${2:-status}"; need_pi
  case "$act" in
    start|stop|restart) run "sudo systemctl $act $unit && systemctl --no-pager --lines=0 status $unit | head -n 3" ;;
    status)             run "systemctl --no-pager status $unit | head -n 12" ;;
    log)                run "sudo journalctl -u $unit -f -n 40" ;;
    enable|disable)     run "sudo systemctl $act $unit" ;;
    *) die "unknown action: $act (use start, stop, restart, status, log)";;
  esac
}

menu() {
  [ "$ON_PI" -eq 1 ] || need_pi
  logins; echo
  cat <<EOF
${B}What do you want to do?${N}
   1) open Node-RED editor        6) restart Node-RED
   2) open Node-RED dashboard     7) Mosquitto status
   3) open Grafana                8) restart Mosquitto
   4) status of everything        9) show the Pi's IPs
   5) SSH into the Pi            10) full readiness check
  11) search for the Pi again
   q) quit
EOF
  printf "> "; read -r c
  case "$c" in
    1) open_url "http://$HOST:1880" ;;   2) open_url "http://$HOST:1880/ui" ;;
    3) open_url "http://$HOST:3000" ;;   4) status ;;
    5) need_pi; [ "$ON_PI" -eq 1 ] && say "you are already on the Pi" || ssh "$PI_USER@$PI_HOST" ;;
    6) service nodered restart ;;        7) service mosquitto status ;;
    8) service mosquitto restart ;;      9) need_pi; run "hostname -I; iwgetid -r 2>/dev/null | sed 's/^/Wi-Fi: /'" ;;
    10) "$0" --host "$PI_HOST" check ;;
    11) find_pi ;;
    *) ;;
  esac
}

cmd="${1:-menu}"; shift 2>/dev/null
case "$cmd" in
  menu)      menu ;;
  open)      need_pi
             case "${1:-nodered}" in
               nodered|editor|node-red) open_url "http://$HOST:1880" ;;
               ui|dashboard)           open_url "http://$HOST:1880/ui" ;;
               grafana)                open_url "http://$HOST:3000" ;;
               all) open_url "http://$HOST:1880"; open_url "http://$HOST:1880/ui"; open_url "http://$HOST:3000" ;;
               *) die "open what? nodered, ui, grafana, all" ;;
             esac ;;
  status)    status ;;
  find)      [ "$ON_PI" -eq 1 ] && die "you are on the Pi already"; find_pi ;;
  use)       [ -n "$1" ] || die "usage: ./pi.sh use <name or IP>"
             echo "$1" > "$SAVED"; say "${G}saved: $1${N}" ;;
  where)     say "$PI_HOST  (${HOST_SRC})" ;;
  logins|ports|help-ports) logins ;;
  ip)        need_pi; run "hostname -I; iwgetid -r 2>/dev/null | sed 's/^/Wi-Fi: /'" ;;
  ssh)       need_pi; [ "$ON_PI" -eq 1 ] && say "you are already on the Pi" || ssh "$PI_USER@$PI_HOST" ;;
  nodered|node-red)
             case "${1:-status}" in
               log) need_pi; run "node-red-log" ;;
               *)   service nodered "${1:-status}" ;;
             esac ;;
  mosquitto) service mosquitto "$1" ;;
  influxdb|influx) service influxdb "$1" ;;
  grafana)   service grafana-server "$1" ;;
  check)     need_pi
             DIR=$(cd "$(dirname "$0")" && pwd)
             if [ "$ON_PI" -eq 1 ]; then bash "$DIR/check_pi_ready.sh"
             else ssh -o ConnectTimeout=6 "$PI_USER@$PI_HOST" 'bash -s' < "$DIR/check_pi_ready.sh"; fi ;;
  setup-key) [ "$ON_PI" -eq 1 ] && die "run setup-key on your Mac, not on the Pi"
             [ -f "$HOME/.ssh/id_ed25519.pub" ] || ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
             ssh-copy-id "$PI_USER@$PI_HOST" && say "${G}done: SSH (and this script) won't ask for the password any more${N}" ;;
  -h|--help|help)
             sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//' ;;
  *)         die "unknown command: $cmd  (try: ./pi.sh help)" ;;
esac
