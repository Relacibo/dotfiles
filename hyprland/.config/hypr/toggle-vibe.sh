#!/bin/bash
STATE_PATH=$(dirname "$(realpath "$HOME/.local/state/custom/vibe-toggle")")
mkdir -p "$STATE_PATH"
STATE_FILE="$STATE_PATH/toggled_on"
# VIBE_BASH_PID_FILE_PATH="$SCRIPT_DIR/../vars/vibe-bash-pid"
STATE=$(cat "$STATE_FILE") || echo 0
# kill $(cat $VIBE_BASH_PID_FILE_PATH) || killall hyprpaper
killall hyprpaper
killall .cargo/bin/vibe
((STATE ^= 1))
if [[ $STATE = 0 ]]; then
  sleep 0.3
  hyprpaper &
else
  ~/.cargo/bin/vibe &
  sleep 0.3
  hyprpaper -c ~/.config/hypr/hyprpaper-vibe.conf &
fi
# echo $$ > $VIBE_BASH_PID_FILE_PATH
echo $STATE > "$TOGGLE_FILE_PATH"
