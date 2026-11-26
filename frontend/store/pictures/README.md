# iLARS store pictures

The App Store and Google Play pictures: five screenshots per store, plus the hero pictures.

## Redraw and export everything

```
cd store/pictures && ./render.sh ios && ./render.sh play && hero/render.sh && ./export.sh
```

`./store-view.sh ios` (or `play`) shows the row as the store shows it: `out/ios-store.png`.

The finished files go to `store/screenshots/ios` (1320 × 2868), `store/screenshots/ios-6.5` (1284 × 2778),
`store/screenshots/android` (1080 × 1920), `store/google-play` (JPEG + feature graphic) and
`store/app-store` (header and search pictures).

## What is here

- `screens/strip.html`: one page draws all five screenshots as one strip. `?target=ios|play`.
  - Headlines and which captures to use: the `TEXT` block at the top. **The headlines are drafts until the owner confirms them.**
  - A Lithuanian set: fill in `TEXT.lt`, then `./render.sh ios lt`, `./render.sh play lt`, `./export.sh lt`.
  - Phone sizes, tilts and the small pieces: the `CONFIGS` block.
  - `GUIDE=1 ./render.sh ios` marks in pink the parts of each screen that must stay whole.
- `shared/`: the two people (`people.js`), the small cards and chips (`pieces.js`), the font (Nunito, licence `OFL.txt`).
- `shared/frame.png` is Apple's iPhone frame and `shared/statusbar.png` a real iPhone status bar. Use them **only for the App Store pictures**. The Google Play pictures use a drawn phone with no status bar.
- `hero/`: the header, search and feature pictures (`hero/render.sh`; `out/hero-*-check.png` shows the safe area in red).
- `raw/en`, `raw/lt`: the app's screens with an invented patient. They come from
  `flutter test tool/store_captures_test.dart` (patient data: `make_fixture.py` → `fixtures/patient.json`).

The drawing needs Google Chrome Beta and ImageMagick on this Mac.
