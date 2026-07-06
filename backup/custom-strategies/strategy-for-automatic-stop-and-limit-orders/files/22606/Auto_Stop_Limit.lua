-- Id: 5517
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=11080

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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

function Init() --The strategy profile initialization
    strategy:name("Auto Stop&Limit strategy")
    strategy:description("Auto Stop&Limit strategy")
    strategy:setTag("Version", "2")

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addString("AllowDirection", "Allow direction for positions", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Both", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Long", "", "Long")
    strategy.parameters:addStringAlternative("AllowDirection", "Short", "", "Short")
end

-- Trading parameters
local Account = nil
local Amount = nil
local BaseSize = nil
local PipSize
local SetLimit = nil
local Limit = nil
local SetStop = nil
local Stop = nil
local TrailingStop = nil
local AllowDirection

--
--
--
function Prepare(nameOnly)
    AllowDirection = instance.parameters.AllowDirection

    local name
    name = profile:id() .. "(" .. instance.bid:name() .. "," .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    Account = instance.parameters.Account
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    PipSize = instance.bid:pipSize()
    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit
    SetStop = instance.parameters.SetStop
    Stop = instance.parameters.Stop
    TrailingStop = instance.parameters.TrailingStop

    Source = ExtSubscribe(2, nil, "t1", true, "close")
end

function haveTrades(BuySell)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and (row.BS == BuySell or BuySell == nil) then
            return true;
        end
        row = enum:next()
    end
    return false
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if not instance.parameters.AllowTrade then
        return
    end
    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    if (haveTrades()) then
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end

            if row.AccountID == Account and row.OfferID == Offer then
                -- Close position if we have corresponding closing conditions.
                if row.BS == "B" and instance.parameters.AllowDirection ~= "Short" then
                    if (row.StopOrderID == "" or row.StopOrderID == nil) and SetStop then
                        valuemap = core.valuemap()
                        valuemap.Command = "CreateOrder"
                        valuemap.OrderType = "S"
                        valuemap.OfferID = row.OfferID
                        valuemap.AcctID = row.AccountID
                        valuemap.TradeID = row.TradeID
                        valuemap.Quantity = row.Lot
                        valuemap.Rate = row.Open - Stop * PipSize
                        valuemap.BuySell = "S"
                        if TrailingStop then
                            valuemap.TrailUpdatePips = 1
                        end

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
                    end
                    if (row.LimitOrderID == "" or row.LimitOrderID == nil) and SetLimit then
                        valuemap = core.valuemap()
                        valuemap.Command = "CreateOrder"
                        valuemap.OrderType = "L"
                        valuemap.OfferID = row.OfferID
                        valuemap.AcctID = row.AccountID
                        valuemap.TradeID = row.TradeID
                        valuemap.Quantity = row.Lot
                        valuemap.Rate = row.Open + Limit * source:pipSize()
                        valuemap.BuySell = "S"

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
                    end
                elseif row.BS == "S" and instance.parameters.AllowDirection ~= "Long" then
                    if (row.StopOrderID == "" or row.StopOrderID == nil) and SetStop then
                        valuemap = core.valuemap()
                        valuemap.Command = "CreateOrder"
                        valuemap.OrderType = "S"
                        valuemap.OfferID = row.OfferID
                        valuemap.AcctID = row.AccountID
                        valuemap.TradeID = row.TradeID
                        valuemap.Quantity = row.Lot
                        valuemap.Rate = row.Open + Stop * PipSize
                        valuemap.BuySell = "B"
                        if TrailingStop then
                            valuemap.TrailUpdatePips = 1
                        end

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
                    end
                    if (row.LimitOrderID == "" or row.LimitOrderID == nil) and SetLimit then
                        valuemap = core.valuemap()
                        valuemap.Command = "CreateOrder"
                        valuemap.OrderType = "L"
                        valuemap.OfferID = row.OfferID
                        valuemap.AcctID = row.AccountID
                        valuemap.TradeID = row.TradeID
                        valuemap.Quantity = row.Lot
                        valuemap.Rate = row.Open - Limit * source:pipSize()
                        valuemap.BuySell = "B"

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
                    end
                end
            end
        end
    end
end

-- The strategy instance finalization.
function ReleaseInstance()
end

function AsyncOperationFinished(cookie, successful, message)
    if not successful then
        core.host:trace("Error: " .. message)
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
