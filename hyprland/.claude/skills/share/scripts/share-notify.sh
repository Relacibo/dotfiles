#!/usr/bin/env bash
# Send a notification via ntfy.
# Usage: share-notify.sh <title> <message> [click-url]
set -euo pipefail

CONFIG="${SHARE_CONFIG:-$HOME/.config/share/share.env}"
if [ ! -f "$CONFIG" ]; then
  echo "Missing config: $CONFIG" >&2; exit 1
fi
source "$CONFIG"

: "${NTFY_URL:?NTFY_URL not set in $CONFIG}"
: "${NTFY_TOPIC:?NTFY_TOPIC not set in $CONFIG}"

title="${1:?usage: share-notify.sh <title> <message> [click-url]}"
message="${2:?}"
click_url="${3:-}"

curl_args=(-s -o /dev/null -w '%{http_code}')
[ -n "${NTFY_USER:-}" ] && curl_args+=(-u "$NTFY_USER:$NTFY_PASS")
curl_args+=(-H "Title: $title")
[ -n "$click_url" ] && curl_args+=(-H "Click: $click_url")
curl_args+=(-d "$message")
curl_args+=("$NTFY_URL/$NTFY_TOPIC")

http_code="$(curl "${curl_args[@]}")"
if [ "$http_code" != "200" ]; then
  echo "ntfy failed (HTTP $http_code)" >&2; exit 1
fi
echo "Sent: $title"
