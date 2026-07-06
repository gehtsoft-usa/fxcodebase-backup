-- Id: 19781
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65388

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
    strategy:name("Murray Math lines strategy")
    strategy:description("")

    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Calculation")
    strategy.parameters:addInteger("P", "Number of periods", "", 64, 2, 10000)
    strategy.parameters:addInteger("N", "Size of the period in minutes", "", 60, 2, 10000)

    strategy.parameters:addGroup("Line Selector")

    strategy.parameters:addBoolean("Show" .. 4, "Use [1/8] Line ", "", true)
    strategy.parameters:addBoolean("Show" .. 5, "Use [2/8] Line ", "", true)
    strategy.parameters:addBoolean("Show" .. 6, "Use [3/8] Line ", "", true)
    strategy.parameters:addBoolean("Show" .. 7, "Use [4/8] Line ", "", true)
    strategy.parameters:addBoolean("Show" .. 8, "Use [5/8] Line ", "", true)
    strategy.parameters:addBoolean("Show" .. 9, "Use [6/8] Line ", "", true)
    strategy.parameters:addBoolean("Show" .. 10, "Use [7/8] Line ", "", true)

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

    strategy.parameters:addString("EntryExecutionType", "Entry Execution Type", "", "Live")
    strategy.parameters:addStringAlternative("EntryExecutionType", "End of Turn", "", "EndOfTurn")
    strategy.parameters:addStringAlternative("EntryExecutionType", "Live", "", "Live")

    strategy.parameters:addGroup("Trade Parameters")

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "MMLS"
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
    --  strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    -- strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30);
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
local SetStop
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
local OpenLong, OpenShort
local CloseLong, CloseShort, HedgeLong, HedgeShort

local P, N
local Show = {}
local depth
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    AccountType = instance.parameters.AccountType
    EntryExecutionType = instance.parameters.EntryExecutionType
    ExitExecutionType = instance.parameters.ExitExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"
    TF = instance.parameters.TF
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

    Show[3] = instance.parameters.Show4
    Show[4] = instance.parameters.Show5
    Show[5] = instance.parameters.Show6
    Show[6] = instance.parameters.Show7
    Show[7] = instance.parameters.Show8
    Show[8] = instance.parameters.Show9
    Show[9] = instance.parameters.Show10

    P = instance.parameters.P
    N = instance.parameters.N

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

    local s, e
    s, e = core.getcandle(Source:barSize(), core.now(), 0)
    barsize = math.floor(((e - s) * 1440) + 0.5)

    depth = P * math.ceil(N / barsize)
    if (depth == 0) then
        depth = P
    end

    first = Source.close:first() + depth

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

