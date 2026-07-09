# Indicore Reader — a Claude skill for understanding fxcodebase Lua

This repository packages a single [Agent Skill](https://docs.claude.com/en/docs/claude-code/skills)
that teaches a coding agent to **read and understand FXCM / Gehtsoft Indicore Lua code** — the
custom indicators, signals, and strategies published on
[fxcodebase.com](https://fxcodebase.com) and run inside Trading Station / Marketscope — so it can
be **ported to another platform**.

> **Get the skill:** the source lives at
> **[github.com/gehtsoft-usa/fxcodebase-backup](https://github.com/gehtsoft-usa/fxcodebase-backup/tree/main/skill)**
> (this `skill/` folder). Clone or download it with:
>
> ```
> git clone https://github.com/gehtsoft-usa/fxcodebase-backup.git
> ```
>
> then see [INSTALL.md](INSTALL.md) for how to install and use it.

## Why this exists

Indicore's Lua dialect looks ordinary but has several semantics that quietly break naive ports:

- streams are indexed by bar `period` and often **don't start at index 0** (built-in warm-up),
- sub-indicator results are read through the **`.DATA` convention** after an explicit `:update()`,
- many scripts shift to the **last closed bar** ("End of Turn" vs "Live"),
- **signals** are built on a shared `helper.lua` **Ext\*** framework,
- **strategies** trade through **`valuemap`-based `terminal:execute`** calls and trading-table
  enumeration.

The skill bundles the entire Indicore SDK surface, distilled into offline reference files, so the
agent can interpret real code accurately **without** access to the original SDK documentation.

## What the skill produces

- **Default:** a platform-neutral **Port Specification** — identity, parameters (portable vs
  cosmetic), inputs/outputs, the algorithm in neutral pseudocode, the platform-specific parts to
  drop/re-map, and porting risks. Template: `skills/indicore-reader/assets/port-spec-template.md`.
- **On request:** the original Lua **annotated** with inline explanations.

## Strengths — and where it helps most

A frank note on value: **capable frontier models (Opus 4.8 and up) already read Indicore Lua
quite well.** On moderate indicators, a strong model with no skill produces a competent port on
its own. This skill is not trying to teach that model to read a moving average — it earns its keep
on the parts that are *non-obvious even to a strong model*, and it lifts *weaker/cheaper models*
up to the level of a strong one. We validated this with a two-round benchmark (with-skill vs.
no-skill, blind semantic-equivalence judging against hand-written references and the Lua source):

- **On a strong model (Opus 4.8) with moderate indicators:** roughly even. The skill adds
  precision on nuances (flagging cosmetic vs. computational parameters, naming the async
  data-load mechanism) but doesn't change the outcome much. Honest result: you don't strictly
  need it here.
- **On a weaker model (Sonnet) with hard cases:** decisive — with-skill won every case
  (avg semantic-equivalence ~88 vs. ~73), because the skill supplies knowledge the model lacks.

Concretely, the skill is strongest at:

- **Non-obvious execution semantics that silently corrupt a port.** The Ext signal framework
  evaluates the **last *closed* bar** (`size()-2`); without that, a port signals on the forming
  bar and repaints. In the benchmark this was the single largest correctness swing.
- **The specialized, less-documented API surface** — the **owner-draw `Draw`/`context`** model,
  **multi-timeframe `getSyncHistory`** with **date-based (not index-based) alignment**, the
  **`valuemap`/`terminal:execute` trading** layer, and the two strategy "eras". These are where a
  model working from memory guesses and gets it subtly wrong.
- **Separating portable logic from platform plumbing** — reliably telling the study's actual
  math/rules apart from drawing, alerts, and trading scaffolding, so the port carries the right
  parts and drops the rest.
- **Consistency and offline determinism.** Every invocation reasons from the same distilled,
  self-contained reference, so ports don't drift with the model's mood or training recency — and
  it works with no network and no access to the original SDK docs.
- **Catching source-level traps** the reference calls out explicitly: period indexing that starts
  above zero (warm-up), the `.DATA` convention, live-vs-end-of-turn shifts, chained MA-of-MA
  construction, and the WMA-vs-LWMA ambiguity. In testing, skill-guided ports (and careful
  unguided ones) even **out-performed a human reference** that had simplified a strategy's true
  entry logic to a plain moving-average cross.

Rule of thumb: **the harder the artifact and the cheaper the model, the more the skill is worth.**
On a top-tier model doing simple indicators it's a consistency aid; on signals, heatmaps,
multi-timeframe studies, and trading strategies — or on smaller models — it's the difference
between a faithful port and a plausible-but-wrong one.

## Contents

```
README.md                                  ← this file
INSTALL.md                                 ← how to install / use the skill
skills/
  indicore-reader/
    SKILL.md                               ← the skill (workflow + when to use)
    references/                            ← the distilled, self-contained SDK
      data-model.md                        ← streams, sources, instance, period indexing, .DATA
      parameters-and-profile.md            ← Init(): profile + parameter declaration API
      core-and-math.md                     ← core.* and mathex.* helpers and constants
      builtin-indicators.md                ← standard indicator catalog (args + output fields)
      signals.md                           ← the Ext* signal framework
      strategies.md                        ← trading API, valuemaps, the two strategy eras
      host-and-drawing.md                  ← drawing/fonts/alerts (mostly droppable plumbing)
      owner-drawing.md                     ← owner-drawn Draw/context + multi-timeframe getSyncHistory
      corpus-idioms.md                     ← field guide: real code shapes, eras, quality caveats
    assets/
      port-spec-template.md                ← the deliverable template
```

## Scope

The skill is about **understanding the source** (platform-neutral). It deliberately does not embed
mapping tables for specific targets (MT4/MT5, NinjaTrader, cTrader, Pine, …); it produces a neutral
spec you can then implement anywhere.

## License / attribution

The reference material is distilled from the FXCM Indicore SDK 3.2 developer documentation and from
publicly published fxcodebase.com studies. Indicore, Trading Station, and Marketscope are trademarks
of their respective owners.
