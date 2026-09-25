---
name: joplin
description: Startet Joplin unsichtbar im Tray und erstellt/aktualisiert Notizen über die Joplin Data API (localhost:41184). Use when the user asks to create, edit, update or sync a Joplin note, or when Joplin needs to be started first, or mentions Joplin notebooks like "Server".
---

# Joplin steuern

## App starten (unsichtbar im Tray)

Joplin ist ein Flatpak und startet mit `startMinimized` + `showTrayIcon` **ohne
sichtbares Fenster** – Prozess + Data API laufen trotzdem:

```bash
setsid nohup flatpak run net.cozic.joplin_desktop >/dev/null 2>&1 &
# dann auf API warten (dauert 3-15 s):
curl -s --max-time 2 http://localhost:41184/ping   # erwartet: JoplinClipperServer
```

Kein Fensterhandling nötig (kein hyprctl/wmctrl). Der User sieht nur das Tray-Icon.
Getestet: funktioniert voll autonom, ohne Rückfrage, aus Agent-Shells heraus.

## Data API

- URL: `http://localhost:41184`
- Token: aus `~/.config/joplin-desktop/settings.json` (Key `"api.token"`) lesen, nicht raten.
- Der API-Server startet automatisch mit der App (`clipperServer.autoStart: true`).

**Antwortformat:** Listen-Endpunkte antworten als `{"items":[...]}` – nicht als bare Array.
Token als Query-Param `?token=…` (Header `X-Auth-Token` unzuverlässig).
Notiz-Update per **PUT** (`PATCH` → HTTP 405).

## Standard-Operationen (Python, JSON-safe)

```python
import json, urllib.request
TOKEN = "<aus settings.json>"

def api(path, method="GET", payload=None):
    data = json.dumps(payload).encode() if payload else None
    req = urllib.request.Request(f"http://localhost:41184/{path}?token={TOKEN}",
                                 data=data, headers={"Content-Type": "application/json"}, method=method)
    return json.load(urllib.request.urlopen(req, timeout=10))

api("folders")                                    # Notizbücher: {"items":[{id,title}]}
api("notes", "POST", {"title": "…", "body": "…", "parent_id": "<folder-id>"})   # neue Notiz
api("notes/<id>", "PUT", {"body": "…"})           # Notiz aktualisieren (PUT, nicht PATCH!)
api("search?query=backup&type=folder")            # suchen
```

Große Bodies: aus Datei/Quelle lesen, nicht ins Template pasten.

## Bekannte IDs (dieses System)

- Notizbuch **"Server"**: `048ad3af500447efbe04c86fe39cb349`
- Notiz **"Backup-Setup: restic (verschlüsselt) → ovilava"**: `8e9bea020f0e4eb8b75793936061ac9a`
  → **Dies ist die Quelle der Wahrheit** für das Backup-Runbook (früher lag es in
  `~/backup-setup.md`, gelöscht). Nach Architektur-Änderungen die Notiz per PUT aktualisieren.

## Wichtige Settings (`~/.config/joplin-desktop/settings.json`)

| Key | Wirkung |
|---|---|
| `clipperServer.autoStart: true` | Data API startet mit der App |
| `showTrayIcon: true` + `startMinimized: true` | App startet unsichtbar im Tray (Fenster-los); nur zusammen aktiv! |

Falls Fenster doch mal sichtbar ist: Schließen (X) parkt Joplin im Tray, beendet es nicht.

## Hinweise

- Sync-Target ist WebDAV (`cloud.rcbnet.work/dav/joplin`) – Notizen synchronisieren von selbst.
- Niemals direkt in `~/.config/joplin-desktop/database.sqlite` schreiben.
