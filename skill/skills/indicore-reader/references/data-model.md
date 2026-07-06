# Indicore Data Model — Streams, Sources & Instance

The single most important thing to understand when reading Indicore code: **everything is a
stream indexed by bar `period`**, and streams may not start at index 0. Get this right and
most porting off-by-ones disappear.

## The `instance` object (available in `Prepare()` and `Update()`)

| Member | Access | Meaning |
|---|---|---|
| `instance.source` | field | The input stream. `bar_stream` if `indicator:requiredSource(core.Bar)`, else `tick_stream`. Not guaranteed to hold prices during `Prepare()`. |
| `instance.parameters` | field | User-chosen parameter values (see parameters-and-profile.md). |
| `instance.bid` / `instance.ask` | field | (Strategy/signal context) the bid/ask tick streams for the traded instrument. |
| `instance.DATA` | field | First output stream of a *nested* indicator instance. |
| `instance.<streamId>` | field | Any output stream of a nested indicator, by its id (e.g. `alligator.SL`). `DATA` == first stream. |

Reading parameters — two equivalent forms:
- Field form: `instance.parameters.N` (returns the value directly, typed by declaration).
- Typed getters: `instance.parameters:getInteger("N")`, `:getString`, `:getBoolean`, `:getDouble`, `:getColor`, `:getFile`.

### `instance` methods you'll see when building an indicator

| Method | Args (in order) | Purpose |
|---|---|---|
| `instance:name(name)` | name | **Set** the instance display name (no-arg form is the getter). |
| `instance:addStream(id, type, fullName, label, color, firstPeriod, extent?)` | see below | Add a visible output stream → returns writable `output_stream`. |
| `instance:addInternalStream(firstPeriod, extent?)` | firstPeriod, extent? | Add a hidden helper stream (not drawn). |
| `instance:update(flag)` | `core.UpdateNew`/`UpdateLast`/`UpdateAll` | Recalc a **nested** indicator before reading it. |
| `instance:getStream(index)` | 0-based | Output stream by index (nested indicator). |
| `instance:getStreamCount()` | — | Number of output streams. |
| `instance:createCandleGroup(label, id, open, high, low, close, volume?, barSize?, isBar?)` | | Group streams into candles/bars. |
| `instance:createChannelGroup(label, id, first, second, color, alpha, mode?)` | | Fill area between two streams. |
| `instance:createTextOutput(label, id, font, size, halign, valign, color, extent?)` | | Text-label output stream. |

**`addStream` argument detail (exact order):** `id` (unique alnum) · `type` (`core.Dot`/`core.Line`/`core.Bar`) · `fullName` (long name like `Id(Source,P1).Label`) · `label` (short name) · `color` (`core.rgb(...)`) · `firstPeriod` (first index that will have data, e.g. `source:first()+N-1`) · `extent` (optional size delta vs source).

## Stream objects

Inheritance: `tick_stream` (base) → `bar_stream`, `output_stream` → `output_stream_impl`.
All streams share the base read API below.

### Base read API (every stream)

Indexing: **`stream[period]`** returns the value at that period (same as `stream:tick(period)`).

| Method | Returns | Meaning |
|---|---|---|
| `:size()` | number | Period count. Valid indices are `first()` .. `size()-1`. |
| `:first()` | number | Index of the **first period with data**. May be `> 0` (e.g. MVA(7) → 7). Guard every read with `if period >= s:first()`. |
| `:tick(index)` | number | Value at period (same as `stream[index]`). |
| `:date(index)` | number | Date/time as an **OLE date** (days since 1899-12-30). Decode with `core.dateToTable`. |
| `:serial(index)` | number | Unique, permanent, never-reused id for that period. Use to identify a bar across `Update()` calls. |
| `:hasData(index)` | boolean | Whether the period holds data. |
| `:pipSize()` | number | Classic pip size (EUR/USD → 0.0001). |
| `:getPrecision()` | number | Digits after the decimal (EUR/USD → 5). |
| `:instrument()` | string | Instrument, e.g. `EUR/USD`. |
| `:barSize()` | string | Timeframe: `t1`, `m30`, `H1`, `D1`, `W1`, `M1`, `Y1` (letter+count). |
| `:isAlive()` | boolean | Subscribed to live updates. |
| `:isBar()` | boolean | true if a `bar_stream`. |
| `:isBid()` | boolean | true = bid prices. |

`size()-1` is always the newest period.

### `bar_stream` — a bar/quotes collection

Price sub-streams are **fields** (each is itself a `tick_stream`); index them per-period:
`source.close[period]`, `source.high[period]`, …

| Field | Value |
|---|---|
| `.open` `.high` `.low` `.close` | OHLC prices |
| `.volume` | volume (check `:supportsVolume()`) |
| `.median` | (high+low)/2 |
| `.typical` | (high+low+close)/3 |
| `.weighted` | (high+low+2·close)/4 |

Dates are **not** a field — use the method `source:date(period)`. `:getAll(index)` returns
open, high, low, close at once.

### `output_stream_impl` — your own output stream (write side)

Returned by `instance:addStream()`. Set values via `output[period] = value` (or `:set(index,value)`);
`= nil` clears the period.

| Method | Meaning |
|---|---|
| `:set(index, value)` | Set value (`nil` = no data). |
| `:setColor(index, color)` | Per-period color. |
| `:setStyle(style)` / `:setWidth(width)` / `:setPrecision(p)` | Line style / width / decimals. |
| `:addLevel(level, style?, width?, color?)` | Add a horizontal reference line. |
| `:setBookmark(id, period)` / `:getBookmark(id)` | Remember a period across `Update()` calls (survives index shifts). |

## The period-indexing model (critical for porting)

- **`period`** is an integer position. Valid range is `stream:first()` .. `stream:size()-1`;
  `size()-1` is the most recent bar.
- **`NOW`** is a global constant meaning the current/last period (equivalent to `size()-1`). It's
  very common: `source[NOW]`, `instance.bid[NOW]`, `source:date(NOW)`. Port it as "the latest bar".
- **`:first()` may be `> 0`.** A moving average of length N has no value for the first N bars,
  so its result stream's `:first()` returns ~N. Real code precomputes e.g.
  `first = source:first() + N - 1` and guards `if period > first then ...`. When porting,
  this is your **warm-up length**.
- **Indices are not stable across calls.** Bars can be prepended/dropped, so the same bar's
  numeric index can change between `Update()` invocations. Code that must remember a bar uses
  `:serial(period)` or bookmarks — not the raw index. Port this as a stable timestamp/id.
- **Nested indicator results use the `.DATA` convention.** After
  `ema = core.indicators:create("EMA", source.close, N)`, read `ema.DATA[period]`. You **must**
  call `ema:update(mode)` before reading it in each pass. Multi-stream indicators expose named
  streams (`macd.Value`, `bb.UP`, …) or `ema:getStream(i)`.

```lua
ema = core.indicators:create("EMA", source.close, N)   -- create in Prepare()
-- in Update(period, mode):
ema:update(mode)
if period >= ema.DATA:first() then
    out[period] = ema.DATA[period]
end
```
