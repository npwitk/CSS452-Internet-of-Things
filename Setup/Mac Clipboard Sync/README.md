# Setup – Copy/paste between Mac and Raspberry Pi

Two-way text clipboard sync over SSH, for use alongside [Mac Screen Sharing](../Mac%20Screen%20Sharing/).

| Copy on | Shortcut | Paste on | Shortcut |
|---|---|---|---|
| Mac | ⌘C | Pi | Ctrl+V |
| Pi | Ctrl+C (Terminal: Ctrl+Shift+C) | Mac | ⌘V |

Text only, including Thai. Images and files aren't copied.

## Why it's needed

In macOS Screen Sharing, **Edit → Use Shared Clipboard** is greyed out with a Pi. With a non-Apple VNC server, Screen Sharing falls back to the oldest VNC protocol (3.3) and never sends clipboard text, so no setting on the Pi can fix it. Instead, a small background job on the Mac syncs the two clipboards over SSH.

## Install (once, on the Mac)

Run this in **Terminal on the Mac**, not on the Pi, from this folder:

```bash
bash install-clipsync.sh                 # default target pi@raspberrypi.local
bash install-clipsync.sh pi@192.168.2.2  # or a specific user@host
```

It asks for:

1. Your **SSH key passphrase**, which is saved in your Keychain so the background job can log in.
2. The **Pi's password**, to copy your SSH key (`ssh-copy-id`).
3. The **Pi's password** again, for `sudo apt install xclip` on the Pi.

Then copy something on each side to test it.

## What it does

| Where | What |
|---|---|
| Mac `~/.ssh/config` | `UseKeychain yes` for the Pi's host, so SSH works without prompts |
| Pi | `xclip` installed, to read and set the X11 clipboard |
| Mac `~/.local/bin/pi-clipsync.py` | Checks both clipboards every 0.5 s and copies new text across |
| Mac `~/Library/LaunchAgents/local.pi-clipsync.plist` | Starts the sync at login and restarts it if it stops |

If the Pi is off or rebooting, the sync waits and reconnects by itself.

## Troubleshooting

```bash
tail -f ~/Library/Logs/pi-clipsync.log                       # shows "Mac → Pi" / "Pi → Mac" lines
launchctl kickstart -k gui/$(id -u)/local.pi-clipsync        # restart it
ssh -o BatchMode=yes pi@raspberrypi.local true && echo ok    # SSH key login works?
```

- **Nothing syncs from the Pi:** make sure the Pi desktop is logged in (X11, display `:0`), and that you actually copied rather than just selected.
- **"Permission denied (publickey)" in the log:** run `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`, then restart the job.

## Uninstall

```bash
bash install-clipsync.sh --uninstall
```
