-- Id: 4217
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4926

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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

function Init()
    strategy:name("Constant Break Entry strategy")
    strategy:description("Constant Break Entry")
    strategy:setTag("Version", "2");

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)
    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("TradeType", "Trade Type", "", "against")
    strategy.parameters:addStringAlternative("TradeType", "Against Trend", "", "against")
    strategy.parameters:addStringAlternative("TradeType", "Along With Trend", "", "along")
    strategy.parameters:addString("OrderTime", "Order Placed", "", "immidiately")
    strategy.parameters:addStringAlternative("OrderTime", "Immidiately After Position Closed", "", "immidiately")
    strategy.parameters:addStringAlternative("OrderTime", "At the end of period", "", "end_of_period")

    strategy.parameters:addGroup("Above Entry Order")
    strategy.parameters:addInteger("pUP", "Above distance", "Distance to place order above current price", 10, 0, 1000)
    strategy.parameters:addInteger("uSL", "Stop", "Stop Order distance", 10, 0, 1000)
    strategy.parameters:addInteger("uTP", "Limit", "Limit Order distance", 10, 0, 1000)

    strategy.parameters:addInteger("pDW", "Below distance", "Distance to place order below current price", 10, 0, 1000)
    strategy.parameters:addInteger("dSL", "Stop", "Stop Order distance", 10, 0, 1000)
    strategy.parameters:addInteger("dTP", "Limit", "Limit Order distance", 10, 0, 1000)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);

    strategy.parameters:addGroup("Time Parameters")

    strategy.parameters:addGroup("Time Parameters")
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00")
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00")

    strategy.parameters:addString("StartDate", "Do not work before date:", "", "12/12/2017")
end

-- Parameters block
local source = nil -- the source stream

local PlaySound
local RecurrentSound
local SoundFile
local Email
local SendEmail

local Account
local Amount
local BaseSize
local Offer
local CanClose
local PipSize

local pUP, uSL, uTP
local pDW, dSL, dTP

local OrderTime
local OpenTime, CloseTime
local ValidInterval
local StartDate

local AllowTrade
-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")"
    instance:name(name)

    ValidInterval = instance.parameters.ValidInterval
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing
    AllowTrade = instance.parameters.AllowTrade

    if nameOnly then
        return
    end

    assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.")

    Account = instance.parameters.Account
    Amount = instance.parameters.Amount
    --CustomID
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    PipSize = instance.bid:pipSize()

    OrderTime = instance.parameters.OrderTime
    TradeType = instance.parameters.TradeType

    if OrderTime == "immidiately" then
        source = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "tick")
    else
        source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    end

    pUP, uSL, uTP = instance.parameters.pUP, instance.parameters.uSL, instance.parameters.uTP
    pDW, dSL, dTP = instance.parameters.pDW, instance.parameters.dSL, instance.parameters.dTP

    local valid
    OpenTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    CloseTime, valid = ParseTime(instance.parameters.StopTime)
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")

    local t, c = core.parseCsv(instance.parameters.StartDate, "/")
    assert(c == 3, "Start date: " .. instance.parameters.StartDate .. " is invalid")

    StartDate = core.date(t[2], t[0], t[1])
end

function ParseTime(time)
    local pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local h = tonumber(string.sub(time, 1, pos - 1))
    time = string.sub(time, pos + 1)
    pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local m = tonumber(string.sub(time, 1, pos - 1))
    local s = tonumber(string.sub(time, pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
        (h == 24 and m == 0 and s == 0)) -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end
-- strategy calculation routine
function ExtUpdate(id, source, period)
    if not AllowTrade then
        return
    end

    now = core.host:execute("getServerTime")

    if now < StartDate then
        core.host:trace("Waiting start date")
        return
    end

    -- get only time
    now = now - math.floor(now)
    -- check whether the time is in the exit time period
    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    if OrderTime == "immidiately" then
        if not haveTrades() and not haveOrders() then
            restart()
        end
    else
        if not haveTrades() then
            deleteOrders()
            restart()
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function deleteOrders()
    local enum = core.host:findTable("orders"):enumerator()
    local row = enum:next()
    local i = 1
    while (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer then
            local valuemap = core.valuemap()
            valuemap.Command = "DeleteOrder"
            valuemap.OrderID = row.OrderID
            success, msg = terminal:execute(100 + i, valuemap)
            if not (success) then
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed delete order " .. row.OrderID .. ":" .. msg,
                    instance.bid:date(NOW)
                )
            end
        end
        row = enum:next()
        i = i + 1
    end
end

function createOrder(bs, distance, stop, limit)
    local valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    -- get the order type
    if bs == "B" and distance < 0 then
        valuemap.OrderType = "LE"
    elseif bs == "B" and distance > 0 then
        valuemap.OrderType = "SE"
    elseif bs == "S" and distance < 0 then
        valuemap.OrderType = "SE"
    elseif bs == "S" and distance > 0 then
        valuemap.OrderType = "LE"
    end

    if bs == "B" then
        valuemap.Rate = instance.ask[NOW] + distance * PipSize
    else
        valuemap.Rate = instance.bid[NOW] + distance * PipSize
    end

    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = bs

    valuemap.PegTypeLimit = "O"
    if bs == "B" then
        valuemap.PegPriceOffsetPipsLimit = limit
    else
        valuemap.PegPriceOffsetPipsLimit = -limit
    end

    valuemap.PegTypeStop = "O"
    if bs == "B" then
        valuemap.PegPriceOffsetPipsStop = -stop
    else
        valuemap.PegPriceOffsetPipsStop = stop
    end

    if not (canClose) then
        -- if regular s/l orders aren't allowed - create ELS order
        valuemap.EntryLimitStop = "Y"
    end

    return valuemap
end

function restart()
    local valuemap = core.valuemap()
    valuemap.Command = "CreateOCO"

    valuemap:append(createOrder(TradeType == "along" and "B" or "S", pUP, uSL, uTP))
    valuemap:append(createOrder(TradeType == "along" and "S" or "B", -pDW, dSL, dTP))

    local success, msg
    success, msg = terminal:execute(100, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[NOW],
            "Failed create order " .. msg,
            instance.bid:date(NOW)
        )
    end
end

-- -----------------------------------------------------------------------
-- Function checks that specified table is ready (filled) for processing
-- or that we running under debugger/simulation conditions.
-- -----------------------------------------------------------------------
function checkReady(table)
    local rc
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true
    else
        rc = core.host:execute("isTableFilled", table)
    end
    return rc
end

-- -----------------------------------------------------------------------
-- Return count of opened trades for spicific direction
-- (both directions if BuySell parameters is 'nil')
-- -----------------------------------------------------------------------
function haveTrades(BuySell)
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            found = true
        end
        row = enum:next()
    end

    return found
end

function haveOrders()
    local enum, row
    local found = false
    enum = core.host:findTable("orders"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer then
            found = true
        end
        row = enum:next()
    end

    return found
end

--===========================================================================--
--                      END OF TRADING UTILITY FUNCTIONS                     --
--===========================================================================--

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
