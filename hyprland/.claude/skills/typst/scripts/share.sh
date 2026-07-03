#!/usr/bin/env bash
# Upload a file to SFTPGo and print a stable, browsable public share link.
# Shares the file's OWN dedicated remote subfolder (not the file directly), because
# SFTPGo only allows inline PDF preview / a non-error /browse page for directory-scope
# shares -- a file-scope share always forces a zip download and can never be inline.
#
# The share is keyed by slug (the local file's parent directory name) and reused across
# calls -- re-running this for an updated version of the same document does NOT mint a
# new link. Each version is additionally archived under versions/ so history isn't lost,
# similar to redeploying an Artifact to the same URL while keeping prior versions.
#
# Usage: share.sh <local-file> [--dir <remote-base-dir>] [--expires-days N] [--password <pw>]
#   --expires-days 0  -> never expires
#
# Auth: prefers SFTPGO_API_KEY (sent as X-SFTPGO-API-KEY, no token exchange needed).
# Falls back to SFTPGO_USER/SFTPGO_PASS (Basic Auth -> JWT via /api/v2/user/token) if no API key is set.
#
# Caveat: the share is keyed only by the local folder's basename (the slug). Two unrelated
# documents that happen to share a folder name will collide onto the same remote share --
# fine for our sources/<slug>/ convention (slugs are meant to be unique), but worth knowing.
set -euo pipefail

CONFIG="${SFTPGO_SHARE_CONFIG:-$HOME/.config/claude-skill-typst/share.env}"
if [ ! -f "$CONFIG" ]; then
  echo "Missing config: $CONFIG" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG"

: "${SFTPGO_BASE_URL:?SFTPGO_BASE_URL not set in $CONFIG}"

local_file="${1:?usage: share.sh <local-file> [--dir <remote-base-dir>] [--expires-days N] [--password <pw>]}"
shift

remote_base_dir="${SFTPGO_UPLOAD_DIR:-/typst-shares}"
expires_days=0
password=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) remote_base_dir="$2"; shift 2 ;;
    --expires-days) expires_days="$2"; shift 2 ;;
    --password) password="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

[ -f "$local_file" ] || { echo "no such file: $local_file" >&2; exit 1; }

auth_header=""
if [ -n "${SFTPGO_API_KEY:-}" ] && [ "${SFTPGO_API_KEY}" != "changeme" ]; then
  auth_header="X-SFTPGO-API-KEY: ${SFTPGO_API_KEY}"
elif [ -n "${SFTPGO_USER:-}" ] && [ -n "${SFTPGO_PASS:-}" ] && [ "${SFTPGO_USER}" != "changeme" ]; then
  token="$(curl -sf -u "${SFTPGO_USER}:${SFTPGO_PASS}" "${SFTPGO_BASE_URL}/api/v2/user/token" | jq -r '.access_token // empty')"
  [ -n "$token" ] || { echo "login failed against ${SFTPGO_BASE_URL}" >&2; exit 1; }
  auth_header="Authorization: Bearer ${token}"
else
  echo "Set either SFTPGO_API_KEY or SFTPGO_USER+SFTPGO_PASS in $CONFIG first." >&2
  exit 1
fi

urlquote() { python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=sys.argv[2] if len(sys.argv) > 2 else "/"))' "$1" "${2:-}"; }

filename="$(basename "$local_file")"
# Slug from the parent directory name (matches our rendered/<doc-slug>/main.pdf convention) so
# each share gets its own remote folder containing only this one file, not whatever else happens
# to be in the local directory.
slug="$(basename "$(cd "$(dirname "$local_file")" && pwd)")"
remote_dir="${remote_base_dir%/}/${slug}"
version_dir="${remote_dir}/versions"
encoded_dir="$(urlquote "$remote_dir")"
encoded_version_dir="$(urlquote "$version_dir")"

upload() { # $1 = destination dir (encoded), $2 = remote filename to use
  local status
  status="$(curl -s -o /tmp/sftpgo-upload-response.$$ -w '%{http_code}' -X POST -H "$auth_header" \
    -F "filenames=@${local_file};filename=$2" \
    "${SFTPGO_BASE_URL}/api/v2/user/files?path=$1&mkdir_parents=true")"
  rm -f /tmp/sftpgo-upload-response.$$
  if [ "$status" -ge 400 ]; then
    echo "upload failed (HTTP ${status}). If using an API key and this is 401, the key might be unbound to a user — see SKILL.md section 9 for the <id>.<secret>.<username> format." >&2
    exit 1
  fi
}

# Current/stable copy (what the printed link always points at).
upload "$encoded_dir" "$filename"
# Archived, timestamped copy for version history.
# Fixed, locale-independent, human-readable format -- numeric fields only, so it never
# varies with system locale (no day/month names), and stays lexicographically sortable.
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
upload "$encoded_version_dir" "${timestamp}-${filename}"

expires_at_ms=0
if [ "$expires_days" != "0" ]; then
  expires_at_ms=$(( $(date -d "+${expires_days} days" +%s) * 1000 ))
fi

existing_share_id="$(curl -sf -H "$auth_header" "${SFTPGO_BASE_URL}/api/v2/user/shares" \
  | jq -r --arg n "$slug" '[.[] | select(.name == $n)] | first | .id // empty')"

if [ -n "$existing_share_id" ]; then
  share_id="$existing_share_id"
else
  share_body="$(jq -n \
    --arg name "${slug}" \
    --argjson scope 1 \
    --arg path "$remote_dir" \
    --argjson expires "$expires_at_ms" \
    --arg pw "$password" \
    '{name: $name, scope: $scope, paths: [$path], expires_at: $expires} + (if $pw != "" then {password: $pw} else {} end)')"

  share_id="$(curl -sf -X POST -H "$auth_header" -H "Content-Type: application/json" \
    -d "$share_body" -D - -o /dev/null "${SFTPGO_BASE_URL}/api/v2/user/shares" \
    | grep -i '^x-object-id:' | tr -d '\r\n' | awk '{print $2}')"

  [ -n "$share_id" ] || { echo "share creation failed (no X-Object-ID header in response)" >&2; exit 1; }
fi

if [[ "$filename" == *.pdf ]]; then
  encoded_file_path="$(urlquote "/${filename}" "")"
  echo "${SFTPGO_BASE_URL}/web/client/pubshares/${share_id}/viewpdf?path=${encoded_file_path}"
else
  echo "${SFTPGO_BASE_URL}/web/client/pubshares/${share_id}/browse"
fi
