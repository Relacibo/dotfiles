---
name: transcribe
description: Transkribiert Audio- und Videodateien lokal (faster-whisper über uv, kein Upload) und zieht bei Videos Standbilder, damit man den Bildschirminhalt mitliest. Use when the user asks to transcribe ("transkribier", "was sagt er im Video", Sprachnachricht, Aufnahme) or to summarize a screen recording / video attachment, e.g. from a ticket.
---

# Transkribieren (lokal)

Läuft komplett lokal auf der CPU, auf Desktop und Laptop gleich. Voraussetzungen: `uv` und `ffmpeg`.
Das Modell (Standard `large-v3-turbo`, ~1,6 GB) lädt beim ersten Lauf von Hugging Face nach
`~/.cache/huggingface`; der Download wird geprüft, abgebrochene Dateien bleiben nicht liegen.

## Ablauf

1. Datei in ein eigenes, neues Verzeichnis legen (`mktemp -d /tmp/transcribe-XXXX`), nicht ins Repo.
   Ticket-Anhänge mit dem Redmine-Skill bzw. `curl` mit API-Key-Header holen und Größe prüfen.
2. Transkript:
   ```bash
   uv run ~/.dotfiles/hyprland/.claude/skills/transcribe/scripts/transcribe.py <datei> [--lang de|auto] [--out <dir>/transcript.txt]
   ```
   Ausgabe: eine Zeile pro Abschnitt mit `[mm:ss-mm:ss]`. Dauer: gemessen 15 s für 1:42 Aufnahme (Desktop-CPU, Modell
   schon im Cache). Für schnelle Entwürfe `--model small`.
3. Bei Videos (Bildschirmaufnahmen) zusätzlich Standbilder ziehen und als Bilder ansehen:
   ```bash
   ~/.dotfiles/hyprland/.claude/skills/transcribe/scripts/frames.sh <video> <dir>/frames 8
   ```
   Nicht alle Bilder lesen: erst jedes zweite bis dritte, dann gezielt die Stellen, auf die sich
   das Transkript bezieht.

## Auswerten

- Schlechter Ton (Zug, Wind, leise) ergibt falsche Wörter und Wiederholungen. Dann den Inhalt aus
  Transkript **und** Bildern zusammensetzen und das im Ergebnis sagen ("Ton schwer verständlich").
- Nichts erfinden, was weder zu hören noch zu sehen ist. Unklare Stellen als unklar markieren.
- Das Rohtranskript nicht ungefragt in Tickets posten; eine Zusammenfassung zeigen und auf OK warten.
