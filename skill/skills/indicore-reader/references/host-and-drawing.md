# Host, Drawing, Fonts & Alerts (mostly droppable plumbing)

`core.host:execute("command", ...)` is a catch-all bridge to the Trading Station / Marketscope
host. In indicators and signals it is used mainly for **chart decoration and notifications** —
things that have a target-platform equivalent or should simply be dropped when porting. It rarely
carries the study's actual math. Recognise these calls so you can classify them correctly in the
port spec rather than trying to reimplement them literally.

## Drawing on the chart

| Call | Meaning |
|---|---|
| `core.host:execute("drawLabel1", serial, date, xref, x, yref, y, halign, valign, font, color, text)` | Draw a text/glyph label at a chart coordinate. `xref`/`yref` are `core.CR_*`; `halign`/`valign` are `core.H_*`/`core.V_*`. Often used with a Wingdings font to draw arrows (`"\225"`, `"\226"`). |
| `core.host:execute("drawLabel", ...)` | Simpler label variant. |
| `core.host:execute("removeLabel", serial)` | Remove a previously drawn label (by bar serial). |
| `core.host:execute("drawLine", ...)` / `"removeLine"` | Free-floating line decoration (distinct from `core.drawLine`, which fills an *output stream* and IS data). |
| `core.host:execute("drawText"/"drawRectangle"/"drawTriangle"/...)` | Other shape decorations. |

## Fonts

| Call | Meaning |
|---|---|
| `font = core.host:execute("createFont", name, size, bold, italic)` | Create a font handle (e.g. `"Wingdings"`). |
| `core.host:execute("deleteFont", font)` | Release it — usually in `ReleaseInstance()`. |

## Dialogs / misc UI

| Call | Meaning |
|---|---|
| `core.host:execute("prompt", id, title, text)` | Pop up a message box. |
| `core.host:execute("addCommand", cookie, text, comment)` | Add a button to the alert dialog → `AsyncOperationFinished(cookie)`. |

## Time / trading-day helpers (these CAN matter)
`("convertTime", tzFrom, tzTo, date)`, `("getServerTime")`, `("getTradingDayOffset")`,
`("getTradingWeekOffset")` — used by time-window filters and candle math. If the study gates on a
trading session or converts to EST/financial time, this is part of its logic — port it. Zones are
`core.TZ_EST/GMT/LOCAL/TS/SERVER/FINANCIAL`.

## Alerts (`terminal`)
`terminal:alertMessage(instrument, price, message, time)`,
`terminal:alertSound(file, recurrent)`, `terminal:alertEmail(email, subject, text)`.
These are notifications — re-map to the target platform's alert mechanism, or drop.

## Porting rule of thumb
- **Drop / re-map:** all `drawLabel*`, `removeLabel`, `drawLine`(host), fonts, `prompt`,
  `addCommand`, sound/email alerts, and their associated parameters (colors, label size, sound
  file, email address).
- **Keep:** anything under time/trading-day helpers that participates in a **decision** (session
  filters, mandatory-closing times), and — for strategies — the trading commands in strategies.md.
- A study whose `Update` does nothing but draw arrows on crossovers is, once ported, just the
  crossover condition plus a target-native marker. Capture the condition; discard the drawing.
