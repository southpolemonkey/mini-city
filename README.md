# Little Cities

Hand-drawn, isometric, 50-second animated maps of real cities. Each one builds itself block by block, takes a camera tour of the landmarks, and has a day and a night mode. Every city is a single self-contained HTML file (Canvas 2D, no build step, no assets).

**See them live:** https://mini-city.rongchenxuan.com/

San Francisco · Shanghai · Sydney · Beijing · Tehran

## Make your own city

The cities are built by [Claude Code](https://claude.com/claude-code) using the `mini-city` skill. This repo is also a Claude Code plugin marketplace, so you can install the skill in one line.

### Option 1: install the plugin

Inside Claude Code:

```
/plugin install mini-city --marketplace southpolemonkey/mini-city
```

(On older Claude Code versions: `/plugin marketplace add southpolemonkey/mini-city`, then `/plugin install mini-city@little-cities`.)

Then, in any folder, ask for a city:

```
/mini-city Tokyo
```

The first time, it clones this repo as a `mini-city/` folder to get the engine and the home page, then builds your city there.

### Option 2: clone the repo

```bash
git clone https://github.com/southpolemonkey/mini-city.git
cd mini-city
claude
> /mini-city Tokyo
```

Claude writes a prompt for the city (`prompts/<city>.txt`), plans the map, builds `<city>/index.html` from the shared engine, screenshots every chapter to check its own work, then adds a tile for it to the home page.

To watch it locally:

```bash
python3 -m http.server 8000
# open http://localhost:8000/tokyo/
```

### Requirements
- [Claude Code](https://claude.com/claude-code)
- `python3` and `node`
- Chromium or Chrome for the screenshot checks: `npx playwright install chromium`, or set `CHROME=/path/to/chrome`


## URL parameters
- `?night=1` / `?night=0`: force night or day (or press **N**)
- `?t=<seconds>`: jump to a moment
- `?bare=1`: hide the title card and controls

## Layout
```
index.html                 home page with a tile per city
<city>/index.html          one city, one file
thumbs/<city>-0|1.webp     tile pictures (day, night)
prompts/<city>.txt         the prompt each city was built from
plugins/mini-city/         the plugin; the skill is in skills/mini-city/ (SKILL.md, engine notes, prompt template, scripts)
.claude-plugin/            marketplace manifest
```

Share what you build: open a pull request with your city folder, thumbnails, prompt and tile.

## License
MIT
