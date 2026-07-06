---
name: indicore-reader
description: >-
  Read and fully understand FXCM/Gehtsoft Indicore Lua code — custom indicators, signals, and
  strategies (the kind published on fxcodebase.com and run in Trading Station / Marketscope) — in
  order to PORT them to another platform. Use this skill whenever you are handed a `.lua` file (or
  a snippet) that contains `Init()`/`Prepare()`/`Update()`, `indicator:name`/`strategy:name`,
  `instance.source`, `core.indicators:create`, `instance:addStream`, `ExtSubscribe`/`ExtSignal`,
  `terminal:execute`, or `dofile(... helper.lua)`, and the user asks to port, convert, translate,
  reimplement, explain, or "understand" an fxcodebase / Indicore / FXCM indicator, signal, or
  strategy. Trigger it even when the user only says "port this indicator" or "convert this Lua
  trading script" without naming Indicore — this SDK has non-obvious semantics (period indexing
  that starts above zero, the `.DATA` convention, live-vs-end-of-turn shifts, the Ext* signal
  framework, valuemap-based trading) that are easy to mis-port without this reference.
---

# Indicore Reader — understand fxcodebase Lua for porting

FXCM Indicore is the engine behind Trading Station / Marketscope custom studies. Its Lua dialect
looks simple but has several semantics that silently break naive ports. This skill teaches you to
read an indicator, signal, or strategy correctly and turn it into a **platform-neutral port
specification** (the default deliverable) — or, on request, an **annotated copy of the source**.

The bundled `references/` files are the whole SDK distilled; they are the source of truth **and
they are all you have** — assume the Indicore documentation is NOT available at runtime. Read the
reference that matches what you're looking at rather than guessing an API's behavior.

## Step 1 — Identify what you're reading

Three artifact types, distinguished by a few tells:

| Type | Declared in `Init()` | Key tells | Does it trade? |
|---|---|---|---|
| **Indicator** | `indicator:name(...)`, `indicator:type(core.Indicator/Oscillator/View)` | `instance:addStream(...)` to emit plottable streams; `Update(period, mode)` writes `out[period] = …` | No |
| **Signal** | `strategy:name(...)` | ends with `dofile(...helper.lua)`; defines `ExtUpdate`, calls `ExtSubscribe`/`ExtSignal`; emits alerts | No |
| **Strategy** | `strategy:name(...)`, often `strategy:type(core.Strategy/Both)` | opens/closes trades via `terminal:execute(cookie, valuemap)`; enumerates `trades`/`offers` tables | Yes |

Strategies come in **two eras** — detect which before reading the logic:
- **Template era** — defines `CreateParameters`, `CreateEntryIndicators`, `CreateCustomActions`,
  `GoLong`/`GoShort`, references `trading_logic`, and has a big customization header
  (`STRATEGY_NAME`, `HISTORY_PRELOAD_BARS`, `DISABLE_EXIT`, …). **The real entry/exit logic lives
  in the `IsPass` functions** inside `CreateCustomActions` (typically `core.crossesOver/Under`);
  the surrounding scaffolding is boilerplate provided by an included template.
- **Raw era** — plain `Init`/`Prepare`/`Update` doing trading directly with `terminal:execute`
  valuemaps and manual `findTable` enumeration.

## Step 2 — Read with the Indicore mental model

Whatever the type, anchor on the lifecycle and data model:

- **`Init()`** declares identity + parameters only. → parameters-and-profile.md
- **`Prepare(nameOnly)`** wires up runtime: reads `instance.parameters`, subscribes to the source,
  creates sub-indicators (`core.indicators:create`), adds output streams. The
  `if nameOnly then return end` early-out means "the host only wants the name" — the setup after
  it is the real wiring.
- **`Update(period, mode)`** is the per-bar calculation. `period` is a bar index; `mode` is
  `core.UpdateLast`/`New`/`All`.

The three semantics that most often break ports (internalize these):
1. **Streams don't start at index 0.** `stream:first()` can be `> 0` (a length-N average is invalid
   for the first ~N bars). Guards like `if period > first then` define the **warm-up length**. → data-model.md
2. **The `.DATA` convention.** A sub-indicator's primary output is `ind.DATA[period]`; you **must**
   `ind:update(mode)` before reading it each pass. Multi-output indicators use named streams
   (`bb.TL`, `macd.SIGNAL`). → builtin-indicators.md
