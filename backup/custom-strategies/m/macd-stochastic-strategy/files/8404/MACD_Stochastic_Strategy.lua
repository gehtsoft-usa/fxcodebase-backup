-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3518
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("MACD-Stochastic strategy")
    strategy:description("MACD-Stochastic strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("MACD indicator parameters")
    strategy.parameters:addInteger("FastPeriod", "Fast period", "Fast period", 12, 1, 1000)
    strategy.parameters:addInteger("SlowPeriod", "Slow period", "Slow period", 26, 1, 1000)
    strategy.parameters:addInteger("SignalPeriod", "Signal period", "Signal period", 9, 1, 1000)
    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "close", "", "close")
    strategy.parameters:addStringAlternative("Price", "open", "", "open")
    strategy.parameters:addStringAlternative("Price", "high", "", "high")
    strategy.parameters:addStringAlternative("Price", "low", "", "low")
    strategy.parameters:addStringAlternative("Price", "median", "", "median")
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    strategy.parameters:addGroup("Stochastic indicator parameters")
    strategy.parameters:addInteger("K", "K period", "K period", 5, 2, 1000)
    strategy.parameters:addInteger("SD", "SD period", "SD period", 3, 2, 1000)
    strategy.parameters:addInteger("D", "D period", "D period", 3, 2, 1000)
    strategy.parameters:addString("MVAT_K", "Smoothing K", "", "MVA")
    strategy.parameters:addStringAlternative("MVAT_K", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("MVAT_K", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("MVAT_K", "MT", "", "MT")
    strategy.parameters:addString("MVAT_D", "Smoothing D", "", "MVA")
    strategy.parameters:addStringAlternative("MVAT_D", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("MVAT_D", "EMA", "", "EMA")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addDouble("StLevelB", "Stoch level B", "Stoch level B", 20)
    strategy.parameters:addDouble("StLevelS", "Stoch level S", "Stoch level S", 80)
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
local MACD = nil
local St = nil

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
                            "MACD(" ..
                                instance.parameters.FastPeriod ..
                                    ", " ..
                                        instance.parameters.SlowPeriod ..
                                            ", " .. instance.parameters.SignalPeriod .. "))"
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

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    Price = instance.parameters.Price
    if Price == "close" then
        MACD =
            core.indicators:create(
            "MACD",
            Source.close,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    elseif Price == "open" then
        MACD =
            core.indicators:create(
            "MACD",
            Source.open,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    elseif Price == "high" then
        MACD =
            core.indicators:create(
            "MACD",
            Source.high,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    elseif Price == "low" then
        MACD =
            core.indicators:create(
            "MACD",
            Source.low,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    elseif Price == "typical" then
        MACD =
            core.indicators:create(
            "MACD",
            Source.typical,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    elseif Price == "median" then
        MACD =
            core.indicators:create(
            "MACD",
            Source.median,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    else
        MACD =
            core.indicators:create(
            "MACD",
            Source.weighted,
            instance.parameters.FastPeriod,
            instance.parameters.SlowPeriod,
            instance.parameters.SignalPeriod
        )
    end
    St =
        core.indicators:create(
        "STOCHASTIC",
        Source,
        instance.parameters.K,
        instance.parameters.SD,
        instance.parameters.D,
        instance.parameters.MVAT_K,
        instance.parameters.MVAT_D
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
    MACD:update(core.UpdateLast)
    St:update(core.UpdateLast)

    -- Check that we have enough data
    if (MACD.DATA:first() > (period - 1)) then
        return
    end
    if (St.DATA:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false

    if MACD.HISTOGRAM[period - 1] < 0 and MACD.HISTOGRAM[period] > 0 and St.D[period] > instance.parameters.StLevelB then
        if instance.parameters.TypeSignal == "direct" then
            MustB = true
        else
            MustS = true
        end
    end

    if MACD.HISTOGRAM[period - 1] > 0 and MACD.HISTOGRAM[period] < 0 and St.D[period] < instance.parameters.StLevelS then
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
        if MustB == true then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

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
