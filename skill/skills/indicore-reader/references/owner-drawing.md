# Owner-Drawn Indicators & Multi-Timeframe Data

Dashboards, heatmaps, and "N-timeframe" studies use two features beyond the basic model:
**owner-drawn rendering** (custom graphics via a `Draw` callback) and **secondary data loading**
(pulling another timeframe/instrument). When porting these, the key move is to separate the
**computation** (portable) from the **rendering** (re-map or drop) and to capture **which**
secondary series are loaded and how they're aligned.

---

## Part A — Owner-drawn indicators

### Opt-in (in `Prepare()`)
- `instance:ownerDrawn(true)` — the host will call a global `Draw(stage, context)` on every repaint.
- `instance:drawOnMainChart(true)` — lets an oscillator (own sub-window) also paint on the main price
  area (adds `stage` 100/101/102 with a separate context).
- Output streams you render yourself are usually hidden with `stream:setVisible(false)`; many
  owner-drawn indicators declare no visible streams at all.

`core.OWNER_MAIN_AREA/ADDITIONAL_AREA/INTERNAL/UNKNOWN` are **return values** of
`core.host:execute("getIndicatorOwner", ...)` (where the indicator is placed) — not the opt-in.

### The `Draw(stage, context)` callback
Called on every repaint (scroll/zoom/resize/tick) — it is **hot; do no heavy math here**. The host
remembers nothing between calls. Everything is in **pixels**, so drawings track the chart.

