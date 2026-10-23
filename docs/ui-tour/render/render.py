#!/usr/bin/env python3
"""Render one screen fragment (site/screens/NAME.html) at 393x852 @2x with headless Chrome,
then build a side-by-side compare PNG next to the real simulator shot.
usage: render.py NAME [REAL_SHOT_BASENAME]   -> render/out/NAME.png and render/out/NAME_vs.html"""
import subprocess, sys, pathlib, html
root = pathlib.Path(__file__).resolve().parent.parent
site = root / 'site'
name = sys.argv[1]
frag = (site / 'screens' / f'{name}.html').read_text()
out = root / 'render' / 'out'; out.mkdir(exist_ok=True)
page = out / f'{name}.page.html'
page.write_text(f'''<!doctype html><meta charset="utf-8"><link rel="stylesheet" href="{site}/hearth.css">
<style>html,body{{margin:0;background:#000}}</style>{frag}
<script src="{site}/hearth.js"></script>''')
chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
png = out / f'{name}.png'
subprocess.run([chrome, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
    '--force-device-scale-factor=2', '--window-size=393,852', '--virtual-time-budget=1500',
    f'--screenshot={png}', page.as_uri()], check=True, capture_output=True)
if len(sys.argv) > 2:
    real = site / 'img' / f'{sys.argv[2]}.jpg'
    # side-by-side image at 1x via sips is not possible; write a tiny compare page and screenshot it
    cmp = out / f'{name}_vs.html'
    cmp.write_text(f'<!doctype html><style>body{{margin:0;display:flex;background:#333}}img{{width:393px;height:852px;display:block}}</style><img src="{png.as_uri()}"><img src="{real.as_uri()}">')
    vs = out / f'{name}_vs.png'
    subprocess.run([chrome, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
        '--force-device-scale-factor=1', '--window-size=786,852', '--virtual-time-budget=800',
        f'--screenshot={vs}', cmp.as_uri()], check=True, capture_output=True)
    print(vs)
else:
    print(png)
