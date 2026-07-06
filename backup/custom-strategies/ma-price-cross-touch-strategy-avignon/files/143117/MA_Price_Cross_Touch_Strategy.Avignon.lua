-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=66893

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  |
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   |
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |
--+------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
--|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
--|Binance MEMO (BEP2 only)   : 107152697                                  |
--|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
--+------------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("MA Price Cross Touch Strategy")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("MA Parameters")

    strategy.parameters:addString("IN", "Data Source", "", "close")
    strategy.parameters:addStringAlternative("IN", "Open", "", "open")
    strategy.parameters:addStringAlternative("IN", "High", "", "high")
    strategy.parameters:addStringAlternative("IN", "Low", "", "low")
    strategy.parameters:addStringAlternative("IN", "Close", "", "close")
    strategy.parameters:addStringAlternative("IN", "Median", "", "median")
    strategy.parameters:addStringAlternative("IN", "Typical", "", "typical")
    strategy.parameters:addStringAlternative("IN", "Weighted ", "", "weighted")

    strategy.parameters:addString("M1", "Method for First Aegage", "", "EMA")
    strategy.parameters:addStringAlternative("M1", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("M1", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("M1", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("M1", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("M1", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("M1", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("M1", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("M1", "Wilders*", "", "WMA")
    strategy.parameters:addStringAlternative("M1", "FRAMA", "", "FRAMA")

    strategy.parameters:addString("M2", "Method for Second Avegage", "", "EMA")
    strategy.parameters:addStringAlternative("M2", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("M2", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("M2", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("M2", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("M2", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("M2", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("M2", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("M2", "Wilders*", "", "WMA")
    strategy.parameters:addStringAlternative("M2", "FRAMA", "", "FRAMA")

    strategy.parameters:addInteger("Frame1", "MA Frame", "", 100, 2, 1000)
    strategy.parameters:addInteger("Frame2", "MA Frame", "", 200, 2, 1000)

    strategy.parameters:addString("Confirmation", "Confirmation Type", "", "Both")
    strategy.parameters:addStringAlternative("Confirmation", "Any", "", "Both")
    strategy.parameters:addStringAlternative("Confirmation", "First MA", "", "One")
    strategy.parameters:addStringAlternative("Confirmation", "Second MA", "", "Two")
    strategy.parameters:addBoolean("confirm_long", "Confirm Using Long MA", "", false);
    strategy.parameters:addBoolean("confirm_distance", "Confirm Using Long-Short MA distance", "", false);
    strategy.parameters:addDouble("distance", "Long-Short MA Distance", "", 0);

    strategy.parameters:addGroup("Cross Type")
    strategy.parameters:addString("CrossType", "Method of Cross", "", "Cross")
    strategy.parameters:addStringAlternative("CrossType", "Cross", "", "Cross")
    strategy.parameters:addStringAlternative("CrossType", "Touch", "", "Touch")

    strategy.parameters:addGroup("Price Type")

    strategy.parameters:addString("PIN", "Data Source", "", "close")
    strategy.parameters:addStringAlternative("PIN", "Open", "", "open")
    strategy.parameters:addStringAlternative("PIN", "High", "", "high")
    strategy.parameters:addStringAlternative("PIN", "Low", "", "low")
    strategy.parameters:addStringAlternative("PIN", "Close", "", "close")
    strategy.parameters:addStringAlternative("PIN", "Median", "", "median")
    strategy.parameters:addStringAlternative("PIN", "Typical", "", "typical")
    strategy.parameters:addStringAlternative("PIN", "Weighted ", "", "weighted")

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
        "MPCTS"
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
    -- strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", true);

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
local IN, PIN, M1, M2, Frame1, Frame2, Confirmation, CrossType
local Direction
local CustomID
local confirm_distance;
local distance;
local indicator = {}

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime
--
function Prepare(nameOnly)
    confirm_distance = instance.parameters.confirm_distance;
    distance = instance.parameters.distance;
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"

    IN = instance.parameters.IN
    PIN = instance.parameters.PIN
    M1 = instance.parameters.M1
    M2 = instance.parameters.M2
    Frame1 = instance.parameters.Frame1
    Frame2 = instance.parameters.Frame2
    Confirmation = instance.parameters.Confirmation
    CrossType = instance.parameters.CrossType

    assert(core.indicators:findIndicator(M1) ~= nil, "Please download and install " .. M1 .. " Indicator!")
    assert(core.indicators:findIndicator(M2) ~= nil, "Please download and install " .. M2 .. " Indicator!")

    -- Exit= instance.parameters.Exit;

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

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

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    if M1 == "FRAMA" then
        indicator[1] = core.indicators:create(M1, Source, Frame1)
    else
        indicator[1] = core.indicators:create(M1, Source[IN], Frame1)
    end

    if M2 == "FRAMA" then
        indicator[2] = core.indicators:create(M2, Source, Frame2)
    else
        indicator[2] = core.indicators:create(M2, Source[IN], Frame2)
    end
    if Frame2 > Frame1 then
        indicator.LongMA = indicator[2];
    else
        indicator.LongMA = indicator[1];
    end

    first = math.max(indicator[1].DATA:first(), indicator[2].DATA:first()) + 1

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

function CrossUnder(period, data)
    if period <= data:first() + 1
        or Source[PIN]:size() <= period 
        or not Source[PIN]:hasData(period - 1)
        or not data:hasData(period - 1)
    then
        return false;
    end
    if not core.crossesUnder(Source[PIN], data, period - 1) then
        return false;
    end
    return Source[PIN][period] < data[period];
end
function CrossOver(period, data)
    if period <= data:first() + 1
        or Source[PIN]:size() <= period 
        or not Source[PIN]:hasData(period - 1)
        or not data:hasData(period - 1)
    then
        return false;
    end
    return core.crossesOver(Source[PIN], data, period - 1)
        and Source[PIN][period] > data[period];
end

function ConfirmLong(period)
    return not instance.parameters.confirm_long or indicator.LongMA.DATA[period] < indicator.LongMA.DATA[period - 1];
end
function ConfirmShort(period)
    return not instance.parameters.confirm_long or indicator.LongMA.DATA[period] > indicator.LongMA.DATA[period - 1];
end
function ConfirmMADistance(period)
    if not confirm_distance then
        return false;
    end
    local dist = math.abs(indicator[1].DATA[period] - indicator[2].DATA[period]) / Source:pipSize();
    return dist >= distance;
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)
    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if period < first or period < 0 then
        return
    end

    if ExecutionType == "Live" and id == 1 then
        period = core.findDate(Source.close, TickSource:date(period), false)
    end

    if period == -1 then
        return
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

    indicator[1]:update(core.UpdateLast)
    indicator[2]:update(core.UpdateLast)

    if period < first then
        return
    end

    if CrossType == "Cross" then
        if ((CrossUnder(period, indicator[1].DATA) and Confirmation ~= "Two") or
            (CrossUnder(period, indicator[2].DATA) and Confirmation ~= "One"))
            and ConfirmLong(period)
            and ConfirmMADistance(period)
            and indicator[1].DATA[period] < Source.close[period]
            and indicator[2].DATA[period] < Source.close[period]
        then
            if Direction then
                SELL()
            else
                BUY()
            end

            ONE = Source:serial(period)
        elseif ((CrossOver(period, indicator[1].DATA) and Confirmation ~= "Two") or
            (CrossUnder(period, indicator[2].DATA) and Confirmation ~= "One"))
            and ConfirmShort(period)
            and ConfirmMADistance(period)
            and indicator[1].DATA[period] > Source.close[period]
            and indicator[2].DATA[period] > Source.close[period]
        then
            if Direction then
                BUY()
            else
                SELL()
            end

            ONE = Source:serial(period)
        end
    elseif CrossType == "Touch" then
        if ((Source.high[period] > indicator[1].DATA[period] and Source.low[period] < indicator[1].DATA[period] and
            Confirmation ~= "Two") or
            (Source.high[period] > indicator[2].DATA[period] and Source.low[period] < indicator[2].DATA[period] and
            Confirmation ~= "One"))
         then
            if ((Confirmation ~= "Two" and Source.close[period - 1] < indicator[1].DATA[period - 1]) or
                (Confirmation ~= "One" and Source.close[period - 1] < indicator[2].DATA[period - 1]))
                and ConfirmLong(period)
                and ConfirmMADistance(period)
            then
                if Direction then
                    BUY()
                else
                    SELL()
                end
            end

            if ((Confirmation ~= "Two" and Source.close[period - 1] > indicator[1].DATA[period - 1]) or
                (Confirmation ~= "One" and Source.close[period - 1] > indicator[2].DATA[period - 1]))
                and ConfirmShort(period)
                and ConfirmMADistance(period)
            then
                if Direction then
                    SELL()
                else
                    BUY()
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
    core.host:trace(BuySell);
    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "LE"
    if BuySell == "B" then
        valuemap.Rate = Source.low[NOW - 1];
    else
        valuemap.Rate = Source.high[NOW - 1];
    end
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
