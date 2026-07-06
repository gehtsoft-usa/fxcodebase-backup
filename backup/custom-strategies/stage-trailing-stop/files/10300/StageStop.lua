-- Id: 3802
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4109

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
    strategy:name("Set stop by stages")
    strategy:description("Strategy changes stop followiung to the user's stages")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addGroup("Stop Parameters")
    strategy.parameters:addInteger("Level1", "Level 1 in pips", "", 10)
    strategy.parameters:addInteger("Stop1", "Stop 1 in pips", "", 50)
    strategy.parameters:addInteger("Level2", "Level 2 in pips", "", 20)
    strategy.parameters:addInteger("Stop2", "Stop 2 in pips", "", 40)
    strategy.parameters:addInteger("Level3", "Level 3 in pips", "", 30)
    strategy.parameters:addInteger("Stop3", "Stop 3 in pips", "", 30)
    strategy.parameters:addInteger("Level4", "Level 4 in pips", "", 40)
    strategy.parameters:addInteger("Stop4", "Stop 4 in pips", "", 20)
    strategy.parameters:addInteger("Level5", "Level 5 in pips", "", 50)
    strategy.parameters:addInteger("Stop5", "Stop 5 in pips", "", 10)

    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addString("Period", "Timeframe", "", "m1")
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trade")
    strategy.parameters:addString("Trade", "Choose Trade", "", "")
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE)
end

local tradeExist = true
local first = true
local stopOrder = nil -- the identifier of the stop order
local tsource = nil
local timer
local minChange
local executing = false

function Prepare(onlyName)
    local name
    name =
        profile:id() ..
        "(" .. instance.bid:instrument() .. "[" .. instance.parameters.Period .. "]" .. instance.parameters.Trade .. ")"
    instance:name(name)
    if onlyName then
        return
    end

    minChange = math.pow(10, -instance.bid:getPrecision())

    ExtSetupSignal(name .. ":", true)
    tsource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar")
end

function ExtUpdate(id, source, period)
    if id == 1 and tradeExist then
        if period > tsource:first() then
            -- check whether trade exists
            local trade, order

            if not (core.host:execute("isTableFilled", "trades")) then
                core.host:trace("not filled")
                -- relogin??
                return
            end

            --if not(core.host:execute("isReadyForTrade")) then
            -- relogin??
            if not (core.host:execute("isTableFilled", "offers")) then
                core.host:trace("not ready")
                return
            end

            trade = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade)

            if trade == nil then
                tradeExist = false
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Trade " .. instance.parameters.Trade .. " disappear",
                    instance.bid:date(NOW)
                )
                core.host:execute("stop")
                return
            end

            local stopValue, valuemap, success, msg
            local stopSide
            local Fl = true
            local OrderPL = trade.PL
            if trade.BS == "B" then
                if OrderPL >= instance.parameters.Level5 and instance.parameters.Level5 ~= 0 then
                    stopValue = instance.bid[NOW] - instance.parameters.Stop5 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level4 and instance.parameters.Level4 ~= 0 then
                    stopValue = instance.bid[NOW] - instance.parameters.Stop4 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level3 and instance.parameters.Level3 ~= 0 then
                    stopValue = instance.bid[NOW] - instance.parameters.Stop3 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level2 and instance.parameters.Level2 ~= 0 then
                    stopValue = instance.bid[NOW] - instance.parameters.Stop2 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level1 and instance.parameters.Level1 ~= 0 then
                    stopValue = instance.bid[NOW] - instance.parameters.Stop1 * instance.bid:pipSize()
                else
                    stopValue = 0
                end

                if trade.StopOrderID ~= "" and trade.StopOrderID ~= nil then
                    if stopValue < trade.Stop then
                        return
                    end
                end
                stopSide = "S"
                if stopValue >= instance.bid[NOW] then
                    --core.host:trace(string.format("not passed %f >= %f", stopValue, instance.bid[NOW]));
                    return
                end
            else
                if OrderPL >= instance.parameters.Level5 and instance.parameters.Level5 ~= 0 then
                    stopValue = instance.ask[NOW] + instance.parameters.Stop5 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level4 and instance.parameters.Level4 ~= 0 then
                    stopValue = instance.ask[NOW] + instance.parameters.Stop4 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level3 and instance.parameters.Level3 ~= 0 then
                    stopValue = instance.ask[NOW] + instance.parameters.Stop3 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level2 and instance.parameters.Level2 ~= 0 then
                    stopValue = instance.ask[NOW] + instance.parameters.Stop2 * instance.bid:pipSize()
                elseif OrderPL >= instance.parameters.Level1 and instance.parameters.Level1 ~= 0 then
                    stopValue = instance.ask[NOW] + instance.parameters.Stop1 * instance.bid:pipSize()
                else
                    stopValue = 0
                end
                if trade.StopOrderID ~= "" and trade.StopOrderID ~= nil then
                    if stopValue > trade.Stop then
                        return
                    end
                end
                stopSide = "B"
                if stopValue <= instance.ask[NOW] then
                    --core.host:trace(string.format("not passed %f <= %f", stopValue, instance.ask[NOW]));
                    return
                end
            end

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