function Calculate(period)
    local Levels = {}

    local min, max, minp, maxp, fractal, range, octave, sum, mn, mx
    min, max, minp, maxp = core.minmax(Source, core.rangeTo(period, depth))
    if max <= 250000 and max > 25000 then
        fractal = 100000
    elseif max <= 25000 and max > 2500 then
        fractal = 10000
    elseif max <= 2500 and max > 250 then
        fractal = 1000
    elseif max <= 250 and max > 25 then
        fractal = 100
    elseif max <= 25 and max > 12.5 then
        fractal = 12.5
    elseif max <= 12.5 and max > 6.25 then
        fractal = 12.5
    elseif max <= 6.25 and max > 3.125 then
        fractal = 6.25
    elseif max <= 3.125 and max > 1.5625 then
        fractal = 3.125
    elseif max <= 1.5625 and max > 0.390625 then
        fractal = 1.5625
    elseif max <= 0.390625 and max > 0 then
        fractal = 0.1953125
    else
        return nil
    end

    range = max - min
    sum = math.floor(math.log(fractal / range) / math.log(2))
    octave = fractal * (math.pow(0.5, sum))
    mn = math.floor(min / octave) * octave
    if mn + octave > max then
        mx = mn + octave
    else
        mx = mn + (2 * octave)
    end

    local x1, x2, x3, x4, x5, x6
    local y1, y2, y3, y4, y5, y6
    local finalH, finalL

    if (min >= (3 * (mx - mn) / 16 + mn)) and (max <= (9 * (mx - mn) / 16 + mn)) then
        x2 = mn + (mx - mn) / 2
    else
        x2 = 0
    end

    if (min >= (mn - (mx - mn) / 8)) and (max <= (5 * (mx - mn) / 8 + mn)) and (x2 == 0) then
        x1 = mn + (mx - mn) / 2
    else
        x1 = 0
    end

    if (min >= (mn + 7 * (mx - mn) / 16)) and (max <= (13 * (mx - mn) / 16 + mn)) then
        x4 = mn + 3 * (mx - mn) / 4
    else
        x4 = 0
    end

    if (min >= (mn + 3 * (mx - mn) / 8)) and (max <= (9 * (mx - mn) / 8 + mn)) and (x4 == 0) then
        x5 = mx
    else
        x5 = 0
    end

    if
        (min >= (mn + (mx - mn) / 8)) and (max <= (7 * (mx - mn) / 8 + mn)) and (x1 == 0) and (x2 == 0) and (x4 == 0) and
            (x5 == 0)
     then
        x3 = mn + 3 * (mx - mn) / 4
    else
        x3 = 0
    end

    if (x1 + x2 + x3 + x4 + x5) == 0 then
        x6 = mx
    else
        x6 = 0
    end

    finalH = x1 + x2 + x3 + x4 + x5 + x6

    if x1 > 0 then
        y1 = mn
    else
        y1 = 0
    end

    if x2 > 0 then
        y2 = mn + (mx - mn) / 4
    else
        y2 = 0
    end

    if x3 > 0 then
        y3 = mn + (mx - mn) / 4
    else
        y3 = 0
    end

    if x4 > 0 then
        y4 = mn + (mx - mn) / 2
    else
        y4 = 0
    end

    if x5 > 0 then
        y5 = mn + (mx - mn) / 2
    else
        y5 = 0
    end

    if (finalH > 0) and ((y1 + y2 + y3 + y4 + y5) == 0) then
        y6 = mn
    else
        y6 = 0
    end

    finalL = y1 + y2 + y3 + y4 + y5 + y6

    local dmml, price, i, price0
    dmml = (finalH - finalL) / 8

    price = finalL - dmml * 2

    price0 = price

    for i = 0, 12, 1 do
        Levels[i] = price
        price = price + dmml
    end

    return Levels
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
        period = core.findDate(Source, TickSource:date(period), false)
    else
        if id ~= 2 then
            return
        end
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    if period < first then
        return
    end

    if EntryExecutionType == "Live" and id == 1 or EntryExecutionType ~= "Live" and id ~= 1 then
        EntryFunction(now, period)
    end
end

function EntryFunction(now, period)
    local Return = false

    local Levels = Calculate(period)

    if Levels == nil then
        return
    end

    if not InRange(now, OpenTime, CloseTime) then
        return Return
    end

    if (LastEntry == Source:serial(period)) then
        return
    end

    local Stop, Limit
    local BuyNOW = false
    local SellNOW = false

    for i = 3, 9, 1 do
        if Show[i] and Source.close[period] > Levels[i] and Source.close[period - 1] <= Levels[i] then
            BuyNOW = true
        end

        Stop = Levels[i - 1]
        Limit = Levels[i + 1]
        if BuyNOW then
            break
        end
    end

    for i = 9, 3, -1 do
        if Show[i] and Source.close[period] < Levels[i] and Source.close[period - 1] >= Levels[i] then
            SellNOW = true
        end

        Stop = Levels[i + 1]
        Limit = Levels[i - 1]
        if SellNOW then
            break
        end
    end

    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if BuyNOW then
        if Direction then
            BUY(Stop, Limit)
        else
            SELL(Limit, Stop)
        end
        LastEntry = Source:serial(period)
        Return = true
    elseif SellNOW then
        if Direction then
            SELL(Stop, Limit)
        else
            BUY(Limit, Stop)
        end
        LastEntry = Source:serial(period)
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
function BUY(Stop, Limit)
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

        enter("B", Stop, Limit)
    else
        Signal("Buy Signal")
    end
end

function SELL(Stop, Limit)
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

        enter("S", Stop, Limit)
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
function enter(BuySell, Stop, Limit)
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

    return MarketOrder(BuySell, Stop, Limit)
end

-- enter into the specified direction
function MarketOrder(BuySell, Stop, Limit)
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

    valuemap.Quantity = Amount * BaseSize

    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID

    -- add stop/limit

    if SetStop then
        valuemap.RateStop = Stop
    end
    if TrailingStop then
        valuemap.TrailStepStop = 1
    end

    if SetLimit then
        valuemap.RateLimit = Limit
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
