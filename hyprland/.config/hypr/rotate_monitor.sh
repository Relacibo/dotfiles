#!/usr/bin/env bash

# This script rotates the focused monitor in Hyprland.
# It depends on `jq` for parsing JSON.

DIRECTION=$1 # "left" or "right"

if ! command -v jq &> /dev/null; then
    hyprctl notify -1 5000 "rgb(ff0000)" "Error: jq is not installed. Please install it to use this script."
    exit 1
fi

if [[ "$DIRECTION" != "left" && "$DIRECTION" != "right" ]]; then
    echo "Usage: $0 <left|right>"
    exit 1
fi

# Get monitor data
MONITOR_DATA=$(hyprctl -j monitors)
FOCUSED_MONITOR=$(echo "$MONITOR_DATA" | jq -r '.[] | select(.focused == true)')

if [ -z "$FOCUSED_MONITOR" ]; then
    hyprctl notify -1 5000 "rgb(ff0000)" "Error: Could not determine focused monitor."
    exit 1
fi

MONITOR_NAME=$(echo "$FOCUSED_MONITOR" | jq -r '.name')
CURRENT_TRANSFORM=$(echo "$FOCUSED_MONITOR" | jq -r '.transform')
CURRENT_SCALE=$(echo "$FOCUSED_MONITOR" | jq -r '.scale')
CURRENT_RES=$(echo "$FOCUSED_MONITOR" | jq -r '"\(.width)x\(.height)@\(.refreshRate)"')
CURRENT_X=$(echo "$FOCUSED_MONITOR" | jq -r '.x')
CURRENT_Y=$(echo "$FOCUSED_MONITOR" | jq -r '.y')
CURRENT_POS="${CURRENT_X}x${CURRENT_Y}"

# Hyprland transform values:
# 0: normal
# 1: 90 degrees clockwise (right)
# 2: 180 degrees
# 3: 270 degrees clockwise (left)
# We only care about these 4 states. Others are for flipping.

# Calculate the new transform value
if [ "$DIRECTION" == "right" ]; then
    # This should be clockwise, which corresponds to adding 1 to the transform value in Hyprland.
    # However, the user reports this is inverted. So we swap the logic.
    NEW_TRANSFORM=$(( (CURRENT_TRANSFORM + 3) % 4 ))
else # left
    # This should be counter-clockwise.
    NEW_TRANSFORM=$(( (CURRENT_TRANSFORM + 1) % 4 ))
fi

# Apply the new rotation
# We need to re-apply all monitor settings.
hyprctl keyword monitor "$MONITOR_NAME,${CURRENT_RES},${CURRENT_POS},${CURRENT_SCALE},transform,${NEW_TRANSFORM}"