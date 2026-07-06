# `core` and `mathex` Reference

`core` (host/registry/constants + helpers) and `mathex` (numeric helpers) are always in scope.
All members are dot-called functions/constants except `core:app_path()` (colon).
Dates are **OLE dates** = days since 1899-12-30.

## `core` constants

**Source / output types:** `core.Tick`, `core.Bar`, `core.Dot`, `core.Line`.
**Indicator placement (`indicator:type`):** `core.Indicator` (on price pane), `core.Oscillator` (separate pane), `core.View` (own chart).
**Strategy kind (`strategy:type`):** `core.Signal` (signals only), `core.Strategy` (trades only), `core.Both`.
**Update modes (the `mode` in `Update`):** `core.UpdateNew`, `core.UpdateLast` (most common), `core.UpdateAll`.
**Line styles:** `core.LINE_NONE/SOLID/DASH/DOT/DASHDOT`.
**Label alignment:** `core.H_Left/H_Center/H_Right`, `core.V_Top/V_Center/V_Bottom`.
**Label coord reference:** `core.CR_CHART/CR_LEFT/CR_RIGHT/CR_CENTER/CR_TOP/CR_BOTTOM`.
**Predefined colors:** `core.COLOR_LABEL/LINE/UPCANDLE/DOWNCANDLE/CUSTOMLEVEL/BACKGROUND`.
**Time zones (`convertTime`):** `core.TZ_EST/GMT/LOCAL/TS/SERVER/FINANCIAL`.
**Parameter flags:** see parameters-and-profile.md.
**Misc:** `core.ASYNC_REDRAW` (return from `AsyncOperationFinished` to force redraw).

## `core` functions — the ones that carry logic

### Cross / touch tests (ubiquitous in signals & strategies)
Signature `(stream1, stream2, period1, period2?)` → boolean. `stream2` may be a numeric level.
They inspect the **previous** bar too, so `period` must be `> stream:first()`.

| Function | True when stream1 … stream2 |
|---|---|
| `core.crossesOver(s1, s2, p)` | crosses **over** |
| `core.crossesUnder(s1, s2, p)` | crosses **under** |
| `core.crosses(s1, s2, p)` | crosses either way |
| `core.crossesOverOrTouch` / `core.crossesUnderOrTouch` | as above, incl. touching |
| `core.touches(s1, s2, p)` | touches |

### Range helpers
Return `{from=, to=}` tables consumed by `mathex` and drawing functions.
`core.range(from,to)`, `core.rangeTo(to,length)` (= last `length` bars ending at `to`),
`core.rangeFrom(from,length)`.

### Colors & dates
`core.rgb(r,g,b)` → color int. `core.colors()` → table of named colors (cache it).
`core.date(y,m,d)`, `core.datetime(y,mo,d,h,mi,s)`, `core.now()`.
`core.dateToTable(date)` → `{year,month,day,hour,min,sec,wday}` (wday 1=Sun).
`core.tableToDate(t)`, `core.formatDate(date)` → `DD/mm/yyyy hh:mm:ss`.
`core.getcandle(barSize, datetime, dayOffset, weekOffset)` → begin,end of the containing candle.
`core.isnontrading(datetime, dayOffset)` → boolean.

### Search / data
`core.findDate(stream, date, precise)` → period index or -1 (binary search).
`core.parseCsv(str, sep?)` → table (**0-based**), count.
`core.eraseStream(output, range)`; `core.drawLine(output, range, v1, pos1, v2, pos2, color?)` (fills an output stream with a straight line — this is data, unlike the host `drawLine` which is chart decoration).

### Objects / factories
`core.indicators` — the indicator registry (`:create`, `:find`/`:findIndicator`; see builtin-indicators.md).
`core.host` — the host application object (`:execute`, `:findTable`, trading; see strategies.md and host-and-drawing.md). May be `nil` if unsupported.
`core.valuemap()` — a key/value bag for trading/terminal requests.
`core.autoBuffer(stream, length, offset, updateFn)` — inline indicator-like buffer with `:update()` and `.DATA`.
`core:app_path()` — path to `lua5.1.dll` (colon-called; used to `dofile` platform includes).
`core.version()`, `core.requires(major, minor, exact?)`.

## `mathex` — numeric helpers

Range-statistics functions accept either `(stream, {from,to})` or `(stream, from, to)`; indexes
must be within `stream:first()..stream:size()-1`. These are the portable math behind many indicators:

| Function | Meaning |
|---|---|
| `sum`, `avg`, `geomean` | sum / mean / geometric mean over a range |
| `median_s`, `median_w` | median |
| `meandev`, `devsq`, `stdev` | mean deviation / sum of squared deviations / standard deviation |
| `lreg`, `lregSlope` | linear-regression endpoint value / slope |
| `lwma` | linear-weighted moving average |
| `kurt`, `skew` | kurtosis / skewness |
| `min`,`max` | value + position; also `min2`/`max2`/`minmax` |

Two-stream: `covar`, `correl` (both take `(s1, s2, from1, to1, from2, to2)`).
`regChannel(stream, from, to)` → a, b, dev, raff (center line `a*x+b`, x=1 at `from`).
Distributions: `gammaln, gammaDist, betaDist(+Inv), binomDist, chiDist, expDist, fDist(+Inv), normalDist, studentDist, weibullDist, poissonDist`.
Arrays/FFT (0-based, sizes power of 2): `makeArray(size)`, `fft`, `ifft`, `cfft`, `icfft`.

> Not present in this SDK version: `core.rgba`, `core.Timeframe`, `core.format`, `core.stdriver`.
