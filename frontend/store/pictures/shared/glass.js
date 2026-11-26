/* Liquid-glass material for the store pictures (screens/strip.html and hero/hero.html).
   The same material as the Dr. Filler store pictures (copied from drfiller/mobile/store/pictures/
   shared/glass.js), so the apps look like one family; only the tints differ: Glass.on(colours)
   takes this app's own ink and shadow colours (iLARS: deep indigo and violet, see the pages).
   Headless Chrome only: it relies on `backdrop-filter` with an SVG filter (url(#…)) for the
   refraction at the rim and for the lens beads.

   A page turns it on with Glass.on({ ink, tint, frost }) and then asks for pieces:
     Glass.panel(el, r, k)            a rectangular card (div with rounded corners) becomes glass
     Glass.bubble(opts)               a speech bubble drawn as glass (returns its container)
     Glass.medalRims(['doc', 'pat'])  the white rings of the medallion symbols become glass rims
     Glass.wave(svg, bands, s)        sheets of tinted glass instead of cut paper
     Glass.bead(parent, x, y, d)      a small clear lens that magnifies what lies behind it
   Nothing here runs unless the page calls it, so with the page's glass flag off the pictures
   are exactly the paper version. */
const Glass = (() => {
  const NS = 'http://www.w3.org/2000/svg';
  let INK = '31, 48, 110';              // dark rims (r, g, b); Dr. Filler navy unless the page says otherwise
  let TINT = '45, 92, 200';             // shadows under glass
  let FROST = '248, 251, 255';          // the faint colour in the lower part of the frost
  let defs = null, uid = 0;

  function el(tag, attrs = {}, parent) {
    const e = document.createElementNS(NS, tag);
    for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v);
    if (parent) parent.appendChild(e);
    return e;
  }
  function getDefs() {
    if (defs) return defs;
    const s = el('svg', { width: 0, height: 0 });
    s.style.position = 'absolute';
    defs = el('defs', {}, s);
    document.body.prepend(s);
    return defs;
  }

  /* ---------- displacement maps (drawn on a canvas, used through feImage) ---------- */
  // R and G channels: horizontal / vertical displacement, 128 = none.
  function mapURL(w, h, fn) {
    w = Math.max(2, Math.round(w)); h = Math.max(2, Math.round(h));
    const c = document.createElement('canvas'); c.width = w; c.height = h;
    const x = c.getContext('2d'), d = x.createImageData(w, h);
    for (let j = 0; j < h; j++) for (let i = 0; i < w; i++) {
      const [dx, dy] = fn(i + .5, j + .5), k = 4 * (j * w + i);
      d.data[k] = 128 + 127 * dx; d.data[k + 1] = 128 + 127 * dy; d.data[k + 2] = 128; d.data[k + 3] = 255;
    }
    x.putImageData(d, 0, 0);
    return c.toDataURL();
  }
  // signed distance to a rounded rectangle (negative inside) and the outward normal
  function rrField(x, y, w, h, r) {
    const px = x - w / 2, py = y - h / 2;
    const qx = Math.abs(px) - (w / 2 - r), qy = Math.abs(py) - (h / 2 - r);
    const dist = Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) + Math.min(Math.max(qx, qy), 0) - r;
    let nx, ny;
    if (qx > 0 && qy > 0) { const l = Math.hypot(qx, qy); nx = qx / l; ny = qy / l; }
    else if (qx > qy) { nx = 1; ny = 0; } else { nx = 0; ny = 1; }
    return { dist, nx: nx * Math.sign(px || 1), ny: ny * Math.sign(py || 1) };
  }
  /* rim refraction: inside a band along the edge the backdrop is sampled further in,
     so what lies behind the rim is stretched and bent along it, like a thick glass edge */
  const rimFilter = (w, h, r, band, strength) => rimFilterAt(w, h, 0, 0, w, h, r, band, strength);
  /* lens: a round bead pulls the backdrop toward its centre (slight magnification) */
  function lensFilter(d) {
    const id = 'glLens' + (++uid), r = d / 2;
    const url = mapURL(d, d, (x, y) => {
      const dx = (x - r) / r, dy = (y - r) / r, q = Math.hypot(dx, dy);
      if (q > 1) return [0, 0];
      const s = 1 - .25 * q * q;          // a touch stronger at the centre than at the rim
      return [-dx * s, -dy * s];
    });
    const f = el('filter', { id, x: 0, y: 0, width: '100%', height: '100%', 'color-interpolation-filters': 'sRGB' }, getDefs());
    el('feImage', { href: url, x: 0, y: 0, width: d, height: d, preserveAspectRatio: 'none', result: 'm' }, f);
    el('feDisplacementMap', { in: 'SourceGraphic', in2: 'm', scale: d * .42, xChannelSelector: 'R', yChannelSelector: 'G', result: 'dm' }, f);
    el('feGaussianBlur', { in: 'dm', stdDeviation: .5 }, f);
    return id;
  }

  /* ---------- shared CSS ---------- */
  function on(o = {}) {
    if (o.ink) INK = o.ink;
    if (o.tint) TINT = o.tint;
    if (o.frost) FROST = o.frost;
    document.body.classList.add('glass');
    const st = document.createElement('style');
    st.textContent = `
      /* rectangular glass panel: frost + rim light; the size-dependent parts are set inline */
      .gl-panel { --frost: .62; background: linear-gradient(155deg, rgba(255,255,255,calc(var(--frost) + .12)), rgba(255,255,255,var(--frost)) 60%,
          rgba(${FROST},calc(var(--frost) + .06))) !important;
        isolation: isolate; }
      .gl-panel::before, .gl-rim::before {
        content: ""; position: absolute; inset: 0; border-radius: inherit; pointer-events: none; z-index: 5;
        padding: var(--rimw, 2px);
        background: linear-gradient(135deg, rgba(255,255,255,1) 0%, rgba(255,255,255,.75) 18%, rgba(255,255,255,.12) 42%,
          rgba(255,255,255,0) 58%, rgba(${INK},.10) 82%, rgba(${INK},.20) 100%);
        -webkit-mask: linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
        -webkit-mask-composite: xor; mask-composite: exclude;
      }
    `;
    document.head.appendChild(st);
  }

  /* opacity: how much white frost lies on the panel (more where something dark could lie behind) */
  function panel(e, r, k = 1, opacity = .62) {
    const w = e.offsetWidth, h = e.offsetHeight;
    const id = rimFilter(w, h, r, 26 * k, 34 * k);
    e.classList.add('gl-panel');
    e.style.setProperty('--frost', opacity);
    e.style.setProperty('--rimw', (2.2 * k) + 'px');
    e.style.backdropFilter = `blur(${11 * k}px) url(#${id}) saturate(1.7) brightness(1.05)`;
    e.style.boxShadow = [
      `inset 0 0 ${22 * k}px rgba(255,255,255,.55)`,                     // faint inner glow
      `inset 0 ${-1.5 * k}px ${3 * k}px rgba(${INK},.05)`,
      `0 ${40 * k}px ${64 * k}px ${-22 * k}px rgba(${TINT},.34)`,          // soft blue shadow: it floats
      `0 ${8 * k}px ${16 * k}px ${-4 * k}px rgba(${TINT},.16)`,
    ].join(', ');
    return e;
  }

  const rr = (x, y, w, h, r) =>
    `M${x + r} ${y} H${x + w - r} A${r} ${r} 0 0 1 ${x + w} ${y + r} V${y + h - r} A${r} ${r} 0 0 1 ${x + w - r} ${y + h}` +
    ` H${x + r} A${r} ${r} 0 0 1 ${x} ${y + h - r} V${y + r} A${r} ${r} 0 0 1 ${x + r} ${y} Z`;

  /* A glass speech bubble.
     o: { parent, box: [minX, minY, bw, bh] (page px), rect: [x, y, w, h, r] (page px),
          tail: path d in page px or null, inner: svg markup in page px (the sound bars), k: scale } */
  function bubble(o) {
    const [minX, minY, bw, bh] = o.box, [x, y, w, h, r] = o.rect, k = o.k || 1;
    const n = ++uid;
    const wrap = document.createElement('div');
    Object.assign(wrap.style, { position: 'absolute', left: minX + 'px', top: minY + 'px', width: bw + 'px', height: bh + 'px' });
    const vb = `${minX} ${minY} ${bw} ${bh}`;
    const rectD = rr(x, y, w, h, r);

    // 1. shadow outside the shape only (no grey under the glass)
    const sh = el('svg', { width: bw, height: bh, viewBox: vb, style: 'position:absolute; left:0; top:0; overflow:visible' });
    const sf = el('filter', { id: 'glBs' + n, x: '-50%', y: '-50%', width: '200%', height: '200%', 'color-interpolation-filters': 'sRGB' }, sh);
    el('feGaussianBlur', { in: 'SourceAlpha', stdDeviation: 13 * k, result: 'b1' }, sf);
    el('feOffset', { in: 'b1', dy: 14 * k, result: 'o1' }, sf);
    el('feFlood', { 'flood-color': `rgb(${TINT})`, 'flood-opacity': .26, result: 'c1' }, sf);
    el('feComposite', { in: 'c1', in2: 'o1', operator: 'in', result: 's1' }, sf);
    el('feGaussianBlur', { in: 'SourceAlpha', stdDeviation: 2.5 * k, result: 'b2' }, sf);
    el('feOffset', { in: 'b2', dy: 3 * k, result: 'o2' }, sf);
    el('feFlood', { 'flood-color': `rgb(${INK})`, 'flood-opacity': .12, result: 'c2' }, sf);
    el('feComposite', { in: 'c2', in2: 'o2', operator: 'in', result: 's2' }, sf);
    el('feMerge', { result: 'm' }, sf).append(el('feMergeNode', { in: 's1' }), el('feMergeNode', { in: 's2' }));
    el('feComposite', { in: 'm', in2: 'SourceAlpha', operator: 'out' }, sf);
    const sg = el('g', { filter: `url(#glBs${n})` }, sh);
    el('path', { d: rectD }, sg);
    if (o.tail) el('path', { d: o.tail, stroke: '#000', 'stroke-width': 6 * k, 'stroke-linejoin': 'round' }, sg);
    wrap.appendChild(sh);

    // 2. the frosted glass itself, clipped to rect ∪ tail
    const cs = el('svg', { width: 0, height: 0, style: 'position:absolute' });
    const cp = el('clipPath', { id: 'glBc' + n, clipPathUnits: 'userSpaceOnUse' }, cs);
    el('path', { d: rr(x - minX, y - minY, w, h, r) }, cp);
    if (o.tail) el('path', { d: o.tail, transform: `translate(${-minX} ${-minY})` }, cp);
    wrap.appendChild(cs);
    const fr = document.createElement('div');
    const rimId = rimFilterAt(bw, bh, x - minX, y - minY, w, h, r, 20 * k, 26 * k);
    Object.assign(fr.style, { position: 'absolute', left: 0, top: 0, width: bw + 'px', height: bh + 'px',
      clipPath: `url(#glBc${n})`,
      background: `linear-gradient(160deg, rgba(255,255,255,.62), rgba(255,255,255,.34) 62%, rgba(${FROST},.46))`,
      backdropFilter: `blur(${7 * k}px) url(#${rimId}) saturate(1.8) brightness(1.06)` });
    wrap.appendChild(fr);

    // 3. rim light, inner glow and the content, clipped to the shape
    const top = el('svg', { width: bw, height: bh, viewBox: vb, style: 'position:absolute; left:0; top:0; overflow:visible' });
    const d = el('defs', {}, top);
    const cp2 = el('clipPath', { id: 'glBu' + n }, d);
    el('path', { d: rectD }, cp2);
    if (o.tail) el('path', { d: o.tail }, cp2);
    const g = el('linearGradient', { id: 'glBg' + n, gradientUnits: 'userSpaceOnUse', x1: x, y1: y, x2: x + w, y2: y + h }, d);
    [[0, '#fff', 1], [.2, '#fff', .8], [.45, '#fff', .1], [.6, '#fff', 0], [.85, `rgb(${INK})`, .12], [1, `rgb(${INK})`, .22]]
      .forEach(([of, c, op]) => el('stop', { offset: of, 'stop-color': c, 'stop-opacity': op }, g));
    const mT = el('mask', { id: 'glBm' + n, maskUnits: 'userSpaceOnUse', x: minX, y: minY, width: bw, height: bh }, d);
    el('rect', { x: minX, y: minY, width: bw, height: bh, fill: '#fff' }, mT);
    if (o.tail) el('path', { d: o.tail, fill: '#000' }, mT);
    const mR = el('mask', { id: 'glBn' + n, maskUnits: 'userSpaceOnUse', x: minX, y: minY, width: bw, height: bh }, d);
    el('rect', { x: minX, y: minY, width: bw, height: bh, fill: '#fff' }, mR);
    el('path', { d: rectD, fill: '#000' }, mR);
    const gf = el('filter', { id: 'glBf' + n, x: '-20%', y: '-20%', width: '140%', height: '140%' }, d);
    el('feGaussianBlur', { stdDeviation: 5 * k }, gf);
    const cl = el('g', { 'clip-path': `url(#glBu${n})` }, top);
    // inner glow along the whole edge
    const glow = el('g', { filter: `url(#glBf${n})`, opacity: .7 }, cl);
    el('path', { d: rectD, fill: 'none', stroke: '#fff', 'stroke-width': 10 * k, mask: `url(#glBm${n})` }, glow);
    if (o.tail) el('path', { d: o.tail, fill: 'none', stroke: '#fff', 'stroke-width': 10 * k, mask: `url(#glBn${n})` }, glow);
    // the rim: bright upper-left, darker lower-right (only the outline of the union is stroked)
    el('path', { d: rectD, fill: 'none', stroke: `url(#glBg${n})`, 'stroke-width': 4.4 * k, mask: `url(#glBm${n})` }, cl);
    if (o.tail) el('path', { d: o.tail, fill: 'none', stroke: `url(#glBg${n})`, 'stroke-width': 4.4 * k, 'stroke-linejoin': 'round', mask: `url(#glBn${n})` }, cl);
    top.insertAdjacentHTML('beforeend', o.inner || '');
    wrap.appendChild(top);
    o.parent.appendChild(wrap);
    return wrap;
  }
  // a rim map for a rounded rect placed at (rx, ry) inside a bigger box (bw × bh)
  function rimFilterAt(bw, bh, rx, ry, w, h, r, band, strength) {
    const id = 'glRim' + (++uid);
    const url = mapURL(bw, bh, (x, y) => {
      const f = rrField(x - rx, y - ry, w, h, r), d = -f.dist;
      if (d > band || d < 0) return [0, 0];
      const s = Math.pow(1 - d / band, 2.2);
      return [-f.nx * s, -f.ny * s];
    });
    const f = el('filter', { id, x: 0, y: 0, width: '100%', height: '100%', 'color-interpolation-filters': 'sRGB' }, getDefs());
    el('feImage', { href: url, x: 0, y: 0, width: bw, height: bh, preserveAspectRatio: 'none', result: 'm' }, f);
    el('feDisplacementMap', { in: 'SourceGraphic', in2: 'm', scale: strength, xChannelSelector: 'R', yChannelSelector: 'G' }, f);
    return id;
  }

  /* ---------- medallion rims ----------
     The symbols draw a white disc (r 207) behind the portrait and a white ring (r 200, width 12).
     Here the ring becomes a glass rim: translucent, light from the upper left, a thin darker
     edge at the lower right, a highlight arc and a faint caustic opposite. */
  function medalRims(ids) {
    const d = getDefs();
    if (!document.getElementById('glRingFill')) {
      const g = el('linearGradient', { id: 'glRingFill', x1: 0, y1: 0, x2: 1, y2: 1 }, d);
      [[0, 1], [.45, .8], [1, .62]].forEach(([o, a]) => el('stop', { offset: o, 'stop-color': '#fff', 'stop-opacity': a }, g));
      const e = el('linearGradient', { id: 'glRingEdge', x1: 0, y1: 0, x2: 1, y2: 1 }, d);
      [[0, '#fff', .0], [.5, `rgb(${INK})`, .0], [1, `rgb(${INK})`, .30]].forEach(([o, c, a]) => el('stop', { offset: o, 'stop-color': c, 'stop-opacity': a }, e));
      const f = el('filter', { id: 'glArcSoft', x: '-20%', y: '-20%', width: '140%', height: '140%' }, d);
      el('feGaussianBlur', { stdDeviation: .6 }, f);
    }
    const arc = (r, a0, a1) => {
      const p = a => [200 + r * Math.cos(a * Math.PI / 180), 200 + r * Math.sin(a * Math.PI / 180)];
      const [x0, y0] = p(a0), [x1, y1] = p(a1);
      return `M${x0.toFixed(2)} ${y0.toFixed(2)} A${r} ${r} 0 0 1 ${x1.toFixed(2)} ${y1.toFixed(2)}`;
    };
    ids.forEach(id => {
      const s = document.getElementById(id);
      const back = s.querySelector(':scope > circle[r="207"]');
      const ring = s.querySelector(':scope > circle[stroke="#fff"]');
      back.setAttribute('fill', 'rgba(255,255,255,.30)');
      ring.setAttribute('stroke', 'url(#glRingFill)');
      const add = (tag, a) => el(tag, a, s);
      add('circle', { cx: 200, cy: 200, r: 206.6, fill: 'none', stroke: 'url(#glRingEdge)', 'stroke-width': 1.4 });
      add('circle', { cx: 200, cy: 200, r: 194.6, fill: 'none', stroke: 'rgba(255,255,255,.75)', 'stroke-width': 1.2 });
      add('path', { d: arc(202.5, 192, 262), fill: 'none', stroke: '#fff', 'stroke-width': 4.2, 'stroke-linecap': 'round', filter: 'url(#glArcSoft)' });
      add('path', { d: arc(202.5, 22, 58), fill: 'none', stroke: 'rgba(255,255,255,.55)', 'stroke-width': 2.4, 'stroke-linecap': 'round' });
    });
  }

  /* ---------- the wave as sheets of tinted glass ----------
     bands: [{ path: <path> element, edge: x => y of its upper edge }], x range [x0, x1], s = scale.
     For each band: a fine specular line on the upper edge, a soft light just inside it, a soft
     inner shadow a little lower; the upper bands are slightly translucent where they overlap. */
  function wave(svg, bands, x0, x1, s, step) {
    const d = svg.querySelector('defs') || el('defs', {}, svg);
    const fb = el('filter', { id: 'glWb' + (++uid), x: '-5%', y: '-50%', width: '110%', height: '200%' }, d);
    el('feGaussianBlur', { stdDeviation: 16 * s }, fb);
    const fs = el('filter', { id: 'glWs' + uid, x: '-5%', y: '-50%', width: '110%', height: '200%' }, d);
    el('feGaussianBlur', { stdDeviation: 7 * s }, fs);
    const fl = el('filter', { id: 'glWl' + uid, x: '-5%', y: '-50%', width: '110%', height: '200%' }, d);
    el('feGaussianBlur', { stdDeviation: .7 * s }, fl);
    bands.forEach((b, i) => {
      const pts = [];
      for (let x = x0; x <= x1 + step; x += step) pts.push(`${x.toFixed(1)} ${b.edge(x).toFixed(1)}`);
      const line = 'M' + pts.join(' L');
      const cp = el('clipPath', { id: `glWc${uid}_${i}` }, d);
      el('path', { d: b.path.getAttribute('d') }, cp);
      const g = el('g', { 'clip-path': `url(#glWc${uid}_${i})` });
      b.path.after(g);
      if (i > 0) b.path.setAttribute('fill-opacity', .9);
      el('path', { d: line, fill: 'none', stroke: '#fff', 'stroke-width': 70 * s, opacity: .26, filter: `url(#glWb${uid})` }, g);
      el('path', { d: line, transform: `translate(0 ${26 * s})`, fill: 'none', stroke: `rgb(${INK})`, 'stroke-width': 16 * s, opacity: .045, filter: `url(#glWs${uid})` }, g);
      el('path', { d: line, fill: 'none', stroke: '#fff', 'stroke-width': 6 * s, opacity: .9, filter: `url(#glWl${uid})` }, g);
    });
  }

  /* ---------- a clear glass bead (a small lens) ---------- */
  function bead(parent, x, y, d) {
    const e = document.createElement('div');
    const id = lensFilter(Math.round(d));
    Object.assign(e.style, {
      position: 'absolute', left: (x - d / 2) + 'px', top: (y - d / 2) + 'px', width: d + 'px', height: d + 'px',
      borderRadius: '50%',
      background: [
        `radial-gradient(circle at 31% 27%, rgba(255,255,255,.95) 0 ${d * .055}px, rgba(255,255,255,0) ${d * .16}px)`,   // specular point
        `radial-gradient(circle at 66% 76%, rgba(255,255,255,.55) 0, rgba(255,255,255,0) ${d * .26}px)`,                // caustic opposite
        'radial-gradient(circle at 50% 50%, rgba(255,255,255,.04) 55%, rgba(255,255,255,.22) 100%)',
      ].join(', '),
      backdropFilter: `url(#${id}) saturate(1.25) brightness(1.04)`,
      boxShadow: [
        `inset ${d * .06}px ${d * .08}px ${d * .05}px ${-d * .02}px rgba(255,255,255,.95)`,    // crescent, upper left
        `inset ${-d * .05}px ${-d * .07}px ${d * .12}px rgba(${TINT},.20)`,                    // lower-right body
        `0 0 0 ${Math.max(1, d * .012)}px rgba(255,255,255,.55)`,
        `0 ${d * .16}px ${d * .22}px ${-d * .06}px rgba(${TINT},.30)`,
      ].join(', '),
    });
    parent.appendChild(e);
    return e;
  }

  return { on, panel, bubble, medalRims, wave, bead };
})();
