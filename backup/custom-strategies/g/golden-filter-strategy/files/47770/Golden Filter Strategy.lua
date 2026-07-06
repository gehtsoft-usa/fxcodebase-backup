-- Id: 8016
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=27333

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

local BAR = true

function Init() --The strategy profile initialization
    strategy:name("Golden Filter Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("MA Calulation")

    strategy.parameters:addString("GoldenLinesPrice1", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "LOW", "", "low")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("GoldenLinesPrice1", "WEIGHTED", "", "weighted")

    strategy.parameters:addString("GoldenLinesMethod1", "MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod1", "WMA", "WMA", "WMA")
    strategy.parameters:addInteger("GoldenLinesPeriod1", "Period", "Period", 5)

    strategy.parameters:addString("GoldenLinesPrice2", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "LOW", "", "low")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("GoldenLinesPrice2", "WEIGHTED", "", "weighted")

    strategy.parameters:addString("GoldenLinesMethod2", "MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("GoldenLinesMethod2", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger("GoldenLinesPeriod2", "Period", "Period", 15)

    strategy.parameters:addGroup("Momentum Calculation")

    strategy.parameters:addInteger("MP", "Momentum Period", "Period", 5)
    strategy.parameters:addString("MS", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("MS", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("MS", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("MS", "LOW", "", "low")
    strategy.parameters:addStringAlternative("MS", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("MS", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("MS", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("MS", "WEIGHTED", "", "weighted")

    strategy.parameters:addGroup("Force Index Calculation")
    strategy.parameters:addInteger("N1", "Smoothing Periods", "", 13, 1, 1000)

    strategy.parameters:addGroup("DeMarker Calculation")
    strategy.parameters:addInteger("N2", "Number of periods for smoothing", "", 14)
    strategy.parameters:addString("MA", "Smoothing Method", "", "MVA")
    strategy.parameters:addStringAlternative("MA", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("MA", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("MA", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("MA", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("MA", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("MA", "Vidya (1995)", "", "VIDYA")
    strategy.parameters:addStringAlternative("MA", "Wilders*", "", "WMA")

    strategy.parameters:addGroup("RSI Calculation")

    strategy.parameters:addString("RP", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("RP", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("RP", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("RP", "LOW", "", "low")
    strategy.parameters:addStringAlternative("RP", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("RP", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("RP", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("RP", "WEIGHTED", "", "weighted")
    strategy.parameters:addInteger("R", "Period", "", 21)

    strategy.parameters:addGroup("MACD Calculation")
    strategy.parameters:addString("MACD", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("MACD", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("MACD", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("MACD", "LOW", "", "low")
    strategy.parameters:addStringAlternative("MACD", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("MACD", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("MACD", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("MACD", "WEIGHTED", "", "weighted")
    strategy.parameters:addInteger("ShortP", "Short Period", "", 8)
    strategy.parameters:addInteger("LongP", "Long Period", "", 17)
    strategy.parameters:addInteger("SignalP", "Signal Period", "", 9)

    strategy.parameters:addGroup("DMI Calculation")
    strategy.parameters:addInteger("DMIP", "Period", "", 14)

    strategy.parameters:addGroup("Exit Options")
    strategy.parameters:addBoolean("Exit", "Use Exit", "", true)

    strategy.parameters:addBoolean("On1", "MA Position Close Exit", "", true)
    strategy.parameters:addBoolean("On2", "Momentum Exit", "", false)
    strategy.parameters:addBoolean("On3", "Force Index Exit", "", false)
    strategy.parameters:addBoolean("On4", "Demarker Exit", "", false)
    strategy.parameters:addBoolean("On5", "RSI Exit", "", false)
    strategy.parameters:addBoolean("On6", "MACD Exit", "", false)
    strategy.parameters:addBoolean("On7", " DMI Exit", "", false)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("Direction", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse")

    CreateTradingParameters()

    strategy.parameters:addGroup("Time Parameters")

    strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00")
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00")

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false)
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00")
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60)
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    -- NG: optimizer/backtester hint
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString(
        "ALLOWEDSIDE",
        "Allowed side",
        "Allowed side for trading or signaling, can be Sell, Buy or Both",
        "Both"
    )
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)

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

local Source

local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowMultiple
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local ShowAlert
local Email
local SendEmail
local BaseSize

local LP, NP

local Indicator = {}
local Short = {}
local Source

local Direction

local first
local Price
local On = {}
local Exit
local GoldenLinesMethod2,
    GoldenLinesMethod1,
    GoldenLinesPrice2,
    GoldenLinesPrice1,
    GoldenLinesPeriod2,
    GoldenLinesPeriod1
local N1, N2, MA, DMIP
local MP, MS, Momentum
local R, RP
local MACD, SignalP, ShortP, LongP

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime

--
function Prepare(nameOnly)
    Exit = instance.parameters.Exit
    On[1] = instance.parameters.On1
    On[2] = instance.parameters.On2
    On[3] = instance.parameters.On3
    On[4] = instance.parameters.On4
    On[5] = instance.parameters.On5
    On[6] = instance.parameters.On6
    On[7] = instance.parameters.On7

    R = instance.parameters.R
    RP = instance.parameters.RP
    MACD = instance.parameters.MACD
    ShortP = instance.parameters.ShortP
    LongP = instance.parameters.LongP
    SignalP = instance.parameters.SignalP

    MP = instance.parameters.MP
    DMIP = instance.parameters.DMIP
    MS = instance.parameters.MS
    GoldenLinesPeriod2 = instance.parameters.GoldenLinesPeriod2
    GoldenLinesPeriod1 = instance.parameters.GoldenLinesPeriod1
    GoldenLinesMethod2 = instance.parameters.GoldenLinesMethod2
    GoldenLinesMethod1 = instance.parameters.GoldenLinesMethod1
    GoldenLinesPrice2 = instance.parameters.GoldenLinesPrice2
    GoldenLinesPrice1 = instance.parameters.GoldenLinesPrice1
    N1 = instance.parameters.N1

    N2 = instance.parameters.N2
    MA = instance.parameters.MA

    assert(core.indicators:findIndicator("AEFI") ~= nil, "Please, download and install AEFI.LUA indicator")
    assert(core.indicators:findIndicator("DEM") ~= nil, "Please, download and install DEM.LUA indicator")
    assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator")

    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct"

    -- NG: check TF1/TF2 instead of TF
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name()
    local i

    name = name .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    Indicator[11] = core.indicators:create("MOMENTUM", Source[MS], MP)
    Short[11] = Indicator[11].DATA

    assert(core.indicators:findIndicator(GoldenLinesMethod1) ~= nil, GoldenLinesMethod1 .. " indicator must be installed");
    Indicator[41] = core.indicators:create(GoldenLinesMethod1, Source[GoldenLinesPrice1], GoldenLinesPeriod1)
    assert(core.indicators:findIndicator(GoldenLinesMethod2) ~= nil, GoldenLinesMethod2 .. " indicator must be installed");
    Indicator[42] = core.indicators:create(GoldenLinesMethod2, Source[GoldenLinesPrice2], GoldenLinesPeriod2)
    Short[41] = Indicator[41].DATA
    Short[42] = Indicator[42].DATA

    Indicator[21] = core.indicators:create("AEFI", Source, true, N1)
    Indicator[22] = core.indicators:create("DEM", Source, N2, MA)
    Short[21] = Indicator[21].DATA
    Short[22] = Indicator[22].DATA

    Indicator[31] = core.indicators:create("RSI", Source[RP], R)
    Short[31] = Indicator[31].DATA

    Indicator[32] = core.indicators:create("MACD", Source[MACD], ShortP, LongP, SignalP)
    Short[32] = Indicator[32].MACD
    Short[33] = Indicator[32].SIGNAL

    Indicator[33] = core.indicators:create("DMI", Source, DMIP)
    Short[34] = Indicator[33].DIP
    Short[35] = Indicator[33].DIM

    first =
        math.max(
        Short[41]:first(),
        Short[42]:first(),
        Short[11]:first(),
        Short[21]:first(),
        Short[22]:first(),
        Short[31]:first(),
        Short[33]:first(),
        Short[35]:first()
    ) + 1

    ToTime = instance.parameters.ToTime
    ValidInterval = instance.parameters.ValidInterval
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing

    if ToTime == 1 then
        ToTime = core.TZ_EST
    elseif ToTime == 2 then
        ToTime = core.TZ_UTC
    elseif ToTime == 3 then
        ToTime = core.TZ_LOCAL
    elseif ToTime == 4 then
        ToTime = core.TZ_SERVER
    elseif ToTime == 5 then
        ToTime = core.TZ_FINANCIAL
    elseif ToTime == 6 then
        ToTime = core.TZ_TS
    end

    local valid
    OpenTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    CloseTime, valid = ParseTime(instance.parameters.StopTime)
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")
    ExitTime, valid = ParseTime(instance.parameters.ExitTime)
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid")

    if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1))
    end
end

function PrepareTrading()
    AllowMultiple = instance.parameters.AllowMultiple
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE

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
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop
        TrailingStop = instance.parameters.TrailingStop
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", 100)
end
function ParseTime(time)
    local pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local h = tonumber(string.sub(time, 1, pos - 1))
    time = string.sub(time, pos + 1)
    pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local m = tonumber(string.sub(time, 1, pos - 1))
    local s = tonumber(string.sub(time, pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
        (h == 24 and m == 0 and s == 0)) -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if id ~= 1 then
        return
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    Indicator[11]:update(core.UpdateLast)
    Indicator[41]:update(core.UpdateLast)
    Indicator[41]:update(core.UpdateLast)
    Indicator[42]:update(core.UpdateLast)
    Indicator[21]:update(core.UpdateLast)
    Indicator[22]:update(core.UpdateLast)
    Indicator[31]:update(core.UpdateLast)
    Indicator[32]:update(core.UpdateLast)
    Indicator[33]:update(core.UpdateLast)

    if period < first + 1 then
        return
    end

    if
        core.crossesOver(Short[41], Short[42], period) and Short[11][period] > 100 and Short[21][period] > 0 and
            Short[22][period] > 0.5 and
            Short[31][period] > 50 and
            Short[32][period] > Short[33][period] and
            Short[34][period] > Short[35][period]
     then
        if Direction then
            BUY()
        else
            SELL()
        end
    elseif
        core.crossesUnder(Short[41], Short[42], period) and Short[11][period] < 100 and Short[21][period] < 0 and
            Short[22][period] < 0.5 and
            Short[31][period] < 50 and
            Short[32][period] < Short[33][period] and
            Short[34][period] < Short[35][period]
     then
        if Direction then
            SELL()
        else
            BUY()
        end
    end

    if Exit then
        if
            (Short[41][period] < Short[42][period] and On[1]) or (Short[11][period] < 100 and On[2]) or
                (Short[21][period] < 0 and On[3]) or
                (Short[22][period] < 0.5 and On[4]) or
                (Short[31][period] < 50 and On[5]) or
                (Short[32][period] < Short[33][period] and On[6]) or
                (Short[34][period] < Short[35][period] and On[7])
         then
            if Direction then
                if haveTrades("B") then
                    exit("B")
                    Signal("Close Long")
                end
            else
                if haveTrades("S") then
                    exit("S")
                    Signal("Close Short")
                end
            end
        end

        if
            (Short[41][period] > Short[42][period] and On[1]) or (Short[11][period] > 100 and On[2]) or
                (Short[21][period] > 0 and On[3]) or
                (Short[22][period] > 0.5 and On[4]) or
                (Short[31][period] > 50 and On[5]) or
                (Short[32][period] > Short[33][period] and On[6]) or
                (Short[34][period] > Short[35][period] and On[7])
         then
            if Direction then
                if haveTrades("S") then
                    exit("S")
                    Signal("Close Short")
                end
            else
                if haveTrades("B") then
                    exit("B")
                    Signal("Close Long")
                end
            end
        end
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime")
            now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
            -- get only time
            now = now - math.floor(now)

            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + (ValidInterval / 86400.0) then
                if not checkReady("trades") then
                    return
                end

                if haveTrades("B") then
                    exit("B")
                    Signal("Close Long")
                end

                if haveTrades("S") then
                    exit("S")
                    Signal("Close Short")
                end
            end
        end
    elseif cookie == 200 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 201 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Close order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
    if AllowTrade then
        if haveTrades("B") and not AllowMultiple then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end
            return
        end

        if ALLOWEDSIDE == "Sell" then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end
            return
        end

        if haveTrades("S") then
            exit("S")
            Signal("Close Short")
        end

        enter("B")
        Signal("Open Long")
    elseif ShowAlert then
        Signal("Up Trend")
    end
end

function SELL()
    if AllowTrade then
        if haveTrades("S") and not AllowMultiple then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end
            return
        end

        if ALLOWEDSIDE == "Buy" then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end
            return
        end

        if haveTrades("B") then
            exit("B")
            Signal("Close Long")
        end

        enter("S")
        Signal("Open Short")
    else
        Signal("Down Trend")
    end
end

function Signal(Label)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], Label, instance.bid:date(NOW))
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound)
    end

    if Email ~= nil then
        terminal:alertEmail(
            Email,
            Label,
            profile:id() ..
                "(" ..
                    instance.bid:instrument() ..
                        ")" .. instance.bid[NOW] .. ", " .. Label .. ", " .. instance.bid:date(NOW)
        )
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table)
end

function tradesCount(BuySell)
    local enum, row
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    -- NG: to get the true count we must NOT stop when count is not a zero or
    -- the function will return 1 or 0 only and will work as "haveTrades"
    -- while count == 0 and row ~= nil do
    while row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            count = count + 1
        end
        row = enum:next()
    end
    return count
end

function haveTrades(BuySell)
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            found = true
        end
        row = enum:next()
    end
    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not AllowMultiple then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell

    -- add stop/limit

    valuemap.PegTypeStop = "O"
    if SetStop then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end
    end
    if TrailingStop then
        valuemap.TrailStepStop = 1
    end

    valuemap.PegTypeLimit = "O"
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = "Y"
    end

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

    return true
end

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
