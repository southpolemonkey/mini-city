# Mini-city engine notes

The engine lives inside each city's `index.html` (one file, Canvas 2D, no assets except Google Fonts). Start from `shanghai/index.html` (the build scripts splice new pieces into it). Look at the newer cities for ready-made pieces: `sydney/` (harbour, bridges, ferries, beach) `beijing/` (mega blocks, auto-cut roads, land slab, lakes, palaces) and `tehran/` (snowy mountain ridges with a hazy far peak, a cable car up the hills, a footbridge spanning a road, mosque domes/minarets/Persian arches and tile patterns, a roundabout with circling cars, GEN wrapping for street-edge trees). Find sections by their `/* ---------- name ---------- */` markers, not by line numbers.

## What to keep vs replace

| Section (marker) | Action |
|---|---|
| `<head>` / CSS / title card / controls | Keep. Change `<title>`, eyebrow coords, `h1` ("Little <span>City</span>"), first chapter text, `--bridge` accent colour (day + `body.night`), canvas `aria-label` |
| night system (`NIGHT_OVR`, `nightCol`, `light`, `lit`, `GLOW`) | Keep |
| `math + projection`, `palette`, `hand-drawn primitives` | Keep. Add city palettes in a separate section |
| `little things` (people, dogs, trees, cars, bus, cable car) | Keep |
| `city blocks` (`LAYOUT`, `LT`, `TOPCOL`, `house`, `drawHouse`, genHouses/Offices/Towers, wander, kite, picnic, tennis, playground) | Keep helpers; **replace** `LAYOUT`, `LT`, `TOPCOL` and the orientation comment |
| `<City> palettes + helpers`, `little activities`, `landmark drawings`, `block generators` (`GEN`) | **Replace** with the new city's. Shanghai's `slab()` (extruded cross-section towers), `sphere()`, `hipRoof()`, `dome()`, `pyramid()`, `cyl()` are good building blocks |
| block creation loop, `bbox`, `blockAt`, `drawBlock` | Keep (adjust bbox `zTop` for very tall blocks) |
| `static world` (bridges, elevated roads, skywalks, lamps, rails) | **Replace** with the city's |
| `moving traffic` (`ROADS`, `PEDROADS`, `mover`, people/taxis/buses/bikes/boats) | Keep the mechanism; **replace** road lists and city-specific vehicles |
| `ground` (`LANDS`, `WAVES`, `REFL`, `drawGround`) | **Replace** land rectangles and reflections |
| `sky layer` (gulls, flocks, clouds, `LABELS`) | **Replace** labels and flock positions |
| `camera` (`HOME`, `KEYS`, `CHAPTERS`, `CHAPTERS_NIGHT`) | **Replace** |
| glows, moon, paper overlay, `render`, `compass`, loop + controls | Keep. Change the localStorage key, the `compass()` direction (`dx,dy`), and the fit (`baseZoom = Math.min(W/…, H/…)`) for the map's size |

## Coordinates
- `P(x,y,z) = [(x-y)*32, (x+y)*16 - z]`: tile coords to world px. +x goes down-right on screen, +y goes down-left, z is pixels up.
- `RX=45.255, RY=22.627` are the screen radii of a 1-tile iso circle.
- Blocks are 3×3 tiles on a 4-tile pitch. Block `(i,j)` spans x `4i+1..4i+4`, y `4j+1..4j+4`, and roads run on the centre lines `x = 4k+.5`. A block's surface is `z=4`, so items sit at z 4.
- Choose the orientation so the hero skyline is far from the viewer (small x+y) and appears upper-centre. Write the orientation in a comment above `LAYOUT`, and set the compass so `N` points the right way. In Shanghai north is +y and east is −x.
- `R = rng(seed)` is the only randomness. `rr(a,b)` and `pick(arr)` use it. Never call `Math.random()`, or scrubbing and the loop stop being deterministic.

## Draw contracts
- **Block item** (static, drawn inside its block):
  - Shape: `{k, t0, ax, ay, az, draw(t,T)}`. `k` is the in-block sort key (usually `x+y`, plus half the footprint for buildings).
  - It pops in at `t0`.
  - `flat(b, t0, draw)` makes a ground decal that sorts first.
- **Block dyn:** `b.dyn.push({t0, upd(T){this.k=…}, draw(t,T)})`. These are animated things inside a block (people, laundry, dancers) and are sorted with that block's items.
- **World STATIC:** `{k, t0, bb:{x0,x1,y0,y1}, draw}`. Every block becomes one STATIC entry with `k = b.x+b.y+b.w`. Long structures (bridges, elevated roads, skywalks, rails) must be split into segments, each with its own key. See the pitfalls.
- **World DYN:** `mover({r, off, dir, s0, sp, t0, draw})` runs along a road in `ROADS`. A custom DYN object needs `upd(T)` to set `k`, `sx`, `sy` (screen pos for culling) and `dyn=1`.
- **Timing:** `t` is loop time (0–50) and `T` is unbounded time for motion.
  - Anything with `t0 > t` is hidden.
  - Blocks drop in over 0.9 s and items pop over 0.7 s.

