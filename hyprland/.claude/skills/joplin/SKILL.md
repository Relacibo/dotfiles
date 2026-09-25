---
name: joplin
description: Startet Joplin und erstellt/aktualisiert Notizen über die Joplin Data API (localhost:41184). Use when the user asks to create, edit, update or sync a Joplin note, or when Joplin needs to be started first, or mentions Joplin notebooks like "Server".
---

# Joplin steuern

## App starten (falls zu)

Joplin ist ein Flatpak. Desktop-App detached starten – Fenster erscheint auf dem User-Screen:

```bash
setsid nohup flatpak run net.cozic.joplin_desktop >/dev/null 2>&1 &
```

## Data API

- URL: `http://localhost:41184`
- Token: aus `~/.config/joplin-desktop/settings.json` (Key `"api.token"`) lesen, nicht raten.
- Der API-Server startet automatisch mit der App (`clipperServer.autoStart: true` ist gesetzt). Nach App-Start einige Sekunden warten.

Verfügbarkeit prüfen (erwartet `JoplinClipperServer`):

```bash
curl -s --max-time 3 http://localhost:41184/ping
```

**Antwortformat:** Listen-Endpunkte antworten als `{"items":[...]}` – nicht als bare Array. Token als Query-Param `?token=…` verwenden (Header `X-Auth-Token` ist unzuverlässig).

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
api("notes/<id>", "PUT", {"body": "…"})           # Notiz aktualisieren (PUT! PATCH = 405)
api("search?query=backup&type=folder")            # suchen
```

Große Bodies: aus Datei lesen (`open(...).read()`), nicht ins Template pasten.

## Bekannte IDs (dieses System)

- Notizbuch **"Server"**: `048ad3af500447efbe04c86fe39cb349`
- Notiz **"Backup-Setup: restic (verschlüsselt) → ovilava"**: `8e9bea020f0e4eb8b75793936061ac9a`
  - Quelle der Wahrheit für den Inhalt: `~/backup-setup.md` – nach Änderungen am Backup-Setup diese Datei aktualisieren und per PATCH in die Notiz spiegeln.

## Hinweise

- Sync-Target ist WebDAV (`cloud.rcbnet.work/dav/joplin`) – die Notiz synchronisiert von selbst.
- Niemals direkt in `~/.config/joplin-desktop/database.sqlite` schreiben.
- Der User muss die App nicht selbst starten: Startkommando oben reicht, danach auf `/ping` warten.
