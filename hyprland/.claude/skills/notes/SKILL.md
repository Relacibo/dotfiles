# Skill: notes

Notizen: plain Markdown in `~/notes`, git-lokal (kein remote), sync per `nsync` (rclone bisync → ovilava WebDAV). User (helix) und LLM schreiben beide — plain md, keine exotischen Konventionen, keine Front-Matter-Deko.

## Struktur & Workflow
- Ordner = Notizbuch: `Einkaufslisten/`, `Filme/`, `Server/`, `business-apotune/`, `Windows/`. Checklisten: `- [ ]` / `- [x]`.
- **Runbook: `~/notes/Server/runbook.md` — Quelle der Wahrheit fürs Backup-Setup.** Nach Architektur-Änderungen editieren + committen.
- Schreiben = Datei-Edit + `git -C ~/notes add -A && git -C ~/notes commit` (kurze Message). Kein push.
- Abhaken auf Zuruf: `- [ ]` → `- [x]` + commit. Lesen: direkt + `rg`.

## Sync
- Auto: `nsync.timer` alle 15 min. Manuell: `nsync` (Flags reichen durch: `--resync` bei Desync, `--dry-run`). Log: `~/.local/state/nsync.log`.
- Konfig: `~/.config/nsync/nsync.conf`; Passwort: `~/.config/nsync/ovilava-notes.pass` — **maschinenlokal, nie in syncbare Dateien oder das Repo!** Script/Units liegen im dotfiles-Repo (stow).
- Konflikte: `*.sync-conflict*`-Dateien → beide Versionen lesen, mergen, Konfliktdatei löschen, commit. Nie stillschweigend löschen.
- `.git/**` wird nicht gesync't. Phone synct dasselbe WebDAV (Markor + FolderSync).
