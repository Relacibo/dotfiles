# Skill: notes

## Notizen-System (seit 02.10.2026 — ersetzt Joplin, das beerdigt wurde)

Notizen sind plain Markdown in `~/notes` — git-Versioniert, kein Daemon, kein Display, kein API-Server. Funktioniert in jeder SSH/tmux-Session ohne `$DISPLAY`.

## Struktur
- Notizbuch = Ordner: `Windows/`, `Einkaufslisten/`, `Filme/`, `business-apotune/`, `Server/`
- Checklisten: `- [ ]` / `- [x]` — Abhaken ist ein Datei-Edit
- **Runbook (Server/Backup): `~/notes/Server/runbook.md` — Quelle der Wahrheit.** Nach Architektur-Änderungen editieren + committen.

## Workflow (LLM)
- Lesen: Dateien direkt, `rg` für Volltext.
- Schreiben: Datei editieren, dann `git -C ~/notes add -A && git -C ~/notes commit` mit kurzer Message. Kein push (Repo ist lokal-only, kein remote).
- Abhaken auf Zuruf („hake ELSTER-Punkt ab"): Edit `- [ ]` → `- [x]` + commit.
- Sync-Konflikte: Dateien wie `*.sync-conflict-*.md` (falls später Phone-Sync via Ordner-Sync) — beide Versionen lesen, mergen, Konfliktdatei löschen, commit. Nie Daten wegwerfen, immer fragen bei echten Ambiguitäten.

## Editor-Realität
Der User editiert selbst (helix o. ä.) — das LLM ist Mitschreiber, nicht Alleinherrscher. Plain Markdown, keine exotischen Konventionen erfinden, keine Front-Matter-Deko ohne Absprache.

## Sync-Transport: AKTIV (seit 02.10.2026)
- **PC ↔ ovilava:** `rclone bisync ~/notes ↔ ovilava-notes:notizen` — WebDAV `https://cloud.rcbnet.work/dav` (SFTPGo hinter Traefik), `vendor = owncloud` (nötig für Modtime-Erhalt — Checkbox-Edits sind größenneutral!), User `reinhard`, Passwort obscured in `~/.config/rclone/rclone.conf`. rclone selbst via dnf (`/usr/bin/rclone`) — nur EIN Binary für alle Syncs (bisync-States sind versionssensibel); Pfad konfigurierbar in `nsync.conf`.
- Timer: `systemctl --user status nsync.timer` (alle 15 min, Persistent). Script: `~/.local/bin/nsync`, Log: `~/.local/state/nsync.log`. Manuell: `~/.local/bin/nsync`.
- Desync/Reparatur: `--resync` an das Script-Kommando. Konflikte landen als `*.sync-conflict*`-Dateien — lesen, mergen, löschen, git commit. Nie stillschweigend löschen.
- `.git/` bleibt außen vor (`~/.config/rclone/notes-filters.txt`) — gesync't wird der Working Tree; git-Historie lebt nur lokal auf anton-bruckner.
- Phone: Markor + FolderSync (WebDAV `…/dav/notizen`, User reinhard) — Einrichtung durch User.
- Timer läuft nur während einer User-Session (kein Linger). Für Sync ohne Login: `loginctl enable-linger reinhard` (braucht User-Sudo).

## Joplin: beerdigt
Nicht mehr starten, nicht mehr reviven. Archiv bleibt bis auf Weiteres: DB `~/.config/joplin-desktop/database.sqlite` + WebDAV-Remote. Passwörter sind längst in Bitwarden (User, 02.10.2026). Die 3 PNG-Resources in der Joplin-DB hängen an gelöschten Notizen und wurden nicht migriert.
