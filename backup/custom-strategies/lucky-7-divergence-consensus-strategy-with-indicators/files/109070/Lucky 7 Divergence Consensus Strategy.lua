-- Id: 17051
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64096

--+------------------------------------------------------------------+
--|                           Lucky 7 Divergence Consensus Strategy  |
--|                               Copyright © 2016, JetApps USA      |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Jim Totaro   |
--|    				with special thanks to Apprentice and Gehtsoft	 |
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

local _gSubscription = {}
local _gUpdatePeriods = {}
local _gLastTime

-----------------------------------------------------------
-- Standard strategy init handler for marketscope strategy
-----------------------------------------------------------
function Init()
    strategy:name("Lucky 7 Divergence Consensus Strategy")

    strategy:type(core.Both)

    strategy.parameters:addString("Account", "Account", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addBoolean("AllowTrade", "Allow trade", "", true)
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
    strategy.parameters:addBoolean("AllowMultiplePositions", "Allow multiple positions", "", false)
    strategy.parameters:addString("tf", "tf", "The used timeframe", "H1")
    strategy.parameters:setFlag("tf", core.FLAG_PERIODS)
    strategy.parameters:addInteger("amount", "amount", "", 5)
    strategy.parameters:addDouble("limit", "limit", "", 50)
    strategy.parameters:addDouble("stop", "stop", "", 20)
    strategy.parameters:addBoolean("isTrailingStop", "Trailing stop?", "", true)
    strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse")
    strategy.parameters:addGroup("SUPER_DIVERGENCE_INDICATOR_JIM_V2 parameters")

    strategy.parameters:addGroup("Selector")
    strategy.parameters:addBoolean("One", "Use MACD Divergence", "", true)
    strategy.parameters:addBoolean("Two", "Use CCI Divergence", "", true)
    strategy.parameters:addBoolean("Three", "Use ROC Divergence", "", true)
    strategy.parameters:addBoolean("Four", "Use TSI Divergence", "", true)
    strategy.parameters:addBoolean("Five", "Use RSI Divergence", "", true)
    strategy.parameters:addBoolean("Six", "Use MFI Divergence", "", true)
    strategy.parameters:addBoolean("Seven", "Use Stochastic Divergence", "", true)

    strategy.parameters:addBoolean("showHidden", "Show Hidden (continuation) divergence?", "", true)

    strategy.parameters:addGroup("MACD Calculation")
    strategy.parameters:addInteger("MACD_N", "Period of short EMA for MACD", "", 12)
    strategy.parameters:addInteger("MACD_N2", "Period of long EMA for MACD", "", 26)
    strategy.parameters:addInteger("MACD_N3", "Signal period of MACD", "", 9)
    strategy.parameters:addDouble("MACD_OB", "MACD Overbought Level", "", 0.0002, -0.1, 0.1)
    strategy.parameters:addDouble("MACD_OS", "MACD Oversold Level", "", -0.0002, -0.1, 0.1)

    strategy.parameters:addGroup("CCI Calculation")
    strategy.parameters:addInteger("CCI_N", "Number of periods", "The number of periods.", 14, 2, 1000)
    strategy.parameters:addDouble("CCI_OB", "CCI Overbought (usually 100)", "", 100, 0, 500)
    strategy.parameters:addDouble("CCI_OS", "CCI Oversold (usually -100)", "", -100, -500, 0)

    strategy.parameters:addGroup("ROC Calculation")
    strategy.parameters:addInteger("ROC_N", "Periods for ROC Indicator ", "", 7)
    strategy.parameters:addDouble("ROC_OB", "ROC Overbought Level", "", 0.1, -5, 5)
    strategy.parameters:addDouble("ROC_OS", "ROC Oversold Level", "", -0.1, -5, 5)

    strategy.parameters:addGroup("TSI Calculation")
    strategy.parameters:addInteger("TSI_N", "Periods for TSI Indicator 1", "", 7)
    strategy.parameters:addInteger("TSI_N2", "Periods for TSI Indicator 2", "", 14)
    strategy.parameters:addDouble("TSI_OB", "TSI Overbought Level", "", 30, -100, 100)
    strategy.parameters:addDouble("TSI_OS", "TSI Oversold Level", "", -30, -100, 100)

    strategy.parameters:addGroup("RSI Calculation")
    strategy.parameters:addInteger("RSI_N", "Periods for RSI Indicator ", "", 7)
    strategy.parameters:addDouble("RSI_OB", "RSI Overbought Level", "", 70)
    strategy.parameters:addDouble("RSI_OS", "RSI Oversold Level", "", 30)

    strategy.parameters:addGroup("MFI Calculation")
    strategy.parameters:addInteger("MFI_N", "MFI Periods ", "", 7)
    strategy.parameters:addDouble("MFI_OB", "MFI Overbought Level", "", 70)
    strategy.parameters:addDouble("MFI_OS", "MFI Oversold Level", "", 30)

    strategy.parameters:addGroup("Stochastic Calculation")
    strategy.parameters:addInteger("STOCH_N", "periods for %K", "", 5, 2, 1000)
    strategy.parameters:addInteger("STOCH_N2", "D smoothing periods", "", 3, 2, 1000)
    strategy.parameters:addInteger("STOCH_N3", "periods for %D", "", 3, 2, 1000)
    strategy.parameters:addDouble("STOCH_OB", "Stochastic Overbought Level", "", 70, 20, 100)
    strategy.parameters:addDouble("STOCH_OS", "Stochastic Oversold Level", "", 30, 1, 80)
end

local mCID = "L7DCS_STRATEGY"
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
local tf
local symbol
local source
local id_source = 101
local Direction
local amount
local limit
local stop
local first
local buySignal
local sellSignal
local isTrailingStop
local One, Two, Three, Four, Five, Six, Seven
local SUPER_DIVERGENCE_INDICATOR = nil
local Parameters = {}
local Indicator = {}
local showHidden

-----------------------------------------------------------
-- Standard prepare handler for marketscope strategy
-----------------------------------------------------------
function Prepare(onlyName)
    assert(instance.parameters.tf ~= "t1", "Tick is not allowed for tf parameter")

    -- collect parameters
    mAccount = instance.parameters.Account
    mLotSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), mAccount)
    mAllowTrade = instance.parameters.AllowTrade
    mAllowedSide = instance.parameters.AllowedSide
    mAllowMultiplePositions = instance.parameters.AllowMultiplePositions
    tf = instance.parameters.tf
    symbol = instance.bid:instrument()
    amount = instance.parameters.amount
    limit = instance.parameters.limit
    stop = instance.parameters.stop
    isTrailingStop = instance.parameters.isTrailingStop
    One = instance.parameters.One
    Two = instance.parameters.Two
    Three = instance.parameters.Three
    Four = instance.parameters.Four
    Five = instance.parameters.Five
    Six = instance.parameters.Six
    Seven = instance.parameters.Seven
    showHidden = instance.parameters.showHidden

    Direction = instance.parameters.Direction == "direct"

    Parameters["MACD_N"] = instance.parameters.MACD_N
    Parameters["MACD_N2"] = instance.parameters.MACD_N2
    Parameters["MACD_N3"] = instance.parameters.MACD_N3
    Parameters["MACD_OB"] = instance.parameters.MACD_OB
    Parameters["MACD_OS"] = instance.parameters.MACD_OS

    Parameters["CCI_N"] = instance.parameters.CCI_N
    Parameters["CCI_OB"] = instance.parameters.CCI_OB
    Parameters["CCI_OS"] = instance.parameters.CCI_OS

    Parameters["ROC_N"] = instance.parameters.ROC_N
    Parameters["ROC_OB"] = instance.parameters.ROC_OB
    Parameters["ROC_OS"] = instance.parameters.ROC_OS

    Parameters["TSI_N"] = instance.parameters.TSI_N
    Parameters["TSI_N2"] = instance.parameters.TSI_N2
    Parameters["TSI_OB"] = instance.parameters.TSI_OB
    Parameters["TSI_OS"] = instance.parameters.TSI_OS

    Parameters["RSI_N"] = instance.parameters.RSI_N
    Parameters["RSI_OB"] = instance.parameters.RSI_OB
    Parameters["RSI_OS"] = instance.parameters.RSI_OS

    Parameters["MFI_N"] = instance.parameters.MFI_N
    Parameters["MFI_OB"] = instance.parameters.MFI_OB
    Parameters["MFI_OS"] = instance.parameters.MFI_OS

    Parameters["STOCH_N"] = instance.parameters.STOCH_N
    Parameters["STOCH_N2"] = instance.parameters.STOCH_N2
    Parameters["STOCH_N3"] = instance.parameters.STOCH_N3
    Parameters["STOCH_OB"] = instance.parameters.STOCH_OB
    Parameters["STOCH_OS"] = instance.parameters.STOCH_OS

    --set name
    instance:name(profile:id() .. "(" .. instance.bid:instrument() .. "(" .. tf .. "))")

    if onlyName then
        return
    end

    --datasources
    source = ExtSubscribe(id_source, symbol, tf, true, "bar")
    first = source.close:first()

    --indicators

    assert(
        core.indicators:findIndicator("DIVERGENCE CONSENSUS 7 INDICATOR") ~= nil,
        "Please, download and install DIVERGENCE CONSENSUS 7 INDICATOR.LUA indicator"
    )
    assert(
        core.indicators:findIndicator("SUPER DIVERGENCE INDICATOR V3") ~= nil,
        "Please, download and install SUPER DIVERGENCE INDICATOR V3.LUA indicator"
    )
    assert(core.indicators:findIndicator("MFI") ~= nil, "Please, download and install MFI.LUA indicator")

    SUPER_DIVERGENCE_INDICATOR =
        core.indicators:create(
        "DIVERGENCE CONSENSUS 7 INDICATOR",
        source,
        One,
        Two,
        Three,
        Four,
        Five,
        Six,
        Seven,
        Parameters["MACD_N"],
        Parameters["MACD_N2"],
        Parameters["MACD_N3"],
        Parameters["MACD_OB"],
        Parameters["MACD_OS"],
        Parameters["CCI_N"],
        Parameters["CCI_OB"],
        Parameters["CCI_OS"],
        Parameters["ROC_N"],
        Parameters["ROC_OB"],
        Parameters["ROC_OS"],
        Parameters["TSI_N"],
        Parameters["TSI_N2"],
        Parameters["TSI_OB"],
        Parameters["TSI_OS"],
        Parameters["RSI_N"],
        Parameters["RSI_OB"],
        Parameters["RSI_OS"],
        Parameters["MFI_N"],
        Parameters["MFI_OB"],
        Parameters["MFI_OS"],
        Parameters["STOCH_N"],
        Parameters["STOCH_N2"],
        Parameters["STOCH_N3"],
        Parameters["STOCH_OB"],
        Parameters["STOCH_OS"],
        showHidden,
        core.rgb(0, 255, 0),
        core.rgb(255, 0, 0),
        core.rgb(0, 0, 255),
        40
    )
    _gUpdatePeriods[SUPER_DIVERGENCE_INDICATOR.DATA] = _gUpdatePeriods[source]
    first = math.max(first, SUPER_DIVERGENCE_INDICATOR.DATA:first())
