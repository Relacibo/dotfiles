#!/usr/bin/env bash
# Open Thunderbird compose with attachment.
# Flatpak sandbox limits file access to ~/Downloads by default,
# so the script auto-copies the file there before attaching.
# Usage: share-email.sh <file> <to> <subject> <body>
set -euo pipefail

file="${1:?usage: share-email.sh <file> <to> <subject> <body>}"
to="${2:?}"
subject="${3:?}"
body_text="${4:?}"

# Flatpak Thunderbird can only access ~/Downloads by default.
# Copy the file there to guarantee the attachment works.
staging_dir="$HOME/Downloads/.share-attachments"
mkdir -p "$staging_dir"
staged="$staging_dir/$(basename "$file")"
cp "$file" "$staged"

COMPOSE="to=${to},subject=${subject},body='${body_text}',attachment=file://${staged}"

nohup flatpak run --command=thunderbird net.thunderbird.Thunderbird -compose "$COMPOSE" > /dev/null 2>&1 &

echo "Thunderbird opened: ${to} (${subject})"
