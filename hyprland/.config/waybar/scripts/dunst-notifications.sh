#!/bin/bash
# Log file for debugging
LOG_FILE="/tmp/dunst_waybar_debug.log"
echo "--- $(date) ---" >> "$LOG_FILE"

DUNSTCTL="/usr/bin/dunstctl"

# Capture stderr for dunstctl commands to prevent spamming Waybar
DISPLAYED_COUNT=$($DUNSTCTL count displayed 2>/dev/null)
WAITING_COUNT=$($DUNSTCTL count waiting 2>/dev/null)
HISTORY_COUNT=$($DUNSTCTL count history 2>/dev/null)
PAUSED=$($DUNSTCTL is-paused 2>/dev/null)

# Log raw outputs for debugging
echo "DISPLAYED_COUNT: '$DISPLAYED_COUNT'" >> "$LOG_FILE"
echo "WAITING_COUNT: '$WAITING_COUNT'" >> "$LOG_FILE"
echo "HISTORY_COUNT: '$HISTORY_COUNT'" >> "$LOG_FILE"
echo "PAUSED: '$PAUSED'" >> "$LOG_FILE"

# Ensure counts are numeric
if ! [[ "$DISPLAYED_COUNT" =~ ^[0-9]+$ ]]; then DISPLAYED_COUNT=0; fi
if ! [[ "$WAITING_COUNT" =~ ^[0-9]+$ ]]; then WAITING_COUNT=0; fi
if ! [[ "$HISTORY_COUNT" =~ ^[0-9]+$ ]]; then HISTORY_COUNT=0; fi

# Calculate total count as requested: displayed + waiting + history
TOTAL_COUNT=$((DISPLAYED_COUNT + WAITING_COUNT + HISTORY_COUNT))
echo "TOTAL_COUNT: '$TOTAL_COUNT'" >> "$LOG_FILE"

TEXT=""
CLASS=""
TOOLTIP=""

if [ "$PAUSED" == "true" ]; then
    TEXT="\uf1f6 $TOTAL_COUNT" # Durchgestrichene Glocke + Gesamtzahl
    CLASS="paused"
    TOOLTIP="Dunst ist pausiert. Gesamt: $TOTAL_COUNT (Angezeigt: $DISPLAYED_COUNT, Wartend: $WAITING_COUNT, Verlauf: $HISTORY_COUNT)"
elif [ "$TOTAL_COUNT" -gt 0 ]; then
    TEXT="\uf0f3 $TOTAL_COUNT" # Normale Glocke + Gesamtzahl
    CLASS="has-notifications"
    TOOLTIP="Gesamt: $TOTAL_COUNT (Angezeigt: $DISPLAYED_COUNT, Wartend: $WAITING_COUNT, Verlauf: $HISTORY_COUNT)"
else
    TEXT="\uf0f3 $TOTAL_COUNT" # Normale Glocke + Gesamtzahl (0)
    CLASS="no-notifications"
    TOOLTIP="Gesamt: $TOTAL_COUNT (Angezeigt: $DISPLAYED_COUNT, Wartend: $WAITING_COUNT, Verlauf: $HISTORY_COUNT)"
fi

# Final JSON output
JSON_OUTPUT="{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
echo "JSON_OUTPUT: $JSON_OUTPUT" >> "$LOG_FILE"
echo "$JSON_OUTPUT"
