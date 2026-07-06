-- Id: 19804
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=65397
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
    strategy:name("ZIG ZAG MA STRATEGY")
    strategy:description("")

    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Time Frame")
    strategy.parameters:addString("TF", "Time frame", "", "m30")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addInteger("Period1", "1. MA Period", "", 5)

    strategy.parameters:addString("Method1", "MA Method", "Method", "EMA")
    strategy.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger("Period2", "2. MA Period", "", 10)

    strategy.parameters:addString("Method2", "MA Method", "Method", "EMA")
    strategy.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger(
        "Depth1",
        "Depth",
        "The minimum number of periods used to draw one ZigZag line.",
        10,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "Deviation1",
        "Deviation",
        "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.",
        5,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "Backstep1",
        "Backstep",
        "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.",
        3,
        1,
        1000
    )

    strategy.parameters:addInteger(
        "Depth2",
        "Depth",
        "The minimum number of periods used to draw one ZigZag line.",
        30,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "Deviation2",
        "Deviation",
        "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.",
        5,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "Backstep2",
        "Backstep",
        "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.",
        3,
        1,
        1000
    )

    CreateTradingParameters()
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Execution Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("AccountType", "Account Type", "", "Automatic")
    strategy.parameters:addStringAlternative("AccountType", "FIFO", "", "FIFO")
    strategy.parameters:addStringAlternative("AccountType", "non FIFO", "", "NON")
    strategy.parameters:addStringAlternative("AccountType", "Automatic", "", "Automatic")

    strategy.parameters:addString("EntryExecutionType", "Entry Execution Type", "", "EndOfTurn")
    strategy.parameters:addStringAlternative("EntryExecutionType", "End of Turn", "", "EndOfTurn")
    strategy.parameters:addStringAlternative("EntryExecutionType", "Live", "", "Live")

    strategy.parameters:addGroup("Trade Parameters")

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "ZZMAS"
    )

    strategy.parameters:addBoolean("PositionCap", "Use Position Cap", "", false)

    strategy.parameters:addInteger(
        "MaxNumberOfPositionInAnyDirection",
        "Max Number Of Open Position In Any Direction",
        "",
        2
    )
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1)

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
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30)
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

local AccountType
local Source, Source1, Source2, Source3, Source4, TickSource
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
local EntyExecutionType, ExitExecutionType
local CloseOnOpposite
local first
local Direction
local CustomID
local PositionCap

local OpenTime, CloseTime, ExitTime
local LastEntry, LastExit
local ToTime
local ValidInterval, UseMandatoryClosing

--Indicator parameters
local MA1, MA2
local TF
local ZIGZAG1, ZIGZAG2

