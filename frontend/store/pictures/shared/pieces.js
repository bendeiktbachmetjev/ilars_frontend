/* iLARS store pictures: the small story pieces, shared by screens/strip.html and hero/hero.html.
   Every piece is a white pop-out card (or a medallion) with a soft, cool-violet shadow.
   Its drawing lives in a fixed viewBox and is scaled to the width you give, so one piece
   looks the same on every canvas. No words inside any piece.

     ilarsPiece(parent, kind, x, y, w, rot, extra)   x, y = top-left corner in page px
       'progress'  a small chart card: a gently rising line and a row of day dots, today's still open
       'check'     a check mark and a few filled day dots
       'food'      a small chip with a drawn icon: extra = 'leaf' | 'loaf' | 'cup'
       'steps'     a footprint and a short progress bar
       'dots'      just a row of day dots on a pill: extra = { n, filled }
     ilarsMedal(parent, who, cx, cy, d, mirrored)     who = 'pat' | 'doc'

   Glass: when the page has turned on shared/glass.js (Glass.on(), body.glass), every piece becomes
   lightly frosted glass instead of a white card; the placeholder lines inside turn into soft ink
   so they still read on the frost. The drawings themselves stay fully opaque.
*/
const ILARS = {
  glassLine: 'rgba(42, 27, 85, .12)',  // placeholder lines on glass
  glassTrack: 'rgba(42, 27, 85, .08)', // empty part of the steps bar on glass
  violet: '#8F5CFF', orange: '#FF9A4A', solidOrange: '#F0812D',
  line: '#E6E1F3',               // grey-violet placeholder lines inside cards
  shadow: '60, 40, 140',         // rgb of the cool violet shadow
};
let ilarsUid = 0;

/* colour at t (0…1) along the violet → orange gradient */
function ilarsMix(t) {
  const a = [0x8F, 0x5C, 0xFF], b = [0xFF, 0x9A, 0x4A];
  return '#' + a.map((v, i) => Math.round(v + (b[i] - v) * t).toString(16).padStart(2, '0')).join('');
}
function ilarsGrad(id, x1 = 0, y1 = 0, x2 = 1, y2 = 0) {
  return `<linearGradient id="${id}" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}">` +
    `<stop offset="0" stop-color="${ILARS.violet}"/><stop offset="1" stop-color="${ILARS.orange}"/></linearGradient>`;
}
/* a row of n day dots from (x0, y) to (x1, y); `filled` of them coloured, the next one an open ring */
function ilarsDotRow(n, filled, x0, x1, y, d) {
  let g = '';
  const step = n > 1 ? (x1 - x0) / (n - 1) : 0;
  for (let i = 0; i < n; i++) {
    const cx = x0 + i * step;
    if (i < filled) g += `<circle cx="${cx}" cy="${y}" r="${d / 2}" fill="${ilarsMix(n > 1 ? i / (n - 1) : 0)}"/>`;
    else g += `<circle cx="${cx}" cy="${y}" r="${d / 2 - 2.5}" fill="#fff" stroke="#D9CFF7" stroke-width="5"/>`;
  }
  return g;
}

