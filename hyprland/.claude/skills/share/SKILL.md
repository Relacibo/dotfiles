---
name: share
description: Share content via ntfy (push notification), Thunderbird (email compose), or SFTPGo (permanent links). Use ONLY when the user explicitly asks to share, send, or push something — never share by default.
---

# Share skill

Three channels, used only when the user explicitly requests them. Credentials in `~/.config/share/share.env` (chmod 600). Scripts in `~/.claude/skills/share/scripts/`.

## Channel 1: ntfy — push notification to phone

```bash
~/.claude/skills/share/scripts/share-notify.sh "<title>" "<message>" "<click-url>"
```

- `title`: notification headline
- `message`: body text (markdown supported by some clients)
- `click-url`: optional, tappable link

The notification appears instantly on the phone (ntfy Android/iOS app) and any desktop clients subscribed to the topic.

**Phone setup (one-time):** Install ntfy app → Add server `https://ntfy.rcbnet.work` → Login with credentials from `~/.config/share/share.env` → Subscribe to topic `share`.

Use when user says "schick mir den Link", "per ntfy", "push notification".

## Channel 2: Thunderbird — email compose

```bash
~/.claude/skills/share/scripts/share-email.sh "<pdf-file>" "<to>" "<subject>" "<body>"
```

- Opens Thunderbird with compose window prefilled: recipient, subject, body, and PDF attached
- Body is a brief note — the PDF is the attachment. Do NOT include a link in the body.
- `nohup ... &` detaches so the terminal doesn't block
- On some Flatpak installs, the sandbox blocks file access outside `~/Downloads`. If Thunderbird says "file not found", first grant filesystem access:
  ```bash
  flatpak override --user --filesystem="$(xdg-user-dir DOCUMENTS)" net.thunderbird.Thunderbird
  ```

Use when user says "per Email", "schick es an X", "sende an".

## Channel 3: SFTPGo — permanent link

```bash
LINK=$(~/.claude/skills/share/scripts/share-upload.sh <local-file> [--expires-days N] [--password <pw>])
echo "$LINK"
```

- Uploads any file to cloud.rcbnet.work and prints a public URL
- For PDFs: viewer URL with inline PDF.js preview
- Shares are keyed by parent directory name (slug) — re-uploading updates the existing link
- Permanent by default; `--expires-days N` to time-box

Use when user says "lade es hoch", "gib mir den Link", or before a ntfy notification.

## Common workflow: upload + notify

```bash
LINK=$(~/.claude/skills/share/scripts/share-upload.sh file.pdf)
~/.claude/skills/share/scripts/share-notify.sh "Title" "Summary" "$LINK"
```

Only do this when the user explicitly asks for it. Never auto-notify.

## Common workflow: email with attachment

```bash
~/.claude/skills/share/scripts/share-email.sh file.pdf "to@example.com" "Subject" "Brief note"
```

No link in the body — the attachment is the document. Keep the body short.

## Authentication

ntfy requires Basic Auth (`~/.config/share/share.env`). Without credentials: 403.

## No credentials in chat

Never paste any credential into chat messages. If scripts fail with auth errors, tell the user to check `~/.config/share/share.env`.
