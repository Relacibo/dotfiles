#!/usr/bin/env bash
# bootstrap-settings.sh – EINMALIG pro Maschine: Joplin-Settings für Agent-Betrieb
# Setzt idempotent: clipperServer.autoStart, showTrayIcon, startMinimized
# (startMinimized wirkt nur zusammen mit showTrayIcon → unsichtbarer Tray-Start)

set -euo pipefail

CFG="$HOME/.config/joplin-desktop/settings.json"
[ -f "$CFG" ] || { echo "Joplin nicht eingerichtet ($CFG fehlt) – erst Joplin installieren & starten." >&2; exit 1; }

if pgrep -f 'net[.]cozic' >/dev/null 2>&1; then
  echo "Joplin läuft gerade – bitte beenden (oder Agent beendet es), dann Bootstrap erneut." >&2
  exit 1
fi

python3 - "$CFG" <<'EOF'
import json, sys
p = sys.argv[1]
cfg = json.load(open(p))
changed = []
for k in ("clipperServer.autoStart", "showTrayIcon", "startMinimized"):
    if not cfg.get(k):
        cfg[k] = True
        changed.append(k)
with open(p, "w") as f:
    json.dump(cfg, f, indent="\t")
print("gesetzt:", ", ".join(changed) if changed else "nichts – alles schon korrekt")
EOF
