# Skill: notes

Notizen: plain Markdown in `~/notes`, git-lokal (kein remote), sync per `nsync` (rclone bisync → ovilava WebDAV). User (helix) und LLM schreiben beide — plain md, keine exotischen Konventionen, keine Front-Matter-Deko.

## Struktur & Workflow
- Ordner = Notizbuch: `Einkaufslisten/`, `Filme/`, `Server/`, `business-apotune/`, `Windows/`. Checklisten: `- [ ]` / `- [x]`.
- **Runbook: `~/notes/Server/runbook.md` — Quelle der Wahrheit fürs Backup-Setup.** Nach Architektur-Änderungen editieren + committen.
- Schreiben = Datei-Edit + `git -C ~/notes add -A && git -C ~/notes commit` (kurze Message). Kein push.
- Abhaken auf Zuruf: `- [ ]` → `- [x]` + commit. Lesen: direkt + `rg`.

## In Helix zeigen
- Öffnen: `~/.claude/scripts/hx-open <datei>` (mehrere Dateien: alle als Argumente, `datei:zeile` geht). Öffnet einen neuen WezTerm-Tab oder wechselt nur hin, wenn die Datei dort schon offen ist — nie `hx` direkt spawnen.
- Nach eigenem Edit an einer offenen Datei: User bitten, in Helix `:reload` auszuführen (keine Tastendrücke in seinen Pane schicken).
- Wann: User sagt „zeig“/„öffne“/„mach auf“; nach dem Anlegen einer neuen Notiz oder einem größeren Umbau, den der User gegenlesen soll; bei Fundstellen aus `rg`, wenn der User sie selbst ansehen will (`hx datei:zeile`).
- Nicht bei kleinen Routine-Edits (Abhaken, ein Eintrag auf der Einkaufsliste) — da reicht eine Zeile Rückmeldung.
- Geöffnet zum Gegenlesen = erst committen, wenn der User fertig ist; vorher Datei neu lesen (er kann in Helix geändert haben).

## Sync
- Auto: `nsync.timer` alle 15 min. Manuell: `nsync` (Flags reichen durch: `--resync` bei Desync, `--dry-run`). Log: `~/.local/state/nsync.log`.
- Konfig: `~/.config/nsync/nsync.conf`; Passwort: `~/.config/nsync/ovilava-notes.pass` — **maschinenlokal, nie in syncbare Dateien oder das Repo!** Script/Units liegen im dotfiles-Repo (stow).
- Konflikte: `*.sync-conflict*`-Dateien → beide Versionen lesen, mergen, Konfliktdatei löschen, commit. Nie stillschweigend löschen.
- `.git/**` wird nicht gesync't. Phone synct dasselbe WebDAV (Markor + FolderSync).
