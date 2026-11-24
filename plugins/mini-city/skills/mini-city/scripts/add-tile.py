#!/usr/bin/env python3
"""Add (or replace) a city tile on the mini-city home page.
usage: add-tile.py <slug> "<Name>" "<coords, e.g. 35.68° N 139.69° E>" "<one-line landmarks>"
Inserts before the "Your city next?" card. Re-running with the same slug replaces that tile."""
import html, os, re, sys
slug, name, coords, desc = sys.argv[1:5]
site = os.environ.get('SITE', os.getcwd())
p = os.path.join(site, 'index.html')
for f in (f'{slug}/index.html', f'thumbs/{slug}-0.webp', f'thumbs/{slug}-1.webp'):
    if not os.path.exists(os.path.join(site, f)): sys.exit(f'missing {f}')
e = html.escape
tile = f'''    <a class="tile" href="{slug}/" data-city>
      <div class="pic">
        <img class="d" src="thumbs/{slug}-0.webp" alt="Isometric illustration of {e(name)} by day">
        <img class="n" src="thumbs/{slug}-1.webp" alt="" aria-hidden="true">
        <span class="hint"></span>
      </div>
      <div class="body">
        <div class="row"><h2>{e(name)}</h2><span class="coord">{e(coords)}</span></div>
        <p class="desc">{e(desc)}</p>
        <span class="go">Open the city</span>
      </div>
    </a>

'''
s = open(p).read()
pat = re.compile(r'    <a class="tile" href="' + re.escape(slug) + r'/".*?</a>\n\n', re.S)
if pat.search(s):
    s = pat.sub(lambda m: tile, s, count=1); print('replaced tile', slug)
else:
    i = s.index('    <a class="soon"'); s = s[:i] + tile + s[i:]; print('added tile', slug)
open(p, 'w').write(s)
