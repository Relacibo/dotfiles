#!/usr/bin/env bash
# print.sh – UTF-8-sicher drucken (Text → paps → PDF → CUPS)
# Löst das Font-Müll-Problem: paps (Pango) rendert korrekt (Umlaute, Unicode),
# Ausgabe wird zu PDF und an CUPS übergeben.
#
# Usage:
#   print.sh [datei|-] [--font "Familie Größe"] [--copies N] [--landscape] [--printer NAME]
#
# Drucker-Auswahl: bevorzugt $DEFAULT_PRINTER; nicht verfügbar → Liste +
# interaktive Auswahl (TTY) bzw. Fehler mit Liste (nicht-interaktiv, Agenten).
#
# Für SECRETS: direkt hierhin pipen, NIE im Chat anzeigen!

set -euo pipefail

DEFAULT_PRINTER="Brother_HL-L2400DW"

font="Monospace 11"; copies=1; land=(); src=""; printer_arg=""
while [ $# -gt 0 ]; do
  case "$1" in
    --font) font="$2"; shift 2 ;;
    --landscape) land=(--landscape); shift ;;
    --copies) copies="$2"; shift 2 ;;
    --printer) printer_arg="$2"; shift 2 ;;
    -) src="/dev/stdin"; shift ;;
    *) src="$1"; shift ;;
  esac
done
[ -n "$src" ] || { echo "usage: print.sh <datei|-> [--font \"Familie Größe\"] [--copies N] [--landscape] [--printer NAME]" >&2; exit 1; }

printers="$(lpstat -e 2>/dev/null)"
[ -n "$printers" ] || { echo "kein Drucker gefunden (lpstat leer)" >&2; exit 1; }

printer=""
if [ -n "$printer_arg" ]; then
  printer="$printer_arg"
elif echo "$printers" | grep -qx "$DEFAULT_PRINTER"; then
  printer="$DEFAULT_PRINTER"
elif [ -t 0 ]; then
  echo "Standard-Drucker '$DEFAULT_PRINTER' nicht verfügbar – bitte wählen:" >&2
  select printer in $printers; do [ -n "$printer" ] && break; done
else
  echo "Standard-Drucker '$DEFAULT_PRINTER' nicht verfügbar. Verfügbare Drucker:" >&2
  echo "$printers" | sed 's/^/  /' >&2
  echo "Auswahl per --printer <name>." >&2
  exit 1
fi

echo "$printers" | grep -qx "$printer" || { echo "unbekannter Drucker: $printer" >&2; echo "verfügbar: $(echo "$printers" | tr '\n' ' ')" >&2; exit 1; }

tmp="$(mktemp /tmp/print-XXXXXX.pdf)"
trap 'rm -f "$tmp"' EXIT

case "$src" in
  *.pdf) lp -d "$printer" -n "$copies" "$src" >/dev/null ;;
  *)
    if [ "$src" = "/dev/stdin" ]; then
      paps --font "$font" --paper=a4 --top-margin=36 --bottom-margin=36 "${land[@]}" |
        ps2pdf - "$tmp"
    else
      paps --font "$font" --paper=a4 --top-margin=36 --bottom-margin=36 "${land[@]}" "$src" |
        ps2pdf - "$tmp"
    fi
    lp -d "$printer" -n "$copies" "$tmp" >/dev/null
    ;;
esac

echo "gedruckt auf $printer ($copies Kopie(n)), Job in Warteschlange."
