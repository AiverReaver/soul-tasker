#!/usr/bin/env python3
"""rects.py NAME -> prints rects (CSS px, 1 decimal) of leaf-ish elements in the rendered fragment."""
import subprocess, sys, pathlib, re, json
root = pathlib.Path(__file__).resolve().parent.parent
site = root/'site'; out = root/'render'/'out'
name = sys.argv[1]
frag = (site/'screens'/f'{name}.html').read_text()
page = out/f'{name}.rects.html'
page.write_text(f'''<!doctype html><meta charset="utf-8"><link rel="stylesheet" href="{site}/hearth.css"><style>html,body{{margin:0}}</style>{frag}
<script src="{site}/hearth.js"></script>
<script>setTimeout(()=>{{const r=[];document.querySelectorAll('.phone *').forEach(e=>{{if(e.closest('svg')||e.classList.contains('glint'))return;const t=[...e.childNodes].filter(n=>n.nodeType==3&&n.textContent.trim()).map(n=>n.textContent.trim()).join(' ');const c=e.className&&e.className.baseVal===undefined?e.className:'';if(!t&&!/(nf|seg|field|ember|task|glass|sheet|alert|thread|action-row|choice-row|fchip|uline|hold|shards|health|flasks)/.test(c))return;const b=e.getBoundingClientRect();r.push([e.tagName.toLowerCase()+'.'+c,t.slice(0,30),+b.left.toFixed(1),+b.top.toFixed(1),+b.right.toFixed(1),+b.bottom.toFixed(1)])}});const p=document.createElement('pre');p.id='o';p.textContent=JSON.stringify(r);document.body.append(p)}},600)</script>''')
chrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
d=subprocess.run([chrome,'--headless=new','--disable-gpu','--allow-file-access-from-files','--window-size=393,852','--virtual-time-budget=1500','--dump-dom',page.as_uri()],capture_output=True,text=True).stdout
m=re.search(r'<pre id="o">(.*?)</pre>',d,re.S)
import html
for r in json.loads(html.unescape(m.group(1))): print('%-28s %-30s x %6.1f-%6.1f  y %6.1f-%6.1f  (%dx%d)'%(r[0][:28],r[1],r[2],r[4],r[3],r[5],r[4]-r[2],r[5]-r[3]))
