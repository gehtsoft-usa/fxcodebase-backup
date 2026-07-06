# Reading Signals (alert generators)

A **signal** watches price/indicators and **emits alerts** (message / sound / email). It does
**not** trade. It is declared with `strategy:name(...)` (conceptually `core.Signal`), and its
tell-tale is the last line of the file:

```lua
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
```

That include pulls in the shared **Ext\*** framework (`helper.lua` → `helperAlert.lua`). The
author writes only `Init()`, `Prepare()`, and `ExtUpdate()`; the framework supplies `Update()`,
`AsyncOperationFinished()`, `ExtSubscribe()`, and the alert primitives.

## Lifecycle (who calls what)

```
Init()      -- YOU: strategy:name, params (Type Bid/Ask, Period timeframe, ShowAlert/PlaySound/
            --      SoundFile/SendEmail/Email); setTag NonOptimizableParameters
Prepare()   -- YOU: read instance.parameters; ExtSetupSignal(base, showAlert);
            --      source = ExtSubscribe(id, instrument, period, bid, kind);
            --      create sub-indicators; instance:name(...)
Update()    -- FRAMEWORK: detects a newly-closed bar, calls ExtUpdate(id, source, period)
ExtUpdate() -- YOU: ind:update(core.UpdateLast); test conditions; ExtSignal(...)
```

The framework chooses `period`:
- **tick** subscription → `stream:size()-1` (last tick)
- **bar** subscription → `stream:size()-2` (last **closed** candle — end-of-turn semantics)

## Framework functions

| Function | Signature | Role |
|---|---|---|
| `ExtSubscribe` | `(id, instrument, period, bid, kind)` → source | Subscribe to price data. `instrument`=name or `nil` (chart instrument); `period`=timeframe (`"m5"`,`"H1"`,`"t1"`); `bid`=boolean (often `Type=="Bid"`); `kind`=`"bar"` or `"open"/"high"/"low"/"close"`. |
| `ExtSubscribe1` | `(id, instrument, period, count, bid, kind)` | Same, bounded to `count` bars. |
| `ExtSetupSignal` | `(base, showAlert)` | `base` = message prefix (e.g. `profile:id()..":"`); `showAlert` master switch. |
| `ExtSetupSignalMail` | `(name, ...)` | Sets email text fragments. |
| `ExtSignal` | `(source, period, message, soundFile, email?, recurrentSound?)` | **Emit the signal.** Fires `terminal:alertMessage/alertSound/alertEmail`. If `source:isBar()` it uses `source.close`. |
| `ExtUpdate` | `(id, source, period)` | **YOU implement** — the per-bar logic. |

> Variation: some signals skip `ExtSignal` and define their own `ALERT(...)` calling
> `terminal:alertMessage/alertSound/alertEmail` directly, using `helper.lua` only for
> `ExtSubscribe`/`Update`/`ExtUpdate`. Both patterns are common and equivalent.

## Detecting events (idioms)
```lua
IND:update(core.UpdateLast)                        -- always recompute first
if IND.DATA:hasData(period) then ... end
core.crossesOver(streamA, valueOrStream, period)   -- rising cross (level or stream)
core.crossesUnder(streamA, valueOrStream, period)
value = IND.AO[period];  prev = IND.AO[period-1]
color = IND.AO:colorI(period)                      -- per-bar color of a Bar stream
```

## Worked example (Awesome Oscillator, zero-line cross)
```lua
function Prepare()
    Fast = instance.parameters.FP; Slow = instance.parameters.SP
    ExtSetupSignal("Awesome Oscillator", instance.parameters.ShowAlert)
    BarSource = ExtSubscribe(1, nil, instance.parameters.Period,
                             instance.parameters.Type == "Bid", "bar")
    AO = core.indicators:create("AO", BarSource, Fast, Slow)
end
function ExtUpdate(id, source, period)
    AO:update(core.UpdateLast)
    if AO.AO[period] > 0 and AO.AO[period-1] <= 0 then
        ExtSignal(BarSource.close, period, "Long", SoundFile)
    elseif AO.AO[period] < 0 and AO.AO[period-1] >= 0 then
        ExtSignal(BarSource.close, period, "Short", SoundFile)
    end
end
```

## What to keep vs drop when porting
- **Keep:** the subscription (which instrument/timeframe/price), the sub-indicators created, and
  the exact **trigger conditions** in `ExtUpdate` (crosses, thresholds, state flags like
  `Flag ~= "Buy"` to fire once per swing). This is the whole point of the signal.
- **Re-map:** `ExtSignal`/`ALERT` → the target platform's notification/alert mechanism.
- **Drop:** sound/email/`ShowAlert` params and `NonOptimizableParameters` tags — pure plumbing.
