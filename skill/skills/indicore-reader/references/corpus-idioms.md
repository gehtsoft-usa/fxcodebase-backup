# Corpus Idioms — recognising real fxcodebase code

Real published studies vary widely in quality and style. This is a field guide to the shapes you
actually meet, with rough prevalence from the fxcodebase backup (≈5,760 indicator, ≈125 signal,
≈1,630 strategy `.lua` files).

## Indicator skeleton (canonical)

```lua
function Init()                       -- profile + parameters only
    indicator:name("...")
    indicator:requiredSource(core.Bar)   -- or core.Tick
    indicator:type(core.Oscillator)      -- or core.Indicator / core.View
    indicator.parameters:addInteger("N", "Period", "", 14)
    -- ... style params (color/width/style) ...
end

function Prepare(nameOnly)
    source = instance.source
    N = instance.parameters.N
    first = source:first() + N - 1        -- warm-up: first valid output index
    instance:name(profile:id().."("..source:name()..")")
    if nameOnly then return end            -- host only wanted the name
    OUT = instance:addStream("OUT", core.Line, name..".OUT", "OUT", color, first)
    -- create sub-indicators here: ema = core.indicators:create("EMA", source.close, N)
end

function Update(period, mode)
    -- sub:update(mode) then read sub.DATA[period]
    if period >= first then OUT[period] = ... end
end

function ReleaseInstance() end            -- optional: deleteFont etc.
function AsyncOperationFinished(cookie, success, message) end  -- optional
```

`instance:addStream` appears in ~4,440 indicator files — outputting streams is the essence of an
indicator. The `if nameOnly then return end` guard is near-universal: the host calls `Prepare`
with `nameOnly=true` just to obtain the instance's display name cheaply, so heavy wiring lives
**after** that line.

## Signal skeleton

`strategy:name(...)`, ends with `dofile(...helper.lua)`, defines `ExtUpdate`, calls
`ExtSubscribe`/`ExtSignal`. ~100 of ~125 signal files use the `helper.lua` framework. See
signals.md.

## Strategy eras (recognise before reading logic)

Prevalence in the ~1,630 strategy files:

| Signal in the code | ~files | Meaning |
|---|---|---|
| `terminal:execute(...)` | ~1,560 | does its own trading with valuemaps (direct-trading) |
| `dofile(...helper.lua)` | ~1,530 | uses the Ext* framework for subscription (`ExtSubscribe`/`ExtUpdate`) |
| `CreateCustomActions` / `trading_logic` | ~105–150 | **template-framework** era |

So the vast majority are **direct-trading**: they include `helper.lua` for data subscription and
then place/close orders themselves inside `ExtUpdate` (or `Update`) via `terminal:execute`
valuemaps and `findTable` enumeration. The **template-framework** era is a ~10% minority.

**Direct-trading shape:** logic in `ExtUpdate(id, source, period)` (or `Update(period, mode)`);
entry/exit decided inline (crossovers, thresholds, state flags); orders built with `core.valuemap()`
and sent with `terminal:execute(cookie, vm)`; positions found by enumerating `findTable("trades")`.
Recognise by hand-written `BUY()`/`SELL()`/`enter()`/`exit()`/`haveTrades()`/`tradesCount()` helpers.

**False-friend:** strategies **never** trade via `core.host:execute("trade", ...)` (0 files). Trading
is `terminal:execute(cookie, valuemap)` (direct era) or the fluent
`trading:MarketOrder(instr):SetSide():SetAmount():SetPipStop():Execute()` API (template era).

**Template-framework shape:** a large customization header of top-level locals (`STRATEGY_NAME`,
`STRATEGY_VERSION`, `HISTORY_PRELOAD_BARS`, `DISABLE_EXIT`, `ENFORCE_POSITION_CAP`, `EntryActions={}`,
`ExitActions={}`), then hooks `CreateParameters`, `CreateEntryIndicators(source)`,
`CreateExitIndicators`, `UpdateIndicators`, and **`CreateCustomActions`** which fills
`EntryActions`/`ExitActions`. Position sizing, stops/limits, breakeven, trailing, trading-window and
mandatory-close are delegated to `trading`/`trading_logic`/`signaler`/`breakeven` modules pulled in
by the same trailing `dofile(...helper.lua)`. **The actual strategy lives in the `IsPass` closures**, e.g.:
```lua
enterLongAction.IsPass = function (source, period, periodFromLast, data)
    return core.crossesOver(Indicator[1].DATA, Indicator[2].DATA, period)
end
enterLongAction.Execute = GoLong    -- (or GoShort under Direction="reverse")
```
Order placement, position management, time filters, and mandatory-closing are all handled by the
included template — treat that scaffolding as boilerplate and extract the `IsPass` conditions,
the indicators created in `CreateEntryIndicators`, and the direction toggle.

## Cross-cutting idioms

| Idiom | How it appears | Prevalence |
|---|---|---|
| Read params (field) | `instance.parameters.SP` | ubiquitous |
| Read params (getter) | `instance.parameters:getInteger("SP")` | common (esp. loops with `"P"..i`) |
| Create sub-indicator | `core.indicators:create("EMA", source.close, N)` then `.DATA[period]` | ubiquitous |
| Crossovers | `core.crossesOver/Under(a, b, period)` | ubiquitous in signals/strategies |
| Bar sub-streams | `source.close[period]`, `source.high[period]` | ubiquitous |
| Latest bar | `source[NOW]`, `source:date(NOW)`, `instance.bid[NOW]` — `NOW` = current/last period | ubiquitous (~2290 files) |
| Bar identity across calls | `source:serial(period)`, `source:date(period)` | common |
| Warm-up guard | `if period > first then` / `if period >= first` | ubiquitous |
| Drawing / fonts | `core.host:execute("drawLabel1"/"createFont"/"removeLabel", ...)` | common (arrows/labels) |
| Alerts | `terminal:alertMessage/alertSound/alertEmail` | common |
| Live vs End-of-Turn | `if Live ~= "Live" then period = period - 1 end` | common in alerting code |

## Quality caveats (so you read defensively)
- Code is often copy-pasted, with dead variables, inconsistent indentation, and unused params
  (colors/alerts declared but never meaningfully used). Don't assume every parameter matters —
  trace whether it actually feeds the computation.
- The same file may mix `instance.parameters.X` and `:getInteger("X")`.
- Comments and donation headers are boilerplate; ignore them.
- A `create("SOMENAME", ...)` for a name not in builtin-indicators.md is a **custom dependency** —
  flag it and, if its `.lua` is available, read it.
