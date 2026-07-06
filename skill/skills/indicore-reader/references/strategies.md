# Reading Strategies (trading logic)

A **strategy** trades. It is declared with `strategy:name(...)` and (usually)
`strategy:type(core.Strategy)` or `core.Both`. Everything reaches the code through four globals:
`strategy` (profile, in `Init`), `instance` (runtime data/params), `terminal` (order execution +
alerts), and `core.host` (data tables, history, timers).

> There are **two eras** of strategy code. Recognising which one you're reading is the first
> step — see corpus-idioms.md. In short: **template-era** files define `CreateParameters`,
> `CreateEntryIndicators`, `CreateCustomActions`, `GoLong/GoShort`, `trading_logic` — the real
> entry/exit logic is the `IsPass` functions. **Raw-era** files do trading directly with
> `terminal:execute(...)` valuemaps inside `Update`/`ExtUpdate`.

## Profile (`Init()`)

| Call | Meaning |
|---|---|
| `strategy:name` / `:description` | identity |
| `strategy:type(t)` | `core.Signal` (alerts only), `core.Strategy` (trades only), `core.Both` |
| `strategy:setTag(name, value)` | host hints; common: `"Version"`, `"NonOptimizableParameters"` (comma list) |
| `strategy.parameters` | same parameters API as indicators (parameters-and-profile.md) |

Trading strategies almost always declare: an `AllowTrade` boolean flagged `core.FLAG_ALLOW_TRADE`,
an `Account` flagged `core.FLAG_ACCOUNT`, an `Amount` (lots), and stop/limit/trailing params.

## Lifecycle

| Function | When | Purpose |
|---|---|---|
| `Init()` | once at load | build profile + parameters. Globals set here are **not** visible later. |
| `Prepare(nameOnly)` | per applied instance | read params, resolve account & offer, subscribe to data, create indicators, `instance:name(...)`. If `nameOnly` return early; don't touch `terminal`. |
| `Update(period, mode)` | every tick | core logic (raw era). Strategies run on a live **tick** stream. |
| `ExtUpdate(id, source, period)` | per closed bar | core logic when `helper.lua` is included (template & many signals). |
| `AsyncOperationFinished(cookie, success, message, ...)` | async op result | trade result, history load, timer fire, button click — keyed by your integer `cookie`. For a successful order, `message` = order id. |
| `ReleaseInstance()` | before destroy | cleanup (killTimer, deleteFont). |

**helper.lua**: files ending with `dofile(core.app_path().."\\strategies\\standard\\include\\helper.lua")`
do **not** define `Update`; they define `ExtUpdate`/`ExtAsyncOperationFinished` and subscribe via
`ExtSubscribe(id, instrument, period, bid, kind)` → returns a price stream.
`instrument`=name or `nil` (applied instrument); `period`=timeframe code (`"m5"`, `"H1"`, `"t1"`);
`bid`=boolean; `kind`=`"bar"` (bar_stream) or `"open"/"high"/"low"/"close"` (tick_stream).

## `instance` at runtime

`instance.parameters.<NAME>` — parameter value.
`instance.bid` / `instance.ask` — tick streams of the applied instrument; latest = current price
(`instance.bid[instance.bid:size()-1]`). `instance.bid:instrument()` is the traded symbol.

## Reading trading tables

```lua
local tbl = core.host:findTable(id)   -- "accounts","offers","orders","trades","closed trades","summary","messages"
```
Tables change constantly — you **find** or **enumerate**, never index directly.

- `tbl:find(column, key)` → row or nil (fast, indexed columns only).
- `tbl:findAll(column, key)` → enumerator. `tbl:enumerator()` → all rows. `tbl:version()` bumps on add/remove.
- enumerator: `:next()` → row or nil, `:reset()`.
- row: `row.ColumnName` or `row:cell("Name")`; date cells are OLE dates.

Extremely common: get the offer id for the traded instrument
```lua
Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
```

