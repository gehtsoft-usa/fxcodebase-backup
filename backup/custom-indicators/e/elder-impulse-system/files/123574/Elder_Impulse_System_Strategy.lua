-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=993
-- Id: 23768
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    strategy:name("Elder impulse system strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert")
    strategy:description("Elder impulse system strategy")

    strategy.parameters:addGroup("Elder inpulse system parameters")
    strategy.parameters:addString("TF1", "Time Frame 1", "", "H1")
    strategy.parameters:setFlag("TF1", core.FLAG_PERIODS)
    strategy.parameters:addInteger("EMA1", "EMA periods 1", "", 13, 1, 100)
    strategy.parameters:addInteger("MACDF1", "MACD periods fast 1", "", 12, 1, 100)
    strategy.parameters:addInteger("MACDS1", "MACD periods slow 1", "", 26, 1, 100)
    strategy.parameters:addString("TF2", "Time Frame 2", "", "H2")
    strategy.parameters:setFlag("TF2", core.FLAG_PERIODS)
    strategy.parameters:addInteger("EMA2", "EMA periods 2", "", 13, 1, 100)
    strategy.parameters:addInteger("MACDF2", "MACD periods fast 2", "", 12, 1, 100)
    strategy.parameters:addInteger("MACDS2", "MACD periods slow 2", "", 26, 1, 100)
    strategy.parameters:addString("TF3", "Time Frame 3", "", "H4")
    strategy.parameters:setFlag("TF3", core.FLAG_PERIODS)
    strategy.parameters:addInteger("EMA3", "EMA periods 3", "", 13, 1, 100)
    strategy.parameters:addInteger("MACDF3", "MACD periods fast 3", "", 12, 1, 100)
    strategy.parameters:addInteger("MACDS3", "MACD periods slow 3", "", 26, 1, 100)
    strategy.parameters:addString("TF4", "Time Frame 4", "", "H6")
    strategy.parameters:setFlag("TF4", core.FLAG_PERIODS)
    strategy.parameters:addInteger("EMA4", "EMA periods 4", "", 13, 1, 100)
    strategy.parameters:addInteger("MACDF4", "MACD periods fast 4", "", 12, 1, 100)
    strategy.parameters:addInteger("MACDS4", "MACD periods slow 4", "", 26, 1, 100)
    strategy.parameters:addString("TF5", "Time Frame 5", "", "H8")
    strategy.parameters:setFlag("TF5", core.FLAG_PERIODS)
    strategy.parameters:addInteger("EMA5", "EMA periods 5", "", 13, 1, 100)
    strategy.parameters:addInteger("MACDF5", "MACD periods fast 5", "", 12, 1, 100)
    strategy.parameters:addInteger("MACDS5", "MACD periods slow 5", "", 26, 1, 100)
    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "close", "", "close")
    strategy.parameters:addStringAlternative("Price", "open", "", "open")
    strategy.parameters:addStringAlternative("Price", "high", "", "high")
    strategy.parameters:addStringAlternative("Price", "low", "", "low")
    strategy.parameters:addStringAlternative("Price", "median", "", "median")
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addInteger("Count", "Count", "Count", 4)
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addString("AllowDirection", "Allow direction for positions", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Both", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Long", "", "Long")
    strategy.parameters:addStringAlternative("AllowDirection", "Short", "", "Short")

    strategy.parameters:addGroup("Signal Parameters")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false)

    strategy.parameters:addGroup("Email Parameters")
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
    strategy.parameters:addString("Email", "Email address", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local ShowAlert
local SoundFile
local RecurrentSound
local SendEmail, Email

local EIS1 = nil
local EIS2 = nil
local EIS3 = nil
local EIS4 = nil
local EIS5 = nil

local openLevel = 0
local closeLevel = 0
local confirmTrend

local AllowTrade = nil
local Account = nil
local Amount = nil
local BaseSize = nil
local PipSize
local SetLimit = nil
local Limit = nil
local SetStop = nil
local Stop = nil
local TrailingStop = nil
local CanClose = nil
local AllowDirection

function Prepare()
    ShowAlert = instance.parameters.ShowAlert
    AllowDirection = instance.parameters.AllowDirection
    local PlaySound = instance.parameters.PlaySound
    if PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or SoundFile ~= "", "Sound file must be chosen")
    RecurrentSound = instance.parameters.Recurrent

    local SendEmail = instance.parameters.SendEmail
    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or Email ~= "", "Email address must be specified")
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "(" .. instance.bid:name() .. ")"
    instance:name(name)

    AllowTrade = instance.parameters.AllowTrade
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        PipSize = instance.bid:pipSize()
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop
        TrailingStop = instance.parameters.TrailingStop
    end

    Source1 = ExtSubscribe(2, nil, instance.parameters.TF1, true, instance.parameters.Price)
    Source2 = ExtSubscribe(3, nil, instance.parameters.TF2, true, instance.parameters.Price)
    Source3 = ExtSubscribe(4, nil, instance.parameters.TF3, true, instance.parameters.Price)
    Source4 = ExtSubscribe(5, nil, instance.parameters.TF4, true, instance.parameters.Price)
    Source5 = ExtSubscribe(6, nil, instance.parameters.TF5, true, instance.parameters.Price)

    assert(
        core.indicators:findIndicator("ELDER_IMPULSE_SYSTEM") ~= nil,
        "ELDER_IMPULSE_SYSTEM" .. " indicator must be installed"
    )
    EIS1 =
        core.indicators:create(
        "ELDER_IMPULSE_SYSTEM",
        Source1,
        instance.parameters.EMA1,
        instance.parameters.MACDF1,
        instance.parameters.MACDS1
    )
    EIS2 =
        core.indicators:create(
        "ELDER_IMPULSE_SYSTEM",
        Source2,
        instance.parameters.EMA2,
        instance.parameters.MACDF2,
        instance.parameters.MACDS2
    )
    EIS3 =
        core.indicators:create(
        "ELDER_IMPULSE_SYSTEM",
        Source3,
        instance.parameters.EMA3,
        instance.parameters.MACDF3,
        instance.parameters.MACDS3
    )
    EIS4 =
        core.indicators:create(
        "ELDER_IMPULSE_SYSTEM",
        Source4,
        instance.parameters.EMA4,
        instance.parameters.MACDF4,
        instance.parameters.MACDS4
    )
    EIS5 =
        core.indicators:create(
        "ELDER_IMPULSE_SYSTEM",
        Source5,
        instance.parameters.EMA5,
        instance.parameters.MACDF5,
        instance.parameters.MACDS5
    )

    ExtSetupSignal(profile:id() .. ":", ShowAlert)
    ExtSetupSignalMail(name)
