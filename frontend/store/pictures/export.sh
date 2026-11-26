#!/bin/bash
# Puts the finished pictures from out/ into the store folders the owner uploads from.
#
#   ./render.sh ios && ./render.sh play && ./render.sh ipad && hero/render.sh && ./export.sh
#
# App Store:   ../screenshots/ios      1320 × 2868 PNG (6.9", the master)
#              ../screenshots/ios-6.3  1206 × 2622 PNG  (the size App Store Connect asks for: "iPhone
#                                                       with Dynamic Island, medium display")
#              ../screenshots/ios-6.5  1284 × 2778 PNG
#              ../screenshots/ipad     2064 × 2752 PNG  (iPad 13")
#              ../app-store            header-3840x1646.png, search-3840x2560.png
# Google Play: ../screenshots/android  1080 × 1920 PNG
#              ../google-play          the same as JPEG + feature-graphic-1024x500.jpg
# No transparency anywhere.
#
# Another language (after ./render.sh ios lt && ./render.sh play lt):  ./export.sh lt
# writes the screenshots into the same folders with "-lt" added (screenshots/ios-lt, …).
set -euo pipefail
cd "$(dirname "$0")"
S=..
L="${1:-en}"
P=""; D=""; [ "$L" = en ] || { P="-$L"; D="-$L"; }   # out/ios-lt-1.png → screenshots/ios-lt/
NAMES=(dashboard daily food diet exercise)

need() { [ -f "$1" ] || { echo "missing $1 - render first" >&2; exit 1; }; }
size() {
  local got; got="$(magick identify -format '%wx%h' "$1")"
  [ "$got" = "$2" ] || { echo "$1 is $got, expected $2" >&2; exit 1; }
}
# Scale to cover the target size, then cut the overhang evenly (a few pixels).
fit() { magick "$1" -resize "$2^" -gravity center -extent "$2" -alpha off "$3"; }

mkdir -p "$S/screenshots/ios$D" "$S/screenshots/ios-6.5$D" "$S/screenshots/ios-6.3$D" "$S/screenshots/android$D" \
  "$S/screenshots/ipad$D" "$S/google-play$D" "$S/app-store"

for i in 1 2 3 4 5; do
  n="$i-${NAMES[$((i - 1))]}"
  need "out/ios$P-$i.png";  size "out/ios$P-$i.png" 1320x2868
  need "out/play$P-$i.png"; size "out/play$P-$i.png" 1080x1920
  magick "out/ios$P-$i.png" -alpha off "$S/screenshots/ios$D/$n.png"
  fit "out/ios$P-$i.png" 1284x2778 "$S/screenshots/ios-6.5$D/$n.png"
  fit "out/ios$P-$i.png" 1206x2622 "$S/screenshots/ios-6.3$D/$n.png"
  magick "out/play$P-$i.png" -alpha off "$S/screenshots/android$D/$n.png"
  magick "out/play$P-$i.png" -alpha off -quality 92 "$S/google-play$D/phone-$n.jpg"
  need "out/ipad$P-$i.png"; size "out/ipad$P-$i.png" 2064x2752
  magick "out/ipad$P-$i.png" -alpha off "$S/screenshots/ipad$D/$n.png"
done

# hero pictures (English phrase; one set for now)
need out/hero-header-3840x1646.png; size out/hero-header-3840x1646.png 3840x1646
need out/hero-search-3840x2560.png; size out/hero-search-3840x2560.png 3840x2560
need out/hero-feature-1024x500.png; size out/hero-feature-1024x500.png 1024x500
magick out/hero-header-3840x1646.png -alpha off "$S/app-store/header-3840x1646.png"
magick out/hero-search-3840x2560.png -alpha off "$S/app-store/search-3840x2560.png"
magick out/hero-feature-1024x500.png -alpha off -quality 92 "$S/google-play$D/feature-graphic-1024x500.jpg"

echo "exported ($L): screenshots/ios$D, ios-6.3$D, ios-6.5$D, ipad$D, android$D; google-play$D; app-store"
