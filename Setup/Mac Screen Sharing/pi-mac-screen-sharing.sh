#!/usr/bin/env bash
# Sets up a Raspberry Pi so macOS Screen Sharing (Finder ⌘K → vnc://<pi>) can connect.
#
# What it does:
#   1. Switches the desktop from Wayland to X11
#   2. Turns off the Pi's built-in VNC servers (wayvnc, RealVNC); macOS can't use their logins
#   3. Installs x11vnc with a plain VNC password, which macOS Screen Sharing supports
#   4. Starts x11vnc automatically at every boot
#
# Run on the Pi:   sudo bash pi-mac-screen-sharing.sh
# Tested on Raspberry Pi OS Bookworm (desktop version, LightDM).

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

say()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m!!\033[0m %s\n' "$*"; }
die()  { printf '\n\033[1;31mxx\033[0m %s\n' "$*"; exit 1; }

# --- Checks ---------------------------------------------------------------
command -v raspi-config >/dev/null || die "raspi-config not found. Is this Raspberry Pi OS?"
[[ -f /usr/share/xsessions/LXDE-pi-x.desktop ]] || \
  die "No X11 desktop session found. This needs Raspberry Pi OS with Desktop (Bookworm)."
[[ -d /etc/lightdm ]] || die "LightDM not found. This needs the Raspberry Pi OS desktop."

# --- VNC password ---------------------------------------------------------
echo
echo "Pick a password for Screen Sharing (max 8 characters; anything longer is cut off)."
while true; do
  read -rsp "VNC password: " P1; echo
  read -rsp "Again: " P2; echo
  if [[ -z "$P1" ]]; then echo "Password can't be empty."; continue; fi
  if [[ "$P1" != "$P2" ]]; then echo "Passwords don't match, try again."; continue; fi
  if (( ${#P1} > 8 )); then echo "Use 8 characters or fewer."; continue; fi
  break
done

# --- 1. Switch to X11 -----------------------------------------------------
say "Switching the desktop to X11"
raspi-config nonint do_wayland W1

# --- 2. Turn off the built-in VNC servers --------------------------------
say "Turning off wayvnc / RealVNC Server (if present)"
for svc in wayvnc wayvnc-control vncserver-x11-serviced; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# --- 3. Install x11vnc ----------------------------------------------------
say "Installing x11vnc"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq x11vnc

x11vnc -storepasswd "$P1" /etc/x11vnc.pass >/dev/null
chmod 600 /etc/x11vnc.pass
unset P1 P2

# --- 4. Start at boot -----------------------------------------------------
say "Creating the x11vnc service"
cat > /etc/systemd/system/x11vnc.service <<'EOF'
[Unit]
Description=x11vnc (macOS Screen Sharing compatible)
After=display-manager.service
Requires=display-manager.service

[Service]
ExecStart=/usr/bin/x11vnc -auth /var/run/lightdm/root/:0 -display :0 -forever -loop -noxdamage -repeat -shared -rfbauth /etc/x11vnc.pass -rfbport 5900
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical.target
EOF
systemctl daemon-reload
systemctl enable x11vnc >/dev/null

# --- Headless Pi: give it a screen size -----------------------------------
if ! grep -qs '^connected' /sys/class/drm/*/status; then
  say "No monitor detected, so setting a 1920x1080 virtual screen"
  raspi-config nonint do_vnc_resolution 1920x1080 || warn "Couldn't set resolution; you may see a black screen."
fi

# --- Done -----------------------------------------------------------------
IP=$(hostname -I | awk '{print $1}')
HOST=$(hostname)
cat <<EOF

Done! After the reboot, on the Mac:
  Finder → Go → Connect to Server (⌘K) → vnc://${HOST}.local
  (or vnc://${IP})
  and enter the VNC password you just set.

Notes:
  • This connection isn't encrypted, so use it on your home network only.
  • If you still use the default 'pi' password, change it with: passwd

EOF

read -rp "Reboot now? [Y/n] " ans
if [[ ! "$ans" =~ ^[Nn] ]]; then
  reboot
else
  echo "Reboot later with: sudo reboot"
fi
