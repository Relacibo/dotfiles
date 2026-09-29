---
name: joplin
description: Startet Joplin unsichtbar im Tray und erstellt/aktualisiert Notizen über die Joplin Data API (localhost:41184). Use when the user asks to create, edit, update or sync a Joplin note, or when Joplin needs to be started first, or mentions Joplin notebooks like "Server".
---

# Joplin steuern

## App starten (unsichtbar im Tray)

> Bewusst KEIN System-Autostart (User-Präferenz) — nur On-Demand-Start durch die AI. Keine ~/.config/autostart/-Einträge anlegen!
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

## Standard-Operationen (Python, JSON-safe)

```python
import json, urllib.request
TOKEN = "<aus settings.json>"

def api(path, method="GET", payload=None):
    # WICHTIG: Token mit & anhängen, wenn path schon ein ? hat –
    # sonst ?…?token= und Joplin antwortet 403 "Missing token parameter"
    sep = "&" if "?" in path else "?"
    data = json.dumps(payload).encode() if payload else None
    req = urllib.request.Request(f"http://localhost:41184/{path}{sep}token={TOKEN}",
                                 data=data, headers={"Content-Type": "application/json"},
                                 method=method)
    return json.load(urllib.request.urlopen(req, timeout=10))

api("folders")                                    # Notizbücher: {"items":[{id,title}]}
api("notes", "POST", {"title": "…", "body": "…", "parent_id": "<folder-id>"})   # neue Notiz
api("notes/<id>", "PUT", {"body": "…"})           # Notiz aktualisieren
api("notes/<id>?fields=body")                     # Body lesen (helper kümmert sich um ?/&)
api("search?query=backup&type=folder")            # suchen
```

Große Bodies: aus Datei/Quelle lesen, nicht ins Template pasten.

## Troubleshooting (echte Fälle aus der Praxis)

| Symptom | Ursache | Fix |
|---|---|---|
| **HTTP 403** `"Missing token parameter"` | Token mit zweitem `?` angehängt, weil path schon `?fields=…` hatte | Helper oben benutzen (`&` statt `?`) |
| **HTTP 405** Method Not Allowed | Notiz-Update per PATCH versucht | Notiz-Update immer **PUT** |
| 403 obwohl Header `X-Auth-Token` gesetzt | Header wird (zumindest 3.7.18) nicht unterstützt | Token ausschließlich als Query-Param |
| `notes?…`-Liste liefert Dict statt Array | gewollt | immer `.["items"]` entpacken |
| Ping tot, App läuft | API braucht nach Kaltstart 3–15 s | Poll-Loop statt Einzelversuch |
| **Prozess da, API bleibt tot**, User sagt „Joplin war nie an"; Neustarts fruchten nicht | Nach hartem Kill (`kill -9`) bleibt `~/.config/joplin-desktop/lock` stehen → neue Instanz beendet sich still (Single-Instance-Guard) | Kill-Loop (s. nächste Zeile!), dann `rm -f ~/.config/joplin-desktop/lock`, dann Start + `/ping` (bis zu 25 s warten) |
| **Shell-Tool-TIMEOUTs ohne jeglichen Output** bei Kill/pgrep-Aktionen rund um Joplin | `pkill/pgrep -f joplin_desktop` matcht die **eigene Kommandozeile** (enthält ja den String) → Kill auf die eigene Shell | Bracket-Trick: `pgrep -f "joplin_[d]esktop"` / `pkill -f "net[.]cozic[.]joplin_desktop"` — matcht Ziel, nie das eigene Kommando |

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

## Bootstrap & Fehlerbehandlung (nicht bei jedem Start prüfen!)

**Einmalig pro neuer Maschine:** `scripts/bootstrap-settings.sh` ausführen
(idempotent, setzt die drei Keys, weigert sich während Joplin läuft).

Danach gilt: **der `/ping` ist der funktionale Test** – Settings nur diagnostizieren,
wenn ein Symptom auftritt:
- Ping kommt nach App-Start nicht hoch → `clipperServer.autoStart` fehlt → Bootstrap.
- User erwähnt ein sichtbares Joplin-Fenster → `showTrayIcon`/`startMinimized` fehlen
  (nur Kosmetik, API funktioniert trotzdem) → Bootstrap beim nächsten belegten Moment.

Falls Fenster doch mal sichtbar ist: Schließen (X) parkt Joplin im Tray, beendet es nicht.

## Hinweise

- Sync-Target ist WebDAV (`cloud.rcbnet.work/dav/joplin`) – Notizen synchronisieren von selbst.
- Niemals direkt in `~/.config/joplin-desktop/database.sqlite` schreiben.
