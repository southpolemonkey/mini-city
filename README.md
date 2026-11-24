# Little Cities

Hand-drawn, isometric, 50-second animated maps of real cities. Each one builds itself block by block, takes a camera tour of the landmarks, and has a day and a night mode. Every city is a single self-contained HTML file (Canvas 2D, no build step, no assets).

**See them live:** https://mini-city.rongchenxuan.com/

San Francisco · Shanghai · Sydney · Beijing · Tehran

## Make your own city

The cities are built by [Claude Code](https://claude.com/claude-code) using the `mini-city` skill that ships in this repo (`.claude/skills/mini-city/`).

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

### Use the skill in another folder
Copy `.claude/skills/mini-city` into `~/.claude/skills/` so it's available everywhere. The scripts work on the current directory, so run Claude from a folder laid out like this repo (it needs `shanghai/index.html` as the engine and `index.html` as the home page).

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
.claude/skills/mini-city/  the skill: SKILL.md, engine notes, prompt template, scripts
```

Share what you build: open a pull request with your city folder, thumbnails, prompt and tile.

## License
MIT
