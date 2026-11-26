#!/bin/bash
# Draws the store strip and cuts it into store screenshots.
#
#   ./render.sh ios [lang]   (targets: ios, play, ipad; lang: en by default; another language
#                             writes out/ios-<lang>-…)
#   ./render.sh ios   →  out/ios-strip.png    (the whole canvas: screenshots with the store's gap between them)
#                        out/ios-1.png … ios-N.png  (each exactly one screenshot, no alpha)
#                        out/ios-preview.png  (half size, the gap strips tinted red)
#                        out/ios-thumbs.png   (each at 220 px wide, as in store search)
#                        out/ios-contrast.txt (headline contrast against what lies behind each line)
#
# One page draws every target: screens/strip.html?target=<target>. Its CONFIGS[target] decides the
# screenshot size, count and gap; the page writes them into <body data-strip="WxHxNxGAP">, and this
# script reads them from there. The gap strips (the space the store leaves between screenshots)
# are drawn so that everything runs on straight through them, and thrown away here.
# Chrome draws the page, ImageMagick cuts it.
#   GUIDE=1 ./render.sh ios   marks in pink the parts of each screen that must stay whole
#   GLASS=0 ./render.sh ios   draws without the glass material (GLASS=1 forces it on)
set -euo pipefail
cd "$(dirname "$0")"
T="${1:?usage: render.sh <target: ios | play | ipad> [lang]}"
L="${2:-en}"
V="$T"; [ "$L" = en ] || V="$T-$L"     # file prefix in out/
CHROME="/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta"
PROFILE="$(mktemp -d)"; TMP="$(mktemp -d)"
trap 'rm -rf "$PROFILE" "$TMP"' EXIT
mkdir -p out
URL="file://$PWD/screens/strip.html?target=$T&lang=$L${GUIDE:+&guide=1}${GLASS:+&glass=$GLASS}"
FLAGS=(--headless=new --hide-scrollbars --force-device-scale-factor=1
  --allow-file-access-from-files --no-first-run --no-default-browser-check
  --user-data-dir="$PROFILE" --virtual-time-budget=8000)

# 1. Ask the page for its size: data-strip="WxHxNxGAP", data-font, data-hl, data-check.
DOM="$("$CHROME" "${FLAGS[@]}" --window-size=1200,800 --dump-dom "$URL" 2>/dev/null)"
STRIP="$(printf '%s' "$DOM" | grep -o 'data-strip="[0-9]*x[0-9]*x[0-9]*x[0-9]*"' | head -1 | tr -dc '0-9x')"
FONT="$(printf '%s' "$DOM" | grep -o 'data-font="[A-Za-z]*"' | head -1 | cut -d'"' -f2)"
HL="$(printf '%s' "$DOM" | grep -o 'data-hl="[0-9]*"' | head -1 | tr -dc '0-9')"
CHECK="$(printf '%s' "$DOM" | grep -o 'data-check="[^"]*"' | head -1 | cut -d'"' -f2 | sed 's/&quot;/"/g')"
[ -n "$STRIP" ] || { echo "page did not report data-strip" >&2; exit 1; }
IFS=x read -r SW SH N GAP <<<"$STRIP"
W=$(( SW * N + GAP * (N - 1) ))
[ "$FONT" = "nunito" ] || echo "WARNING: headline font is '$FONT', not Nunito" >&2

# 2. Draw it (and once more without the headlines, for the contrast check).
"$CHROME" "${FLAGS[@]}" --window-size="$W,$SH" \
  --screenshot="$PWD/out/$V-strip.png" "$URL" >/dev/null 2>&1
"$CHROME" "${FLAGS[@]}" --window-size="$W,$SH" \
  --screenshot="$TMP/nohl.png" "$URL&nohl=1" >/dev/null 2>&1
SIZE="$(magick identify -format '%wx%h' "out/$V-strip.png")"
if [ "$SIZE" != "${W}x${SH}" ]; then
  echo "strip is $SIZE, expected ${W}x${SH}" >&2
  exit 1
fi

# 3. The store pictures: no transparency, exactly SW × SH; the gap strips are dropped.
SHOTS=() SEAMS=()
for (( i = 1; i <= N; i++ )); do
  X=$(( (i - 1) * (SW + GAP) ))
  magick "out/$V-strip.png" -crop "${SW}x${SH}+$X+0" +repage \
    -background white -alpha remove -alpha off "out/$V-$i.png"
  magick "$TMP/nohl.png" -crop "${SW}x${SH}+$X+0" +repage -alpha off "$TMP/bg-$i.png"
  SHOTS+=("out/$V-$i.png")
  (( i < N )) && SEAMS+=(-draw "rectangle $(( i * SW + (i - 1) * GAP )),0 $(( i * (SW + GAP) - 1 )),$SH")
done

# 4. Headline contrast: each line's colour against the darkest pixel behind its glyph box.
LINES="$(printf '%s' "$CHECK" | python3 -c 'import json,sys; [print(*l) for l in json.load(sys.stdin)["lines"]]')"
: > "out/$V-contrast.txt"
while read -r S LN X1 Y1 X2 Y2; do
  [ "$LN" = 1 ] && C="2A1B55" || C="6A3FE0"
  # the darkest background luminance in the box (relative luminance, sRGB → linear)
  MIN="$(magick "$TMP/bg-$S.png" -crop "$(( X2 - X1 ))x$(( Y2 - Y1 ))+$X1+$Y1" +repage \
    -colorspace RGB -fx '0.2126*r+0.7152*g+0.0722*b' -format '%[fx:minima]' info:)"
  python3 - "$C" "$MIN" "$S" "$LN" >> "out/$V-contrast.txt" <<'PY'
import sys
c, bg, s, ln = sys.argv[1], float(sys.argv[2]), sys.argv[3], sys.argv[4]
lin = lambda v: v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4
r, g, b = (lin(int(c[i:i + 2], 16) / 255) for i in (0, 2, 4))
L = .2126 * r + .7152 * g + .0722 * b
print(f"shot {s} line {ln} #{c}: {(bg + .05) / (L + .05):.2f}:1")
PY
done <<<"$LINES"
WORST="$(awk '{print $6}' "out/$V-contrast.txt" | sort -n | head -1)"

# 5. Checking aids.
magick "out/$V-strip.png" -fill '#ff2d5566' -stroke '#ff2d55' -strokewidth 3 "${SEAMS[@]}" \
  -resize 50% "out/$V-preview.png"
magick "${SHOTS[@]}" -resize 220x \
  -background white -splice 12x0 +append -bordercolor white -border 12 "out/$V-thumbs.png"

echo "font=$FONT headline=${HL}px  $N × ${SW}x${SH}, gap ${GAP}px, canvas ${W}x${SH}"
echo "headline contrast, worst: $WORST (out/$V-contrast.txt)"
echo "check: $CHECK"
echo "out/$V-strip.png ${SHOTS[*]} out/$V-preview.png out/$V-thumbs.png"
