#!/bin/bash

# Dieses Skript liest die Umgebungsvariable $KVM_TARGET,
# die in der Hyprland-Konfiguration pro Maschine gesetzt wird,
# und schaltet den KVM-Switch auf diesen Ziel-Input.

# Prüfen, ob die Ziel-Variable gesetzt ist
if [ -z "$KVM_TARGET" ]; then
    notify-send "KVM Fehler" "Umgebungsvariable \$KVM_TARGET nicht gesetzt!"
    exit 1
fi

# Finde den Dell U2724DE Monitor
DELL_DISPLAY_ID=$(ddcutil detect | awk '/^Display/ {display=$2} /Model:.*DELL U2724DE/ {print display}')

if [ -z "$DELL_DISPLAY_ID" ]; then
    notify-send "KVM Fehler" "Dell U2724DE nicht gefunden."
    exit 1
fi

ddcutil setvcp 60 "$KVM_TARGET" -d "$DELL_DISPLAY_ID"
