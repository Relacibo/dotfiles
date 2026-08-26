#!/usr/bin/env bash
# Upload a file to SFTPGo and print a public share link.
# Wraps the typst skill's share.sh with the share skill's config.
# Usage: share-upload.sh <local-file> [--expires-days N] [--password <pw>]

set -euo pipefail

export SFTPGO_SHARE_CONFIG="$HOME/.config/share/share.env"

# Delegate to the typst skill's share.sh (single source of truth for SFTPGo logic)
exec "$HOME/.config/opencode/skills/typst/scripts/share.sh" "$@"
