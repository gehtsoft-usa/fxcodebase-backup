-- Id: 5896
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2791

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    strategy:name("Set stop by fractals")
    strategy:description("Strategy changes stop followiung to the fractals")
    strategy:setTag("strategy_type", "Money management");

    strategy.parameters:addGroup("Fractal Parameters")
    strategy.parameters:addInteger("Frame", "Number of bars for fractals (Odd)", "", 5, 3, 99)

    strategy.parameters:addGroup("Stop Parameters")
    strategy.parameters:addInteger("Indent", "Indent from fractal", "", 0, 0, 1000)
    strategy.parameters:addBoolean("MoveBack", "Move stop back", "", false)

    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addString("Period", "Timeframe", "", "m1")
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addString("Symbol", "Choose Symbol", "", "")
    strategy.parameters:setFlag("Symbol", core.FLAG_INSTRUMENTS)
end

local tradeExist = true
local first = true
local stopOrder = nil -- the identifier of the stop order
local tsource = nil
local timer
local minChange
local executing = false
local CanClose
local Shift
local FirstStart

function Prepare(onlyName)
    local name
    name =
        profile:id() ..
        "(" ..
            instance.bid:instrument() ..
                "[" ..
                    instance.parameters.Period ..
                        "]" ..
                            "," ..
                                instance.parameters.Frame ..
                                    "," .. "," .. instance.parameters.Indent .. "," .. instance.parameters.Symbol .. ")"
    instance:name(name)
    if onlyName then
        return
    end

    minChange = math.pow(10, -instance.bid:getPrecision())

    CanClose =
        core.host:execute(
        "getTradingProperty",
        "canCreateMarketClose",
        instance.bid:instrument(),
        instance.parameters.Account
    )

    ExtSetupSignal(name .. ":", true)
    tsource =
        ExtSubscribe(
        1,
        instance.parameters.Symbol,
        instance.parameters.Period,
        instance.parameters.Type == "Bid",
        "bar"
    )
    Shift = math.floor(instance.parameters.Frame / 2)
    FirstStart = true
end

function FirstStop(source, period)
    local stopValue
    local stopSide
    local UpFracPos, DnFracPos = FindLastFractals(source, period)

    if UpFracPos ~= nil or DnFracPos ~= nil then
        local trades = core.host:findTable("trades")
        local enum = trades:enumerator()
        while true do
            local trade = enum:next()
            if trade == nil then
                break
            end
            if trade.Instrument == instance.parameters.Symbol then
                if trade.BS == "B" then
                    if DnFracPos ~= nil then
                        stopValue = tsource.low[DnFracPos] - instance.parameters.Indent * instance.bid:pipSize()
                        setStop(trade, stopValue, "S")
                    end
                else
                    if UpFracPos ~= nil then
                        stopValue = tsource.high[UpFracPos] + instance.parameters.Indent * instance.bid:pipSize()
                        setStop(trade, stopValue, "B")
                    end
                end
            end
        end
    end
end

function IsFractal(source, period)
    local Up = true
    local Dn = true
    local i
    for i = 1, Shift, 1 do
        if
            source.high[period - Shift - i] >= source.high[period - Shift] or
                source.high[period - Shift + i] >= source.high[period - Shift]
         then
            Up = false
        end
        if
            source.low[period - Shift - i] <= source.low[period - Shift] or
                source.low[period - Shift + i] <= source.low[period - Shift]
         then
            Dn = false
        end
    end
    return Up, Dn
end

function FindLastFractals(source, period)
    local UpPos, DnPos = nil, nil
    local i = period
    local first = source:first() + instance.parameters.Frame
    while (UpPos == nil or DnPos == nil) and i >= first do
        local Up, Dn = IsFractal(source, i)
        if Up and UpPos == nil then
            UpPos = i - Shift
        end
        if Dn and DnPos == nil then
            DnPos = i - Shift
        end
        i = i - 1
    end
    return UpPos, DnPos
end

