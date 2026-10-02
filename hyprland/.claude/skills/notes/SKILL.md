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
- **PC ↔ ovilava:** `nsync` (rclone bisync) — WebDAV `https://cloud.rcbnet.work/dav/notizen` (SFTPGo hinter Traefik), `vendor = owncloud` (nötig für Modtime-Erhalt — Checkbox-Edits sind größenneutral!), User `reinhard`. rclone via dnf (`/usr/bin/rclone`), nur EIN Binary (bisync-States sind versionssensibel).
- **Kein Secret in syncbaren Dateien:** Das Remote wird per Umgebungsvariable definiert (`RCLONE_CONFIG_OVILAVA-NOTES_*`) — kein Eintrag in `rclone.conf`, keine Pass-Zeile in der Config. Passwort: obscured-Datei `~/.config/nsync/ovilava-notes.pass` (chmod 600, maschinenlokal, erzeugt via `rclone obscure`).
- **Dotfiles-Repo (stow):** `hyprland/.local/bin/nsync`, `hyprland/.config/nsync/nsync.conf` + `filters.txt`, `hyprland/.config/systemd/user/nsync.{service,timer}` — Home-Symlinks zeigen ins Repo. **Laptop-Setup:** dotfiles stowen → `pacman -S rclone` → `mkdir -p ~/.config/nsync && read -s PW && rclone obscure "$PW" > ~/.config/nsync/ovilava-notes.pass && chmod 600 ~/.config/nsync/ovilava-notes.pass` → `systemctl --user enable --now nsync.timer` → einmal `nsync --resync`.
- Timer: `systemctl --user status nsync.timer` (alle 15 min, Persistent). Manuell: `nsync` / `nsync --dry-run` / `nsync --resync` (Flags durchgereicht). Log: `~/.local/state/nsync.log`. Konfig: `~/.config/nsync/nsync.conf` (Env-Override: `NSYNC_CONF`; Auto-Commit aus: `NSYNC_NO_GIT=1`).
- Konflikte: `*.sync-conflict*`-Dateien — lesen, mergen, löschen, commit. Nie stillschweigend löschen. `.git/**` gefiltert; git-Historie lebt bislang nur lokal auf anton-bruckner (kein git-remote für ~/notes).
- Timer läuft nur während einer User-Session (kein Linger). Für Sync ohne Login: `loginctl enable-linger reinhard` (braucht User-Sudo).

## Joplin: beerdigt
Nicht mehr starten, nicht mehr reviven. Archiv bleibt bis auf Weiteres: DB `~/.config/joplin-desktop/database.sqlite` + WebDAV-Remote. Passwörter sind längst in Bitwarden (User, 02.10.2026). Die 3 PNG-Resources in der Joplin-DB hängen an gelöschten Notizen und wurden nicht migriert.
