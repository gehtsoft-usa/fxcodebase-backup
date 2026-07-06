-- Id: 6662
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=16865

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    strategy:name("Trend Stop Strategy with Filters")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("Price", "Price Type", "", "close")
    strategy.parameters:addStringAlternative("Price", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("TS Calculation")

    strategy.parameters:addInteger("Period", "Period", "Period", 10)
    strategy.parameters:addString("Mode", "Triger", "", "Close")
    strategy.parameters:addStringAlternative("Mode", "Close", "", "Close")
    strategy.parameters:addStringAlternative("Mode", "High/Low", "", "High")

    strategy.parameters:addGroup("MA Filter Calculation")
    strategy.parameters:addBoolean("Reverse", "Reverse MA Filter", "", false)
    strategy.parameters:addBoolean("MaFilter1", "Use First MA Filter", "", false)
    strategy.parameters:addInteger("FP1", "Average Period", "", 20)
    strategy.parameters:addString("Method1", "First Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Method1", "HMA", "HMA", "HMA")
    strategy.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA")
    strategy.parameters:addBoolean("MaFilter2", "Use Second MA Filter", "", false)
    strategy.parameters:addInteger("FP2", "Average Period", "", 40)
    strategy.parameters:addString("Method2", "Method2", "Method", "MVA")
    strategy.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Method2", "HMA", "HMA", "HMA")
    strategy.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA")

    strategy.parameters:addGroup("Trendstop Confirmation Filter Calculation")
    strategy.parameters:addBoolean("Confirmation", "Use Trendstop Confirmation Filter", "", false)
    strategy.parameters:addBoolean("Simultaneous", "Simultaneous Crossover of Both TS", "", false)
    strategy.parameters:addInteger("CP", "Period", "Period", 15)
    strategy.parameters:addString("CM", "Triger", "", "Close")
    strategy.parameters:addStringAlternative("CM", "Close", "", "Close")
    strategy.parameters:addStringAlternative("CM", "High/Low", "", "High")

    strategy.parameters:addGroup("Trendstop trailing stop")
    strategy.parameters:addString("TTS1", "Use first Trendstop trailing stop", "", "MVA")
    strategy.parameters:addStringAlternative("TTS1", "No", "No", "No")
    strategy.parameters:addStringAlternative("TTS1", "Always", "Always", "Always")
    strategy.parameters:addStringAlternative("TTS1", "MVAsMatch", "MVAsMatch", "MVAsMatch")
    strategy.parameters:addStringAlternative("TTS1", "MVAsOpposite", "MVAsOpposite", "MVAsOpposite")
    strategy.parameters:addDouble("TS1", "Trendstop trailing stop (in pips)", "", 50)
    strategy.parameters:addString("TTS2", "Use second Trendstop trailing stop", "", "MVA")
    strategy.parameters:addStringAlternative("TTS2", "No", "No", "No")
    strategy.parameters:addStringAlternative("TTS2", "Always", "Always", "Always")
    strategy.parameters:addStringAlternative("TTS2", "MVAsMatch", "MVAsMatch", "MVAsMatch")
    strategy.parameters:addStringAlternative("TTS2", "MVAsOpposite", "MVAsOpposite", "MVAsOpposite")
    strategy.parameters:addDouble("TS2", "Trendstop trailing stop (in pips)", "", 50)

    CreateTradingParameters()
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn")
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn")
    strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live")

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "TSSWF"
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
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", false)

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

local Source, TickSource
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
local first
local Mode, Period
local Indicator = {}
local Short = {}
local Price
local Direction
local CustomID
local Reverse
local Method1, Method2
local FP1, FP2
local TS1, TS2, TTS1, TTS2
local CP, CM, Simultaneous
local MaFilter1, MaFilter2
local Confirmation

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime
--
function Prepare(nameOnly)
    Reverse = instance.parameters.Reverse
    CP = instance.parameters.CP
    CM = instance.parameters.CM
    MaFilter1 = instance.parameters.MaFilter1
    MaFilter2 = instance.parameters.MaFilter2
    Price = instance.parameters.Price
    Method1 = instance.parameters.Method1
    FP1 = instance.parameters.FP1
    Method2 = instance.parameters.Method2
    FP2 = instance.parameters.FP2
    TS1 = instance.parameters.TS1
    TTS1 = instance.parameters.TTS1
    TS2 = instance.parameters.TS2
    TTS2 = instance.parameters.TTS2
    Confirmation = instance.parameters.Confirmation
    Simultaneous = instance.parameters.Simultaneous

    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"

    Mode = instance.parameters.Mode
    Period = instance.parameters.Period

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    assert(core.indicators:findIndicator("TRENDSTOP") ~= nil, "Please, download and install TRENDSTOP.LUA indicator")

    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    Indicator[1] = core.indicators:create("TRENDSTOP", Source, Period, Mode)
    Short[1] = Indicator[1]:getStream(0)

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    Indicator[2] = core.indicators:create(Method1, Source[Price], FP1)
    Short[2] = Indicator[2]:getStream(0)

    Indicator[3] = core.indicators:create("TRENDSTOP", Source, CP, CM)
    Short[3] = Indicator[3]:getStream(0)

    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    Indicator[4] = core.indicators:create(Method2, Source[Price], FP2)
    Short[4] = Indicator[4]:getStream(0)

    first = math.max(Short[1]:first(), Short[2]:first(), Short[3]:first(), Short[4]:first())

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
    if Pos == nil then
        return nil, false
    end
    local h = tonumber(string.sub(time, 1, Pos - 1))
    time = string.sub(time, Pos + 1)
    Pos = string.find(time, ":")
    if Pos == nil then
        return nil, false
    end
    local m = tonumber(string.sub(time, 1, Pos - 1))
    local s = tonumber(string.sub(time, Pos + 1))
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
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
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

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)
    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    if ExecutionType == "Live" and id == 1 then
        period = core.findDate(Source.close, TickSource:date(period), false)
    end

    if ExecutionType == "Live" then
        if ONE == Source:serial(period) then
            return
        end

        if id == 2 then
            return
        end
    else
        if id ~= 2 then
            return
        end
    end

    -- update indicators.
    Indicator[1]:update(core.UpdateAll)
    Indicator[2]:update(core.UpdateAll)
    Indicator[3]:update(core.UpdateAll)
    Indicator[4]:update(core.UpdateAll)

    if period < first then
        return
    end

    if
        Short[1][period - 1] > Source.close[period - 1] and Short[1][period] < Source.close[period] and
            (not MaFilter1 or
                ((Source.close[period] > Short[2][period] and not Reverse) or
                    (Source.close[period] < Short[2][period] and Reverse))) and
            (not MaFilter2 or
                ((Source.close[period] > Short[4][period] and not Reverse) or
                    (Source.close[period] < Short[4][period] and Reverse))) and
            (not Confirmation or Short[3][period] < Source.close[period]) and
            (not Simultaneous or Short[3][period - 1] > Source.close[period - 1])
     then
        if Direction then
            BUY()
        else
            SELL()
        end
        ONE = Source:serial(period)
    elseif
        Short[1][period - 1] < Source.close[period - 1] and Short[1][period] > Source.close[period] and
            (not MaFilter1 or
                ((Source.close[period] < Short[2][period] and not Reverse) or
                    (Source.close[period] > Short[2][period] and Reverse))) and
            (not MaFilter2 or
                ((Source.close[period] < Short[4][period] and not Reverse) or
                    (Source.close[period] > Short[4][period] and Reverse))) and
            (not Confirmation or Short[3][period] > Source.close[period]) and
            (not Simultaneous or Short[3][period - 1] < Source.close[period - 1])
     then
        if Direction then
            SELL()
        else
            BUY()
        end
        ONE = Source:serial(period)
    end

    local TTS1Check = GetTTSValue(period, TTS1, TS1 * source:pipSize())
    local TTS2Check = GetTTSValue(period, TTS2, TS2 * source:pipSize())

    if (TTS1Check == 1 or TTS2Check == 1) then
        if haveTrades("B") then
            exitSpecific("B")
            Signal("Close Long")
        end
    elseif (TTS1Check == -1 or TTS2Check == -1) then
        if haveTrades("S") then
            exitSpecific("S")
            Signal("Close Short")
        end
    end
