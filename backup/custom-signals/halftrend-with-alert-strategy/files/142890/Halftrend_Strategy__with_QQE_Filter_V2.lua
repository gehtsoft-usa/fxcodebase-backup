-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=70747
--+------------------------------------------------------------------+
--|                                   Copyright © 2017, Addons To Go |
--|                                    http://www.addons-to-go.com/  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: mario.jemic@gmail.com |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("3 MA Cross Strategy with QQE Filter")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Selector")
    strategy.parameters:addBoolean("Selector1", "Use 1. Entry Rule ", "", true)
    strategy.parameters:addBoolean("Selector2", "Use 2. Entry Rule ", "", true)
    strategy.parameters:addBoolean("Selector3", "Use 3. Entry Rule ", "", true)
    strategy.parameters:addBoolean("Selector4", "Use Trend MA ", "", true)

    strategy.parameters:addGroup("Halftrend")
    strategy.parameters:addInteger("Amplitude", "Period", "", 2, 2, 5000)

    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF1", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF1", core.FLAG_PERIODS)

    strategy.parameters:addInteger("Fast_Period", "Fast MA Period", "", 7)
    strategy.parameters:addString("Fast_Method", "Fast MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Fast_Method", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Fast_Method", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Fast_Method", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Fast_Method", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Fast_Method", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Fast_Method", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Fast_Method", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Fast_Method", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger("Medium_Period", "Medium MA Period", "", 14)
    strategy.parameters:addString("Medium_Method", "Medium MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Medium_Method", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Medium_Method", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Medium_Method", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Medium_Method", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Medium_Method", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Medium_Method", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Medium_Method", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Medium_Method", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger("Slow_Period", "Slow MA Period", "", 21)
    strategy.parameters:addString("Slow_Method", "Slow MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Slow_Method", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Slow_Method", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Slow_Method", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Slow_Method", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Slow_Method", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Slow_Method", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Slow_Method", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Slow_Method", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger("Trend_Period", "Tend MA Period", "", 200)
    strategy.parameters:addString("Trend_Method", "Fast MA Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Trend_Method", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Trend_Method", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Trend_Method", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Trend_Method", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Trend_Method", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Trend_Method", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Trend_Method", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Trend_Method", "WMA", "WMA", "WMA")

    strategy.parameters:addGroup("QQE Calculation")

    strategy.parameters:addBoolean("Filter", "Use 1. QQE Filter", "", true)
    strategy.parameters:addBoolean("Filter2", "Use 2. QQE Filter", "", true)
    strategy.parameters:addString("TF2", "1. QQE Time frame", "", "H1")
    strategy.parameters:setFlag("TF2", core.FLAG_PERIODS)

    strategy.parameters:addString("TF3", "2. QQE Time frame", "", "D1")
    strategy.parameters:setFlag("TF3", core.FLAG_PERIODS)

    strategy.parameters:addInteger("RF", "RSI Period", "RSI Period", 14)
    strategy.parameters:addInteger("RSP", "RSI  Smoothing Period", "RSI  Smoothing Period", 5)
    strategy.parameters:addInteger("AP", " ATR Period", " ATR Period", 14)
    strategy.parameters:addDouble("F", "Fast ATR Multipliers", "Fast ATR Multipliers", 2.618)
    strategy.parameters:addDouble("S", "Slow ATR Multipliers", "Slow ATR Multipliers", 4.236)

    CreateTradingParameters()
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("AccountType", "Account Type", "", "Automatic")
    strategy.parameters:addStringAlternative("AccountType", "FIFO", "", "FIFO")
    strategy.parameters:addStringAlternative("AccountType", "non FIFO", "", "NON")
    strategy.parameters:addStringAlternative("AccountType", "Automatic", "", "Automatic")

    strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn")
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn")
    strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live")

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "3MACS"
    )

    strategy.parameters:addInteger(
        "MaxNumberOfPositionInAnyDirection",
        "Max Number Of Open Position In Any Direction",
        "",
        2,
        1,
        100
    )
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100)

    strategy.parameters:addString(
        "ALLOWEDSIDE",
        "Allowed side",
        "Allowed side for trading or signaling, can be Sell, Buy or Both",
        "Both"
    )
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse")

    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", false)

    strategy.parameters:addString("ExitType", "ExitType", "Type", "Slow")
    strategy.parameters:addStringAlternative("ExitType", "Fast", "Fast", "Fast")
    strategy.parameters:addStringAlternative("ExitType", "Medium", "Medium", "Medium")
    strategy.parameters:addStringAlternative("ExitType", "Slow", "Slow", "Slow")

    strategy.parameters:addGroup("Alerts")
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)

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
local ExitType
local Source, TickSource, QQE_Source
local QQE, RF, RSP, AP, F, S
local QQE2, RF2, RSP2, AP2, F2, S2
local Filter, Filter2
local MaxNumberOfPositionInAnyDirection, MaxNumberOfPosition
local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
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
local ExecutionType
local CloseOnOpposite
local first, first_QQE, first_QQE2
local Exit
local Fast, Medium, Slow, Trend
local Direction
local CustomID
local AccountType
local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime, halftrend

local Selector1, Selector2, Selector3, Selector4

function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"
    AccountType = instance.parameters.AccountType
    ExitType = instance.parameters.ExitType

    Selector1 = instance.parameters.Selector1
    Selector2 = instance.parameters.Selector2
    Selector3 = instance.parameters.Selector3
    Selector4 = instance.parameters.Selector4

    Exit = instance.parameters.Exit

    RF = instance.parameters.RF
    RSP = instance.parameters.RSP
    AP = instance.parameters.AP
    F = instance.parameters.F
    S = instance.parameters.S

    RF2 = instance.parameters.RF2
    RSP2 = instance.parameters.RSP2
    AP2 = instance.parameters.AP2
    F2 = instance.parameters.F2
    S2 = instance.parameters.S2

    Filter = instance.parameters.Filter
    Filter2 = instance.parameters.Filter2

    assert(instance.parameters.TF1 ~= "t1", "The time frame must not be tick")
    assert(instance.parameters.TF2 ~= "t1", "The time frame must not be tick")

    s1, e1 =
        core.getcandle(
        instance.parameters.TF1,
        0,
        core.host:execute("getTradingDayOffset"),
        core.host:execute("getTradingWeekOffset")
    )
    s2, e2 =
        core.getcandle(
        instance.parameters.TF2,
        0,
        core.host:execute("getTradingDayOffset"),
        core.host:execute("getTradingWeekOffset")
    )
    s3, e3 =
        core.getcandle(
        instance.parameters.TF3,
        0,
        core.host:execute("getTradingDayOffset"),
        core.host:execute("getTradingWeekOffset")
    )

    if Filter then
        assert((e1 - s1) <= (e2 - s2), "1. QQE time frame must be equal to or bigger than 3 MA time frame!")
    end

    if Filter2 then
        assert((e1 - s1) <= (e3 - s3), "2. QQE time frame must be equal to or bigger than 3 MA time frame!")
    end

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    assert(core.indicators:findIndicator("QQE") ~= nil, "Please, download and install QQE.LUA indicator")

    Source = ExtSubscribe(2, nil, instance.parameters.TF1, instance.parameters.Type == "Bid", "bar")
    QQE_Source = ExtSubscribe(3, nil, instance.parameters.TF2, instance.parameters.Type == "Bid", "bar")
    QQE_Source2 = ExtSubscribe(4, nil, instance.parameters.TF3, instance.parameters.Type == "Bid", "bar")

    local profile = core.indicators:findIndicator("HALFTREND WITH ALERT");
    assert(profile ~= nil, "Please, download and install " .. "HALFTREND WITH ALERT" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setBoolean("ShowAlert", false);
    indicatorParams:setBoolean("strategy_mode", true);
    indicatorParams:setInteger("Amplitude", instance.parameters.Amplitude);
    halftrend = core.indicators:create("HALFTREND WITH ALERT", Source, indicatorParams);

    Trend = core.indicators:create(instance.parameters.Trend_Method, Source.close, instance.parameters.Trend_Period)

    first = math.max(Trend.DATA:first())

    QQE = core.indicators:create("QQE", QQE_Source.close, RF, RSP, AP, F, S, false, true)
    QQE2 = core.indicators:create("QQE", QQE_Source2.close, RF2, RSP2, AP2, F2, S2, false, true)

    first_QQE = QQE.TS1:first()
    first_QQE2 = QQE2.TS1:first()

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

-- NG: create a function to parse time
function ParseTime(time)
    local Pos = string.find(time, ":")
    local h = tonumber(string.sub(time, 1, Pos - 1))
    time = string.sub(time, Pos + 1)
    Pos = string.find(time, ":")
    local m = tonumber(string.sub(time, 1, Pos - 1))
    local s = tonumber(string.sub(time, Pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
        (h == 24 and m == 0 and s == 0)) -- validity flag
end

function PrepareTrading()
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
    Account = instance.parameters.Account
    Amount = instance.parameters.Amount
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID

    if AccountType == "FIFO" then
        CanClose = false
    elseif AccountType == "NON" then
        CanClose = true
    else
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    end

    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit
    SetStop = instance.parameters.SetStop
    Stop = instance.parameters.Stop
    TrailingStop = instance.parameters.TrailingStop
end

local Last
local LAST
local ONE

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if ExecutionType == "Live" then
        if ONE == Source:serial(period) then
            return
        end

        if id ~= 1 then
            return
        end

        period = core.findDate(Source.close, TickSource:date(period), false)
        period_qqe = core.findDate(QQE_Source.close, TickSource:date(period), false)
        period_qqe2 = core.findDate(QQE_Source2.close, TickSource:date(period), false)
    else
        if id ~= 2 then
            return
        end

        period_qqe = core.findDate(QQE_Source.close, Source:date(period), false)
        period_qqe2 = core.findDate(QQE_Source2.close, Source:date(period), false)
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)
    if not (now >= OpenTime and now <= CloseTime) then
        return
    end

    -- update indicators.
    halftrend:update(core.UpdateLast)
    Trend:update(core.UpdateLast)
    QQE:update(core.UpdateLast)
    QQE2:update(core.UpdateLast)

    if period < first or period_qqe < first_QQE or period_qqe2 < first_QQE2 then
        return
    end

    -- QQE > TS Fast
    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if
        (halftrend.signal[period - 1] == 1 or not Selector1) and
            (not Filter or (Filter and QQE.DATA[period_qqe] > QQE.TS1[period_qqe])) and
            (not Filter2 or (Filter2 and QQE2.DATA[period_qqe2] > QQE2.TS1[period_qqe2])) and
            (Selector1 or Selector2 or Selector3)
     then
        if Direction then
            BUY()
        else
            SELL()
        end
        ONE = Source:serial(period)
    elseif
        (halftrend.signal[period - 1] == -1 or not Selector1) and
            (not Filter or (Filter and QQE.DATA[period_qqe] < QQE.TS1[period_qqe])) and
            (not Filter2 or (Filter2 and QQE2.DATA[period_qqe2] < QQE2.TS1[period_qqe2])) and
            (Selector1 or Selector2 or Selector3)
     then
        if Direction then
            SELL()
        else
            BUY()
        end
        ONE = Source:serial(period)
    end

    if Exit then
        if halftrend.signal[period - 1] == -1 then
            if Direction then
                if haveTrades("B") then
                    exitSpecific("B")
                    Signal("Close Long")
                end
            else
                if haveTrades("S") then
                    exitSpecific("S")
                    Signal("Close Short")
                end
            end
        end
        if halftrend.signal[period - 1] == 1 then
            if Direction then
                if haveTrades("S") then
                    exitSpecific("S")
                    Signal("Close Short")
                end
            else
                if haveTrades("B") then
                    exitSpecific("B")
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
                    exitSpecific("B")
                    Signal("Close Long")
                end

                if haveTrades("S") then
                    exitSpecific("S")
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
        if CloseOnOpposite and haveTrades("S") then
            -- close on opposite signal
            exitSpecific("S")
            Signal("Close Short")
        end

        if ALLOWEDSIDE == "Sell" then
            -- we are not allowed buys.
            return
        end

        enter("B")
    else
        Signal("Buy Signal")
    end
end

function SELL()
    if AllowTrade then
        if CloseOnOpposite and haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B")
            Signal("Close Long")
        end

        if ALLOWEDSIDE == "Buy" then
            -- we are not allowed sells.
            return
        end

        enter("S")
    else
        Signal("Sell Signal")
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
    local rc
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true
    else
        rc = core.host:execute("isTableFilled", table)
    end

    return rc
end

function tradesCount(BuySell)
    local enum, row
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while row ~= nil do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
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
    while (row ~= nil) do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
            found = true
            break
        end

        row = enum:next()
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    -- do not enter if position in the specified direction already exists
    if tradesCount(BuySell) >= MaxNumberOfPosition or ((tradesCount(nil)) >= MaxNumberOfPositionInAnyDirection) then
        return true
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal("Sell Signal")
    else
        Signal("Buy Signal")
    end

    return MarketOrder(BuySell)
end

-- enter into the specified direction
function MarketOrder(BuySell)
    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID

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

function exitSpecific(BuySell)
    --side
    -- closes all positions of the specified direction (B for buy, S for sell)

    local enum, row, valuemap

    enum = core.host:findTable("trades"):enumerator()
    while true do
        row = enum:next()
        if row == nil then
            break
        end
        if row.AccountID == Account and row.OfferID == Offer and row.BS == BuySell and row.QTXT == CustomID then
            -- if trade has to be closed

            if CanClose then
                -- non-FIFO account, create a close market order
                valuemap = core.valuemap()
                valuemap.OrderType = "CM"
                valuemap.OfferID = Offer
                valuemap.AcctID = Account
                valuemap.Quantity = row.Lot
                valuemap.TradeID = row.TradeID
                valuemap.CustomID = CustomID
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                success, msg = terminal:execute(201, valuemap)
                if not (success) then
                    terminal:alertMessage(
                        instance.bid:instrument(),
                        instance.bid[instance.bid:size() - 1],
                        "Close order failed" .. msg,
                        instance.bid:date(instance.bid:size() - 1)
                    )
                    return false
                end
            else
                -- FIFO account, create an opposite market order
                valuemap = core.valuemap()
                valuemap.OrderType = "OM"
                valuemap.OfferID = Offer
                valuemap.AcctID = Account
                valuemap.Quantity = Amount * BaseSize
                valuemap.CustomID = CustomID
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                success, msg = terminal:execute(201, valuemap)
                if not (success) then
                    terminal:alertMessage(
                        instance.bid:instrument(),
                        instance.bid[instance.bid:size() - 1],
                        "Close order failed" .. msg,
                        instance.bid:date(instance.bid:size() - 1)
                    )
                    return false
                end
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