end

function haveTrades(BuySell)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and (row.BS == BuySell or BuySell == nil) then
            return true
        end
        row = enum:next()
    end
    return false
end

function ExtUpdate(id, source, period)
    EIS1:update(core.UpdateLast)
    EIS2:update(core.UpdateLast)
    EIS3:update(core.UpdateLast)
    EIS4:update(core.UpdateLast)
    EIS5:update(core.UpdateLast)

    if
        not EIS1.UP:hasData(period) or not EIS2.UP:hasData(period) or not EIS3.UP:hasData(period) or
            not EIS4.UP:hasData(period) or
            not EIS5.UP:hasData(period)
     then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false

    local SignalCountB = 0
    local SignalCountS = 0
    SignalCountB = (EIS1.UP[period] + EIS2.UP[period] + EIS3.UP[period] + EIS4.UP[period] + EIS5.UP[period]) / 100
    SignalCountS = (EIS1.DN[period] + EIS2.DN[period] + EIS3.DN[period] + EIS4.DN[period] + EIS5.DN[period]) / 100

    if SignalCountB >= instance.parameters.Count then
        if instance.parameters.TypeSignal == "direct" then
            MustB = true
        else
            MustS = true
        end
    end

    if SignalCountS >= instance.parameters.Count then
        if instance.parameters.TypeSignal == "direct" then
            MustS = true
        else
            MustB = true
        end
    end

    if (haveTrades()) then
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end

            if row.AccountID == Account and row.OfferID == Offer then
                if row.BS == "B" then
                    if MustS then
                        if ShowAlert then
                            if instance.parameters.AllowDirection == "Long" then
                                ExtSignal(source, period, "Close BUY", SoundFile, Email, RecurrentSound)
                            else
                                ExtSignal(source, period, "Close BUY and SELL", SoundFile, Email, RecurrentSound)
                            end
                        end

                        if AllowTrade then
                            Close(row)
                            if instance.parameters.AllowDirection ~= "Long" then
                                Open("S")
                            end
                        end
                    end
                elseif row.BS == "S" then
                    if MustB then
                        if ShowAlert then
                            if instance.parameters.AllowDirection == "Short" then
                                ExtSignal(source, period, "Close SELL", SoundFile, Email, RecurrentSound)
                            else
                                ExtSignal(source, period, "Close SELL and BUY", SoundFile, Email, RecurrentSound)
                            end
                        end

                        if AllowTrade then
                            Close(row)
                            if instance.parameters.AllowDirection ~= "Short" then
                                Open("B")
                            end
                        end
                    end
                end
            end
        end
    else
        if MustB == true and instance.parameters.AllowDirection ~= "Short" then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

        if MustS == true and instance.parameters.AllowDirection ~= "Long" then
            if ShowAlert then
                ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("S")
            end
        end
    end
end

function ReleaseInstance()
end

function Open(side)
    local valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.CustomID = CID
    valuemap.BuySell = side
    valuemap.QTXT = "1"
    if SetStop and CanClose then
        valuemap.PegTypeStop = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end
    if SetLimit and CanClose then
        valuemap.PegTypeLimit = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)

    if not (CanClose) then
        if SetStop then
            valuemap = core.valuemap()
            valuemap.OrderType = "SE"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "y"
            if side == "B" then
                valuemap.BuySell = "S"
                rate = instance.ask[NOW] - Stop * PipSize
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] + Stop * PipSize
                valuemap.Rate = rate
            end
            if TrailingStop then
                valuemap.TrailUpdatePips = 1
            end
            success, msg = terminal:execute(200, valuemap)
            assert(success, msg)
        end
        if SetLimit then
            valuemap = core.valuemap()
            valuemap.OrderType = "LE"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "y"
            if side == "B" then
                valuemap.BuySell = "S"
                rate = instance.ask[NOW] + Limit * PipSize
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] - Limit * PipSize
                valuemap.Rate = rate
            end
            success, msg = terminal:execute(200, valuemap)
            assert(success, msg)
        end
    end
end

function Close(trade)
    local valuemap
    valuemap = core.valuemap()

    if CanClose then
        valuemap.OrderType = "CM"
        valuemap.TradeID = trade.TradeID
    else
        valuemap.OrderType = "OM"
    end

    valuemap.OfferID = trade.OfferID
    valuemap.AcctID = trade.AccountID
    valuemap.Quantity = trade.Lot
    valuemap.CustomID = trade.QTXT
    if trade.BS == "B" then
        valuemap.BuySell = "S"
    else
        valuemap.BuySell = "B"
    end
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
end

function AsyncOperationFinished(cookie, successful, message)
    if not successful then
        core.host:trace("Error: " .. message)
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
