#!/usr/bin/env python3
"""Compare two design versions' board sources, ignoring the noise every
version adds: the version in <title> and boards that were renamed.

usage: board_diff.py BASE_DIR NEW_DIR [Old=New ...] [--full]
  BASE_DIR, NEW_DIR  folders holding project/*.dc.html (as Artifact read saves them)
  Old=New            a board renamed between versions, e.g. Main=Home
  --full             print the unified diff of each changed board
"""
import difflib, pathlib, re, sys

args = [a for a in sys.argv[1:] if a != '--full']
full = '--full' in sys.argv
if len(args) < 2:
    sys.exit(__doc__)
base, new = (pathlib.Path(a) / 'project' for a in args[:2])
renames = dict(r.split('=', 1) for r in args[2:])
TITLE = re.compile(r'<title>Hearthrise[^<—]*—')


def norm(text):
    text = TITLE.sub('<title>Hearthrise —', text)
    for old, nu in renames.items():
        text = text.replace(f'{old}.dc.html', f'{nu}.dc.html')
    return text


def boards(d):
    return {p.name: p for p in d.glob('*.dc.html')}


b, n = boards(base), boards(new)
mapped = {renames.get(k[:-8], k[:-8]) + '.dc.html': v for k, v in b.items()}
same, changed = [], []
for name in sorted(set(mapped) & set(n)):
    x, y = norm(mapped[name].read_text()), norm(n[name].read_text())
    if x == y:
        same.append(name)
        continue
    changed.append(name)
    if full:
        sys.stdout.writelines(difflib.unified_diff(
            x.splitlines(True), y.splitlines(True), f'base/{name}', f'new/{name}', n=1))
print('removed:', ' '.join(sorted(set(mapped) - set(n))) or '-')
print('added:  ', ' '.join(sorted(set(n) - set(mapped))) or '-')
print('changed:', ' '.join(changed) or '-')
print('same:   ', len(same), 'boards')
