#!/usr/bin/env python3
"""Two-way text clipboard sync between this Mac and a Raspberry Pi over SSH.

macOS Screen Sharing can't share the clipboard with a non-Mac VNC server, so
this runs alongside it:
  Mac ⌘C        → Pi clipboard (paste with Ctrl+V)
  Pi  Ctrl+C    → Mac clipboard (paste with ⌘V)

Usage: pi-clipsync.py [user@host]      (default pi@raspberrypi.local)
Needs: SSH key login to the Pi, and `xclip` installed on the Pi.
"""
import base64, os, subprocess, sys, threading, time

HOST = sys.argv[1] if len(sys.argv) > 1 else "pi@raspberrypi.local"
POLL = 0.5
SSH = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=5",
       "-o", "ServerAliveInterval=10", "-o", "ServerAliveCountMax=2",
       "-o", "ControlMaster=auto", "-o", "ControlPersist=60",
       "-o", "ControlPath=~/.ssh/cm-clipsync-%r@%h:%p", HOST]
UTF8 = dict(os.environ, LANG="en_US.UTF-8", LC_ALL="en_US.UTF-8")
PI_ENV = "export DISPLAY=:0 XAUTHORITY=$HOME/.Xauthority;"

# Prints the Pi's clipboard as one base64 line every time it changes.
PI_WATCH = PI_ENV + r"""
last=""
while sleep %s; do
  cur=$(xclip -selection clipboard -o 2>/dev/null | base64 -w0)
  if [ "$cur" != "$last" ]; then last=$cur; echo "$cur"; fi
done
""" % POLL
PI_SET = PI_ENV + "xclip -selection clipboard -i >/dev/null 2>&1"

last = None          # last text seen on either side (prevents ping-pong)
lock = threading.Lock()

def log(msg):
    print(time.strftime("%H:%M:%S"), msg, flush=True)

def mac_get():
    return subprocess.run(["pbpaste"], capture_output=True, env=UTF8).stdout.decode("utf-8", "replace")

def mac_set(text):
    subprocess.run(["pbcopy"], input=text.encode(), env=UTF8)

def pi_set(text):
    r = subprocess.run(SSH + [PI_SET], input=text.encode(), capture_output=True, timeout=15)
    return r.returncode == 0

def watch_pi():
    """Pi → Mac. Reconnects forever (e.g. while the Pi reboots)."""
    global last
    while True:
        p = subprocess.Popen(SSH + [PI_WATCH], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        log(f"connected to {HOST}")
        for line in p.stdout:
            try:
                text = base64.b64decode(line.strip()).decode("utf-8", "replace")
            except Exception:
                continue
            with lock:
                if text and text != last:
                    last = text
                    mac_set(text)
                    log(f"Pi → Mac ({len(text)} chars)")
        err = p.stderr.read().decode(errors="replace").strip()
        log(f"lost connection{': ' + err if err else ''}; retrying in 5 s")
        time.sleep(5)

def watch_mac():
    """Mac → Pi."""
    global last
    with lock:
        last = mac_get()   # don't push whatever was already on the Mac clipboard at start
    while True:
        time.sleep(POLL)
        text = mac_get()
        with lock:
            if not text or text == last:
                continue
            last = text
        try:
            ok = pi_set(text)
        except subprocess.TimeoutExpired:
            ok = False
        log(f"Mac → Pi ({len(text)} chars)" if ok else "Mac → Pi failed (Pi offline?)")

if __name__ == "__main__":
    threading.Thread(target=watch_pi, daemon=True).start()
    watch_mac()