function setStop(trade, stopValue, stopSide)
    if not instance.parameters.AllowTrade then
        return;
    end
    if CanClose then
        if trade.StopOrderID == "" or trade.StopOrderID == nil then
            valuemap = core.valuemap()
            valuemap.Command = "CreateOrder"
            valuemap.OrderType = "S"
            valuemap.OfferID = trade.OfferID
            valuemap.AcctID = trade.AccountID
            valuemap.TradeID = trade.TradeID
            valuemap.Quantity = trade.Lot
            valuemap.Rate = stopValue
            valuemap.BuySell = stopSide
            executing = true
            success, msg = terminal:execute(200, valuemap)
            if not (success) then
                executing = false
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed create stop " .. msg,
                    instance.bid:date(NOW)
                )
            end
        else
            if instance.parameters.MoveBack == false then
                if trade.BS == "B" then
                    if stopValue <= trade.Stop then
                        return
                    end
                else
                    if stopValue >= trade.Stop then
                        return
                    end
                end
            end
            if math.abs(stopValue - trade.Stop) > minChange then
                -- stop exists
                valuemap = core.valuemap()
                valuemap.Command = "EditOrder"
                valuemap.AcctID = trade.AccountID
                valuemap.OrderID = trade.StopOrderID
                valuemap.Rate = stopValue
                executing = true
                success, msg = terminal:execute(200, valuemap)
                if not (success) then
                    executing = false
                    terminal:alertMessage(
                        instance.bid:instrument(),
                        instance.bid[NOW],
                        "Failed change stop " .. msg,
                        instance.bid:date(NOW)
                    )
                end
            end
        end
    else
        local order = nil
        local rate

        local enum, row
        enum = core.host:findTable("orders"):enumerator()
        row = enum:next()
        while (row ~= nil) do
            if
                row.OfferID == trade.OfferID and row.AccountID == trade.AccountID and row.BS == stopSide and
                    row.NetQuantity and
                    row.Type == "SE"
             then
                order = row.OrderID
                rate = row.Rate
            end
            row = enum:next()
        end

        if order == nil then
            valuemap = core.valuemap()
            valuemap.Command = "CreateOrder"
            valuemap.OrderType = "SE"
            valuemap.OfferID = trade.OfferID
            valuemap.AcctID = trade.AccountID
            valuemap.TradeID = trade.TradeID
            valuemap.NetQtyFlag = "y"
            valuemap.Rate = stopValue
            valuemap.BuySell = stopSide
            executing = true
            success, msg = terminal:execute(200, valuemap)
            if not (success) then
                executing = false
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed create stop " .. msg,
                    instance.bid:date(NOW)
                )
            end
        else
            if instance.parameters.MoveBack == false then
                if trade.BS == "B" then
                    if stopValue <= rate then
                        return
                    end
                else
                    if stopValue >= rate then
                        return
                    end
                end
            end
            if math.abs(stopValue - rate) > minChange then
                -- stop exists
                valuemap = core.valuemap()
                valuemap.Command = "EditOrder"
                valuemap.OfferID = trade.OfferID
                valuemap.AcctID = trade.AccountID
                valuemap.OrderID = order
                valuemap.Rate = stopValue
                executing = true
                success, msg = terminal:execute(200, valuemap)
                if not (success) then
                    executing = false
                    terminal:alertMessage(
                        instance.bid:instrument(),
                        instance.bid[NOW],
                        "Failed change stop " .. msg,
                        instance.bid:date(NOW)
                    )
                end
            end
        end
    end
end

function ExtUpdate(id, source, period)
    if id == 1 and tradeExist then
        if period > tsource:first() + instance.parameters.Frame then
            -- check whether trade exists
            local trade, order

            if FirstStart then
                --             FirstStart=false;
                FirstStop(source, period)
            else
                local stopValue
                local stopSide
                local UpFractal, DnFractal = IsFractal(source, period)

                if UpFractal or DnFractal then
                    local trades = core.host:findTable("trades")
                    local enum = trades:enumerator()
                    while true do
                        local trade = enum:next()
                        if trade == nil then
                            break
                        end
                        if trade.Instrument == instance.parameters.Symbol then
                            if trade.BS == "B" then
                                if DnFractal then
                                    stopValue =
                                        tsource.low[period - Shift] -
                                        instance.parameters.Indent * instance.bid:pipSize()
                                    setStop(trade, stopValue, "S")
                                end
                            else
                                if UpFractal then
                                    stopValue =
                                        tsource.high[period - Shift] +
                                        instance.parameters.Indent * instance.bid:pipSize()
                                    setStop(trade, stopValue, "B")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        executing = false
        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[NOW],
                "Failed create/change stop " .. message,
                instance.bid:date(NOW)
            )
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
