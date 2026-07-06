-- Id: 9367
-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    strategy:name("Laguerre Filter Close Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup(" Laguerre Filter Calculation")
    strategy.parameters:addDouble("Gamma", "Gamma", "", 0.7, -0.5, 1.05)

    strategy.parameters:addGroup("Account")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("Mode", "Close type", "", "Any")
    strategy.parameters:addStringAlternative("Mode", "Any", "", "Any")
    strategy.parameters:addStringAlternative("Mode", "Cross Over", "", "Over")
    strategy.parameters:addStringAlternative("Mode", "Cross Under", "", "Under")

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

    strategy.parameters:addGroup("Alerts")
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local first = true
local Source = nil

local AcctID
local Trade
local AllowTrade

local ShowAlert
local Email
local SendEmail
local RecurrentSound = false
local SoundFile = nil
local Gamma
local Indicator
local Mode
function PrepareTrading()
    AllowMultiple = instance.parameters.AllowMultiple
    Mode = instance.parameters.Mode
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE
    Gamma = instance.parameters.Gamma

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
    Trade = instance.parameters.Trade
end

function Prepare(onlyName)
    PrepareTrading()

    local name = profile:id() .. ", " .. instance.bid:instrument() .. ", " .. AcctID .. ", " .. Trade .. ", " .. Gamma
    instance:name(name)

    local TradeID = core.host:findTable("trades"):find("TradeID", Trade)
    assert(TradeID ~= nil, "Trade can not be found")

    if onlyName then
        return
    end

    assert(
        core.indicators:findIndicator("LAGUERRE_FILTER") ~= nil,
        "Please, download and install LAGUERRE_FILTER.LUA indicator"
    )
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "close")
    Indicator = core.indicators:create("LAGUERRE_FILTER", Source, Gamma)

    first = Indicator.DATA:first()
end

function ExtUpdate(id, source, period)
    if id ~= 1 then
        return
    end

    Indicator:update(core.UpdateLast)

    if period < first then
        return
    end

    if not (checkReady("trades")) or not (checkReady("orders")) then
        return
    end

    local TradeID = core.host:findTable("trades"):find("TradeID", Trade).TradeID

    if TradeID == nil then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[NOW],
            "Trade " .. Trade .. " disappear",
            instance.bid:date(NOW)
        )
        core.host:execute("stop")
        return
    else
        if core.crossesOver(Source.close, Indicator.DATA, period) and Mode ~= "Under" then
            MarketClose(TradeID)
        elseif core.crossesOver(Source.close, Indicator.DATA, period) and Mode ~= "Over" then
            MarketClose(TradeID)
        end
    end
end

function MarketClose(TradeID)
    if not (AllowTrade) then
        return true
    end

    local AmountK = core.host:findTable("trades"):find("TradeID", TradeID).AmountK
    local Instrument = core.host:findTable("trades"):find("TradeID", TradeID).Instrument
    local OfferID = core.host:findTable("offers"):find("Instrument", Instrument).OfferID
    local IsBuy = core.host:findTable("trades"):find("TradeID", TradeID).IsBuy
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
