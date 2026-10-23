#!/usr/bin/env python3
"""Assemble site/design.html from design.src.html + every site/screens/*.html fragment."""
import pathlib, re, html
site = pathlib.Path(__file__).resolve().parent.parent / 'site'
ORDER = ['onboard-1','onboard-2','onboard-3','onboard-4','onboard-5','home','home-empty','home-pinned','home-choral','home-greymoor','today','today-three',
 'all-bosses','all-bosses-waiting','boss-longpress','boss-new','boss-new-filled','boss-new-bottom','task-sheet','delete-chapter',
 'boss','boss-lower','boss-kneel','boss-empty','strike-result','task-actions','commit','extend','rule-of-three','split','boss-actions','leave-alert','defeat-confirm',
 'new-task','which-boss','bonfire','bonfire-filled','tomorrow-picker','bonfire-rested','reminder-invite','bonfire-checkin','bonfire-fallen',
 'away-summary','flask-choice','fallen','fallen-health','victory','relic','profile','profile-empty','settings','settings-biomes','day-starts','settings-moss']
frags = {p.stem: p.read_text() for p in (site / 'screens').glob('*.html')}
names = [n for n in ORDER if n in frags] + sorted(n for n in frags if n not in ORDER)
out, shots = [], []
for n in names:
    f = frags[n]
    shot = re.search(r'data-shot="([^"]+)"', f).group(1)
    title = re.search(r'data-title="([^"]+)"', f)
    title = title.group(1) if title else n
    shots.append(shot)
    out.append(f'''<article class="scr" data-mode="side" id="s-{n}"><header><h4>{html.escape(title)}</h4><code>screens/{n}.html · shot #{shot}</code></header>
<div class="ctl" role="group" aria-label="Compare mode"><button type="button" data-mode="side" aria-pressed="true">Side by side</button><button type="button" data-mode="swipe" aria-pressed="false">Swipe</button><button type="button" data-mode="blend" aria-pressed="false">Blend</button><input class="rng" type="range" min="0" max="100" value="50" aria-label="Wipe position" hidden></div>
<div class="pair"><div class="frame"><small>Rebuilt in CSS</small><div class="zoomer"><div class="inner">{f}</div><div class="over ov"><img src="img/{shot}.jpg" alt="Real screenshot overlay" loading="lazy"></div></div></div>
<div class="frame real-frame"><small>Simulator</small><div class="zoomer"><div class="inner"><img class="real" src="img/{shot}.jpg" alt="Real screenshot: {html.escape(title)}" loading="lazy"></div></div></div></div></article>''')
src = (site / 'design.src.html').read_text().replace('<!--SCREENS-->', '\n'.join(out))
(site / 'design.html').write_text(src)
(site / 'design_shots.txt').write_text('\n'.join(sorted(set(shots))))
print(len(names), 'screens:', ' '.join(names))
