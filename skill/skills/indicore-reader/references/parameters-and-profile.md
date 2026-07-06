# Profile & Parameters API

This covers `Init()`: how an artifact declares its identity and its user-facing parameters.
The **parameters** API is shared verbatim between indicators (`indicator.parameters`) and
signals/strategies (`strategy.parameters`).

## The profile object (`indicator` or `strategy`, in `Init()`)

For indicators the global is `indicator`; for signals and strategies it is `strategy`.

| Method | Args | Purpose |
|---|---|---|
| `:name(name)` | string | Display name. |
| `:description(text)` | string | Description. |
| `indicator:requiredSource(type)` | `core.Bar` / `core.Tick` | Declares whether the input is bars or ticks. |
| `indicator:type(type)` | `core.Indicator` / `core.Oscillator` / `core.View` | Chart placement. `Indicator`=same area as price; `Oscillator`=separate subwindow; `View`=own chart. |
| `strategy:type(type)` | `core.Signal` | Marks a strategy profile as a **signal** (no trading). |
| `:setTag(name, value)` | string, string | Host hints. Common: `"NonOptimizableParameters"` (comma list of param ids), `"Version"`, `"group"`. |

`profile` is a separate global exposing the *current script's* identity at runtime:
`profile:id()` (uppercased filename without extension, e.g. `MyIndi.lua` → `"MYINDI"`) and
`profile:name()`. Widely used to build the display name: `profile:id().."("..source:name()..")"`.

## Declaring parameters (in `Init()`)

Parameters and groups render in creation order.

| Method | Args (exact order) |
|---|---|
| `addGroup(name)` | name |
| `addInteger(id, name, description, default [, min, max])` | min/max optional (supply both or neither) |
| `addDouble(id, name, description, default [, min, max])` | |
| `addBoolean(id, name, description, default)` | default is boolean |
| `addString(id, name, description, default)` | default is string |
| `addColor(id, name, description, default)` | default e.g. `core.rgb(0,255,0)` |
| `addFile(id, name, description, value)` | value = default file name |
| `addDate(id, name, description, value)` | value = OLE date double (see date flags) |
| `addIntegerAlternative(id, name, description, value)` | adds a dropdown choice to an existing integer param |
| `addStringAlternative(id, name, description, value)` | adds a dropdown choice to an existing string param |
| `setFlag(id, flag)` | changes a previously-created param's UI/behavior |

**Dropdowns:** an `addString`/`addInteger` followed by several `addStringAlternative`/
`addIntegerAlternative` calls with the same `id` = a combo box. The chosen value is read back
plainly (e.g. `instance.parameters.Method1` → `"EMA"`).

## Reading parameters back (runtime)

Two equivalent styles on `instance.parameters`:
```lua
local n = instance.parameters.SP              -- field form (auto-typed)
local n = instance.parameters:getInteger("SP")-- getter form
```
Getters: `getInteger`, `getDouble`, `getBoolean`, `getString`, `getColor`, `getFile`.

## FLAG_* values (with `setFlag`)

These mostly control the **editor UI** and rarely affect ported logic — but they tell you what
a parameter *means*, which matters for the port spec.

**String parameter → chooser:**
| Flag | Meaning of the value |
|---|---|
| `core.FLAG_INSTRUMENTS` | instrument name |
| `core.FLAG_PERIODS` / `FLAG_PERIODS_EDIT` | timeframe/bar-size code (e.g. `m5`); `_EDIT` allows custom like `m3` |
| `core.FLAG_BARPERIODS` / `_EDIT` | like above, no tick period |
| `core.FLAG_BIDASK` | bid/ask price type |
| `core.FLAG_ACCOUNT` | account id |
| `core.FLAG_ORDER` / `FLAG_TRADE` | order id / trade id |
| `core.FLAG_INDICATOR` / `FLAG_ONLYINDICATORS` / `FLAG_ONLYOSCILLATORS` | picks another indicator; read its params via `getCustomParameters()` |
| `core.FLAG_STRATEGY` | picks a signal |
| `core.FLAG_EMAIL` | email address |

**File parameter:** `core.FLAG_SOUND` → sound-file path.
**Integer parameter:** `core.FLAG_LINE_STYLE` / `core.FLAG_LEVEL_STYLE` → line-style chooser (value is `core.LINE_*`).
**Double (strategies):** `core.FLAG_PRICE` → default tracks live price.
**Boolean (strategies):** `core.FLAG_ALLOW_TRADE` → the "allow strategy to trade" master switch.
**Date:** `core.FLAG_DATE`, `FLAG_DATE_OR_NULL`, `FLAG_DATETIME`, `FLAG_DATETIME_OR_NULL`.

## Using another indicator's profile (nested creation via profile)

Besides `core.indicators:create(...)`, code sometimes discovers a profile and instantiates it:
```lua
local prof   = core.indicators:findIndicator("ALLIGATOR2")
local params = prof:parameters()
params:setInteger("JawN", instance.parameters.JawN)
local alligator = prof:createInstance(source, params)
local jaws = alligator:getStream(0)   -- or alligator.DATA / alligator.<id>
```
Profile getters: `:id()`, `:name()`, `:type()`, `:requiredSource()`, `:parameters()`, `:createInstance(source, params)`.

## Trading tables (referenced by strategies)

`core.host:findTable(name)` returns a `tradingtable` (`"accounts"`, `"offers"`, `"orders"`,
`"trades"`, `"closed trades"`, `"summary"`, `"messages"`). Iterate with `:enumerator()` →
`:next()`; look up with `:find(column, key)` / `:findAll(column, key)`; read a row via
`row.ColumnName` or `row:cell("Name")`. A `valuemap` (`core.valuemap()`) is a key/value bag
used to pass requests to the trading engine. Full detail in strategies.md.
