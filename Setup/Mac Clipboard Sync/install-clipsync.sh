#!/usr/bin/env bash
# Run on the MAC (in Terminal, not on the Pi):
#   bash install-clipsync.sh [user@host]        default: pi@raspberrypi.local
#
# Sets up two-way clipboard sync with the Pi so copy/paste works while using
# macOS Screen Sharing. Run `bash install-clipsync.sh --uninstall` to remove it.

set -euo pipefail
cd "$(dirname "$0")"

LABEL="local.pi-clipsync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
BIN="$HOME/.local/bin/pi-clipsync.py"
LOG="$HOME/Library/Logs/pi-clipsync.log"

say() { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }

if [[ "${1:-}" == "--uninstall" ]]; then
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  rm -f "$PLIST" "$BIN"
  echo "Clipboard sync removed."
  exit 0
fi

TARGET="${1:-pi@raspberrypi.local}"
HOSTNAME_ONLY="${TARGET#*@}"

# 1. SSH key login (asks for your key passphrase / Pi password once) ----------
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  say "Creating an SSH key"
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
fi

say "Remembering the SSH key passphrase in your Keychain"
touch ~/.ssh/config
if ! grep -q "# pi-clipsync" ~/.ssh/config; then
  cat >> ~/.ssh/config <<EOF

# pi-clipsync
Host $HOSTNAME_ONLY
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
fi
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

if ssh -o BatchMode=yes -o ConnectTimeout=5 "$TARGET" true 2>/dev/null; then
  say "SSH key login already works"
else
  say "Copying your SSH key to the Pi (enter the Pi's password)"
  ssh-copy-id -i ~/.ssh/id_ed25519.pub "$TARGET"
fi
ssh -o BatchMode=yes "$TARGET" true || { echo "SSH key login still fails, stopping."; exit 1; }

# 2. xclip on the Pi --------------------------------------------------------
say "Installing xclip on the Pi (may ask for the Pi's sudo password)"
ssh -t "$TARGET" 'command -v xclip >/dev/null || (sudo apt-get update -qq && sudo apt-get install -y -qq xclip)'

# 3. Background job on the Mac ----------------------------------------------
say "Installing the background clipboard sync"
mkdir -p "$(dirname "$BIN")" "$(dirname "$PLIST")" "$(dirname "$LOG")"
cp pi-clipsync.py "$BIN"
chmod +x "$BIN"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/python3</string>
    <string>-u</string>
    <string>$BIN</string>
    <string>$TARGET</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ThrottleInterval</key><integer>10</integer>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

sleep 3
say "Done. Recent log ($LOG):"
tail -n 5 "$LOG" || true
cat <<EOF

Copy on the Mac (⌘C)  → paste on the Pi (Ctrl+V)
Copy on the Pi (Ctrl+C) → paste on the Mac (⌘V)

It starts automatically at login. Remove with: bash install-clipsync.sh --uninstall
EOF
