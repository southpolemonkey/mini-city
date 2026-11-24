---
name: mini-city
description: Build a new "Little <City>" animation for the Little Cities site — a 50-second, hand-drawn, isometric Canvas 2D map of a real city that builds itself, with day/night modes, chapters and a camera tour — and add it as a tile on the home page. Use when the user asks to add, build or make another city (e.g. "/mini-city Tokyo", "do Tokyo", "add Paris to mini-city"), or to write the prompt for one.
---

# mini-city: add a city to Little Cities

The repo is a folder of self-contained HTML animations plus a home page of tiles. Run everything from the repo root:

```
<repo root>/
  index.html                          ← home page, one tile per city
  thumbs/<slug>-0.webp, <slug>-1.webp ← tile pictures (day, night)
  prompts/<slug>.txt                  ← the prompt each city was built from
  san-francisco/, sydney/, beijing/, tehran/ …
  shanghai/index.html                 ← the base engine: start from this
  .claude/skills/mini-city/           ← this skill (scripts/ and reference/)
```

- **Preview:** `python3 -m http.server 8000` in the repo root, then open `http://localhost:8000/<slug>/`. Each city is one static HTML file, so any static host (GitHub Pages, Netlify, Cloudflare Pages) can serve the folder as is.
- **Keep it local.** Build the city as files in the repo. Don't publish it anywhere (Artifacts, gists, hosting) unless the user asks.
- **Needs:** `python3`, `node` (syntax check) and a Chromium/Chrome for screenshots (`npx playwright install chromium`, or set `CHROME=/path/to/chrome`).
- Script paths below are relative to this skill's folder: `.claude/skills/mini-city/scripts/…`.

## Workflow

1. **Prompt.** If the user hasn't given one, write `prompts/<slug>.txt` from `reference/prompt-template.txt`. Fill in 12–15 landmarks and everyday scenes that make the city recognisable. `reference/example-prompt-shanghai.txt` is a finished example. Show it to the user only if they asked to see the prompt; otherwise go ahead.
2. **Plan the map** before writing any code:
   - Decide which way the viewer looks, so the signature skyline or landmark sits upper-centre.
   - Set the land/water rectangles and the block grid. Each block is 3×3 tiles on a 4-tile pitch, with block (i,j) at x=4i+1, y=4j+1.
   - Give each block a `GEN` type in `LAYOUT`, and give landmark blocks an `LT` time that matches their chapter.
   - Make the compass in `compass()` match the chosen orientation.
3. **Build `<slug>/index.html`.** Copy `shanghai/index.html`, then replace the city-specific sections listed in `reference/engine.md`. Leave the engine (projection, primitives, people, cars, night system, render loop, controls) alone.
   - **Write one file:** fine for a small city.
   - **Assemble from pieces:** for a big one, write the pieces in the scratchpad (head, layout, generators, world, ground/camera) and join them with a short Python script. That keeps each edit small.
   - Use a fresh seed in `rng(...)` and a fresh localStorage key (`'<abbr>-night'`).
4. **Verify** with `scripts/shoot.sh <slug> [times...]`. It runs a syntax check, writes day, night and phone screenshots to `/tmp/mini-city-shots/<slug>/` (set `OUT=` to change this, for example to the scratchpad), prints any console errors, and exits non-zero if there were any. With no times given it shoots every chapter.
   - Look at every image. Check that each chapter's camera key frames its landmark and that labels sit on the things they name.
   - Check for sort-order glitches: things drawn on top of buildings they should be behind.
   - Check that the night frames look lit rather than just dark.
   - Fix what you find, then shoot again.
5. **Add the tile:**
   - Run `scripts/thumbs.sh <slug>` to make the two thumbnails.
   - Run `scripts/add-tile.py <slug> "<Name>" "<coords>" "<one-line landmarks>"` to add the tile to the home page.
   - Shoot the home page (`scripts/shoot.sh home`) and look at it.
6. **Report** the link (`http://localhost:8000/<slug>/` locally, or the user's own site if they host one; add `?night=1` for night mode), what is in each chapter, and any known quirks.

## URL parameters every city supports
- `?t=<seconds>`: jump to a moment (used for screenshots).
- `?night=0|1`: force day or night.
- `?bare=1`: hide the title card and controls (used for thumbnails).

Read `reference/engine.md` before writing code. It covers the coordinate system, the item and dynamic-object contracts, the night-mode rules, the camera and chapters, and the mistakes that already cost time once.
