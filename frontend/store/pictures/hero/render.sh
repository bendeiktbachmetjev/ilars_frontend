#!/bin/bash
# Renders the three store hero pictures and their check images into ../out/ (hero-* only).
# Usage: ./render.sh [header|search|feature ...]   (default: all three)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HERE/../out"
OUT="$(cd "$HERE/../out" && pwd)"
CHROME="/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta"
KINDS=("$@"); [ ${#KINDS[@]} -eq 0 ] && KINDS=(header search feature)
EXTRA=""

size() { case "$1" in header) echo "3840 1646";; search) echo "3840 2560";; feature) echo "1024 500";; esac; }
safe() { case "$1" in header) echo "1097 493 1646 661";; search) echo "836 765 2168 1030";; feature) echo "154 50 716 400";; esac; }

for K in "${KINDS[@]}"; do
  read W H <<<"$(size "$K")"
  read SX SY SW SH <<<"$(safe "$K")"
  FINAL="$OUT/hero-$K-${W}x${H}.png"
  RAW="$(mktemp -t hero).png"
  PROFILE="$(mktemp -d)"
  "$CHROME" --headless=new --hide-scrollbars --force-device-scale-factor=1 \
    --allow-file-access-from-files --no-first-run --no-default-browser-check \
    --user-data-dir="$PROFILE" --window-size="$W,$H" --virtual-time-budget=5000 \
    --screenshot="$RAW" "file://$HERE/hero.html?kind=$K$EXTRA" >/dev/null 2>&1
  rm -rf "$PROFILE"
  magick "$RAW" -alpha off -define png:color-type=2 "$FINAL"
  rm -f "$RAW"
  echo "$(basename "$FINAL"): $(magick identify -format '%wx%h %[channels]' "$FINAL")"

  # check: scaled to 1600 wide (feature at real size), safe area as a thin red rectangle
  if [ "$K" = feature ]; then SC=1; else SC=$(echo "1600/$W" | bc -l); fi
  X1=$(echo "$SX*$SC" | bc -l); Y1=$(echo "$SY*$SC" | bc -l)
  X2=$(echo "($SX+$SW)*$SC" | bc -l); Y2=$(echo "($SY+$SH)*$SC" | bc -l)
  magick "$FINAL" -resize "$(echo "$W*$SC" | bc -l | cut -d. -f1)x" -fill none -stroke red -strokewidth 2 \
    -draw "rectangle $X1,$Y1,$X2,$Y2" "$OUT/hero-$K-check.png"

  if [ "$K" = header ]; then
    magick "$FINAL" -crop "${SW}x${SH}+${SX}+${SY}" +repage "$OUT/hero-header-crop-safe.png"
    magick "$FINAL" -crop "${SW}x${H}+${SX}+0" +repage "$OUT/hero-header-crop-tall.png"
  fi
done
