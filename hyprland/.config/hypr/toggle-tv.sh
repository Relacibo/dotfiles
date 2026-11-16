#!/bin/bash

# Der Name des Monitors, der umgeschaltet werden soll
MONITOR_NAME="HDMI-A-1"
STATE_FILE="/tmp/hypr-tv-state"

# WICHTIG: 3840x2160@120 geht auf diesem Rechner (RX 6700 XT / amdgpu) NICHT:
# Der DRM-Commit schlaegt mit "Cannot allocate memory" fehl. Hyprland meldet
# den Monitor trotzdem als aktiv, aber der TV bleibt schwarz. Schlimmer: Nach
# dem fehlgeschlagenen 120Hz-Modeset bleibt der Output haengen und weitere
# enable/disable-Zyklen loesen keinen Modeset mehr aus (Erholung nur via
# dpms off/on). Deshalb hier nur Modi verwenden, die zuverlaessig funktionieren:
# 4K@60 fuer den Standardbetrieb, 1440p@120 fuer --performance.
MODE_DEFAULT="3840x2160@60"
MODE_PERFORMANCE="2560x1440@120"

# Zustand aus der Statusdatei lesen (Standard: aus, wie beim Boot).
# Eine Datei ist noetig, weil "hyprctl monitors -j" nach disable/enable
# asynchron aktualisiert: Ein gerade deaktivierter Monitor kann je nach
# Hyprland-Version noch kurz (mit altem Zustand) gelistet sein, wodurch
# der alte Check fälschlich wieder "deaktivieren" ausgeloest hat.
STATE="off"
[ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "on" ] && STATE="on"

# Erst das neue Lua-Config-System versuchen (hyprctl eval),
# sonst auf das alte hyprlang-Interface zurueckfallen (hyprctl keyword).
apply_lua() {
    local out
    out=$(hyprctl eval "$1" 2>&1)
    [ "$out" = "ok" ]
}

monitor_rule() { # $1 = mode, $2 = scale
    echo "hl.monitor({ output = \"$MONITOR_NAME\", disabled = false, mode = \"$1\", position = \"0x0\", scale = \"$2\" })"
}

if [ "$STATE" = "on" ]; then
    # TV ist aktiv -> deaktivieren
    apply_lua "hl.monitor({ output = \"$MONITOR_NAME\", disabled = true })" \
        || hyprctl keyword monitor "${MONITOR_NAME},disable" >/dev/null 2>&1
    echo off > "$STATE_FILE"
else
    # TV ist deaktiviert -> aktivieren
    case "$1" in
        --performance) apply_lua "$(monitor_rule "$MODE_PERFORMANCE" "1")" ;;
        *)             apply_lua "$(monitor_rule "$MODE_DEFAULT" "1.5")" ;;
    esac
    echo on > "$STATE_FILE"
fi
