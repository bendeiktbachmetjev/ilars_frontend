#!/bin/bash
# Shows the screenshots the way the store lays them out: in a row, rounded corners,
# with exactly the gap the page is drawn for (CONFIGS[target].gap), at half size.
#   ./store-view.sh ios  →  out/ios-store.png        (row with the configured gap: the honest view)
#                           out/ios-store-nogap.png  (the same screenshots touching, for comparison)
# Uses every out/<target>-<n>.png that render.sh made (1, 2, 3, … in order). The gap is read
# from out/<target>-strip.png: its width is N × shot width + (N − 1) × gap.
set -euo pipefail
cd "$(dirname "$0")"
V="${1:?usage: store-view.sh <target: ios | play | ipad>}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PARTS=() FLAT=()
# corner radius as the store draws it, in % of the screenshot width: App Store ~10 % (product page),
# Google Play ~8 %
case "$V" in play) ROUND=8;; *) ROUND=10;; esac
for (( i = 1; ; i++ )); do
  F="out/$V-$i.png"; [ -f "$F" ] || break
  read -r W H <<<"$(magick identify -format '%w %h' "$F")"
  w=$(( W / 2 )) h=$(( H / 2 )) r=$(( w * ROUND / 100 ))
  magick "$F" -resize "${w}x${h}!" "$TMP/flat-$i.png"
  magick "$TMP/flat-$i.png" \
    \( -size "${w}x${h}" xc:none -fill white -draw "roundrectangle 0,0 $(( w - 1 )),$(( h - 1 )) $r,$r" \) \
    -alpha set -compose DstIn -composite "$TMP/$i.png"
  PARTS+=("$TMP/$i.png") FLAT+=("$TMP/flat-$i.png")
done
N=${#PARTS[@]}
[ "$N" -gt 0 ] || { echo "no out/$V-1.png; run ./render.sh $V first" >&2; exit 1; }
SW="$(magick identify -format '%w' "out/$V-1.png")"
STRIPW="$(magick identify -format '%w' "out/$V-strip.png")"
GAP=0; (( N > 1 )) && GAP=$(( (STRIPW - N * SW) / (N - 1) ))
G=$(( GAP / 2 ))                     # the gap at the preview's half scale
EDGE=30

# the honest row: gap G between screenshots (+append with -splice puts G before each one)
magick -background white "${PARTS[@]}" -splice "${G}x0" +append -gravity west -chop "${G}x0" \
  -gravity east -splice "${EDGE}x0" -gravity west -splice "${EDGE}x0" \
  -gravity center -bordercolor white -border 0x40 \
  -background white -alpha remove -alpha off "out/$V-store.png"

# for comparison: the same screenshots touching, square corners
magick "${FLAT[@]}" +append -bordercolor white -border "${EDGE}x40" \
  -background white -alpha remove -alpha off "out/$V-store-nogap.png"

echo "out/$V-store.png ($N screenshots, gap ${GAP}px → ${G}px at half size)  out/$V-store-nogap.png"
