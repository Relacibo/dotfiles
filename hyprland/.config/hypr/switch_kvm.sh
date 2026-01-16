#!/bin/bash

# Dieses Skript liest die Umgebungsvariable $KVM_TARGET,
# die in der Hyprland-Konfiguration pro Maschine gesetzt wird,
# und schaltet den KVM-Switch auf diesen Ziel-Input.

CACHE_DIR="$HOME/.cache"
CACHE_FILE="$CACHE_DIR/kvm_display_id"

# Prüfen, ob die Ziel-Variable gesetzt ist
if [ -z "$KVM_TARGET" ]; then
    notify-send "KVM Fehler" "Umgebungsvariable \$KVM_TARGET nicht gesetzt!"
    exit 1
fi

# Caching-Logik für die Display ID
if [ -f "$CACHE_FILE" ]; then
    # Wenn Cache-Datei existiert, ID von dort lesen
    DELL_DISPLAY_ID=$(cat "$CACHE_FILE")
else
    # Wenn keine Cache-Datei existiert, langsame Erkennung durchführen
    DELL_DISPLAY_ID=$(ddcutil detect | awk '/^Display/ {display=$2} /Model:.*DELL U2724DE/ {print display}')
    
    if [ -z "$DELL_DISPLAY_ID" ]; then
        notify-send "KVM Fehler" "Dell U2724DE nicht gefunden (bei Erkennung)."
        exit 1
    fi
    
    # ID in Cache-Datei für die Zukunft speichern
    mkdir -p "$CACHE_DIR"
    echo "$DELL_DISPLAY_ID" > "$CACHE_FILE"
fi

# Führe den eigentlichen Befehl aus
notify-send "KVM Switch" "Wechsle zu Ziel: $KVM_TARGET..."
ddcutil setvcp 60 "$KVM_TARGET" -d "$DELL_DISPLAY_ID"
