#!/bin/bash
# Shows the screenshots the way the App Store lays them out: in a row,
# small gaps, rounded corners.   ./store-view.sh ios  →  out/ios-store.png
# Uses every out/<target>-<n>.png that render.sh made (1, 2, 3, … in order).
set -euo pipefail
cd "$(dirname "$0")"
V="${1:?usage: store-view.sh <target: ios | play>}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PARTS=()
for (( i = 1; ; i++ )); do
  F="out/$V-$i.png"; [ -f "$F" ] || break
  read -r W H <<<"$(magick identify -format '%w %h' "$F")"
  w=$(( W / 2 )) h=$(( H / 2 )) r=$(( W * 46 / 1320 ))
  magick "$F" -resize "${w}x${h}!" \
    \( -size "${w}x${h}" xc:none -fill white -draw "roundrectangle 0,0 $(( w - 1 )),$(( h - 1 )) $r,$r" \) \
    -alpha set -compose DstIn -composite "$TMP/$i.png"
  PARTS+=("$TMP/$i.png")
done
[ ${#PARTS[@]} -gt 0 ] || { echo "no out/$V-1.png; run ./render.sh $V first" >&2; exit 1; }
magick -background white "${PARTS[@]}" -splice 30x0 +append \
  -gravity east -splice 30x0 -gravity center -bordercolor white -border 0x40 \
  -background white -alpha remove -alpha off "out/$V-store.png"
echo "out/$V-store.png (${#PARTS[@]} screenshots)"
