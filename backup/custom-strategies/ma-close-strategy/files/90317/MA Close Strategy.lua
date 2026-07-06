-- Id: 10283
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=59731

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

function Init()
    strategy:name("MA Close Strategy")
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy.parameters:addGroup("Calculation")

    strategy.parameters:addInteger("Period", "Period", "Period", 50)
    strategy.parameters:addString("Method", "MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")

    strategy.parameters:addGroup("Account")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("AcctID", "Choose Account", "", "")
    strategy.parameters:setFlag("AcctID", core.FLAG_ACCOUNT)

    strategy.parameters:addString("Trade", "Choose Trade", "", "")
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE)

    strategy.parameters:addGroup("Price")

    strategy.parameters:addString("TF", "Timeframe", "", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("Price", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("Price", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    strategy.parameters:addGroup("Alerts")

    strategy.parameters:addString("Mode", "End of Turn/Live", "", "1")
    strategy.parameters:addStringAlternative("Mode", "End of Turn", "", "1")
    strategy.parameters:addStringAlternative("Mode", "Live", "", "2")

    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end
local Mode
local first = true
local Source = nil
local StopUpdate = false
local AcctID
local Trade
local AllowTrade

local ShowAlert
local Email
local SendEmail
local RecurrentSound = false
local SoundFile = nil
local Method, Period, Price
local Indicator
local TradeID
local IsBuy
local TickSource
function PrepareTrading()
    IsBuy = core.host:findTable("trades"):find("TradeID", TradeID).IsBuy
    Mode = instance.parameters.Mode

    local PlaySound = instance.parameters.PlaySound
    if PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen")

    ShowAlert = instance.parameters.ShowAlert
    RecurrentSound = instance.parameters.RecurrentSound

    SendEmail = instance.parameters.SendEmail

    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

    AllowTrade = instance.parameters.AllowTrade
    AcctID = instance.parameters.AcctID
end

function Prepare(onlyName)
    Trade = instance.parameters.Trade
    assert(TradeID ~= nil, "Trade can not be found")
    TradeID = core.host:findTable("trades"):find("TradeID", Trade).TradeID

    Method = instance.parameters.Method
    Period = instance.parameters.Period
    Price = instance.parameters.Price

    PrepareTrading()

    local name =
        profile:id() ..
        ", " ..
            instance.bid:instrument() ..
                ", " .. AcctID .. ", " .. Trade .. ", " .. Method .. ", " .. Price .. ", " .. Period
    instance:name(name)

    if onlyName then
        return
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    TickSource = ExtSubscribe(2, nil, "t1", instance.parameters.Type == "Bid", "close")
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    Indicator = core.indicators:create(Method, Source[Price], Period)

    first = Indicator.DATA:first()
end

function ExtUpdate(id, source, period)
    if id == 1 then
        Indicator:update(core.UpdateLast)
    end

    if id ~= 1 and Mode == "1" then
        return
    elseif id ~= 2 and Mode == "2" then
        return
    end

    local Last = Source.close:size() - 1

    if not Indicator.DATA:hasData(Last) then
        return
    end

    if not (checkReady("trades")) or not (checkReady("orders")) then
        return
    end

    if core.host:findTable("trades"):find("TradeID", Trade).TradeID == nil then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[NOW],
            "Trade " .. Trade .. " disappear",
            instance.bid:date(NOW)
        )
        core.host:execute("stop")
        return
    end

    if IsBuy then
        if Source.close[Source.close:size() - 1] < Indicator.DATA[Last] then
            MarketClose()
        end
    else
        if Source.close[Source.close:size() - 1] > Indicator.DATA[Last] then
            MarketClose()
        end
    end
end

function MarketClose()
    if not (AllowTrade) then
        return true
    end

    -- local Instrument= instance.bid:instrument();
    local AmountK = core.host:findTable("trades"):find("TradeID", TradeID).AmountK
    local Instrument = core.host:findTable("trades"):find("TradeID", TradeID).Instrument
    local OfferID = core.host:findTable("offers"):find("Instrument", Instrument).OfferID
    local Close = core.host:findTable("trades"):find("TradeID", TradeID).Close
    local lotSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), AcctID)
    local CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), AcctID)

    if IsBuy then
        Side = "S"
    else
        Side = "B"
    end

    local valuemap, success, msg

    valuemap = core.valuemap()

    if not CanClose then
        valuemap.OrderType = "OM"
    else
        valuemap.OrderType = "CM"
    end

    valuemap.Command = "CreateOrder"
    valuemap.OfferID = OfferID
    valuemap.Rate = Close
    valuemap.TradeID = TradeID
    valuemap.Quantity = AmountK * lotSize
    valuemap.AcctID = AcctID
    valuemap.BuySell = Side
    success, msg = terminal:execute(200, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    if ShowAlert then
        terminal:alertMessage(Instrument, instance.bid[NOW], "Position Closed", instance.bid:date(NOW))
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound)
    end

    if Email ~= nil then
        terminal:alertEmail(
            Email,
            "Position Close",
            profile:id() ..
                "(" ..
                    instance.bid:instrument() ..
                        ")" .. instance.bid[NOW] .. ", " .. "Position Close" .. ", " .. instance.bid:date(NOW)
        )
    end

    core.host:execute("stop")
    return true
end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                "Position Close Failure" .. message,
                instance.bid:date(instance.bid:size() - 1)
            )
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table)
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
