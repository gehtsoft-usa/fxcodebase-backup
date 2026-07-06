-- Id: 12584
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=61223

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-----------------------------------------------------------
-- Sells when ExtremeUpper Line  crossesOver KeltnerUpper Line  and Open Positions are < Multiple Positions Limit.
--Buys when ExtremeLower Line crossesUnder KeltnerLower Line and Open Positions are < Multiple Positions Limit.
-- Author: ScottFree

-----------------------------------------------------------

local _gSubscription = {}
local _gUpdatePeriods = {}
local _gLastTime

-----------------------------------------------------------
-- Standard strategy init handler for marketscope strategy
-----------------------------------------------------------
function Init()
    strategy:name("Extreme_Keltner_Strategy")
    strategy:description(
        "Sells when ExtremeUpper Line  crossesOver KeltnerUpper Line  and Open Positions are < Multiple Positions Limit.   Buys when ExtremeLower Line crossesUnder KeltnerLower Line and Open Positions are < Multiple Positions Limit."
    )
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy:type(core.Both)

    strategy.parameters:addString("Account", "Account", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addBoolean("AllowTrade", "Allow trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString(
        "AllowedSide",
        "Allowed side",
        "Allowed side for trading or signaling, can be Sell, Buy or Both",
        "Both"
    )
    strategy.parameters:addStringAlternative("AllowedSide", "Both", "", "Both")
    strategy.parameters:addStringAlternative("AllowedSide", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("AllowedSide", "Sell", "", "Sell")
    strategy.parameters:addBoolean("AllowMultiplePositions", "Allow multiple positions", "", true)
    strategy.parameters:addString("Timeframe", "Timeframe", "The used timeframe", "m1")
    strategy.parameters:setFlag("Timeframe", core.FLAG_PERIODS)
    strategy.parameters:addString("PriceType", "PriceType", "Price type", "Bid")
    strategy.parameters:addStringAlternative("PriceType", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("PriceType", "Ask", "", "Ask")
    strategy.parameters:addInteger("Multiple_Positions_Limit", " Multiple Positions Limit", "", 2)
    strategy.parameters:addInteger("Amount_Lots", " Amount Lots", "", 1)
    strategy.parameters:addDouble("Limit", " Limit", "", 0)
    strategy.parameters:addDouble("Stop", " Stop", "", 0)
    strategy.parameters:addInteger("Shift_Sell_Cross", " Shift Sell Cross", "", 0)
    strategy.parameters:addInteger("Shift_Buy_Cross", " Shift Buy Cross", "", 0)
    strategy.parameters:addGroup("Extreme_Band_Lines parameters")
    strategy.parameters:addInteger("Extreme_Band_Lines_TMA_Period", "TMA period", "", 16)
    strategy.parameters:addInteger("Extreme_Band_Lines_ATR_Period", "ATR period", "", 8)
    strategy.parameters:addDouble("Extreme_Band_Lines_ATR_Mult", "ATR multiplier", "", 1.2)
    strategy.parameters:addBoolean("Redraw", "Redraw", "", false)

    strategy.parameters:addGroup("Keltner_Band_Lines parameters")
    strategy.parameters:addInteger("Keltner_Band_Lines_NM", "Number of the periods to smooth the center line", "", 20)
    strategy.parameters:addInteger("Keltner_Band_Lines_NB", "Number of periods to smooth deviation", "", 12)
    strategy.parameters:addDouble("Keltner_Band_Lines_F", "Factor which is used to apply the deviation", "", 2.8)
end

local mCID = "FXSW_STRATEGY"
local mAccount
local mLotSize
local mAllowTrade = false
local mAllowedSide = "Both"
local mPlaySound = false
local mReccurentSound = false
local mSendEmail = false
local mShowAlert = false
local mEmail
local mAllowMultiplePositions = true
local Timeframe
local symbol
local sourceE
local id_sourceE = 101
local Redraw
local mPriceType
local sourceK
local id_sourceK = 102

local Multiple_Positions_Limit
local Amount_Lots
local Limit
local Stop
local Shift_Sell_Cross
local Shift_Buy_Cross
local Extreme_Band_Lines_TMA_Period
local Extreme_Band_Lines_ATR_Period
local Extreme_Band_Lines_ATR_Mult
local Extreme_Band_Lines_TrendThreshold
local Extreme_Band_Lines_ShowTMA
local Extreme_Band_Lines_Redraw
local Extreme_Band_Lines
local Keltner_Band_Lines_NM
local Keltner_Band_Lines_NB
local Keltner_Band_Lines_F
local Keltner_Band_Lines_SRC
local Keltner_Band_Lines_MS
local Keltner_Band_Lines_MV
local Keltner_Band_Lines
local Sell = false

local Buy = false

-----------------------------------------------------------
-- Standard prepare handler for marketscope strategy
-----------------------------------------------------------
function Prepare(onlyName)
    assert(instance.parameters.Timeframe ~= "t1", "Tick is not allowed for Timeframe parameter")

    -- collect parameters
    mAccount = instance.parameters.Account
    mLotSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), mAccount)
    mAllowTrade = instance.parameters.AllowTrade
    mAllowedSide = instance.parameters.AllowedSide
    mAllowMultiplePositions = instance.parameters.AllowMultiplePositions
    Timeframe = instance.parameters.Timeframe
    symbol = instance.bid:instrument()
    mPriceType = instance.parameters.PriceType == "Bid"
    Multiple_Positions_Limit = instance.parameters.Multiple_Positions_Limit
    Amount_Lots = instance.parameters.Amount_Lots
    Limit = instance.parameters.Limit
    Stop = instance.parameters.Stop
    Shift_Sell_Cross = instance.parameters.Shift_Sell_Cross
    Shift_Buy_Cross = instance.parameters.Shift_Buy_Cross
    Extreme_Band_Lines_TMA_Period = instance.parameters.Extreme_Band_Lines_TMA_Period
    Extreme_Band_Lines_ATR_Period = instance.parameters.Extreme_Band_Lines_ATR_Period
    Extreme_Band_Lines_ATR_Mult = instance.parameters.Extreme_Band_Lines_ATR_Mult
    Keltner_Band_Lines_NM = instance.parameters.Keltner_Band_Lines_NM
    Keltner_Band_Lines_NB = instance.parameters.Keltner_Band_Lines_NB
    Keltner_Band_Lines_F = instance.parameters.Keltner_Band_Lines_F
    Redraw = instance.parameters.Redraw

    --set name
    instance:name(profile:id() .. "(" .. instance.bid:instrument() .. "(" .. Timeframe .. "))")

    if onlyName then
        return
    end
    assert(
        core.indicators:findIndicator("EXTREME_TMA_LINE") ~= nil,
        "Please, download and install EXTREME_TMA_LINE.LUA indicator"
    )
    assert(core.indicators:findIndicator("KELTNER") ~= nil, "Please, download and install KELTNER.LUA indicator")

    --datasources
    sourceE = ExtSubscribe(id_sourceE, symbol, Timeframe, mPriceType, "bar")
    sourceK = ExtSubscribe(id_sourceK, symbol, Timeframe, mPriceType, "bar")

    --indicators
    Extreme_Band_Lines =
        core.indicators:create(
        "EXTREME_TMA_LINE",
        sourceE,
        Extreme_Band_Lines_TMA_Period,
        Extreme_Band_Lines_ATR_Period,
        Extreme_Band_Lines_ATR_Mult,
        0,
        true,
        Redraw,
        8421504,
        65280,
        255,
        2,
        1,
        32896,
        1,
        2
    )
    _gUpdatePeriods[Extreme_Band_Lines.DATA] = _gUpdatePeriods[sourceE]
    Keltner_Band_Lines =
        core.indicators:create(
        "KELTNER",
        sourceK,
        Keltner_Band_Lines_NM,
        Keltner_Band_Lines_NB,
        Keltner_Band_Lines_F,
        "M2",
        "SMMA",
        "AHL",
        255,
        1,
        1,
        16776960,
        1,
        1,
        255,
        1,
        1
    )
    _gUpdatePeriods[Keltner_Band_Lines.DATA] = _gUpdatePeriods[sourceK]
end

-----------------------------------------------------------
-- 'Event handler' that is called when a datasource is updated
-----------------------------------------------------------
function ExtUpdate(id, updatedSource, period)
    if not checkReady("trades") or not checkReady("summary") then
        return
    end

    -- update indicators values
    Extreme_Band_Lines:update(core.UpdateLast)
    Keltner_Band_Lines:update(core.UpdateLast)

    -- update expressions
    if id == id_sourceE then --Updates handler of 'sourceE' datasource ('Timeframe'  timeframe)
        --Check that all data of used datasources is available
        if
            canCalculate(
                Extreme_Band_Lines.Upper,
                getClosedPeriod(Extreme_Band_Lines.Upper, Extreme_Band_Lines.Upper:size() - 1 - Shift_Sell_Cross)
            ) and
                canCalculate(
                    Extreme_Band_Lines.Upper,
                    getClosedPeriod(Extreme_Band_Lines.Upper, Extreme_Band_Lines.Upper:size() - 1 - Shift_Sell_Cross) -
                        1
                ) and
                canCalculate(
                    Keltner_Band_Lines.H,
                    getClosedPeriod(Keltner_Band_Lines.H, Keltner_Band_Lines.H:size() - 1 - Shift_Sell_Cross)
                ) and
                canCalculate(
                    Keltner_Band_Lines.H,
                    getClosedPeriod(Keltner_Band_Lines.H, Keltner_Band_Lines.H:size() - 1 - Shift_Sell_Cross) - 1
                )
         then
            Sell =
                core.crossesOver(
                Extreme_Band_Lines.Upper,
                Keltner_Band_Lines.H,
                getClosedPeriod(Extreme_Band_Lines.Upper, Extreme_Band_Lines.Upper:size() - 1 - Shift_Sell_Cross),
                getClosedPeriod(Keltner_Band_Lines.H, Keltner_Band_Lines.H:size() - 1 - Shift_Sell_Cross)
            )
        end
        --Check that all data of used datasources is available
        if
            canCalculate(
                Extreme_Band_Lines.Lower,
                getClosedPeriod(Extreme_Band_Lines.Lower, Extreme_Band_Lines.Lower:size() - 1 - Shift_Buy_Cross)
            ) and
                canCalculate(
                    Extreme_Band_Lines.Lower,
                    getClosedPeriod(Extreme_Band_Lines.Lower, Extreme_Band_Lines.Lower:size() - 1 - Shift_Buy_Cross) - 1
                ) and
                canCalculate(
                    Keltner_Band_Lines.L,
                    getClosedPeriod(Keltner_Band_Lines.L, Keltner_Band_Lines.L:size() - 1 - Shift_Buy_Cross)
                ) and
                canCalculate(
                    Keltner_Band_Lines.L,
                    getClosedPeriod(Keltner_Band_Lines.L, Keltner_Band_Lines.L:size() - 1 - Shift_Buy_Cross) - 1
                )
         then
            Buy =
                core.crossesUnder(
                Extreme_Band_Lines.Lower,
                Keltner_Band_Lines.L,
                getClosedPeriod(Extreme_Band_Lines.Lower, Extreme_Band_Lines.Lower:size() - 1 - Shift_Buy_Cross),
                getClosedPeriod(Keltner_Band_Lines.L, Keltner_Band_Lines.L:size() - 1 - Shift_Buy_Cross)
            )
        end
    end

    -- processing of Activation points
    if id == id_sourceE then --Updates handler of 'sourceE' datasource ('Timeframe'  timeframe)
        --'SELLpoint' activation point logic
        if Sell and countShortPositions(symbol) < Multiple_Positions_Limit then
            if mAllowTrade then
                close("B", core.host:findTable("offers"):find("Instrument", symbol).OfferID)
            end
            if mAllowTrade then
                createTrueMarketOrder("S", Amount_Lots, symbol, Stop, false, Limit)
            end
        end
        --'BUYpoint' activation point logic
        if Buy and countLongPositions(symbol) < Multiple_Positions_Limit then
            if mAllowTrade then
                close("S", core.host:findTable("offers"):find("Instrument", symbol).OfferID)
            end
            if mAllowTrade then
                createTrueMarketOrder("B", Amount_Lots, symbol, Stop, false, Limit)
            end
        end
    end
end

function checkReady(tableName)
    return core.host:execute("isTableFilled", tableName)
end

-----------------------------------------------------------
--Enters to the market
--   side: B - BUY or S - SELL
--   amount: order amount
--   instrumentName: instrument of order
--   stop:  0, 1 or greater value
--   isTrailingStop: true/false
--   limit: 0, 1 or greater value
-----------------------------------------------------------
function createTrueMarketOrder(side, amount, instrumentName, stop, isTrailingStop, limit)
    if not mAllowTrade then
        return
    end

    local offerId = core.host:findTable("offers"):find("Instrument", instrumentName).OfferID

    if
        not (mAllowedSide == "Both" or (mAllowedSide == "Buy" and side == "B") or
            (mAllowedSide == "Sell" and side == "S"))
     then
        return
    end

    if not mAllowMultiplePositions then
        if (side == "B" and countLongPositions(instrumentName) > 0) then
            return
        elseif (side == "S" and countShortPositions(instrumentName) > 0) then
            return
        end
    end

    local valuemap

    valuemap = core.valuemap()
    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "OM"
    valuemap.OfferID = offerId
    valuemap.AcctID = mAccount
    valuemap.GTC = "FOK" --Fill or Kill order to avoid partial execution
    valuemap.Quantity = amount * mLotSize
    valuemap.BuySell = side
    valuemap.CustomID = mCID
    if stop >= 1 then
        valuemap.PegTypeStop = "M"
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -stop
        else
            valuemap.PegPriceOffsetPipsStop = stop
        end
        if isTrailingStop then
            valuemap.TrailStepStop = 1
        end
    end
    if limit >= 1 then
        valuemap.PegTypeLimit = "M"
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = limit
        else
            valuemap.PegPriceOffsetPipsLimit = -limit
        end
    end

    if (not canClose(instrumentName)) and (stop >= 1 or limit >= 1) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
end

-----------------------------------------------------------
-- closes all positions of the specified direction (B for buy, S for sell)
-----------------------------------------------------------
function canClose(instrumentName)
    return core.host:execute("getTradingProperty", "canCreateMarketClose", instrumentName, mAccount)
end

function close(side, offer)
    local enum, row, valuemap

    enum = core.host:findTable("trades"):enumerator()
    while true do
        row = enum:next()
        if row == nil then
            break
        end
        if row.AccountID == mAccount and row.OfferID == offer and row.BS == side and row.QTXT == mCID then
            -- if trade has to be closed

            if canClose(row.Instrument) then
                -- create a close market order when hedging is allowed
                valuemap = core.valuemap()
                valuemap.OrderType = "CM"
                valuemap.OfferID = offer
                valuemap.AcctID = mAccount
                valuemap.Quantity = row.Lot
                valuemap.TradeID = row.TradeID
                valuemap.CustomID = mCID
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                success, msg = terminal:execute(200, valuemap)
                assert(success, msg)
            else
                -- create an opposite market order when FIFO
                valuemap = core.valuemap()
                valuemap.OrderType = "OM"
                valuemap.OfferID = offer
                valuemap.AcctID = mAccount
                valuemap.Quantity = row.Lot
                valuemap.CustomID = mCID
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                success, msg = terminal:execute(200, valuemap)
                assert(success, msg)
            end
        end
    end
end

-----------------------------------------------------------
--Handle command execution result
-----------------------------------------------------------
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loaded = true
    elseif cookie == 200 then
        assert(success, message)
    end
end

-----------------------------------------------------------
-- Helper functions
-----------------------------------------------------------
function getOppositeSide(side)
    if (side == "B") then
        return "S"
    else
        return "B"
    end
end

function getDSPeriod(ds, updatedSource, period)
    local p
    if ds:isBar() then
        p = core.findDate(ds.open, updatedSource:date(period), false)
    else
        p = core.findDate(ds, updatedSource:date(period), false)
    end
    if (p > ds:size() - 1) then
        p = ds:size() - 1
    elseif (p < ds:first()) then
        p = ds:first()
    end
    return p
end

-----------------------------------------------------------
-- Allow to calculate last closed bar period for ds datasource
-- which has not tick frequency updates
-----------------------------------------------------------
function getClosedPeriod(ds, supposedPeriod)
    --Check if datasource lastdate is closed on updatePeriod or shift supposedPeriod to -1
    if _gUpdatePeriods[ds] == "t1" or _gUpdatePeriods[ds] == nil then
        return supposedPeriod
    else
        return supposedPeriod - 1
    end
end

-----------------------------------------------------------
--Helper functions to wrap the table's method call into the simple function call
-----------------------------------------------------------
function streamSize(stream)
    return stream:size()
end

function streamHasData(stream, period)
    return stream:hasData(period)
end

function canCalculate(stream, period)
    return (period >= 0) and (period > stream:first()) and streamHasData(stream, period)
end

-----------------------------------------------------------
-- Helper functions to be sure that you work with a tick stream
-----------------------------------------------------------
function getTickStreamOfPriceType(stream, priceType)
    if stream:isBar() then
        if priceType == "open" then
            return stream.open
        elseif priceType == "high" then
            return stream.high
        elseif priceType == "low" then
            return stream.low
        elseif priceType == "close" then
            return stream.close
        elseif priceType == "typical" then
            return stream.typical
        elseif priceType == "weighted" then
            return stream.weighted
        elseif priceType == "volume" then
            return stream.volume
        else
            return stream.close
        end
    else
        return stream
    end
end

function selectStream(safeStream, subStream)
    if safeStream:isBar() then
        return subStream
    else
        return safeStream
    end
end

---------------------------------------------------------
-- Subscription for updates by datasource timeframe
---------------------------------------------------------

-- subscribe for the price data
function ExtSubscribe(id, instrument, period, bid, type)
    local sub = {}
    if instrument == nil and period == "t1" then
        if bid then
            sub.stream = instance.bid
        else
            sub.stream = instance.ask
        end
        sub.tick = true
        sub.loaded = true
        sub.lastSerial = -1
        _gSubscription[id] = sub
    elseif instrument == nil then
        sub.stream = core.host:execute("getHistory", id, instance.bid:instrument(), period, 0, 0, bid)
        sub.tick = false
        sub.loaded = false
        sub.lastSerial = -1
        _gSubscription[id] = sub
    else
        sub.stream = core.host:execute("getHistory", id, instrument, period, 0, 0, bid)
        sub.tick = (period == "t1")
        sub.loaded = false
        sub.lastSerial = -1
        _gSubscription[id] = sub
    end
    _gUpdatePeriods[sub.stream] = period
    if sub.tick then
        return sub.stream
    else
        if type == "open" then
            _gUpdatePeriods[sub.stream.open] = period
            return sub.stream.open
        elseif type == "high" then
            _gUpdatePeriods[sub.stream.high] = period
            return sub.stream.high
        elseif type == "low" then
            _gUpdatePeriods[sub.stream.low] = period
            return sub.stream.low
        elseif type == "close" then
            _gUpdatePeriods[sub.stream.close] = period
            return sub.stream.close
        elseif type == "bar" then
            _gUpdatePeriods[sub.stream.open] = period
            _gUpdatePeriods[sub.stream.high] = period
            _gUpdatePeriods[sub.stream.low] = period
            _gUpdatePeriods[sub.stream.close] = period
            _gUpdatePeriods[sub.stream.median] = period
            _gUpdatePeriods[sub.stream.typical] = period
            _gUpdatePeriods[sub.stream.volume] = period
            _gUpdatePeriods[sub.stream.weighted] = period
            return sub.stream
        else
            assert(false, type .. " is unknown")
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    local sub
    sub = _gSubscription[cookie]
    if sub ~= nil then
        sub.loaded = true
        if sub.stream:size() > 1 then
            sub.lastSerial = sub.stream:serial(sub.stream:size() - 1)
        end
    else
        -- unknown cookie
        if ExtAsyncOperationFinished ~= nil then
            ExtAsyncOperationFinished(cookie, success, message)
        end
    end
end

function Update()
    if instance.bid:size() > 0 then
        _gLastTime = instance.bid:date(instance.bid:size() - 1)
    end
    for k, v in pairs(_gSubscription) do
        if v.loaded and v.stream:size() > 1 then
            local s = v.stream:serial(v.stream:size() - 1)
            local p
            if s ~= v.lastSerial then
                if v.tick then
                    p = v.stream:size() - 1 -- the last tick
                else
                    p = v.stream:size() - 2 -- the previous candle
                end
                ExtUpdate(k, v.stream, p)
                v.lastSerial = s
            end
        end
    end
end

---------------------------------------------------------
-- Additional functions
---------------------------------------------------------
local mAccountRow = nil
local mSummaries = {}

function checkAccountRow()
    if mAccountRow == nil then
        mAccountRow = core.host:findTable("accounts"):find("AccountID", mAccount)
    else
        mAccountRow:refresh()
    end
end

function checkSummaryRow(sInstrument)
    local sOfferID, summaryIter, summaryRow

    if mSummaries[sInstrument] ~= nil then
        --try refresh
        if not (mSummaries[sInstrument]:refresh()) then
            mSummaries[sInstrument] = nil
        end
    end

    --re-read all cache
    if mSummaries[sInstrument] == nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID
        summaryIter = core.host:findTable("summary"):enumerator()
        summaryRow = summaryIter:next()
        while summaryRow ~= nil do
            if summaryRow.OfferID == sOfferID then
                mSummaries[sInstrument] = summaryRow
                break
            end
            summaryRow = summaryIter:next()
        end
    end
end

function getEquity()
    checkAccountRow()
    return mAccountRow.Equity
end

function getBalance()
    checkAccountRow()
    return mAccountRow.Balance
end

function getProfit()
    checkAccountRow()
    return mAccountRow.Equity - mAccountRow.Balance
end

function getAmountK(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.AmountK
    end
end

function getGrossPL(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.GrossPL
    end
end

function getNetPL(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.NetPL
    end
end

function getSellAmountK(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.SellAmountK
    end
end

function getBuyAmountK(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.BuyAmountK
    end
end

function getBuyNetPLPip(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.BuyNetPLPip
    end
end

function getSellNetPLPip(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.SellNetPLPip
    end
end

function getBuyNetPL(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.BuyNetPL
    end
end

function getSellNetPL(sInstrument)
    local res
    checkSummaryRow(sInstrument)
    res = mSummaries[sInstrument]
    if res == nil then
        return 0
    else
        return res.SellNetPL
    end
end

function countPositions(sInstrument)
    local tradesIter, tradeRow, count, sOfferID
    count = 0
    if sInstrument ~= nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID
    end
    tradesIter = core.host:findTable("trades"):enumerator()
    tradeRow = tradesIter:next()
    while tradeRow ~= nil do
        if (sInstrument == nil or tradeRow.OfferID == sOfferID) then
            count = count + 1
        end
        tradeRow = tradesIter:next()
    end
    return count
end

function countLongPositions(sInstrument)
    local tradesIter, tradeRow, count, sOfferID
    count = 0
    if sInstrument ~= nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID
    end
    tradesIter = core.host:findTable("trades"):enumerator()
    tradeRow = tradesIter:next()
    while tradeRow ~= nil do
        if ((sInstrument == nil or tradeRow.OfferID == sOfferID) and tradeRow.BS == "B") then
            count = count + 1
        end
        tradeRow = tradesIter:next()
    end
    return count
end

function countShortPositions(sInstrument)
    local tradesIter, tradeRow, count, sOfferID
    count = 0
    if sInstrument ~= nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID
    end
    tradesIter = core.host:findTable("trades"):enumerator()
    tradeRow = tradesIter:next()
    while tradeRow ~= nil do
        if ((sInstrument == nil or tradeRow.OfferID == sOfferID) and tradeRow.BS == "S") then
            count = count + 1
        end
        tradeRow = tradesIter:next()
    end
    return count
end

function getLastUpdateTime()
    if (_gLastTime == nil) then
        return 0
    else
        return _gLastTime
    end
end

function time(hours, minutes, seconds)
    local dtLast
    dtLast = core.dateToTable(_gLastTime)
    if seconds == nil then
        seconds = 0
    end
    return core.datetime(dtLast.year, dtLast.month, dtLast.day, hours, minutes, seconds)
end

function isValidDate(checkDate)
    if (checkDate < 1) then
        return false
    else
        return true
    end
end

function parseTime(sTime)
    local iDelimHMPos = string.find(sTime, ":")
    local h = tonumber(string.sub(sTime, 1, iDelimHMPos - 1))
    local sTimeTile = string.sub(sTime, iDelimHMPos + 1)
    local iDelimMSPos = string.find(sTimeTile, ":")
    local m, s
    s = 0
    if iDelimMSPos == nil then
        m = tonumber(sTimeTile)
    else
        m = tonumber(string.sub(sTimeTile, 1, iDelimMSPos - 1))
        s = tonumber(string.sub(sTimeTile, iDelimMSPos + 1))
    end
    return time(h, m, s)
end

function getPipSize(sInstrument)
    return core.host:findTable("offers"):find("Instrument", sInstrument).PointSize
end