3. **Live vs End-of-Turn.** Many scripts shift `period = period - 1` to act on the last *closed*
   bar. The Ext* signal framework does this for you (bar subscriptions evaluate `size()-2`).
   Get this shift right or every signal is off by one bar.

Also watch: bar indices are **not stable** across `Update` calls — code identifies bars by
`:serial(period)` or bookmarks, which you should port as a stable timestamp/id.

Two advanced shapes are common in dashboards, heatmaps, and multi-timeframe studies — recognise
them so you split *computation* from *rendering* correctly:
- **Owner-drawn** indicators call `instance:ownerDrawn(true)` and render from a `Draw(stage, context)`
  callback using a drawing `context` (fonts, text, rectangles, pixel coordinates) instead of (or on
  top of) output streams. The `Draw` code is presentation — port the *values* it displays and the
  *color/threshold rules*, not the pixel plumbing. → owner-drawing.md
- **Multi-timeframe / multi-instrument** studies load secondary data with
  `core.host:execute("getSyncHistory", ...)` (or async `getHistory`), then align the secondary
  series to the chart bars by date. This is the mechanism behind "3 TF …" averages and heatmap
  grids; capture *which* instrument/timeframe each series uses and how they're combined. → owner-drawing.md

## Step 3 — Consult the right reference

Read the file(s) relevant to what's in front of you — don't try to hold the whole SDK in your head:

- **references/data-model.md** — streams, sources, `instance`, period indexing, `.DATA`. *Read this for almost everything.*
- **references/parameters-and-profile.md** — `Init()`: profile + the full parameter-declaration API and flags.
- **references/core-and-math.md** — `core.*` (crosses, colors, dates, ranges, factories) and `mathex.*` numeric helpers.
- **references/builtin-indicators.md** — the standard indicator catalog: constructor args + output field names. *Essential for decoding `core.indicators:create`.*
- **references/signals.md** — the Ext* framework (`ExtSubscribe`/`ExtUpdate`/`ExtSignal`).
- **references/strategies.md** — trading: tables, `terminal:execute` valuemaps, order types, the two eras.
- **references/host-and-drawing.md** — `core.host:execute` drawing/fonts/alerts — mostly platform-specific plumbing to drop.
- **references/owner-drawing.md** — owner-drawn indicators (`Draw`/`context`) and multi-timeframe secondary data (`getSyncHistory`). *Read for dashboards, heatmaps, "N TF" studies.*
- **references/corpus-idioms.md** — field guide to real code shapes (skeletons, the two strategy eras, prevalence, quality caveats). *Read when unsure what you're looking at.*

## Step 4 — Produce the deliverable

**Default: a platform-neutral Port Specification.** Fill in `assets/port-spec-template.md`. The
goal is that someone who has never seen Indicore can reimplement the study from your spec alone.
Be rigorous about:
- **Parameters** — mark each as portable (affects the computed result) vs cosmetic/plumbing
  (colors, fonts, alert sound/email, account/optimizer scaffolding).
- **Algorithm** — express the per-bar computation as platform-neutral pseudocode. Translate
  Indicore idioms; don't transcribe them. State the warm-up length and any period shift explicitly.
- **Outputs** — streams (indicator), alert conditions (signal), or entry/exit/risk rules (strategy).
- **Platform-specific parts to drop or re-map** — drawing, alerts, live/end-of-turn toggles, and
  (for strategies) the whole Indicore trading-table + valuemap layer, which maps to the target
  broker API.
- **Porting risks** — off-by-ones from `first()`, `NOW`/period shifts, precision/pip assumptions,
  and any custom (non-standard) indicator dependency that must itself be ported.

**On request: annotated source.** If the user asks to "annotate"/"explain inline", return the
original Lua with concise comments mapping each construct to its meaning and its portable intent
(e.g. `-- warm-up: first valid bar = source.first()+N-1`). Keep the original code intact; add
comments only.

Verify field names and constructor signatures against the references before asserting them — a
wrong output-field name or argument order is the most common way a port goes subtly wrong. If a
called indicator name isn't in the catalog, it's a **custom dependency**: flag it, and read its
`.lua` if available.
