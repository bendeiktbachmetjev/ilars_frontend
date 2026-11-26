#!/bin/bash
# Draws the store strip and cuts it into store screenshots.
#
#   ./render.sh ios [lang]   (lang: en by default; another language writes out/ios-<lang>-…)
#   ./render.sh ios   →  out/ios-strip.png    (all screenshots side by side)
#                        out/ios-1.png … ios-N.png  (each exactly one screenshot, no alpha)
#                        out/ios-preview.png  (half size, with the seams drawn)
#                        out/ios-thumbs.png   (each at 220 px wide, as in store search)
#
# One page draws every target: screens/strip.html?target=<target> (ios, play). Its CONFIGS[target]
# decides the screenshot size and count; the page writes them into <body data-strip="WxHxN">,
# and this script reads them from there.
# Chrome draws the page, ImageMagick cuts it. GUIDE=1 ./render.sh ios marks the parts of each
# screen that must stay whole (pink); data-check reports whether they do.
set -euo pipefail
cd "$(dirname "$0")"
T="${1:?usage: render.sh <target: ios | play> [lang]}"
L="${2:-en}"
V="$T"; [ "$L" = en ] || V="$T-$L"     # file prefix in out/
CHROME="/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta"
PROFILE="$(mktemp -d)"
trap 'rm -rf "$PROFILE"' EXIT
mkdir -p out
URL="file://$PWD/screens/strip.html?target=$T&lang=$L${GUIDE:+&guide=1}"
FLAGS=(--headless=new --hide-scrollbars --force-device-scale-factor=1
  --allow-file-access-from-files --no-first-run --no-default-browser-check
  --user-data-dir="$PROFILE" --virtual-time-budget=5000)

# 1. Ask the page for its size: data-strip="WxHxN", data-font, data-hl.
DOM="$("$CHROME" "${FLAGS[@]}" --window-size=1200,800 --dump-dom "$URL" 2>/dev/null)"
STRIP="$(printf '%s' "$DOM" | grep -o 'data-strip="[0-9]*x[0-9]*x[0-9]*"' | head -1 | tr -dc '0-9x')"
FONT="$(printf '%s' "$DOM" | grep -o 'data-font="[A-Za-z]*"' | head -1 | cut -d'"' -f2)"
HL="$(printf '%s' "$DOM" | grep -o 'data-hl="[0-9]*"' | head -1 | tr -dc '0-9')"
CHECK="$(printf '%s' "$DOM" | grep -o 'data-check="[^"]*"' | head -1 | cut -d'"' -f2 | sed 's/&quot;/"/g')"
[ -n "$STRIP" ] || { echo "page did not report data-strip" >&2; exit 1; }
IFS=x read -r SW SH N <<<"$STRIP"
W=$(( SW * N ))
[ "$FONT" = "nunito" ] || echo "WARNING: headline font is '$FONT', not Nunito" >&2

# 2. Draw it.
"$CHROME" "${FLAGS[@]}" --window-size="$W,$SH" \
  --screenshot="$PWD/out/$V-strip.png" "$URL" >/dev/null 2>&1
SIZE="$(magick identify -format '%wx%h' "out/$V-strip.png")"
if [ "$SIZE" != "${W}x${SH}" ]; then
  echo "strip is $SIZE, expected ${W}x${SH}" >&2
  exit 1
fi

# 3. The store pictures: no transparency, exactly SW × SH.
SHOTS=() SEAMS=()
for (( i = 1; i <= N; i++ )); do
  magick "out/$V-strip.png" -crop "${SW}x${SH}+$(( (i - 1) * SW ))+0" +repage \
    -background white -alpha remove -alpha off "out/$V-$i.png"
  SHOTS+=("out/$V-$i.png")
  (( i < N )) && SEAMS+=(-draw "line $(( i * SW )),0 $(( i * SW )),$SH")
done

# 4. Checking aids.
magick "out/$V-strip.png" -stroke '#ff2d55' -strokewidth 3 "${SEAMS[@]}" \
  -resize 50% "out/$V-preview.png"
magick "${SHOTS[@]}" -resize 220x \
  -background white -splice 12x0 +append -bordercolor white -border 12 "out/$V-thumbs.png"

echo "font=$FONT headline=${HL}px  $N × ${SW}x${SH}"
echo "check: $CHECK"
echo "out/$V-strip.png ${SHOTS[*]} out/$V-preview.png out/$V-thumbs.png"
