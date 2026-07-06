-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3308

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

function Init() --The strategy profile initialization
    strategy:name("Strategy 5")
    strategy:description("Strategy 5")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("AMKA indicator parameters")
    strategy.parameters:addInteger("periodAMA", "periodAMA", "", 9)
    strategy.parameters:addDouble("nfast", "nfast", "", 2)
    strategy.parameters:addDouble("nslow", "nslow", "", 30)
    strategy.parameters:addDouble("Pow", "Pow", "", 2)
    strategy.parameters:addDouble("dK", "dK", "", 1)
    strategy.parameters:addString("use_stdev", "use_stdev", "", "true")
    strategy.parameters:addStringAlternative("use_stdev", "true", "", "true")
    strategy.parameters:addStringAlternative("use_stdev", "false", "", "false")
    strategy.parameters:addString("app_price", "app_price", "", "close")
    strategy.parameters:addStringAlternative("app_price", "close", "", "close")
    strategy.parameters:addStringAlternative("app_price", "open", "", "open")
    strategy.parameters:addStringAlternative("app_price", "high", "", "high")
    strategy.parameters:addStringAlternative("app_price", "low", "", "low")
    strategy.parameters:addStringAlternative("app_price", "median", "", "median")
    strategy.parameters:addStringAlternative("app_price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("app_price", "weighted", "", "weighted")

    strategy.parameters:addGroup("Trend Pressure 1 indicator parameters")
    strategy.parameters:addInteger("Frame1", "Period 1", "Period 1", 20)

    strategy.parameters:addGroup("Trend Pressure 2 indicator parameters")
    strategy.parameters:addInteger("Frame2", "Period 2", "Period 2", 5)

    strategy.parameters:addGroup("Dinapoli Prefered Stochastic indicator parameters")
    strategy.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 26, 2, 1000)
    strategy.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 9, 2, 1000)
    strategy.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 4, 2, 1000)
    strategy.parameters:addDouble("Level", "Level", "Level", 50)

    strategy.parameters:addGroup("WSI indicator parameters")
    strategy.parameters:addInteger("CCIP", "CCI Period", "CCI Period", 100, 2, 2000)
    strategy.parameters:addInteger("ADXP", "ADX Period", "ADX Period", 100, 2, 2000)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
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
local AMKA = nil
local TrendPressure1 = nil
local TrendPressure2 = nil
local DPS = nil
local WSI = nil

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
local Source
local Direction = nil