## Night mode
- At night `ctx.fillStyle` / `strokeStyle` are routed through `nightCol` (moonlit indigo) unless `LIT` is set. Wrap anything that should *glow* in `lit(()=>…)` or use `litDot`.
- `light(x,y,size,kind,alpha)` queues an additive glow sprite. Kinds: 0 warm, 1 white, 2 red (aviation), 3 cyan, 4 lantern, 5 rose. It does nothing during the day, so you can call it unconditionally.
- Every landmark needs a night look: lit windows, a glowing facade or crown, lamps, red blinking tips on tall towers.
- Add water reflections for the brightest landmarks in `REFL`.
- Write `CHAPTERS_NIGHT` with the same count as `CHAPTERS`.
- The moon only shows in wide shots (zoom < 1.55).

## Camera and chapters
- `KEYS` entries are `[t, x, y, z, zoom]`, Catmull-Rom interpolated. Start and end on `HOME` (the loop must match), with the overview from about 46 s to 50 s.
- A close-up uses zoom 2–2.5. A mid shot of a tall skyline uses 1.4–1.8 and raises z to 80–120 so the tops stay in frame.
- Use about 9 `CHAPTERS` `[t, caption]`. Each landmark block's `LT` should be about 0.5–1 s *after* the camera starts arriving, so it builds on screen.
- `LABELS`: `[text, x, y, zLabelHeight, tAppear]`. Labels fade in when zoomed in (zoom > 0.45 scaled).

## Pitfalls (each of these cost time once)
1. **TDZ / undefined names in assembled pieces.** Declare `const STATIC=[],DYN=[]` together before anything pushes to them. After assembling, run a syntax check: extract the `<script>` and run `node --check`. Also confirm the shoot script reports no console errors.
2. **Long structures sorting wrong.** One sort key for a whole bridge or elevated road puts it on top of buildings everywhere, or under them. Split it into per-block segments, and key each segment just above the block it passes over (`blockAt(x,y).key + .02`). Shanghai's `elevKey`, `ringKey` and the two-part Nanpu bridge are the examples.
3. **Elevated things too flat to read.** Elevated roads need z ≥ 20, a thick side face (~4.5 px), and chunky pillars, or they read as painted lines.
4. **Stray labels** for things hidden behind towers look like floating text. Drop the label, or move it to where the thing is visible.
5. **Traffic on the wrong roads.** Exclude elevated and pedestrian-only roads from `ROADS` (cars); put pedestrian streets only in `PEDROADS`. Cars on elevated roads use `r.z` and `elevZ`.
6. **Fit.** Bigger maps need a smaller base zoom. Shanghai uses `fit=Math.min(W/2350, H/1420)` and, in portrait, `Math.max(fit, W/1650)`. Check the phone screenshot.
7. **Empty early lots are fine.** Blocks without an `LT` drop in at random in the first ~4.5 s. Landmark blocks wait for their chapter.
8. **Clouds look like white blobs in close-ups.** This is the same in every city, so accept it.
9. **Landmarks hiding each other.** Two things with the same `x−y` share a screen column, so a tall tower at larger `x+y` completely hides whatever sits behind it (Beijing's CITIC tower hid CCTV). Check the screen x, `(x−y)*32`, of every tall landmark and keep the blocks in front of a landmark low.
10. **Big landmarks need bigger blocks.** `beijing/` adds `MEGA={'i,j':[w,d]}`: the anchor cell's block spans several cells, the build patches the create loop (`w`/`d` from `MEGA`, `key = x+y+(w+d)/2`, `bbox` height from `ZTOP[type]`), and roads are cut automatically around mega blocks (`segs()`/`blocked()` in its world section). Long walls inside a mega block must be split into 0.5-tile segments with their own keys (`wallRing`).
11. **No sea?** `beijing/` replaces the water plane with a floating land slab and draws lakes as polygons inside blocks (`lake()`, `lakeBoat()`).
12. **Structures that span a road** (Tehran's Nature Bridge) are split into short segments: segments over a block are items of that block (so they sort with its trees), segments over the road are world STATIC with a key between the two blocks. Draw the people on the deck inside the segment's draw, so they sort with it.
13. **Edge trees along one avenue:** wrap the `GEN` functions after defining them (`GEN[k]=b=>{f(b);edgeTrees(b)}`) and have the generic generators leave a strip clear on that edge (`reg(b)` in `tehran/`). Adding items after the create loop doesn't work, because `b.items` is sorted once at creation.

## Verification checklist
- `node --check` passes, and the shoot script prints no console errors.
- Day frames at roughly every chapter time plus 2 s, and at 48 s (overview).
- Night frames at 3 chapter times plus the overview.
- A phone frame (390×844) at the overview.
- Every landmark from the prompt is visible and labelled in at least one chapter.
