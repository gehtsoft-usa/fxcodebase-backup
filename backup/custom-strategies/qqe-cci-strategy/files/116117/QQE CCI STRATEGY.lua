-- Id: 19764

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=65378

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
    strategy:name("QQE CCI STRATEGY")
    strategy:description("")

    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("1. Time Frame")
    strategy.parameters:addString("TF1", "Time frame", "", "m15")
    strategy.parameters:setFlag("TF1", core.FLAG_PERIODS)
    strategy.parameters:addInteger("CCI_Period", "CCI Period", "", 14)
    strategy.parameters:addDouble("CCI_Buy", "Buy Level", "", 0)
    strategy.parameters:addDouble("CCI_Sell", "Sell Level", "", 0)

    strategy.parameters:addGroup("2. Time Frame")
    strategy.parameters:addString("TF2", "Time frame", "", "m30")
    strategy.parameters:setFlag("TF2", core.FLAG_PERIODS)

    strategy.parameters:addInteger(
        "Depth",
        "Depth",
        "The minimum number of periods used to draw one ZigZag line.",
        13,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "Deviation",
        "Deviation",
        "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.",
        8,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "Backstep",
        "Backstep",
        "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.",
        5,
        1,
        1000
    )

    strategy.parameters:addGroup("3. Time Frame")
    strategy.parameters:addString("TF3", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF3", core.FLAG_PERIODS)

    strategy.parameters:addInteger("RF", "RSI Period", "RSI Period", 14)
    strategy.parameters:addInteger("RSP", "RSI  Smoothing Period", "RSI  Smoothing Period", 5)
    strategy.parameters:addInteger("AP", " ATR Period", " ATR Period", 14)
    strategy.parameters:addDouble("F", "Fast ATR Multipliers", "Fast ATR Multipliers", 2.618)
    strategy.parameters:addDouble("S", "Slow ATR Multipliers", "Slow ATR Multipliers", 4.236)

    strategy.parameters:addDouble("QQE_Buy", "Buy Level", "", 50)
    strategy.parameters:addDouble("QQE_Sell", "Sell Level", "", 50)

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
        "QQECCIS"
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
local Source1, Source2, Source3, TickSource
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
local TF
local OpenTime, CloseTime, ExitTime
local LastEntry, LastExit
local ToTime
local ValidInterval, UseMandatoryClosing

--Indicator parameters
local CCI, TF1, CCI_Period, CCI_Buy, CCI_Sell
local QQE, TF3, RF, RSP, AP, F, S, QQE_Buy, QQE_Sell
local ZIGZAG, Depth, Deviation, Backstep

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
    TF1 = instance.parameters.TF1
    TF2 = instance.parameters.TF2
    TF3 = instance.parameters.TF3

    CCI_Period = instance.parameters.CCI_Period
    CCI_Buy = instance.parameters.CCI_Buy
    CCI_Sell = instance.parameters.CCI_Sell

    TF3 = instance.parameters.TF3
    RF = instance.parameters.RF
    RSP = instance.parameters.RSP
    AP = instance.parameters.AP
    F = instance.parameters.F
    S = instance.parameters.S
    QQE_Buy = instance.parameters.QQE_Buy
    QQE_Sell = instance.parameters.QQE_Sell

    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep

    assert(TF1 ~= "t1", "The time frame must not be tick")
    assert(TF2 ~= "t1", "The time frame must not be tick")
    assert(TF3 ~= "t1", "The time frame must not be tick")

    name = profile:id() .. ", " .. instance.bid:name() .. ", " .. CustomID
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    assert(core.indicators:findIndicator("QQE") ~= nil, "Please, download and install QQE.LUA indicator")

    if EntryExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source1 = ExtSubscribe(2, nil, TF1, instance.parameters.Type == "Bid", "bar")
    Source2 = ExtSubscribe(3, nil, TF2, instance.parameters.Type == "Bid", "bar")
    Source3 = ExtSubscribe(4, nil, TF3, instance.parameters.Type == "Bid", "bar")
    CCI = core.indicators:create("CCI", Source1, CCI_Period)
    QQE = core.indicators:create("QQE", Source3.close, RF, RSP, AP, F, S, true, true)
    ZIGZAG = core.indicators:create("ZIGZAG", Source2, Depth, Deviation, Backstep)

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

    --local trade_in_progress=false;
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
        period1 = core.findDate(Source1, TickSource:date(period), false)
        period2 = core.findDate(Source2, TickSource:date(period), false)
        period3 = core.findDate(Source3, TickSource:date(period), false)
    else
        if id ~= 2 then
            return
        end

        period1 = period
        period2 = core.findDate(Source2, Source1:date(period), false)
        period3 = core.findDate(Source3, Source1:date(period), false)
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    -- update indicators.
    CCI:update(core.UpdateLast)
    QQE:update(core.UpdateLast)
    ZIGZAG:update(core.UpdateAll)

    if
        not CCI.DATA:hasData(period1) or not CCI.DATA:hasData(period1 - 1) or not QQE.TS1:hasData(period3) or
            not QQE.TS2:hasData(period3) or
            not QQE.QQE:hasData(period3)
     then
        return
    end

    if EntryExecutionType == "Live" and id == 1 or EntryExecutionType ~= "Live" and id ~= 1 then
        EntryFunction(now, period1, period2, period3)
    end
end

function FindLast(period)
    local ZZ = 0

    for i = period, Source2:first(), -1 do
        if ZIGZAG.DATA:hasData(i) and ZIGZAG.DATA[i] ~= 0 and ZIGZAG.DATA[i] ~= nil then
            if ZIGZAG.DATA[i] == Source2.high[i] then
                ZZ = 1
            end

            if ZIGZAG.DATA[i] == Source2.low[i] then
                ZZ = -1
            end

            break
        end
    end

    return ZZ
end

function EntryFunction(now, period1, period2, period3)
    local Return = false

    if not InRange(now, OpenTime, CloseTime) then
        return Return
    end

    if (LastEntry == Source1:serial(period1)) then
        return
    end

    local ZZ = FindLast(period2)

    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if
        CCI.DATA[period1] > CCI_Buy and CCI.DATA[period1 - 1] <= CCI_Buy and QQE.TS2[period3] > QQE_Buy and
            QQE.QQE[period3] > QQE.TS1[period3] and
            QQE.TS1[period3] > QQE.TS2[period3] and
            ZZ == -1
     then
        if Direction then
            BUY()
        else
            SELL()
        end
        LastEntry = Source1:serial(period1)
        Return = true
    elseif
        CCI.DATA[period1] < CCI_Sell and CCI.DATA[period1 - 1] >= CCI_Sell and QQE.TS2[period3] < QQE_Sell and
            QQE.QQE[period3] < QQE.TS1[period3] and
            QQE.TS1[period3] < QQE.TS2[period3] and
            ZZ == 1
     then
        if Direction then
            SELL()
        else
            BUY()
        end
        LastEntry = Source1:serial(period1)
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
