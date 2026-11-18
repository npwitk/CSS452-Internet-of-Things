# Setup – Raspberry Pi desktop from macOS Screen Sharing

See and control the Pi's desktop from a Mac with the built-in **Screen Sharing** app. You don't need to install RealVNC Viewer.

Requires **Raspberry Pi OS Bookworm with Desktop**, with the Pi and the Mac on the same Wi-Fi.

## Why the default VNC doesn't work

Out of the box, the Pi's VNC servers (wayvnc on Wayland, RealVNC Server on X11) only offer their own login methods. macOS Screen Sharing only supports the plain **VNC password**, so it fails with *"Unable to communicate…"* or *"…appears to be incompatible with this version of Screen Sharing"*. Turning on `VncAuth` and turning off encryption in RealVNC isn't enough, because RealVNC still doesn't offer the plain password method.

To fix it, the script switches the desktop to X11, turns off wayvnc and RealVNC, and runs **x11vnc** with a plain VNC password instead.

## Run it (once)

From the Mac, in this folder:

```bash
scp pi-mac-screen-sharing.sh pi@raspberrypi.local:
ssh pi@raspberrypi.local
```

Then on the Pi:

```bash
sudo bash pi-mac-screen-sharing.sh
```

1. Enter a VNC password **(8 characters max)** twice.
2. Answer `Y` to reboot.

## Connect from the Mac

Finder → **Go → Connect to Server** (⌘K) → `vnc://raspberrypi.local` → enter the VNC password.

If `raspberrypi.local` doesn't resolve, use the IP address printed at the end of the script instead (e.g. `vnc://192.168.2.2`).

## What the script does

| Step | Command |
|---|---|
| Desktop → X11 | `raspi-config nonint do_wayland W1` |
| Turn off built-in VNC | `systemctl disable --now wayvnc vncserver-x11-serviced` |
| Install x11vnc + password | `apt install x11vnc`, `x11vnc -storepasswd … /etc/x11vnc.pass` |
| Start at boot | `/etc/systemd/system/x11vnc.service` on display `:0` |
| No monitor attached | `raspi-config nonint do_vnc_resolution 1920x1080` |

## Troubleshooting

```bash
systemctl status x11vnc          # should be "active (running)"
sudo ss -ltnp | grep 5900        # should show x11vnc, not wayvnc / vncserver
```

- **Black screen:** no monitor is attached. Run `sudo raspi-config nonint do_vnc_resolution 1920x1080 && sudo reboot`.
- **Change the VNC password:** `sudo x11vnc -storepasswd /etc/x11vnc.pass && sudo systemctl restart x11vnc`
- **Undo:** run `sudo systemctl disable --now x11vnc`, then turn VNC back on in `sudo raspi-config` → Interface Options → VNC.

## Notes

- The VNC connection **isn't encrypted**. Use it only on a trusted network, and never forward port 5900 on the router.
- After setup, RealVNC Viewer and the RealVNC cloud service won't connect to this Pi.
- If the `pi` user still has the default password, change it with `passwd`.
