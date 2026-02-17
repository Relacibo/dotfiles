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
    echo "clear_all|🗑️  Alle löschen"
    echo "toggle_pause|⏸️  Pausieren/Fortsetzen"
    
    # History
    if [ -n "$HISTORY_JSON" ] && [ "$NOTIF_COUNT" != "0" ]; then
        # echo "separator|"
        
        echo "$HISTORY_JSON" | jq -r '.data[0][]? | 
            select(.summary.data != null) | 
            [.id.data, .appname.data, .summary.data, .body.data // ""] | 
            @tsv' | while IFS=$'\t' read -r id app summary body; do
            
            # Bereinige und kürze Texte
            summary=$(echo "$summary" | tr '\n' ' ' | sed 's/  */ /g')
            body=$(echo "$body" | tr '\n' ' ' | sed 's/  */ /g')
            
            summary_disp=$(echo "$summary" | head -c 45)
            [ ${#summary} -gt 45 ] && summary_disp="${summary_disp}…"
            
            body_disp=$(echo "$body" | head -c 50)
            [ ${#body} -gt 50 ] && body_disp="${body_disp}…"
            
            # Format: ID|Icon App • Summary • Body
            if [ -n "$body_disp" ]; then
                echo "$id|📱 $app • $summary_disp • $body_disp"
            else
                echo "$id|📱 $app • $summary_disp"
            fi
        done
    fi
} > "$TMPFILE"

# Zeige Rofi mit Keybindings
SELECTION=$(cat "$TMPFILE" | cut -d'|' -f2- | \
    rofi -dmenu -i \
    -p "Benachrichtigungen" \
    -format 'i' \
    -mesg "Enter=Anzeigen • Alt+d=Löschen" \
    -kb-custom-1 "Alt+d")

EXIT_CODE=$?
log "Rofi exit code: $EXIT_CODE, Index: $SELECTION"

[ -z "$SELECTION" ] && { log "Abbruch"; exit 0; }

# Hole ID der Auswahl
LINE=$(sed -n "$((SELECTION + 1))p" "$TMPFILE")
ID=$(echo "$LINE" | cut -d'|' -f1)
log "Gewählt: ID=$ID"

# Aktion basierend auf Exit-Code (Enter=0, Alt+d=10)
case "$ID" in
    "clear_all")
        log "Lösche History"
        $DUNSTCTL history-clear
        ;;
    "toggle_pause")
        log "Toggle Pause"
        $DUNSTCTL set-paused toggle
        ;;
    "separator"|"history_header")
        log "Header/Separator ignoriert"
        ;;
    *)
        # Exit code 10 = Alt+d = Löschen
        # Exit code 0 = Enter = Anzeigen/Close
        if [ "$EXIT_CODE" -eq 10 ]; then
            log "Lösche Benachrichtigung $ID"
            $DUNSTCTL history-rm "$ID"
        else
            log "Zeige/Close Benachrichtigung $ID"
            # history-pop zeigt History-Items wieder an
            # close schließt angezeigte Items
            $DUNSTCTL history-pop "$ID" 2>/dev/null || $DUNSTCTL close "$ID" 2>/dev/null
        fi
        ;;
esac

log "=== Menu beendet ==="