--
--
--
function Prepare(nameOnly)
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
                            "AMKA(" ..
                                instance.parameters.periodAMA ..
                                    ", " ..
                                        instance.parameters.nfast ..
                                            ", " ..
                                                instance.parameters.nslow ..
                                                    ", " ..
                                                        instance.parameters.Pow ..
                                                            ", " ..
                                                                instance.parameters.dK ..
                                                                    ", " ..
                                                                        instance.parameters.use_stdev ..
                                                                            ", " ..
                                                                                instance.parameters.app_price .. "), "
    name = name .. "Trend pressure (" .. instance.parameters.Frame1 .. ", " .. instance.parameters.Frame2 .. "), "
    name =
        name ..
        "Dinapoli Prefered Stochastic (" ..
            instance.parameters.K ..
                ", " ..
                    instance.parameters.SD ..
                        ", " .. instance.parameters.D .. ", " .. instance.parameters.Level .. "), "
    name = name .. "WSI (" .. instance.parameters.CCIP .. ", " .. instance.parameters.ADXP .. "))"
    instance:name(name)
    if nameOnly then
        return;
    end

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

    assert(core.indicators:findIndicator("AMKA2") ~= nil, "Please, download and install AMKA2.LUA indicator")
    assert(
        core.indicators:findIndicator("TREND REVERS PRESSURE") ~= nil,
        "Please, download and install TREND REVERS PRESSURE.LUA indicator"
    )
    assert(
        core.indicators:findIndicator("DINAPOLI PREFERRED STOCHASTIC") ~= nil,
        "Please, download and install DINAPOLI PREFERRED STOCHASTIC.LUA indicator"
    )
    assert(core.indicators:findIndicator("WSI2") ~= nil, "Please, download and install WSI2.LUA indicator")

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    AMKA =
        core.indicators:create(
        "AMKA2",
        Source,
        instance.parameters.periodAMA,
        instance.parameters.nfast,
        instance.parameters.nslow,
        instance.parameters.Pow,
        instance.parameters.dK,
        instance.parameters.use_stddev,
        instance.parameters.app_price
    )
    TrendPressure1 = core.indicators:create("TREND REVERS PRESSURE", Source, instance.parameters.Frame1, 30)
    TrendPressure2 = core.indicators:create("TREND REVERS PRESSURE", Source, instance.parameters.Frame2, 30)
    DPS =
        core.indicators:create(
        "DINAPOLI PREFERRED STOCHASTIC",
        Source,
        instance.parameters.K,
        instance.parameters.SD,
        instance.parameters.D
    )
    WSI = core.indicators:create("WSI2", Source, instance.parameters.CCIP, instance.parameters.ADXP)

    Direction = nil

    ExtSetupSignal(profile:id() .. ":", ShowAlert)
    ExtSetupSignalMail(name)
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
    AMKA:update(core.UpdateLast)
    TrendPressure1:update(core.UpdateLast)
    TrendPressure2:update(core.UpdateLast)
    DPS:update(core.UpdateLast)
    WSI:update(core.UpdateLast)

    -- Check that we have enough data
    if (AMKA.DATA:first() > (period - 1)) 
        or not AMKA.Line:hasData(period - 1) 
        or not AMKA.Dn:hasData(period - 1)
        or not AMKA.Up:hasData(period - 1)
        or not TrendPressure1.Trend:hasData(period - 1)
        or not TrendPressure1.Revers:hasData(period - 1)
        or not TrendPressure2.Trend:hasData(period - 1)
        or not TrendPressure2.Revers:hasData(period - 1)
        or not DPS.K:hasData(period - 1)
        or not WSI.WSI:hasData(period - 1)
    then
        return
    end
    if (TrendPressure1.DATA:first() > (period - 1)) then
        return
    end
    if (TrendPressure2.DATA:first() > (period - 1)) then
        return
    end
    if (DPS.DATA:first() > (period - 1)) then
        return
    end
    if (WSI.DATA:first() > (period - 1 - math.max(instance.parameters.CCIP, instance.parameters.ADXP))) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false

    if AMKA.Line[period - 1] == AMKA.Dn[period - 1] and AMKA.Line[period] == AMKA.Up[period] then
        if
            TrendPressure1.Trend[period - 1] > TrendPressure1.Revers[period - 1] and
                TrendPressure1.Trend[period] > TrendPressure1.Revers[period]
         then
            if
                TrendPressure2.Trend[period - 1] < TrendPressure2.Revers[period - 1] and
                    TrendPressure2.Trend[period] > TrendPressure2.Revers[period]
             then
                if DPS.K[period] < instance.parameters.Level then
                    if WSI.WSI[period] > 0 and WSI.WSI[period - 1] > 0 then
                        if instance.parameters.TypeSignal == "direct" then
                            if Direction ~= 1 then
                                MustB = true
                                Direction = 1
                            end
                        else
                            if Direction ~= -1 then
                                MustS = true
                                Direction = -1
                            end
                        end
                    end
                end
            end
        end
    end

    if AMKA.Line[period - 1] == AMKA.Up[period - 1] and AMKA.Line[period] == AMKA.Dn[period] then
        if
            TrendPressure1.Trend[period - 1] < TrendPressure1.Revers[period - 1] and
                TrendPressure1.Trend[period] < TrendPressure1.Revers[period]
         then
            if
                TrendPressure2.Trend[period - 1] > TrendPressure2.Revers[period - 1] and
                    TrendPressure2.Trend[period] < TrendPressure2.Revers[period]
             then
                if DPS.K[period] > instance.parameters.Level then
                    if WSI.WSI[period] < 0 and WSI.WSI[period - 1] < 0 then
                        if instance.parameters.TypeSignal == "direct" then
                            if Direction ~= -1 then
                                MustS = true
                                Direction = -1
                            end
                        else
                            if Direction ~= 1 then
                                MustB = true
                                Direction = 1
                            end
                        end
                    end
                end
            end
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
