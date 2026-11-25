#!/usr/bin/env bash
# Extract still frames from a video so the screen content can be read alongside the transcript.
# Usage: frames.sh <video> <outdir> [every_seconds=8] [width=1280]
set -euo pipefail
video=$1; out=$2; every=${3:-8}; width=${4:-1280}
mkdir -p "$out"
ffmpeg -v error -y -i "$video" -vf "fps=1/${every},scale=${width}:-1" "$out/f_%03d.png"
ls "$out"/f_*.png
