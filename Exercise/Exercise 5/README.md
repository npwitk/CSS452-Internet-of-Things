# Exercise 5 – Access the Raspberry Pi from a Notebook

**Task:** record a video showing that you can reach the Raspberry Pi from your notebook (Lecture Note 8, Section 2, Raspberry Pi Setup). The video must show the **Raspberry Pi desktop** and the **Thonny Python IDE**. Submit it to Google Classroom.

These are the Mac steps. The lecture uses PuTTY on Windows, and on a Mac the Terminal's `ssh` does the same job.

Default login on the course SD card: user `pi`, password `raspberry`.

## 1. Connect

1. Insert the SD card and connect an Ethernet cable from the Pi to the Mac. Use a USB-C or Thunderbolt Ethernet adapter if the Mac has no Ethernet port.
2. Power the Pi through its USB-C port.

## 2. Share the Mac's internet with the Pi

- **macOS Ventura or later:** System Settings → General → Sharing → **Internet Sharing** → click ⓘ.
  Set "Share your connection from" to **Wi-Fi** and "To computers using" to your **USB/Thunderbolt LAN** adapter, then turn it on.
- **Older macOS:** System Preferences → Sharing → Internet Sharing. The settings are the same.

Wait about a minute after boot. `raspberrypi.local` resolves through Bonjour (mDNS).

## 3. SSH in and enable VNC

```bash
ssh pi@raspberrypi.local        # password: raspberry
sudo raspi-config
```

In `raspi-config`, move with the arrow keys, press Enter to choose, and press Tab to reach Finish:

1. **Interface Options → VNC → Yes**. This enables the VNC server.
2. **System Options → Boot / Auto Login → Desktop Autologin**. On older OS versions the path is Boot Options → Desktop/CLI → Desktop Autologin.
3. **Finish**. The Pi reboots and the SSH session ends.

## 4. Open the desktop with RealVNC Viewer

1. Install **RealVNC Viewer** (realvnc.com). The built-in macOS Screen Sharing often cannot log in with RealVNC's default security.
2. Connect to `raspberrypi.local` → **Continue** → `pi` / `raspberry` → **OK**.
3. The Pi desktop appears in the VNC window.

## 5. Open Thonny

Raspberry menu → **Programming → Thonny Python IDE**. Open `01_Hello_Thonny/01_Hello_Thonny.py`, or paste its contents, and click **Run**. The Shell prints `Hello World`, the Pi's hostname and the Python version.

## Resolution fix: "Cannot currently show the desktop"

With no monitor plugged in, the Pi may have no display mode, and VNC then shows this message. To fix it:

```bash
ssh pi@raspberrypi.local
sudo raspi-config               # Display Options → Resolution → e.g. 1280x720 → Finish → reboot
```

Reconnect with VNC Viewer afterwards.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `raspberrypi.local` not found | Check that Internet Sharing is on and the right adapter is ticked. Wait about 1 minute after boot. |
| `ssh: connection refused` | SSH is disabled. Create an empty file named `ssh` in the SD card's boot partition. |
| VNC "Cannot currently show the desktop" | Set a resolution other than Default (see above). |
| VNC refuses the login | Make sure VNC is enabled in `raspi-config` and check the username and password. |

## The video must show

- the Ethernet cable and power connected to the Pi
- the VNC Viewer window with the Raspberry Pi desktop
- Thonny Python IDE open, running `01_Hello_Thonny.py`
