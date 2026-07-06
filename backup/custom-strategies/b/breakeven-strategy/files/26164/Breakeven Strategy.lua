-- Id: 5829
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Breakeven Strategy")
    strategy:description("")

    strategy.parameters:addGroup("Price")

    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addString("Period", "Timeframe", "", "m1")
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Stop")
    strategy.parameters:addInteger("Profit", "Min Profit", "", 0, 0, 1000000)

    strategy.parameters:addGroup("Trade")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "")
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE)

    --strategy.parameters:addGroup("Account");
    --strategy.parameters:addString("Account", "(FIFO) Choose Account", "", "");
    --strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
end

local first = true
local stopOrder = nil -- the identifier of the stop order
local Source = nil
local sar = nil
local timer
local minChange
local executing = false
local Profit
local first

local Parameters = {}
local CanClose = true

local orderId
local tradeId
local requestId

function Prepare(onlyName)
    local name

    Profit = instance.parameters.Profit
    name =
        profile:id() ..
        "(" ..
            instance.bid:instrument() .. "[" .. instance.parameters.Period .. "], " .. instance.parameters.Trade .. ")"

    tradeId = instance.parameters.Trade

    local trade = core.host:findTable("trades"):find("TradeID", tradeId)
    assert(trade ~= nil, "Trade can not be found")

    Account = trade.AccountID
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)

    instance:name(name)
    if onlyName then
        return
    end

    minChange = math.pow(10, -instance.bid:getPrecision())

    ExtSetupSignal(name .. ":", true)
    Source = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar")

    first = Source:first() - 1
end

function moveStop(rate, side)
    -- Check that order is stil exist
    local order = nil

    if orderId ~= nil then
        order = core.host:findTable("orders"):find("OrderID", orderId)
    end

    if order == nil then
        -- =======================================================================
        --                           CREATE NEW ORDER                           --
        -- =======================================================================

        valuemap = core.valuemap()
        valuemap.Command = "CreateOrder"
        valuemap.OfferID = Offer
        valuemap.Rate = rate
        valuemap.BuySell = side

        if CanClose then
            local trade = core.host:findTable("trades"):find("TradeID", tradeId)

            valuemap.OrderType = "S"
            valuemap.AcctID = trade.AccountID
            valuemap.TradeID = trade.TradeID
            valuemap.Quantity = trade.Lot
        else
            valuemap.OrderType = "SE"
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
        end

        success, msg = terminal:execute(200, valuemap)
        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[NOW],
                "Failed create stop " .. msg,
                instance.bid:date(NOW)
            )
        else
            requestId = core.parseCsv(msg)[0]
        end
    else
        -- =======================================================================
        --                      CHANGE EXISTING ORDER                           --
        -- =======================================================================
        if math.abs(rate - order.Rate) > minChange then
            -- stop exists
            valuemap = core.valuemap()
            valuemap.Command = "EditOrder"
            valuemap.AcctID = order.AccountID
            valuemap.OrderID = order.OrderID
            valuemap.Rate = rate

            success, msg = terminal:execute(200, valuemap)
            if not (success) then
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

function ExtUpdate(id, source, period)
    if id ~= 1 or not instance.parameters.AllowTrade then
        return
    end

    if period < first then
        return
    end

    if not (checkReady("trades")) or not (checkReady("orders")) then
        return
    end

    -- check whether trade exists
    local trade, order

    trade = core.host:findTable("trades"):find("TradeID", tradeId)

    if trade == nil then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[NOW],
            "Trade " .. instance.parameters.Trade .. " disappear",
            instance.bid:date(NOW)
        )
        core.host:execute("stop")
        return
    end

    if requestId ~= nil then
        order = core.host:findTable("orders"):find("RequestID", requestId)
        if order ~= nil then
            orderId = order.OrderID
            requestId = nil
        end
    end

    local stopValue, valuemap, success, msg
    local stopSide

    if trade.BS == "B" then
        if trade.PL > Profit then
            stopValue = instance.ask[NOW] - trade.PL * source:pipSize()
        else
            return
        end

        stopSide = "S"
        if stopValue >= instance.bid[NOW] then
            return
        end
    else
        if trade.PL > Profit then
            stopValue = instance.bid[NOW] + trade.PL * source:pipSize()
        else
            return
        end
        stopSide = "B"
        if stopValue <= instance.ask[NOW] then
            return
        end
    end

    moveStop(stopValue, stopSide)
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

function checkReady(table)
    return core.host:execute("isTableFilled", table)
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