**Key columns.** accounts: AccountID, Balance, Equity, UsableMargin, DayPL. offers: OfferID,
Instrument, Bid, Ask, PipCost, PointSize (pip size), Digits. trades (open positions): TradeID,
AccountID, OfferID, Lot, BS (`B`/`S`), Open, Close, Stop, Limit, PL, GrossPL, StopOrderID,
LimitOrderID, OpenOrderReqID. orders (pending): OrderID, OfferID, TradeID, BS, Type, FixStatus
(`W`=waiting…), Rate, Stop, Limit. closed trades: +Open/CloseTime, PL, GrossPL.

Count/detect open positions by enumerating `trades` filtered on `AccountID`, `OfferID`, `BS`.

## Non-trading host commands (`core.host:execute(...)`)

| Call | Purpose |
|---|---|
| `("getTradingProperty", name, instrument, account)` | e.g. `"baseUnitSize"` (contracts per lot → `Quantity = lots*baseUnitSize`), `"canCreateMarketClose"`, `"canCreateEntry"`, min/max quantity |
| `("isTableFilled", tableId)` | table loaded & safe to use — gate trading on this |
| `("getServerTime")` / `("convertTime", tzFrom, tzTo, date)` | server time / zone conversion |
| `("setTimer", cookie, seconds)` / `("killTimer", id)` | repeating timer → `AsyncOperationFinished(cookie)` |
| `("getHistory", cookie, instrument, barSize, from, to, bidOrAsk)` | async history load; `getHistory1` = fixed count |
| `("subscribeTradeEvents", cookie, table)` | change events for offers/orders/trades |
| `("stop")` | strategy stops itself |

## Executing orders — `terminal:execute(cookie, valuemap)`

All order commands go through `terminal:execute`. Build a request with `core.valuemap()`, set
fields, execute. Returns `success` (was it *sent*) and `msg` = request id (or error text). The
final server result arrives later in `AsyncOperationFinished(cookie, success, message)`.

`Command` values: `CreateOrder` (default), `EditOrder`, `DeleteOrder`, `CreateOCO`, `CreateOTO`,
contingency joins.

`OrderType` (with `CreateOrder`): `OM` true-market open · `O` open at rate · `CM` true-market
close · `C` close at rate · `LE` entry limit · `SE` entry stop · `L`/`S` limit/stop close orders.

**Open market (typical entry):**
```lua
local vm = core.valuemap()
vm.OrderType = "OM"
vm.OfferID   = Offer
vm.AcctID    = Account
vm.Quantity  = lots * baseUnitSize
vm.BuySell   = "B"                    -- or "S"
success, msg = terminal:execute(200, vm)
```
**Attach stop/limit** (add to the opening valuemap): `RateStop`/`RateLimit` (absolute), or pegged
`PegTypeStop="O"` (from open) / `"M"` (from market) with `PegPriceOffsetPipsStop`
(**negative for buy, positive for sell**) and `PegPriceOffsetPipsLimit` (opposite sign);
`TrailStepStop` (pips; `1` = dynamic trailing); `EntryLimitStop="Y"` for ELS on FIFO/US accounts.

**Close a trade:** `OrderType="CM"`, `OfferID`, `AcctID`, `TradeID`, `Quantity=row.Lot`,
`BuySell` = **opposite** of `row.BS`. **Netting close** (works under FIFO): `OrderType="CM"`,
`OfferID`, `AcctID`, `NetQtyFlag="Y"`, `BuySell` opposite of position side (no TradeID/Quantity).

**Cookie pattern:** pick a distinct integer per operation and branch on it in
`AsyncOperationFinished`. Gate trading with `isTableFilled`.

## Alerts
`terminal:alertMessage(instrument, price, message, time)`, `terminal:alertSound(file, recurrent)`,
`terminal:alertEmail(email, subject, text)`.

## What to keep vs drop when porting
- **Keep (the strategy's essence):** the entry/exit conditions (indicator crossovers, thresholds),
  amount/stop/limit/trailing *logic*, direction reversal, time-window filters, mandatory-closing.
- **Re-map to the target broker API:** `terminal:execute` valuemaps → the target's order calls;
  `findTable("trades"/"offers")` enumeration → the target's positions/quotes; `baseUnitSize`/pip
  math → the target's contract/point sizing.
- **Usually drop:** `isTableFilled`/`subscribeTradeEvents` plumbing, cookie bookkeeping, alert
  sound/email, the `AllowTrade`/`Account`/optimizer-tag scaffolding.
