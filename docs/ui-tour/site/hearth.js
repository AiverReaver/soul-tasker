// Hearthrise drawings as SVG, same path data as app/lib/ui (stroke_icon.dart, nav_icon.dart,
// boss_art.dart, relic_emblem.dart, glass_surface.dart glint). Call Hearth.paint(root) after
// inserting markup. Placeholders:
//   <svg data-i="back|more|check|profile|settings|plus|flame|strike" data-s="22" data-w="1.6">
//   <svg data-nav="0..3">  <span data-boss="72">  <span data-emblem="48" data-nicks="0">
//   <div class="statusbar" data-time="9:41">   every .glass gets a glint automatically
(function () {
  const NS = 'http://www.w3.org/2000/svg';
  const ICONS = {
    back: 'M15 5 8 12l7 7',
    more: 'M5.2 10.4 7 12.2 5.2 14 3.4 12.2zM12 10.4l1.8 1.8L12 14l-1.8-1.8zM18.8 10.4l1.8 1.8-1.8 1.8-1.8-1.8z',
    check: 'M5 12.5 10 17.5 19 7',
    profile: 'M12 4 15 8 12 12 9 8zM5 20 8 15.5h8L19 20',
    settings: 'M4 8h16M4 16h16M9 6l2 2-2 2-2-2zM15 14l2 2-2 2-2-2z',
    plus: 'M12 5v14M5 12h14',
    flame: 'M12 2l5 8-2.6-.6L18 15l-6 7-6-7 3.6-5.6L7 10z',
    strike: 'M4 20 16 8M18.5 3 21 5.5 18.5 8 16 5.5z',
  };
  const NAV = [
    'M5 4 12 6 19 4 18 13 12 21 6 13zM9 11 11 12M15 11 13 12',
    'M4 20 16 8M18.5 3 21 5.5 18.5 8 16 5.5zM4 8h6v6',
    'M12 3 16 9 14 8.6 16.5 13 12 17 7.5 13 10 8.6 8 9zM4 21h16M7 18.5 17 21M17 18.5 7 21',
    'M12 3 19 10 12 21 5 10zM5 10h14M12 3v18',
  ];
  // boss_art.dart _drawing: [path, fill token, stroke token, width, alpha]
  const BOSS = [
    ['M150 176 174 26', null, 'ink', 6],
    ['M150 176 174 26', null, 'shard', 2.6],
    ['M174 28c12-12 18-22 12-28-8 8-16 14-18 30z', 'deep', 'ink', 2],
    ['M100 40c-30 10-42 50-48 90-4 20-12 35-18 42l16-6 8 8 12-10 12 12 12-10 12 10 12-11 12 10 12-10 8 8 16-1c-6-7-14-22-18-42-6-40-18-80-48-90z', 'raised', 'ink', 2.6],
    ['M76 92c-6 26-10 52-18 72M124 92c6 26 10 52 18 72', null, 'mote', 1.4, .3],
    ['M82 120c4 20 2 36-4 48M100 100c1 30 0 50 0 70M118 120c-4 20-2 36 4 48', null, 'ink', 1.6],
    ['M136 112c8-4 14-10 20-16l6 4', null, 'ink', 2.4],
    ['M84 34C76 20 66 12 54 10c10 8 16 18 20 32zM116 34c8-14 18-22 30-24-10 8-16 18-20 32z', 'bone', 'ink', 2.2],
    ['M100 26c-16 0-24 12-22 28 2 14 12 22 22 26 10-4 20-12 22-26 2-16-6-28-22-28z', 'bone', 'ink', 2.6],
    ['M90 46c-4 6-3 16 2 20 3-6 3-14-2-20zM110 46c4 6 3 16-2 20-3-6-3-14 2-20z', 'ink', null, 0],
  ];
  const el = (n, a) => { const e = document.createElementNS(NS, n); for (const k in a) e.setAttribute(k, a[k]); return e; };

  function icon(svg) {
    const name = svg.dataset.i, s = +(svg.dataset.s || 22), w = +(svg.dataset.w || 1.6);
    svg.setAttribute('viewBox', '0 0 24 24'); svg.setAttribute('width', s); svg.setAttribute('height', s);
    svg.classList.add('icon'); svg.style.strokeWidth = w;
    const p = el('path', { d: ICONS[name] });
    if (name === 'more' || svg.dataset.fill != null) { p.setAttribute('fill', 'currentColor'); }
    svg.replaceChildren(p);
  }
  function nav(svg) {
    svg.setAttribute('viewBox', '0 0 24 24'); svg.setAttribute('width', 22); svg.setAttribute('height', 22);
    svg.classList.add('icon'); svg.replaceChildren(el('path', { d: NAV[+svg.dataset.nav] }));
  }
  function boss(span) {
    const w = +span.dataset.boss; const svg = el('svg', { viewBox: '0 0 200 180', width: w, height: w * .9 });
    svg.style.display = 'block'; svg.style.overflow = 'visible';
    for (const [d, f, s, sw, a] of BOSS) {
      const p = el('path', { d, fill: f ? `var(--${f})` : 'none' });
      if (s) { p.setAttribute('stroke', `var(--${s})`); p.setAttribute('stroke-width', sw); p.setAttribute('stroke-linecap', 'round'); p.setAttribute('stroke-linejoin', 'round'); }
      if (a) p.setAttribute('opacity', a);
      svg.append(p);
    }
    span.style.display = 'block'; span.replaceChildren(svg);
  }
  function emblem(span) {
    const size = +span.dataset.emblem, n = +(span.dataset.nicks || 0), c = size / 2, r = size / 2 - 2, sw = size / 28;
    const svg = el('svg', { viewBox: `0 0 ${size} ${size}`, width: size, height: size }); svg.style.display = 'block';
    svg.append(el('circle', { cx: c, cy: c, r, fill: 'none', stroke: 'var(--text)', 'stroke-width': sw }));
    const d = r * .62;
    svg.append(el('path', { d: `M${c} ${c - d}L${c + d} ${c}L${c} ${c + d}L${c - d} ${c}Z`, fill: 'none', stroke: 'color-mix(in srgb, var(--text) 80%, transparent)', 'stroke-width': sw }));
    svg.append(el('circle', { cx: c, cy: c, r: r * .14, fill: 'var(--silk)' }));
    for (let i = 0; i < n; i++) {
      const a = i * 2 * Math.PI / n + i * .35, r0 = r * (.78 + .1 * (i % 3)), r1 = r + 2;
      svg.append(el('line', { x1: c + Math.cos(a) * r0, y1: c + Math.sin(a) * r0, x2: c + Math.cos(a) * r1, y2: c + Math.sin(a) * r1, stroke: 'var(--void)', 'stroke-width': size / 40, 'stroke-linecap': 'round' }));
    }
    span.style.display = 'block'; span.replaceChildren(svg);
  }
  function glint(g) {
    if (g.querySelector(':scope > .glint') || g.classList.contains('flat') || g.dataset.noglint != null) return;
    const r = g.getBoundingClientRect();
    const box = +(g.dataset.glint || Math.min(r.width, r.height, 88)); if (!box) return;
    const unit = box / 100, ink = 3 + box * .04, k = 1 / unit;
    const svg = el('svg', { class: 'glint', viewBox: '0 0 100 100', width: box, height: box });
    const arc = 'M14.3 37A38 38 0 0 1 37 14.3';
    svg.append(el('path', { d: arc, fill: 'none', stroke: 'var(--glassKey)', 'stroke-width': ink * k, 'stroke-linecap': 'round' }));
    svg.append(el('path', { d: arc, fill: 'none', stroke: '#FFF8EC', 'stroke-width': ink * .6 * k, 'stroke-linecap': 'round' }));
    svg.append(el('circle', { cx: 53.3, cy: 12.1, r: ink * .65 * k, fill: 'var(--glassKey)' }));
    svg.append(el('circle', { cx: 53.3, cy: 12.1, r: ink * .45 * k, fill: '#FFF8EC' }));
    g.prepend(svg);
  }
  function statusbar(sb) {
    if (sb.childElementCount) return;
    sb.innerHTML = `<span class="time">${sb.dataset.time || '9:41'}</span>${sb.dataset.noisland != null ? '' : '<i class="island"></i>'}
      <span class="icons"><svg width="18" height="4" viewBox="0 0 18 4"><g fill="currentColor" opacity=".45"><circle cx="2" cy="2" r="1.7"/><circle cx="6.6" cy="2" r="1.7"/><circle cx="11.2" cy="2" r="1.7"/><circle cx="15.8" cy="2" r="1.7"/></g></svg>
      <svg width="16" height="12" viewBox="0 0 16 12"><path fill="currentColor" d="M8 2.2c2.3 0 4.4.9 6 2.4l1.2-1.3A10.4 10.4 0 0 0 8 .4C5.2.4 2.7 1.5.8 3.3L2 4.6a8.6 8.6 0 0 1 6-2.4Zm0 3.6c1.3 0 2.5.5 3.4 1.3l1.2-1.3A6.7 6.7 0 0 0 8 4c-1.8 0-3.4.7-4.6 1.8l1.2 1.3c.9-.8 2.1-1.3 3.4-1.3Zm0 3.6c-.5 0-1 .2-1.3.5L8 11.6l1.3-1.7c-.3-.3-.8-.5-1.3-.5Z"/></svg>
      <svg width="27" height="13" viewBox="0 0 27 13"><rect x=".5" y=".5" width="23" height="12" rx="3.8" fill="none" stroke="currentColor" opacity=".35"/><rect x="2" y="2" width="20" height="9" rx="2.5" fill="currentColor"/><path d="M25 4.5v4c.8-.3 1.3-1.1 1.3-2s-.5-1.7-1.3-2Z" fill="currentColor" opacity=".4"/></svg></span>`;
  }
  function paint(root = document) {
    root.querySelectorAll('svg[data-i]').forEach(icon);
    root.querySelectorAll('svg[data-nav]').forEach(nav);
    root.querySelectorAll('[data-boss]').forEach(boss);
    root.querySelectorAll('[data-emblem]').forEach(emblem);
    root.querySelectorAll('.statusbar').forEach(statusbar);
    requestAnimationFrame(() => root.querySelectorAll('.glass').forEach(glint));
  }
  window.Hearth = { paint, ICONS, NAV };
  document.addEventListener('DOMContentLoaded', () => paint());
})();
