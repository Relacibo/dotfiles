#!/usr/bin/env bash
# Compile a Typst document living at <typst-root>/sources/<slug>/src/main.typ
# into <typst-root>/rendered/<slug>/main.pdf.
# Usage: compile.sh <doc-root> [extra typst compile args...]
# <doc-root> must be a .../typst/sources/<slug> path (global or project-local).
set -euo pipefail

doc_root="${1:?usage: compile.sh <doc-root> [extra typst args...]}"
shift

doc_root="$(cd "$doc_root" && pwd)"
slug="$(basename "$doc_root")"
typst_root="$(dirname "$(dirname "$doc_root")")"
rendered_dir="$typst_root/rendered/$slug"

font_args=()

if [ -z "${TYPST_FONT_PATHS:-}" ]; then
  docs_dir="$(xdg-user-dir DOCUMENTS 2>/dev/null || echo "$HOME/Documents")"
  if [ -d "$docs_dir/typst/fonts" ]; then
    font_args+=(--font-path "$docs_dir/typst/fonts")
  fi
fi

if [ -d "$doc_root/fonts" ]; then
  font_args+=(--font-path "$doc_root/fonts")
fi

mkdir -p "$rendered_dir"
typst compile "${font_args[@]}" "$doc_root/src/main.typ" "$rendered_dir/main.pdf" "$@"