const ILARS_PIECES = {
  progress: { vb: [420, 300], r: 44, draw(u) {
    const pts = [[40, 182], [92, 172], [144, 176], [196, 154], [248, 148], [300, 124], [352, 116], [380, 98]];
    let d = `M${pts[0][0]} ${pts[0][1]}`;
    for (let i = 0; i < pts.length - 1; i++) {   // Catmull-Rom → Bézier: a soft, hand-made line
      const p0 = pts[i - 1] || pts[i], p1 = pts[i], p2 = pts[i + 1], p3 = pts[i + 2] || p2;
      d += ` C ${p1[0] + (p2[0] - p0[0]) / 6} ${p1[1] + (p2[1] - p0[1]) / 6}, ${p2[0] - (p3[0] - p1[0]) / 6} ${p2[1] - (p3[1] - p1[1]) / 6}, ${p2[0]} ${p2[1]}`;
    }
    const end = pts[pts.length - 1];
    return `<defs>${ilarsGrad('pg' + u)}<linearGradient id="pa${u}" x1="0" y1="0" x2="0" y2="1">` +
      `<stop offset="0" stop-color="${ILARS.violet}" stop-opacity=".16"/><stop offset="1" stop-color="${ILARS.violet}" stop-opacity="0"/></linearGradient></defs>` +
      `<rect x="40" y="36" width="130" height="20" rx="10" fill="${ILARS.line}"/>` +
      `<path d="${d} L ${end[0]} 204 L 40 204 Z" fill="url(#pa${u})"/>` +
      `<path d="${d}" fill="none" stroke="url(#pg${u})" stroke-width="10" stroke-linecap="round"/>` +
      `<circle cx="${end[0]}" cy="${end[1]}" r="15" fill="#fff"/><circle cx="${end[0]}" cy="${end[1]}" r="9" fill="${ILARS.orange}"/>` +
      ilarsDotRow(7, 6, 52, 368, 252, 26);
  } },
  check: { vb: [330, 190], r: 44, draw(u) {
    return `<defs>${ilarsGrad('cg' + u, 0, 0, 1, 1)}</defs>` +
      `<circle cx="92" cy="95" r="54" fill="url(#cg${u})"/>` +
      `<path d="M66 97 L 85 116 L 119 79" fill="none" stroke="#fff" stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/>` +
      `<rect x="176" y="60" width="112" height="18" rx="9" fill="${ILARS.line}"/>` +
      ilarsDotRow(4, 4, 189, 287, 122, 24);
  } },
  food: { vb: [160, 160], r: 46, draw(u, icon) {
    if (icon === 'leaf') return '' +
      `<path d="M32 126 C 26 78, 62 34, 132 28 C 136 96, 98 132, 32 126 Z" fill="#AE86FF"/>` +
      `<path d="M32 126 C 72 102, 110 64, 132 28 C 136 96, 98 132, 32 126 Z" fill="#8C5EF2"/>` +
      `<path d="M32 126 C 66 100, 100 66, 124 38" stroke="#F2EBFF" stroke-width="5" fill="none" stroke-linecap="round"/>` +
      `<path d="M62 102 L 58 78 M86 80 L 84 58 M72 94 L 96 98 M96 72 L 116 76" stroke="#F2EBFF" stroke-width="4" fill="none" stroke-linecap="round" opacity=".85"/>` +
      `<path d="M32 126 L 20 140" stroke="#8C5EF2" stroke-width="7" stroke-linecap="round"/>`;
    if (icon === 'loaf') return '' +
      `<path d="M30 104 C 26 70, 50 48, 80 48 C 110 48, 134 70, 130 104 Q 130 118 116 118 L 44 118 Q 30 118 30 104 Z" fill="#FFB27A"/>` +
      `<path d="M30 98 Q 30 118 44 118 L 116 118 Q 130 118 130 98 C 112 106, 48 106, 30 98 Z" fill="#F08F4E"/>` +
      `<path d="M52 76 Q 58 66 68 62" stroke="#FFE1C6" stroke-width="7" fill="none" stroke-linecap="round"/>` +
      `<path d="M76 72 Q 82 62 92 58" stroke="#FFE1C6" stroke-width="7" fill="none" stroke-linecap="round"/>` +
      `<path d="M100 74 Q 106 66 112 64" stroke="#FFE1C6" stroke-width="7" fill="none" stroke-linecap="round"/>`;
    // cup
    return '' +
      `<path d="M66 40 C 60 32, 72 26, 66 16" stroke="#D9CFF7" stroke-width="6" fill="none" stroke-linecap="round"/>` +
      `<path d="M90 40 C 84 32, 96 26, 90 16" stroke="#D9CFF7" stroke-width="6" fill="none" stroke-linecap="round"/>` +
      `<path d="M112 72 C 138 70, 140 106, 108 108" stroke="#E2894D" stroke-width="10" fill="none" stroke-linecap="round"/>` +
      `<path d="M38 56 L 118 56 L 110 116 Q 108 130 94 130 L 62 130 Q 48 130 46 116 Z" fill="#FFB27A"/>` +
      `<path d="M98 56 L 118 56 L 110 116 Q 108 130 94 130 L 88 130 Q 100 122 100 108 Z" fill="#F08F4E"/>` +
      `<ellipse cx="78" cy="56" rx="40" ry="9" fill="#FFD9BD"/>` +
      `<ellipse cx="78" cy="57" rx="32" ry="5.5" fill="#C9A6FF"/>`;
  } },
  steps: { vb: [360, 150], r: 46, draw(u) {
    const foot = (x, y, a, c, c2) => `<g transform="translate(${x} ${y}) rotate(${a})">` +
      `<path d="M0 -40 C 16 -40, 22 -22, 20 -6 C 18 8, 12 14, 0 14 C -12 14, -18 8, -18 -6 C -20 -24, -14 -40, 0 -40 Z" fill="${c}"/>` +
      `<path d="M8 -38 C 18 -32, 22 -18, 20 -6 C 18 8, 12 14, 0 14 C 10 4, 14 -16, 8 -38 Z" fill="${c2}"/>` +
      `<ellipse cx="1" cy="32" rx="13" ry="12" fill="${c}"/><path d="M8 22 C 16 28, 14 40, 4 44 C 10 36, 10 30, 8 22 Z" fill="${c2}"/></g>`;
    return `<defs>${ilarsGrad('sg' + u)}</defs>` +
      foot(66, 84, -14, '#A47DFF', '#8A5CF2') + foot(116, 66, 10, '#FFA766', '#EE8A45') +
      `<rect x="164" y="48" width="96" height="18" rx="9" fill="${ILARS.line}"/>` +
      `<rect x="164" y="86" width="164" height="22" rx="11" fill="#EFEBF9"/>` +
      `<rect x="164" y="86" width="118" height="22" rx="11" fill="url(#sg${u})"/>`;
  } },
  dots: { vb: [300, 70], r: 35, draw(u, o = {}) {
    const n = o.n || 5, f = o.filled == null ? n - 1 : o.filled;
    return ilarsDotRow(n, f, 36, 264, 35, 26);
  } },
};

