# Built-in Indicator Catalog

When code does `core.indicators:create("NAME", source, ...)`, it's instantiating a **standard
library indicator**. To read the source correctly you must know two things per indicator: its
**constructor arguments** and its **output stream field names** (how results are read back).

```lua
local h = core.indicators:create("NAME", source, arg1, arg2, ...)
h:update(core.UpdateLast)               -- always update before reading, every pass
local v = h.FIELD[period]               -- read a result
```
- `source` is a price line (`src.close`, `src.median`, …), a bar collection, or another
  indicator's output stream (chaining, e.g. an EMA of an EMA).
- Trailing color/width/style args may follow the calc args; they don't affect values.
- Availability is often guarded: `assert(core.indicators:findIndicator("NAME") ~= nil, "...")`.

## The `.DATA` convention (critical)
**Every indicator's primary output stream is readable both by its own id and by the universal
alias `.DATA`.** So `ema.DATA` == `ema.EMA`. Multi-output indicators expose additional streams
**only** by their own ids (and `.DATA` = the first one). When a field name is unclear, open the
indicator's `.lua` and look at its `instance:addStream("ID", ...)` calls — the `ID` is the field.

## Moving averages (`source` = a price line)

| NAME | Calc args (defaults) | Output field(s) |
|---|---|---|
| `MVA` (Simple/SMA) | `N`=7 | `.DATA` / `.MVA` |
| `EMA` (Exponential) | `N`=10 | `.DATA` / `.EMA` |
| `LWMA` (Linear Weighted) | `N`=14 | `.DATA` / `.LWMA` |
| `WMA` (Weighted) | `N`=14 | `.DATA` / `.WMA` |  *(distinct from `LWMA` — see note)* |
| `SMMA` (Smoothed) | `N`=7 | `.DATA` / `.SMMA` |
| `TMA` (Triangular) | `N`=14 | `.DATA` / `.TMA` |
| `KAMA` (Kaufman Adaptive) | `N`=14 | `.DATA` / `.KAMA` |
| `VIDYA` | `P`=9 | `.DATA` / `.V` |

> **WMA vs LWMA — don't conflate them.** These are two *distinct* standard indicators. `LWMA` is
> the classic linear-weighted MA (weights 1,2,3,…,N). `WMA` is a separate indicator whose exact
> weighting is not implied by the name. When code selects `"WMA"` (common in method-dropdown
> strategies), do **not** silently map it to LWMA in a port — open the `WMA` indicator's `.lua` and
> read its weighting, or flag it as a dependency whose formula must be confirmed. Guessing here
> changes the computed values.

## Oscillators & momentum

| NAME | Calc args (defaults) | Output field(s) |
|---|---|---|
| `RSI` | `N`=14 | `.DATA` / `.RSI` |
| `MACD` | `SN`=12, `LN`=26, `IN`=9 | `.DATA`/`.MACD` (line), `.SIGNAL`, `.HISTOGRAM` |
| `Stochastic` | `K`=5, `SD`=3, `D`=3, `MVAT_K`="MVA", `MVAT_D`="MVA" | `.K` (=`.DATA`), `.D` |
| `CCI` | `N`=14 | `.DATA` / `.CCI` |
| `ROC` (Rate of Change) | `N`=14 | `.DATA` / `.ROC` |
| `RLW` (Williams %R) | `N`=14 | `.DATA` / `.RLW` |
| `CMO` (Chande Momentum) | `P`=9 | `.DATA` / `.CMO` |
| `OSC` (Momentum) | `M`=7, `N`=14 | `.DATA` / `.OSC` |
| `TSI` (True Strength) | `N`=7, `M`=14 | `.DATA` / `.TSI` |

## Bill Williams (`source` = bar collection)

| NAME | Calc args (defaults) | Output field(s) |
|---|---|---|
| `AO` (Awesome Oscillator) | `FM`=5, `SM`=35 | `.DATA` / `.AO` (a `core.Bar` stream; `:colorI(period)` for up/down color) |
| `AC` (Accelerator) | `FM`=5, `SM`=35, `M`=5 | `.DATA` / `.AC` (Bar stream) |

## Trend / strength / volatility / bands

| NAME | Calc args (defaults) | Output field(s) |
|---|---|---|
| `BB` (Bollinger Bands) | `N`=20, `Dev`=2.0 | `.TL` (upper, =`.DATA`), `.BL` (lower), `.AL` (middle) |
| `ATR` (Average True Range) | `N`=14 | `.DATA` / `.ATR` |
| `ADX` (Avg Directional Index) | `N`=14 | `.DATA` / `.ADX` |
| `DMI` (Directional Movement) | `N`=14 | `.DIP` (DI+, =`.DATA`), `.DIM` (DI−) |
| `SAR` (Parabolic SAR) | `Step`=0.02, `Max`=0.2 | `.UP`, `.DN` (Dot streams) |
| `AROON` | `N`=25 | `.UP`, `.DOWN` |
| `ICH` (Ichimoku) | `X`=9, `Y`=26, `Z`=52 | `.SL`=Tenkan, `.TL`=Kijun, `.CS`=Chikou, `.SA`=Senkou A, `.SB`=Senkou B (read by **id**) |

## Others present in the standard library
`ARSI, ASI, AD, CHO, CMF, OBV, MD, HA (Heikin-Ashi), Kagi, KRI, MAE (MA Envelope), OBOS, PPMA,
Regression, Renko_candles, SFK, SSD, TMACD, ZigZag, alligator, gator, fractal, pivot,
point_and_figure, EW/EWN/EWO (Elliott Wave)`. Same convention: primary via `.DATA`, extra
streams by their declared ids. Custom (non-standard) names like `"AROON OSCILLATOR"` refer to
another *custom* indicator that must be installed — read that indicator's file to learn its
outputs.

> Names are case- and spelling-sensitive as passed to `create`. A name you don't recognise is
> almost certainly a custom indicator; treat it as an external dependency in the port spec and,
> if its `.lua` is available, read it to capture its algorithm and outputs.
