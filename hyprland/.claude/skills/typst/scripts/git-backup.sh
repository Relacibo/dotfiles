#!/usr/bin/env bash
# Ensure a bare git remote exists on the ovilava host for a local typst repo, wire it up
# as "origin" if not already set, and push. Safe to call repeatedly (idempotent).
#
# Usage: git-backup.sh <local-repo-dir> <remote-relative-path-without-.git>
#   git-backup.sh ~/Dokumente/typst/sources/hallo-typst sources/hallo-typst
#   git-backup.sh ~/Dokumente/typst/templates templates
set -euo pipefail

REMOTE_HOST="ovilava.rcbnetwork.de"
REMOTE_BASE="/mnt/data/git/typst"

local_repo="${1:?usage: git-backup.sh <local-repo-dir> <remote-relative-path>}"
remote_rel="${2:?usage: git-backup.sh <local-repo-dir> <remote-relative-path>}"

[ -d "$local_repo/.git" ] || { echo "not a git repo: $local_repo" >&2; exit 1; }

remote_path="${REMOTE_BASE}/${remote_rel}.git"
remote_dir="$(dirname "$remote_path")"

ssh "$REMOTE_HOST" "mkdir -p '$remote_dir' && [ -d '$remote_path' ] || git init --quiet --bare '$remote_path'"

cd "$local_repo"
if ! git remote get-url origin > /dev/null 2>&1; then
  git remote add origin "${REMOTE_HOST}:${remote_path}"
fi

git push --quiet origin --all
git push --quiet origin --tags 2> /dev/null || true

echo "backed up: ${local_repo} -> ${REMOTE_HOST}:${remote_path}"