function ilarsPiece(parent, kind, x, y, w, rot = 0, extra) {
  const P = ILARS_PIECES[kind];
  if (!P) throw new Error('unknown piece ' + kind);
  const [vw, vh] = P.vb, s = w / vw, h = vh * s, u = ++ilarsUid;
  const e = document.createElement('div');
  e.className = 'piece piece-' + kind;
  Object.assign(e.style, {
    position: 'absolute', left: x + 'px', top: y + 'px', width: w + 'px', height: h + 'px',
    background: '#fff', borderRadius: P.r * s + 'px', transform: `rotate(${rot}deg)`,
    boxShadow: `0 ${34 * s}px ${54 * s}px -${18 * s}px rgba(${ILARS.shadow}, .26), 0 ${5 * s}px ${11 * s}px rgba(${ILARS.shadow}, .10)`,
  });
  const glass = typeof Glass !== 'undefined' && document.body.classList.contains('glass');
  let art = P.draw(u, extra);
  if (glass) art = art.split(`fill="${ILARS.line}"`).join(`fill="${ILARS.glassLine}"`)
    .split('fill="#EFEBF9"').join(`fill="${ILARS.glassTrack}"`);
  e.innerHTML = `<svg width="${w}" height="${h}" viewBox="0 0 ${vw} ${vh}" style="display:block; position:relative; z-index:1">${art}</svg>`;
  parent.appendChild(e);
  // glass scale: the rim's refraction band follows the piece's size (a small chip gets a thin rim)
  if (glass) Glass.panel(e, P.r * s, Math.max(.4, Math.min(1.4, Math.sqrt(w * h) / 300)));
  return e;
}

function ilarsMedal(parent, who, cx, cy, d, mirrored) {
  const m = document.createElement('div');
  m.className = 'medal';
  Object.assign(m.style, { position: 'absolute', left: (cx - d / 2) + 'px', top: (cy - d / 2) + 'px', width: d + 'px', height: d + 'px' });
  const k = d / 340, flip = mirrored ? 'transform: scaleX(-1);' : '';
  m.innerHTML =
    `<div style="position:absolute; left:14%; right:14%; bottom:-7%; height:12%; border-radius:50%;` +
    ` background: radial-gradient(closest-side, rgba(${ILARS.shadow}, .20), rgba(${ILARS.shadow}, 0))"></div>` +
    `<svg viewBox="0 0 100 100" style="position:absolute; inset:0; width:100%; height:100%; overflow:visible; ${flip}` +
    ` filter: drop-shadow(0 ${14 * k}px ${18 * k}px rgba(${ILARS.shadow}, .22)) drop-shadow(0 ${3 * k}px ${4 * k}px rgba(${ILARS.shadow}, .16))">` +
    `<use href="#${who}" x="0" y="0" width="100" height="100"/></svg>`;
  parent.appendChild(m);
  return m;
}
