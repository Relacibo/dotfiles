#!/usr/bin/env bash

# cliphist-Verlauf als rofi-Menue
# Enter=Kopieren (Mehrfach moeglich) • Alt+d=Auswahl loeschen • Alt+x=Alles loeschen

HINT_BOTTOM='mainbox { children: [inputbar, listview, message]; }'

# Hinweis: bewusst ohne -no-custom (rofi 2.0 Bug: sofortiger Exit damit).
# Eingetippter Text ohne Treffer wird unten im Loop gefiltert (muss mit ID beginnen).
SELECTION=$(cliphist list | rofi -dmenu -i \
    -p "Zwischenablage" \
    -multi-select \
    -mesg "Enter=Kopieren • Alt+d=Löschen • Alt+x=Alles löschen • Esc=Abbrechen" \
    -kb-custom-1 "Alt+d" \
    -kb-custom-2 "Alt+x" \
    -theme-str "$HINT_BOTTOM")

EXIT_CODE=$?

case "$EXIT_CODE" in
    0)
        # Kopieren (Mehrfachauswahl: Zeilen einzeln dekodieren; nur echte Eintraege mit ID)
        [ -z "$SELECTION" ] && exit 0
        while IFS= read -r line; do
            case "$line" in [0-9]*) echo "$line" | cliphist decode 2>/dev/null ;; esac
        done <<< "$SELECTION" | wl-copy
        ;;
    10)
        # Ausgewaehlte Eintraege loeschen
        [ -n "$SELECTION" ] && echo "$SELECTION" | cliphist delete
        ;;
    11)
        # Kompletten Verlauf leeren
        cliphist wipe
        notify-send -a "cliphist" "Zwischenablage" "Verlauf komplett geleert"
        ;;
esac
