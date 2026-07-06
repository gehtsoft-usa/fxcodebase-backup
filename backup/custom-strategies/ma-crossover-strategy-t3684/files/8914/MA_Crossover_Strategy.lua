-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3684
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("MA Crossover strategy")
    strategy:description("MA Crossover strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Indicator parameters")
    strategy.parameters:addString("FastMA_Method", "FastMA_Method", "", "EMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("FastMA_Method", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative("FastMA_Method", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "HMA", "", "HMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "T3", "", "T3")
    strategy.parameters:addStringAlternative("FastMA_Method", "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative("FastMA_Method", "Median", "", "Median")
    strategy.parameters:addStringAlternative("FastMA_Method", "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative("FastMA_Method", "REMA", "", "REMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative("FastMA_Method", "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative("FastMA_Method", "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative("FastMA_Method", "JSmooth", "", "JSmooth")

    strategy.parameters:addInteger("FastMA_Period", "FastMA_Period", "", 5)

    strategy.parameters:addString("SlowMA_Method", "SlowMA_Method", "", "EMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative("SlowMA_Method", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "HMA", "", "HMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "T3", "", "T3")
    strategy.parameters:addStringAlternative("SlowMA_Method", "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative("SlowMA_Method", "Median", "", "Median")
    strategy.parameters:addStringAlternative("SlowMA_Method", "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative("SlowMA_Method", "REMA", "", "REMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative("SlowMA_Method", "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative("SlowMA_Method", "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative("SlowMA_Method", "JSmooth", "", "JSmooth")

    strategy.parameters:addInteger("SlowMA_Period", "SlowMA_Period", "", 8)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

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

-- Signal Parameters
local ShowAlert
local SoundFile
local RecurrentSound
local SendEmail, Email

-- Internal indicators
local FastMA = nil
local SlowMA = nil

-- Strategy parameters
local openLevel = 0
local closeLevel = 0
local confirmTrend

-- Trading parameters
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

--
--
--
function Prepare()
    ShowAlert = instance.parameters.ShowAlert
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
    name =
        profile:id() ..
        "(" ..
            instance.bid:name() ..
                "." ..
                    instance.parameters.TF ..
                        "," ..
                            "FastMA(" ..
                                instance.parameters.FastMA_Method ..
                                    instance.parameters.FastMA_Period ..
                                        ")" ..
                                            "SlowMA(" ..
                                                instance.parameters.SlowMA_Method ..
                                                    instance.parameters.SlowMA_Period .. "))"
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

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    FastMA =
        core.indicators:create(
        "AVERAGES",
        Source.close,
        instance.parameters.FastMA_Method,
        instance.parameters.FastMA_Period,
        false
    )
    SlowMA =
        core.indicators:create(
        "AVERAGES",
        Source.open,
        instance.parameters.SlowMA_Method,
        instance.parameters.SlowMA_Period,
        false
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

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    FastMA:update(core.UpdateLast)
    SlowMA:update(core.UpdateLast)

    -- Check that we have enough data
    if (FastMA.DATA:first() > (period - 1)) then
        return
    end
    if (SlowMA.DATA:first() > (period - 1)) then
        return
    end

    local FMA, SMA = FastMA.DATA, SlowMA.DATA
    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false
    if
        (FMA[period - 1] > SMA[period - 1] and FMA[period - 2] < SMA[period - 2] and FMA[period] > SMA[period] and
            instance.parameters.TypeSignal == "direct") or
            (FMA[period - 1] < SMA[period - 1] and FMA[period - 2] > SMA[period - 2] and FMA[period] < SMA[period] and
                instance.parameters.TypeSignal == "reverse")
     then
        MustB = true
    end
    if
        (FMA[period - 1] < SMA[period - 1] and FMA[period - 2] > SMA[period - 2] and FMA[period] < SMA[period] and
            instance.parameters.TypeSignal == "direct") or
            (FMA[period - 1] > SMA[period - 1] and FMA[period - 2] < SMA[period - 2] and FMA[period] > SMA[period] and
                instance.parameters.TypeSignal == "reverse")
     then
        MustS = true
    end

    if (haveTrades()) then
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end

            if row.AccountID == Account and row.OfferID == Offer then
                -- Close position if we have corresponding closing conditions.
                if row.BS == "B" then
                    if MustS == true then
                        if ShowAlert then
                            ExtSignal(source, period, "Close BUY and SELL", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                            Open("S")
                        end
                    end
                elseif row.BS == "S" then
                    if MustB == true then
                        if ShowAlert then
                            ExtSignal(source, period, "Close SELL and BUY", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                            Open("B")
                        end
                    end
                end
            end
        end
    else
        -- Open BUY (Long) position if MACD line crosses over SIGNAL line
        -- in negative area below openLevel. Also check MA trend if
        -- confirmTrend flag is 'true'
        if MustB == true then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

        -- Open SELL (Short) position if MACD line crosses under SIGNAL line
        -- in positive area above openLevel. Also check MA trend if
        -- confirmTrend flag is 'true'
        if MustS == true then
            if ShowAlert then
                ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("S")
            end
        end
    end
end

-- The strategy instance finalization.
function ReleaseInstance()
end

-- The method enters to the market
function Open(side)
    local valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.CustomID = CID
    valuemap.BuySell = side
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

    -- FIFO Account, in that case we have to open Net Limit and Stop Orders
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
            --core.host:trace('Set stop @ ' .. rate);
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
            --core.host:trace('Set limit @ ' .. rate);
            assert(success, msg)
        end
    end
end

-- Closes specific position
function Close(trade)
    local valuemap
    valuemap = core.valuemap()

    if CanClose then
        -- non-FIFO account, create a close market order
        valuemap.OrderType = "CM"
        valuemap.TradeID = trade.TradeID
    else
        -- FIFO account, create an opposite market order
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
