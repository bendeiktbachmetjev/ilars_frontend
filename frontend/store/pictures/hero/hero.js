/* iLARS store hero pictures: one scene, three canvases.
   ?kind=header|search|feature   &guide=1 draws the safe area.
   Inside the safe area: the patient (in front) and her doctor, and the two-line phrase.
   Outside it: the wave and a few small pieces (day dots, a line card, food chips). */
const q = new URLSearchParams(location.search);
const kind = q.get('kind') || 'header';

/* Canvas and safe area [x, y, w, h]. The feature graphic has no official one:
   central 70 % of the width and 80 % of the height. */
const KINDS = {
  header:  { W: 3840, H: 1646, safe: [1097, 493, 1646, 661] },
  search:  { W: 3840, H: 2560, safe: [836, 765, 2168, 1030] },
  feature: { W: 1024, H: 500,  safe: [154, 50, 716, 400] },
};
const L = {
  /* d: patient medallion diameter (the doctor is 0.8 of it); cy: medallion centre (fraction of safe height);
     m: margin inside the safe area; fmax: largest phrase size;
     wave: x0 = lowest point, yLow = top edge there, yL/yR = top edge at the canvas sides, th = band thickness at x0;
     pieces: ['progress'|'dots'|'food', x, y, width, rot, extra] — all outside the safe area */
  header: {
    d: 370, cy: .55, m: 30, fmax: 200,
    wave: { x0: 2200, yLow: 1250, yL: 160, yR: 640, p: 1.8, th: 120 },
    pieces: [
      ['dots', 250, 250, 360, -6, { n: 5, filled: 4 }],
      ['progress', 640, 330, 380, -4],
      ['food', 2930, 560, 200, 6, 'loaf'],
      ['food', 3260, 400, 180, -6, 'leaf'],
    ],
  },
  search: {
    d: 500, cy: .55, m: 50, fmax: 300,
    wave: { x0: 2250, yLow: 1930, yL: 480, yR: 1100, p: 1.8, th: 170 },
    pieces: [
      ['dots', 110, 520, 460, -6, { n: 5, filled: 4 }],
      ['progress', 250, 820, 500, -4],
      ['food', 3150, 980, 270, 6, 'loaf'],
      ['food', 3460, 760, 240, -6, 'leaf'],
    ],
  },
  feature: {
    d: 150, cy: .52, m: 6, fmax: 90,
    wave: { x0: 512, yLow: 448, yL: 150, yR: 200, p: 1.8, th: 36 },
    pieces: [
      ['dots', 16, 120, 128, -6, { n: 4, filled: 3 }],
      ['food', 900, 130, 96, 6, 'leaf'],
    ],
  },
};
const C = KINDS[kind], P = L[kind];
const [sx, sy, sw, sh] = C.safe;
const { W, H } = C;
document.documentElement.style.width = document.body.style.width = W + 'px';
document.documentElement.style.height = document.body.style.height = H + 'px';
const S = W / 3840;
const story = document.getElementById('story');

/* ---------- grain ---------- */
const grainTile = Math.max(120, Math.round(360 * Math.max(S, H / 1646 * .5)));
document.getElementById('grain').style.backgroundSize = `${grainTile}px ${grainTile}px`;

/* ---------- the wave: three soft bands in one U-shaped sweep under the centre ---------- */
{
  const w = P.wave;
  const wv = document.getElementById('wave');
  wv.setAttribute('width', W); wv.setAttribute('height', H);
  wv.setAttribute('viewBox', `0 0 ${W} ${H}`);
  const sc = Math.max(.35, H / 1646);
  const ps = document.getElementById('ps'), ls = document.getElementById('ls');
  ps.setAttribute('dy', 12 * sc); ps.setAttribute('stdDeviation', 14 * sc);
  ls.setAttribute('dy', -6 * sc); ls.setAttribute('stdDeviation', 9 * sc);
  const t = x => x < w.x0 ? (w.x0 - x) / w.x0 : (x - w.x0) / (W - w.x0);
  const top = x => {
    const tt = t(x), side = x < w.x0 ? w.yL : w.yR;
    return w.yLow - (w.yLow - side) * Math.pow(tt, w.p);
  };
  const thick = x => w.th * (1 + 1.1 * Math.pow(t(x), 2));
  const edge = k => x => top(x) + k * thick(x);
  function band(fTop) {
    const pts = [], step = Math.max(4, W / 400);
    for (let x = -40; x <= W + 40; x += step) pts.push([x, fTop(x)]);
    pts.push([W + 40, H + 200], [-40, H + 200]);
    return 'M' + pts.map(p => p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' L') + ' Z';
  }
  document.getElementById('arA').setAttribute('d', band(edge(0)));
  document.getElementById('arB').setAttribute('d', band(edge(1)));
  document.getElementById('arC').setAttribute('d', band(edge(2)));
  window.waveTop = top;
}

/* ---------- outside the safe area ---------- */
P.pieces.forEach(([k, x, y, w, rot, extra]) => ilarsPiece(story, k, x, y, w, rot, extra));

/* ---------- inside the safe area (after the font has loaded, so the phrase is measured right) ---------- */
document.fonts.load('900 100px NunitoHero', 'A full life after rectal surgery').then(() => {
  const d = P.d, dd = d * .8, cy = sy + sh * P.cy;
  const hl = document.getElementById('hl');
  // the doctor a little behind and higher, the patient in front
  const docX = sx + P.m + dd / 2, patX = docX + dd / 2 + d * .2;
  ilarsMedal(story, 'doc', docX, cy - d * .10, dd);
  ilarsMedal(story, 'pat', patX, cy + d * .04, d);
  const left = patX + d / 2 + d * .1, right = sx + sw - P.m;
  let f = P.fmax;
  for (; f > 10; f -= 1) {
    hl.style.fontSize = f + 'px';
    const r = hl.getBoundingClientRect();
    if (r.width <= right - left && r.height <= sh * .8) break;
  }
  const r = hl.getBoundingClientRect();
  hl.style.left = ((left + right) / 2 - r.width / 2) + 'px';
  hl.style.top = (sy + sh * .5 - r.height / 2) + 'px';

  const hr = hl.getBoundingClientRect();
  document.title = `kind=${kind} font=${hl.style.fontSize} phrase=${Math.round(hr.left)},${Math.round(hr.top)},${Math.round(hr.right)},${Math.round(hr.bottom)} waveAtCentre=${Math.round(window.waveTop(hr.left + hr.width / 2))}`;
  if (q.get('guide')) {
    const g = document.getElementById('guide');
    Object.assign(g.style, { position: 'absolute', left: sx + 'px', top: sy + 'px', width: sw + 'px', height: sh + 'px', outline: '4px solid red' });
  }
});
