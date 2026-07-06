# Port Specification — {ARTIFACT NAME}

> Platform-neutral description of an FXCM Indicore Lua {indicator | signal | strategy},
> produced for porting to another platform. Everything below is expressed independently
> of the Indicore/Trading Station runtime so it can be re-implemented anywhere.

## 1. Identity
- **Name (shown to user):** {indicator:name / strategy:name}
- **Artifact type:** {Indicator | Signal | Strategy (raw) | Strategy (template)}
- **Category / display:** {Oscillator | overlay on price | subwindow | trading}
- **Required source:** {tick / bar; single timeframe or multi-timeframe}
- **Source file(s):** {path(s)}
- **One-line purpose:** {what it computes / when it signals / how it trades}

## 2. Inputs (parameters)
One row per user parameter. `Portable?` = whether the parameter affects the computed
result (yes) or only affects platform plumbing like colors/alerts/fonts (no).

| ID | Type | Default | Range | Meaning | Portable? |
|----|------|---------|-------|---------|-----------|
| {SP} | integer | 14 | 2..1000 | Short MA period | yes |
| {color1} | color | green | — | Line color | no (cosmetic) |

## 3. Data consumed
- **Price series used:** {close / open / high / low / median / typical / weighted / bid / ask}
- **Sub-indicators created:** {e.g. EMA(source, SP) → EMA.DATA; EMA(source, LP) → EMA.DATA}
- **External / secondary timeframes or instruments:** {none | describe}
- **Warm-up / first valid period:** {how many bars before output is valid — from :first() logic}

## 4. Outputs
### Indicators / signals
- **Streams produced:** {name, type (line/histogram/dot), meaning}
- **Signals emitted:** {condition → Buy/Sell/alert}

### Strategies
- **Entry rules:** {precise condition → open long / open short}
- **Exit rules:** {precise condition → close}
- **Order/risk handling:** {market vs entry order, stop, limit, trailing, amount, position cap}

## 5. Algorithm (platform-neutral pseudocode)
Describe the per-bar computation as it would run on any platform. Use array indexing by
bar; state which values come from prior bars. Do NOT copy Lua idioms verbatim — translate
them (see the porting notes for period/`NOW`/`mode` semantics).

```
for each bar p (once enough history exists):
    macd[p] = EMA_short[p] - EMA_long[p]
    if macd[p] crosses over signal[p]: emit Buy
    ...
```

## 6. Platform-specific parts to drop or re-map
List everything that is Indicore/Trading-Station-specific and should NOT be ported literally
— it either has a target-platform equivalent or should be omitted:
- Drawing: {drawLabel / drawLine / createFont / removeLabel …}
- Alerts: {terminal:alertMessage / alertSound / alertEmail, email/sound params}
- "Live vs End of Turn" execution toggles and the `period-1` shift they imply
- Trading plumbing tied to Indicore tables (accounts/offers/trades enumeration)
- Any `core.host:execute(...)` UI/host calls

## 7. Porting risks & notes
- {off-by-one from :first() / warm-up}
- {NOW vs explicit period}
- {end-of-turn vs live shift}
- {rounding / precision / pip size assumptions}
- {anything ambiguous the porter must verify against a reference run}