end

function GetTTSValue(period, TTS, TSValue)
    local check = false
    if (TTS == "Always") then
        check = true
    elseif (TTS == "MVAsMatch") then
        local mva1 = Source.close[period] > Short[2][period]
        local mva2 = Source.close[period] > Short[4][period]
        check = mva1 == mva2
    elseif (TTS == "MVAsOpposite") then
        local mva1 = Source.close[period] > Short[2][period]
        local mva2 = Source.close[period] > Short[4][period]
        check = mva1 ~= mva2
    end

    if (not check) then
        return 0
    end

    if (Short[1][period] - TSValue) > Source.close[period] then
        if Direction then
            return 1
        else
            return -1
        end
    end

    if (Short[1][period] + TSValue) < Source.close[period] then
        if Direction then
            return -1
        else
            return 1
        end
    end

    return 0
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

-- exit from the specified trade using the direction as a key
function exitSpecific(BuySell)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
            exitTrade(row)
        end

        row = enum:next()
    end
end

-- exit from the specified direction
function exitTrade(tradeRow)
    if not (AllowTrade) then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    -- switch the direction since the order must be in oppsite direction
    if tradeRow.BS == "B" then
        BuySell = "S"
    else
        BuySell = "B"
    end
    valuemap.OrderType = "CM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    if (CanClose) then
        -- Non-FIFO can close each trade independantly.
        valuemap.TradeID = tradeRow.TradeID
        valuemap.Quantity = tradeRow.Lot
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y" -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID
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

    return true
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
