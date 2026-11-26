# iLARS store pictures

The App Store and Google Play pictures: five screenshots per target (iPhone, iPad, Android),
plus the hero pictures.

## Redraw and export everything

```
cd store/pictures && ./render.sh ios && ./render.sh play && ./render.sh ipad && hero/render.sh && ./export.sh
```

`./store-view.sh ios` (or `play`, `ipad`) shows the row as the store shows it, with the store's gap
and rounded corners: `out/ios-store.png`; `out/ios-store-nogap.png` is the same row with the
screenshots touching.

## Which folder goes where

| Folder | Size | Upload to |
|---|---|---|
| `store/screenshots/ios-6.3` | 1206 × 2622 | App Store Connect, iPhone (the size it accepts) |
| `store/screenshots/ipad` | 2064 × 2752 | App Store Connect, iPad 13" |
| `store/google-play` | 1080 × 1920 JPEG + feature graphic 1024 × 500 | Google Play |
| `store/app-store` | header 3840 × 1646, search 3840 × 2560 | App Store header and search pictures |

`store/screenshots/ios` (1320 × 2868, the master), `ios-6.5` (1284 × 2778) and `android`
(1080 × 1920 PNG) are kept as well. No transparency anywhere.

## The gap

A store shows the screenshots side by side with a gap between them. A tilted phone edge that runs
across a seam would reappear shifted by that gap, so each strip is drawn with the gap in it:
screenshot i starts at x = i × (width + gap), paper, wave, devices and shadows run straight
through the gaps, and `render.sh` cuts the screenshots out and throws the gap strips away.
One `gap` number per target, in `CONFIGS` in `screens/strip.html`; the values were measured for
the Dr. Filler pictures and are the same here:

- `ios` 72 px, `ipad` 114 px: 5.5 % of the width (App Store product page ~4.2 %, search ~7–8 %);
- `play` 146 px: 13.5 % (Google Play app ~13.9 %, web ~10 %).

A device either crosses into the next screenshot with a real piece (a corner with some screen,
~15 % of its width), or runs off the edge of its own screenshot and ends inside the gap, so nothing
of it shows in the neighbour. On `play` and `ipad` every device runs off. The page's self-check
(`check:` in the output of `render.sh`) reports for each device how it leaves its screenshot, and
for each crossing edge that it leaves screenshot i and enters screenshot i + 1 on one straight
line at the configured gap (`seamsOk`).

## Glass

`shared/glass.js` is the Liquid Glass material of the Dr. Filler pictures (copied, with this app's
indigo and violet tints): frosted pieces with a bent rim and a light edge upper-left, glass rims on
the medallions, a glossy line along the wave, and a few clear beads (at most two per screenshot,
never on a seam, near a headline or on a screen). One `glass` flag per target in `CONFIGS`, and
`HERO_GLASS` in `hero/hero.js`; default on. `GLASS=0 ./render.sh ios` draws the paper version for
comparing. `out/<target>-contrast.txt` lists every headline line's contrast against what lies
behind it (it must stay at or above 4.5:1).

## What is here

- `screens/strip.html`: one page draws all five screenshots as one strip. `?target=ios|play|ipad`.
  - Headlines and which captures to use: the `TEXT` block at the top. **The headlines are drafts until the owner confirms them.**
  - A Lithuanian set: fill in `TEXT.lt`, then `./render.sh ios lt`, `./render.sh play lt`, `./export.sh lt`
    (the iPad set needs Lithuanian iPad captures first).
  - Device sizes, tilts, gap, glass and the small pieces: the `CONFIGS` block. What must stay whole on each
    screen: the `KEEP` block (one list for the phone captures, one for the iPad captures).
  - `GUIDE=1 ./render.sh ios` marks in pink the parts of each screen that must stay whole.
- `shared/`: the two people (`people.js`), the small cards and chips (`pieces.js`), the glass (`glass.js`),
  the font (Nunito, licence `OFL.txt`).
- `shared/frame.png` (iPhone) and `shared/frame-ipad.png` (iPad Pro 13", screen opening 2064 × 2752 at
  118, 124, corner ~62 px) are Apple's frames; `shared/statusbar.png` and `shared/statusbar-ipad.png`
  are real status bars, laid over the screen with multiply. Use them **only for the App Store pictures**,
  only rotated, never stretched or recoloured. The Google Play pictures use a drawn phone with no status bar.
- `hero/`: the header, search and feature pictures (`hero/render.sh`; `out/hero-*-check.png` shows the safe area in red).
- `raw/en`, `raw/lt` (iPhone, 1320 × 2868) and `raw/ipad/en` (iPad, 1032 × 1376 points at 2×, safe area
  24 top / 20 bottom, 2064 × 2752): the app's screens with an invented patient. They come from
  `flutter test tool/store_captures_test.dart` (only the iPad: add `--plain-name ipad`; patient data:
  `make_fixture.py` → `fixtures/patient.json`).

The drawing needs Google Chrome Beta and ImageMagick on this Mac.
