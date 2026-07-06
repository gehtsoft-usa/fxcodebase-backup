-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64607

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

function Init()
    strategy:name("Breakout strategy")
    strategy:description("Breakout strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString(
        "BreakoutType",
        "Type of Breakout (PastPeriods or IntraDay)",
        "No description",
        "Close"
    )
    strategy.parameters:addStringAlternative("BreakoutType", "Close", "Candles closed below/above price.", "Close")
    strategy.parameters:addStringAlternative("BreakoutType", "Tick", "Current Tick breakout", "Tick")
    strategy.parameters:addBoolean("OncePerDay", "Once Per Day", "Only one breakout per day allowed.", true)
    strategy.parameters:addInteger(
        "Threshold",
        "Excess (in pips) over high limit to open position",
        "Excess (in pips) over high limit to open position.",
        0,
        0,
        10000
    )

    strategy.parameters:addGroup("Breakout Indicator Parameters")
    strategy.parameters:addString("PeriodBegin", "The hour and minute when the period begins", "", "00:00")
    strategy.parameters:addString("PeriodEnd", "The hour and minute when the period ends", "", "05:30")
    strategy.parameters:addString("BoxEnd", "The hour and minute when the box ends", "", "23:00")
    strategy.parameters:addString("Type2", "The time type", "", "TD")
    strategy.parameters:addStringAlternative("Type2", "Local Time", "", "LT")
    strategy.parameters:addStringAlternative("Type2", "EST Time", "", "EST")
    strategy.parameters:addStringAlternative("Type2", "GMT Time", "", "GMT")
    strategy.parameters:addStringAlternative("Type2", "Trading Day time", "", "TD")

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Order", "", true)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Order", "", true)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addString("custom_id", "Custom ID", "", "")
    strategy.parameters:addBoolean("close_on_opposite", "Close on Opposite", "", false)
    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false)
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00")
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60)

    strategy.parameters:addGroup("Notification")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- strategy instance initialization routine
-- Processes strategy parameters and creates output streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
-- Parameters block
local BreakoutType
local Multiple
local Threshold

-- Notification
local PlaySound
local RecurrentSound
local SoundFile
local Email
local SendEmail

-- Trading parameters
local AllowTrade
local Account
local Amount
local BaseSize
local Limit
local SetLimit
local SetStop
local TrailingStop
local Offer
local CanClose
local CustomID
local CloseOnOpposite
local ValidInterval, UseMandatoryClosing
local ToTime

local gSource, gTick  -- streams
local P, H, L
local todaySell, todayBuy = false, false
local bo_ask, bo_bid, opposite_indicator;

-- Routine
function Prepare(nameOnly)
    BreakoutType = instance.parameters.BreakoutType
    Threshold = instance.parameters.Threshold * instance.bid:pipSize()
    Multiple = not instance.parameters.OncePerDay
    CustomID = instance.parameters.custom_id
    CloseOnOpposite = instance.parameters.close_on_opposite
    ValidInterval = instance.parameters.ValidInterval
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing
    ToTime = instance.parameters.Type2
    if ToTime == "EST" then
        ToTime = core.TZ_EST
    elseif ToTime == "GMT" then
        ToTime = core.TZ_UTC
    elseif ToTime == "LT" then
        ToTime = core.TZ_LOCAL
    elseif ToTime == "TD" then
        ToTime = core.TZ_FINANCIAL
    end

    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    ShowAlert = instance.parameters.ShowAlert
    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        RecurrentSound = instance.parameters.RecurSound
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified")

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
        Limit = instance.parameters.Limit * instance.bid:pipSize()
        SetLimit = instance.parameters.SetLimit
        SetStop = instance.parameters.SetStop
        TrailingStop = instance.parameters.TrailingStop
    end

    gTick = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    gSource = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    opposite_source = ExtSubscribe(3, nil, instance.parameters.TF, instance.parameters.Type ~= "Bid", "bar");
    assert(core.indicators:findIndicator("BREAKOUT") ~= nil, "Please, download and install BREAKOUT.LUA indicator")

    I = core.indicators:create("BREAKOUT", gSource, instance.parameters.PeriodBegin, instance.parameters.PeriodEnd,
        instance.parameters.BoxEnd, instance.parameters.Type2, false)
    opposite_indicator = core.indicators:create("BREAKOUT", opposite_source, instance.parameters.PeriodBegin, instance.parameters.PeriodEnd,
        instance.parameters.BoxEnd, instance.parameters.Type2, false);

    if instance.parameters.Type == "Bid" then
        bo_bid = I;
        bo_ask = opposite_indicator;
    else
        bo_ask = I;
        bo_bid = opposite_indicator;
    end

    ExitTime, valid = ParseTime(instance.parameters.ExitTime)
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid")

    if UseMandatoryClosing then
        core.host:execute("setTimer", 1007, math.max(ValidInterval / 2, 1))
    end

    P = I:getStream(0)
    H = I:getStream(1)
    L = I:getStream(2)

    ExtSetupSignal(name .. ":", ShowAlert)
    ExtSetupSignalMail(name .. ":")
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

