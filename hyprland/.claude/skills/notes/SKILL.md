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

## Sync-Transport: offen
Noch nichts eingerichtet. Kandidaten: WebDAV (rcbnet.work), SFTPGo (läuft auf ovilava), Phone-App: Markor. Falls Ordner-Sync eingerichtet wird: `.git/` vom Sync ausschließen.

## Joplin: beerdigt
Nicht mehr starten, nicht mehr reviven. Archiv bleibt bis auf Weiteres: DB `~/.config/joplin-desktop/database.sqlite` + WebDAV-Remote. Passwörter sind längst in Bitwarden (User, 02.10.2026). Die 3 PNG-Resources in der Joplin-DB hängen an gelöschten Notizen und wurden nicht migriert.