end

-----------------------------------------------------------
-- 'Event handler' that is called when a datasource is updated
-----------------------------------------------------------
function ExtUpdate(id, updatedSource, period)
    if not checkReady("trades") or not checkReady("summary") then
        return
    end

    -- update indicators values

    if id == id_source then --Updates handler of 'source' datasource ('tf'  timeframe)
        SUPER_DIVERGENCE_INDICATOR:update(core.UpdateLast)

        if period < first + 1 then
            return
        end

        buySignal = false
        sellSignal = false

        --check for positive divergence

        if SUPER_DIVERGENCE_INDICATOR.open[period] == 1 then
            if Direction then
                buySignal = true
                sellSignal = false
            else
                sellSignal = true
                buySignal = false
            end
        end
        --Check for negative divergence
        if SUPER_DIVERGENCE_INDICATOR.open[period] == -1 then
            if Direction then
                sellSignal = true
                buySignal = false
            else
                buySignal = true
                sellSignal = false
            end
        end

        -- processing of Activation points
        --'Buy' activation point logic
        if buySignal then
            if mAllowTrade then
                close("S", core.host:findTable("offers"):find("Instrument", symbol).OfferID)
            end
            if mAllowTrade then
                createTrueMarketOrder("B", amount, symbol, stop, isTrailingStop, limit)
            end
        end
        --'Sell' activation point logic
        if sellSignal then
            if mAllowTrade then
                close("B", core.host:findTable("offers"):find("Instrument", symbol).OfferID)
            end
            if mAllowTrade then
                createTrueMarketOrder("S", amount, symbol, stop, isTrailingStop, limit)
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