local BE_NONE = 0 -- belongs to period
local BE_PERIOD = 1 -- belongs to period
local BE_BOX = 2 -- belongs to box

-- strategy calculation routine
function ExtUpdate(id, source, period)
    I:update(core.UpdateLast)
    opposite_indicator:update(core.UpdateLast);
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end
    if not P:hasData(NOW) then
        return;
    end

    if (BreakoutType == "Tick" and id ~= 1) then
        return;
    elseif (BreakoutType == "Close" and id ~= 2) then
        return;
    end

    local prev, curr = source[period - 1], source[period];
    -- if we're currently in the box
    if P[NOW] == BE_BOX then
        if
            ((prev <= H[NOW] + Threshold) and (curr > H[NOW] + Threshold)) and -- cross high line over threshold
                tradesCount("B") == 0 and -- no currently open positions
                (Multiple or (not todayBuy))
            then -- first daily trade or multiple daily trades allowed
            if (AllowTrade) then
                if CloseOnOpposite then
                    exit("S")
                end
                enter("B")
                todayBuy = true
            end
            if (ShowAlert) then
                ExtSignal(source, period, "Price breaks high. Buy.", SoundFile, Email, RecurrentSound)
            end
        elseif
            ((prev >= L[NOW] - Threshold) and (curr < L[NOW] - Threshold)) and tradesCount("S") == 0 and
                (Multiple or (not todaySell))
            then
            if (AllowTrade) then
                if CloseOnOpposite then
                    exit("B")
                end
                enter("S")
                todaySell = true
            end
            if (ShowAlert) then
                ExtSignal(source, period, "Price breaks low. Sell", SoundFile, Email, RecurrentSound)
            end
        end
    elseif P[NOW] == BE_PERIOD then
        todaySell, todayBuy = false, false
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 1007 then
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
    end
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

function exitSpecific(BuySell)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
           exitTrade(row);
        end

        row = enum:next();
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
    while count == 0 and row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            count = count + 1
        end
        row = enum:next()
    end

    return count
end

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.PegTypeStop = "M"
    valuemap.CustomID = CustomID

    if CanClose and SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit
        end
    end

    if CanClose and SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = bo_ask.L[NOW]
        else
            valuemap.RateStop = bo_bid.H[NOW]
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end

    success, msg = terminal:execute(100, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    if not (CanClose) and SetLimit then
        if BuySell == "B" then
            fifoSL("LE", "S", instance.ask[NOW] + Limit, false)
        else
            fifoSL("LE", "B", instance.ask[NOW] - Limit, false)
        end
    end

    if not (CanClose) and SetStop then
        if BuySell == "B" then
            fifoSL("SE", "S", instance.ask[NOW] - Stop, TrailingStop)
        else
            fifoSL("SE", "B", instance.ask[NOW] + Stop, TrailingStop)
        end
    end

    return true
end

function fifoSL(orderType, side, rate, trailing)
    local enum, row
    local buy, sell
    enum = core.host:findTable("orders"):enumerator()
    row = enum:next()
    while (row ~= nil) do
        if
            row.OfferID == Offer and row.AccountID == Account and row.BS == side and row.NetQuantity and
                row.Type == orderType
         then
            return
        end
        row = enum:next()
    end

    local valuemap, success, msg
    valuemap = core.valuemap()
    valuemap.Command = "CreateOrder"
    valuemap.OrderType = orderType
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.NetQtyFlag = "y"
    valuemap.Rate = rate
    valuemap.BuySell = side
    valuemap.CustomID = CustomID
    if trailing then
        valuemap.TrailUpdatePips = 1
    end

    success, msg = terminal:execute(102, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[NOW],
            "Failed create limit or stop " .. msg,
            instance.bid:date(NOW)
        )
    end
end

-- exit from the specified direction
function exit(BuySell)
    if not (AllowTrade) then
        return true
    end

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
        valuemap.CustomID = CustomID
        success, msg = terminal:execute(101, valuemap)

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
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
