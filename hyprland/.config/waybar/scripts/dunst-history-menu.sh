#!/bin/bash

# Dunst History Menu mit Rofi

LOG_FILE="/tmp/dunst_history_menu.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"; }

DUNSTCTL="/usr/bin/dunstctl"
ROFI="/usr/bin/rofi"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

log "=== Menu gestartet ==="

# Hole alle Benachrichtigungen
HISTORY_JSON=$($DUNSTCTL history --json 2>/dev/null)
NOTIF_COUNT=$(echo "$HISTORY_JSON" | jq -r '.data[0] | length' 2>/dev/null)
DISPLAYED_COUNT=$($DUNSTCTL count displayed 2>/dev/null)
WAITING_COUNT=$($DUNSTCTL count waiting 2>/dev/null)

log "History: $NOTIF_COUNT, Angezeigt: $DISPLAYED_COUNT, Wartend: $WAITING_COUNT"

# Baue Menü mit besserer Formatierung
{
    # History
    if [ -n "$HISTORY_JSON" ] && [ "$NOTIF_COUNT" != "0" ]; then
        
        echo "$HISTORY_JSON" | jq -r '.data[0][]? | 
            select(.summary.data != null) | 
            [.id.data, .appname.data, .summary.data, .body.data // "", .icon_path.data // "", .timestamp.data] | 
            @tsv' | sort -t$'\t' -k6 -rn | while IFS=$'\t' read -r id app summary body icon timestamp; do
            
            # Bereinige und kürze Texte
            summary=$(echo "$summary" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
            body=$(echo "$body" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
            
            summary_disp=$(echo "$summary" | head -c 45)
            [ ${#summary} -gt 45 ] && summary_disp="${summary_disp}"
            
            body_disp=$(echo "$body" | head -c 50)
            [ ${#body} -gt 50 ] && body_disp="${body_disp}"
            
            # Konvertiere Timestamp (Mikrosekunden) zu lesbarem Format
            timestamp_sec=$((timestamp / 1000000))
            time_str=$(date -d "@$timestamp_sec" +"%H:%M" 2>/dev/null || echo "")
            
            # Format: [Zeit] App Summary (Body klein)
            if [ -n "$body_disp" ]; then
                echo "$id|$icon|<span size='x-small' alpha='50%'>$time_str</span> <b>$app</b> <small>$summary_disp - $body_disp</small>"
            else
                echo "$id|$icon|<span size='x-small' alpha='50%'>$time_str</span> <b>$app</b> <small>$summary_disp</small>"
            fi
        done
    fi
} > "$TMPFILE"

# Zeige Rofi mit Icons und Keybindings
SELECTION=$(awk -F'|' '{
    if ($2 != "") {
        printf "%s\0icon\x1f%s\n", $3, $2
    } else {
        printf "%s\n", $3
    }
}' "$TMPFILE" | \
    rofi -dmenu -i \
    -p "Benachrichtigungen" \
    -format 'i' \
    -show-icons \
    -markup-rows \
    -mesg "Enter=Anzeigen • Alt+d=Löschen • Alt+Shift+d=Alle löschen" \
    -kb-custom-1 "Alt+d" \
    -kb-custom-2 "Alt+Shift+d")

EXIT_CODE=$?
log "Rofi exit code: $EXIT_CODE, Index: $SELECTION"

[ -z "$SELECTION" ] && { log "Abbruch"; exit 0; }

# Hole ID der Auswahl
LINE=$(sed -n "$((SELECTION + 1))p" "$TMPFILE")
ID=$(echo "$LINE" | cut -d'|' -f1)
log "Gewählt: ID=$ID"

# Aktion basierend auf Exit-Code (Enter=0, Alt+d=10, Alt+Shift+d=11)
case "$EXIT_CODE" in
    11)
        # Alt+Shift+d = Alle löschen
        log "Lösche gesamten Verlauf"
        $DUNSTCTL history-clear
        ;;
    10)
        # Alt+d = Einzelne löschen
        log "Lösche Benachrichtigung $ID"
        $DUNSTCTL history-rm "$ID"
        ;;
    0)
        # Enter = Anzeigen
        log "Zeige/Close Benachrichtigung $ID"
        $DUNSTCTL history-pop "$ID" 2>/dev/null || $DUNSTCTL close "$ID" 2>/dev/null
        ;;
esac

log "=== Menu beendet ==="
