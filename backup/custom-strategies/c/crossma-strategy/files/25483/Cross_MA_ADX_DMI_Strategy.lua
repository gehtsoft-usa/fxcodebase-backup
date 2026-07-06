-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=9702
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Cross MA and ADX-DMI strategy")
    strategy:description("Cross MA and ADX-DMI strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addString("Method", "Method", "", "MVA")
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("Method", "KAMA", "", "KAMA")
    strategy.parameters:addStringAlternative("Method", "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative("Method", "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative("Method", "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative("Method", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("Method", "HMA", "", "HMA")
    strategy.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative("Method", "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative("Method", "T3", "", "T3")
    strategy.parameters:addStringAlternative("Method", "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative("Method", "Median", "", "Median")
    strategy.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative("Method", "REMA", "", "REMA")
    strategy.parameters:addStringAlternative("Method", "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative("Method", "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth")
    strategy.parameters:addInteger("Number", "Number", "Number", 1)
    strategy.parameters:addString("Periods", "Periods", "", "15,20,45,67,75")

    strategy.parameters:addGroup("ADX indicator parameters")
    strategy.parameters:addInteger("ADX_N", "Period of ADX", "Period of ADX", 14, 2, 1000)

    strategy.parameters:addGroup("DMI indicator parameters")
    strategy.parameters:addInteger("DMI_N", "Period of DMI", "Period of DMI", 14, 1, 1000)

    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "close", "", "close")
    strategy.parameters:addStringAlternative("Price", "open", "", "open")
    strategy.parameters:addStringAlternative("Price", "high", "", "high")
    strategy.parameters:addStringAlternative("Price", "low", "", "low")
    strategy.parameters:addStringAlternative("Price", "median", "", "median")
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addDouble("ADX_Level", "ADX_Level", "ADX_Level", 20)
    strategy.parameters:addDouble("DMI_P_Level_BUY", "DMI_P_Level_BUY", "DMI_P_Level_BUY", 25)
    strategy.parameters:addDouble("DMI_M_Level_SELL", "DMI_M_Level_SELL", "DMI_M_Level_SELL", 25)
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

-- Signal Parameters
local ShowAlert
local SoundFile
local RecurrentSound
local SendEmail, Email

-- Internal indicators
local CrMA = nil
local ADX = nil
local DMI = nil

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
local AllowDirection

--
--
--
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
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF
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
        Source_ = Source.close
    elseif Price == "open" then
        Source_ = Source.open
    elseif Price == "high" then
        Source_ = Source.high
    elseif Price == "low" then
        Source_ = Source.low
    elseif Price == "typical" then
        Source_ = Source.typical
    elseif Price == "median" then
        Source_ = Source.median
    else
        Source_ = Source.weighted
    end

    assert(core.indicators:findIndicator("CROSS_MA") ~= nil, "Please, download and install CROSS_MA.LUA indicator")
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")

    CrMA =
        core.indicators:create(
        "CROSS_MA",
        Source_,
        instance.parameters.Method,
        "both",
        instance.parameters.Number,
        instance.parameters.Periods,
        "strategy"
    )
    ADX = core.indicators:create("ADX", Source, instance.parameters.ADX_N)
    DMI = core.indicators:create("DMI", Source, instance.parameters.DMI_N)

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
    CrMA:update(core.UpdateLast)
    ADX:update(core.UpdateLast)
    DMI:update(core.UpdateLast)

    -- Check that we have enough data
    if (CrMA.DATA:first() > (period - 1)) then
        return
    end
    if (ADX.DATA:first() > (period - 1)) then
        return
    end
    if (DMI.DATA:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustOpenB = false
    local MustOpenS = false

    if
        CrMA.Crosses[period] == 1 and ADX.DATA[period] >= instance.parameters.ADX_Level and
            DMI.DIP[period] >= instance.parameters.DMI_P_Level_BUY
     then
        if instance.parameters.TypeSignal == "direct" then
            MustOpenB = true
        else
            MustOpenS = true
        end
    end
    if
        CrMA.Crosses[period] == -1 and ADX.DATA[period] >= instance.parameters.ADX_Level and
            DMI.DIM[period] >= instance.parameters.DMI_M_Level_SELL
     then
        if instance.parameters.TypeSignal == "direct" then
            MustOpenS = true
        else
            MustOpenB = true
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
                    if MustOpenS then
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
                    if MustOpenB then
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
        if MustOpenB == true and instance.parameters.AllowDirection ~= "Short" then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

        if MustOpenS == true and instance.parameters.AllowDirection ~= "Long" then
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