Three calls per repaint for the indicator's own area: `stage 0` (after grid, bottom), `stage 1`
(after price + earlier indicators), `stage 2` (after this indicator's own streams, topmost). With
`drawOnMainChart`, `100/101/102` fire for the main area. Real code picks one stage and returns on
the rest (ADR: `if stage ~= 2 or day_value == nil then return end`; AO heatmap: `if stage ~= 0`).

**Update() vs Draw() separation (port this cleanly):** `Update(period, mode)` does the
**calculation** (fills streams/globals); `Draw` only **reads those values and paints**. Guard `Draw`
against not-yet-computed data. One-time font/pen setup is done lazily behind an `init` flag inside
`Draw` because the context only exists at draw time.

### The `context` drawing object (argument order matters)
Geometry (no args): `context:left()/top()/right()/bottom()`, `context:firstBar()/lastBar()`,
`context:minPrice()/maxPrice()`. No width/height — compute from the above.

Coordinate conversion:
| Method | → |
|---|---|
| `positionOfBar(index)` | `x(center), x1(left), x2(right)` |
| `positionOfDate(date)` | `x, x1, x2` |
| `indexOfBar(x)` / `priceOfPoint(y)` | index / price |
| `pointOfPrice(price)` | `visible, y` |
| `pointsToPixels(pt)` / `pixelsToPoints(px)` | size fonts |
| `startEnumeration()` + `nextBar()` → `index,x,x1,x2,c1,c2` | iterate visible bars |

GDI objects live in 64 slots (id 0..63); `-1` = null pen/brush.
```
createPen(id, style, width, color)          -- style context.SOLID/DOT/DASH/...
createSolidBrush(id, color)                 -- also createHatchBrush(id, style, color)
createFont(id, name, width, heightPx, styleFlags)   -- height is the 4th arg; style context.BOLD/ITALIC/...
measureText(font, text, style) -> w, h
drawText(font, text, color, bg(-1=transparent), x1,y1,x2,y2, style, transp?)  -- style context.LEFT/CENTER/VCENTER/SINGLELINE...
drawLine(pen, x1,y1, x2,y2, transp?)
drawRectangle(pen, brush, x1,y1, x2,y2, transp?)   -- also drawEllipse/Arc/Polygon/Polyline/Bezier/Gradient*
drawPicture(picture, x, y, transp?) / drawIcon(icon, x, y, transp?)
setClipRectangle(x1,y1,x2,y2) / resetClipRectangle()
context.tooltip(left, top, right, bottom, text)     -- note '.' divisor
```
`transp?` 0=opaque..255=invisible (semi-transparent is much slower). `ownerdraw_points` (from
`context:createPoints()`) is a 0-based `:add(x,y)`/`:get(i)`/`:size()` collection for poly/bezier.
`math2d.*` provides 2-D geometry helpers.

**Porting owner-draw:** capture *what values are shown* and the *color/threshold rules* (e.g. "cell
is red when AO<0 and falling"). The pixel plumbing (fonts, rectangles, coordinates) maps to the
target's drawing API or is dropped — it is never the study's logic.

---

## Part B — Secondary data (multi-timeframe / multi-instrument)

All three loaders are **asynchronous**: the call returns an initially-empty stream; completion
arrives via `AsyncOperationFinished`. Keep the returned stream in a **global** or it is garbage-collected.

### `getSyncHistory` — the standard indicator tool
```lua
stream = core.host:execute("getSyncHistory",
    instrument,    -- e.g. source:instrument()
    barSize,       -- "D1", "m5", "t1" (ticks) ...
    bidOrAsk,      -- bool, usually source:isBid()
    barsAtLeft,    -- extra bars kept before the source's first bar (0..300)
    cookieDone,    -- AsyncOperationFinished cookie when load/sync COMPLETES
    cookieStarted) -- cookie when it STARTS
```
The returned stream **ends at the same time as the main source** and starts `barsAtLeft` bars
earlier — the standard way to overlay a higher/lower timeframe or another instrument. Indicators
only (in strategies it degrades to `getHistory`). Max ~15000 bars / 5000 ticks.
Example (ADR): `getSyncHistory(source:instrument(), "D1", source:isBid(), 30, 1, 2)` = load 30+ D1
bars of the same instrument, cookie 1 on complete, 2 on start.

### `getHistory` / `getHistory1` (indicators *and* strategies)
```lua
stream = core.host:execute("getHistory",  cookie, instrument, barSize, from, to, bidOrAsk)
stream = core.host:execute("getHistory1", cookie, instrument, barSize, count, to, bidOrAsk)
```
`from=0` → ~300 bars before `to`; `to=0` → up to now and stay subscribed. Typical pattern: a
global `loading` flag; bail in `Update` while loading; set it in `AsyncOperationFinished` then
`instance:updateFrom(bookmark)`.

### Completion callback & redraw
```lua
function AsyncOperationFinished(cookie, success, message, message1, message2)
```
Branch on `cookie`. For `getSyncHistory` the *started* cookie means "don't read yet"; the *complete*
cookie means "data ready → `instance:updateFrom(0)`". **Return `core.ASYNC_REDRAW`** to force a
repaint (heatmaps do this so newly loaded slots appear). Timers: `("setTimer", cookie, seconds)` /
`("killTimer", id)` drive periodic refresh.

### Align by DATE, never by index (critical)
The secondary stream's bar index does **not** match the main source's. To line up:
```lua
local date   = source:date(period)
local candle = core.getcandle(TF, date, dayOffset, weekOffset)   -- normalize to TF candle start
local p      = core.findDate(secondaryStream, candle, false)     -- <0 if not present
if p >= 0 and secondaryStream:hasData(p) then v = secondaryStream.close[p] end
```
Offsets come from `getTradingDayOffset` / `getTradingWeekOffset`. Direct index math is valid only
*within* one stream (ADR iterates its own D1 stream by `NOW, NOW-1, …`).

### Multi-slot heatmap pattern
A helper like `Add(id, TF, Flag, Instrument)` generates per-slot params (`On{id}`, `TF{id}` with
`FLAG_PERIODS`, `Instrument{id}` with `FLAG_INSTRUMENTS`, MA lengths). An "Override" method can
rewrite each slot from the chart. For each active slot: one `getSyncHistory` stream with **unique
paired cookies**, an embedded indicator on it (`core.indicators:create("AO", slotStream, FM, SM)`),
and in `Draw` a grid of colored cells (rectangle per bar×slot) with the color chosen from the
slot's indicator value/slope at the date-aligned index. **Port spec should list each slot's
instrument/timeframe/indicator and the exact cell-color rule.**
