---
name: print
description: Druckt Text/Dateien UTF-8-sicher auf den Brother-Drucker (paps → PDF → CUPS). Use when the user asks to print ("druck", "print", "ausdrucken", Papier) — especially plain text from AI answers, secrets/keys/passwords that must NOT appear in chat, or reports. Never pipe text through raw lpr (font garbage).
---

# Drucken (UTF-8-sicher)

## Regeln

1. **Niemals `lpr`/`lp` direkt auf Textdateien** – der Drucker rendert dann mit falschem
   Font/Encoding → Müll (Umlaute kaputt, Proportional-Chaos). Immer `print.sh` verwenden.
2. **Secrets (Passwörter, Keys, Tokens):** direkt in `print.sh` pipen und im Chat **nichts**
   davon anzeigen – nur die Job-Bestätigung. Temp-Dateien danach `shred -u`.
3. Nach dem Drucken den absoluten Speicherpfad bzw. Job-Status nennen, nicht den Inhalt.

## Usage

```bash
# Einfacher Text (Datei)
~/.claude/skills/print/scripts/print.sh bericht.txt

# Von stdin (z. B. AI-Antwort)
echo "…text…" | ~/.claude/skills/print/scripts/print.sh -

# Secrets: erzeugen → drucken → wegwerfen, ohne Chat-Kontakt
PW=$(openssl rand -hex 16)
{ echo "Titel"; echo; echo "$PW"; } | ~/.claude/skills/print/scripts/print.sh - --copies 2

# Optionen
--font "Monospace 12"   # Pango-Font-String (Standard: Monospace 11)
--copies N              # Kopien
--landscape             # Querformat
--printer NAME          # Drucker überschreiben
```

## Drucker-Auswahl

Bevorzugt `Brother_HL-L2400DW` (Default im Skript). Nicht verfügbar →
interaktiv wählen (TTY) bzw. als Agent: Skript bricht mit Drucker-Liste ab –
dann entweder Nutzer fragen oder mit `--printer <name>` erneut ausführen.
Ein Duplikat-Queue `Brother_HL_L2400DW` (Unterstrich) existierte mal – nach
`sudo lpadmin -x Brother_HL_L2400DW` ist die Liste sauber.

## Interna

- Pipeline: `paps` (Pango, korrektes UTF-8/A4-Rand) → `ps2pdf` → `lp -d <Drucker>`
- Drucker wird automatisch erkannt (`lpstat -e`, locale-unabhängig); aktuell `Brother_HL-L2400DW`
- PDFs gehen ungefiltert direkt an CUPS
- Skill lebt im dotfiles-Repo und ist per Symlink an opencode + claude gebunden