function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    AccountType = instance.parameters.AccountType
    EntryExecutionType = instance.parameters.EntryExecutionType
    ExitExecutionType = instance.parameters.ExitExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"
    ToTime = instance.parameters.ToTime

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

    PositionCap = instance.parameters.PositionCap
    ValidInterval = instance.parameters.ValidInterval
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing

    LastEntry = nil
    LastExit = nil

    --Indicator parameters
    TF = instance.parameters.TF

    assert(TF ~= "t1", "The time frame must not be tick")

    name = profile:id() .. ", " .. instance.bid:name() .. ", " .. CustomID
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    if EntryExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, TF, instance.parameters.Type == "Bid", "bar")

    assert(core.indicators:findIndicator(instance.parameters.Method1) ~= nil, instance.parameters.Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(instance.parameters.Method1, Source.close, instance.parameters.Period1)
    assert(core.indicators:findIndicator(instance.parameters.Method2) ~= nil, instance.parameters.Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(instance.parameters.Method2, Source.close, instance.parameters.Period2)

    ZIGZAG1 =
        core.indicators:create(
        "ZIGZAG",
        Source,
        instance.parameters.Depth1,
        instance.parameters.Deviation1,
        instance.parameters.Backstep1
    )
    ZIGZAG2 =
        core.indicators:create(
        "ZIGZAG",
        Source,
        instance.parameters.Depth2,
        instance.parameters.Deviation2,
        instance.parameters.Backstep2
    )

    ValidInterval = instance.parameters.ValidInterval
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing

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

function ReleaseInstance()
    core.host:execute("killTimer", 100)
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
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
    --CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);

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

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if period < 0 then
        return
    end

    if EntryExecutionType == "Live" then
        if id ~= 1 then
            return
        end
        period0 = core.findDate(Source, TickSource:date(period), false)
    else
        if id ~= 2 then
            return
        end
        period0 = period
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    -- update indicators.
    MA1:update(core.UpdateLast)
    MA2:update(core.UpdateLast)
    ZIGZAG1:update(core.UpdateAll)
    ZIGZAG2:update(core.UpdateAll)

    if
        not MA1.DATA:hasData(period0) or not MA2.DATA:hasData(period0) or not MA1.DATA:hasData(period0 - 1) or
            not MA2.DATA:hasData(period0 - 1)
     then
        return
    end

    if EntryExecutionType == "Live" and id == 1 or EntryExecutionType ~= "Live" and id ~= 1 then
        EntryFunction(now, period0)
    end
end

function FindLast(period0)
    local Top1 = {0, 0, 0, 0}
    local Bottom1 = {0, 0, 0, 0}
    local Top1_Count = 0
    local Bottom1_Count = 0

    local Top2 = {0, 0, 0, 0}
    local Bottom2 = {0, 0, 0, 0}
    local Top2_Count = 0
    local Bottom2_Count = 0

    for i = period0, Source:first(), -1 do
        if ZIGZAG1.DATA:hasData(i) and ZIGZAG1.DATA[i] ~= 0 and ZIGZAG1.DATA[i] ~= nil then
            if ZIGZAG1.DATA[i] == Source.high[i] then
                Top1_Count = Top1_Count + 1
                Top1[Top1_Count] = i
            end

            if ZIGZAG1.DATA[i] == Source.low[i] then
                Bottom1_Count = Bottom1_Count + 1
                Bottom1[Bottom1_Count] = i
            end

            if Top1_Count >= 2 and Bottom1_Count >= 2 then
                break
            end
        end
    end

    for i = period0, Source:first(), -1 do
        if ZIGZAG2.DATA:hasData(i) and ZIGZAG2.DATA[i] ~= 0 and ZIGZAG2.DATA[i] ~= nil then
            if ZIGZAG2.DATA[i] == Source.high[i] then
                Top2_Count = Top2_Count + 1
                Top2[Top2_Count] = i
            end

            if ZIGZAG2.DATA[i] == Source.low[i] then
                Bottom2_Count = Bottom2_Count + 1
                Bottom2[Bottom2_Count] = i
            end

            if Top2_Count >= 2 and Bottom2_Count >= 2 then
                break
            end
        end
    end

    return Top1[1], Top1[2], Bottom1[1], Bottom1[2], Top2[1], Top2[2], Bottom2[1], Bottom2[2]
end

function EntryFunction(now, period0)
    local Return = false

    if not InRange(now, OpenTime, CloseTime) then
        return Return
    end

    if (LastEntry == Source:serial(period0)) then
        return
    end

    local Top_1_1, Top_1_2, Bottom_1_1, Bottom_1_2, Top_2_1, Top_2_2, Bottom_2_1, Bottom_2_2 = FindLast(period0)

    if
        Top_1_1 == 0 or Top_1_2 == 0 or Bottom_1_1 == 0 or Bottom_1_2 == 0 or Top_2_1 == 0 or Top_2_2 == 0 or
            Bottom_2_1 == 0 or
            Bottom_2_2 == 0
     then
        return
    end

    --[[
	
	buy;

	1.zig zag 1((current)= down and
	2.zig zag 2(current)= down and
	3.zig zag1(down)(current zig zag ) > zig zag2(down)(current zig zag) and
	4.zig zag1 (up)(previous zig zag) < zig zag 2(up)((previous zig zag) and

	5.ema 5 cross over ema 10

	sell:

	1.zig zag 1((current)= up and
	2.zig zag 2(current)= up and
	3.zig zag1(up)(current zig zag ) < zig zag2(up)(current zig zag) and
	4.zig zag1 (down)(previous zig zag) > zig zag 2(down)((previous zig zag) and
	5. ema 5 cross under ema 10

	]]
    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if
        MA1.DATA[period0] > MA2.DATA[period0] and MA1.DATA[period0 - 1] <= MA2.DATA[period0 - 1] and
            ZIGZAG1.DATA[Bottom_1_1] == Source.low[Bottom_1_1] and
            ZIGZAG2.DATA[Bottom_2_1] == Source.low[Bottom_2_1] and
            ZIGZAG1.DATA[Bottom_1_1] > ZIGZAG2.DATA[Bottom_2_1] and
            ZIGZAG1.DATA[Top_1_2] < ZIGZAG2.DATA[Top_2_2]
     then
        if Direction then
            BUY()
        else
            SELL()
        end
        LastEntry = Source:serial(period0)
        Return = true
    elseif
        MA1.DATA[period0] < MA2.DATA[period0] and MA1.DATA[period0 - 1] >= MA2.DATA[period0 - 1] and
            ZIGZAG1.DATA[Top_1_1] == Source.high[Top_1_1] and
            ZIGZAG2.DATA[Top_2_1] == Source.high[Top_2_1] and
            ZIGZAG1.DATA[Top_1_1] < ZIGZAG2.DATA[Top_2_1] and
            ZIGZAG1.DATA[Bottom_1_2] > ZIGZAG2.DATA[Bottom_2_2]
     then
        if Direction then
            SELL()
        else
            BUY()
        end
        LastEntry = Source:serial(period0)
        Return = true
    end

    return Return
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
        --if CanClose and CloseOnOpposite and  haveTrades("S") then
        if (CloseOnOpposite or Hedge) and haveTrades("S") then
            -- close on opposite signal
            exitSpecific("S")
            Signal("Close Short")
        end

        if ALLOWEDSIDE == "Sell" then
            -- we are not allowed buys.
            return
        end

        enter("B", 0)
    else
        Signal("Buy Signal")
    end
end

function HEDGELONG()
    if ALLOWEDSIDE == "Buy" and haveTrades("B") then
        -- we are not allowed sells.
        return
    end

    if not haveTrades("B") then
        return
    end

    if AllowTrade then
        local bCount = tradesCount("B")

        if bCount > 0 then
            exitSpecific("B")
            Signal("Hedge Long")
            enter("S", bCount)
        end
    else
        Signal("Hedge Long")
    end
end
function HEDGESHORT()
    if ALLOWEDSIDE == "Sell" and haveTrades("S") then
        -- we are not allowed buys.
        return
    end

    if not haveTrades("S") then
        return
    end

    if AllowTrade then
        local sCount = tradesCount("S")

        if sCount > 0 then
            exitSpecific("S")
            Signal("Hedge Short")
            enter("B", sCount)
        end
    else
        Signal("Hedge Short")
    end
end

function SELL()
    if AllowTrade then
        --if CanClose and CloseOnOpposite and  haveTrades("B") then
        if (CloseOnOpposite or Hedge) and haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B")
            Signal("Close Long")
        end

        if ALLOWEDSIDE == "Buy" then
            -- we are not allowed sells.
            return
        end

        enter("S", 0)
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
        terminal:alertEmail(Email, profile:id() .. " : " .. Label, FormatEmail(Source, NOW, Label))
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
function enter(BuySell, hCount)
    -- do not enter if position in the specified direction already exists
    if
        (tradesCount(BuySell) >= MaxNumberOfPosition or (tradesCount(nil) >= MaxNumberOfPositionInAnyDirection)) and
            PositionCap
     then
        return true
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal("Sell Signal")
    else
        Signal("Buy Signal")
    end

    return MarketOrder(BuySell, hCount)
end

-- enter into the specified direction
function MarketOrder(BuySell, hCount)
    --  if trade_in_progress then
    --return;
    --end

    -- trade_in_progress=true;

    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    if hCount > 0 then
        valuemap.Quantity = hCount * BaseSize
    else
        valuemap.Quantity = Amount * BaseSize
    end
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
    if not AllowTrade then
        return
    end

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
                --valuemap.Quantity = Amount*BaseSize;
                valuemap.Quantity = row.Lot
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
