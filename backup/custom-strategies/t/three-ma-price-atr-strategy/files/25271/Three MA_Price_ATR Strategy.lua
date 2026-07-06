-- Id: 5756
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=12889

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

function Init() --The strategy profile initialization
    strategy:name("Three MA/Price/ATR Strategy")
    strategy:description("")
    strategy:setTag("Version", "1.1")
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Fast MA time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("1. MA Calculation")
    strategy.parameters:addInteger("MA1", "Period", "", 34)

    strategy.parameters:addString("Price1", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("Price1", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price1", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price1", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price1", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price1", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted")

    strategy.parameters:addString("Type1", "Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Type1", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Type1", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Type1", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Type1", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Type1", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Type1", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Type1", "WMA", "WMA", "WMA")
    strategy.parameters:addStringAlternative("Type1", "VIDYA", "VIDYA", "VIDYA")

    strategy.parameters:addGroup("2. MA Calculation")
    strategy.parameters:addInteger("MA2", "Period", "", 70)

    strategy.parameters:addString("Price2", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("Price2", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price2", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price2", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price2", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price2", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted")

    strategy.parameters:addString("Type2", "Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Type2", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Type2", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Type2", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Type2", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Type2", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Type2", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Type2", "WMA", "WMA", "WMA")
    strategy.parameters:addStringAlternative("Type2", "VIDYA", "VIDYA", "VIDYA")

    strategy.parameters:addGroup("3. MA Calculation")
    strategy.parameters:addInteger("MA3", "Period", "", 100)

    strategy.parameters:addString("Price3", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("Price3", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price3", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price3", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price3", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price3", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted")

    strategy.parameters:addString("Type3", "Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Type3", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Type3", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Type3", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Type3", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("Type3", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("Type3", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("Type3", "WMA", "WMA", "WMA")
    strategy.parameters:addStringAlternative("Type3", "VIDYA", "VIDYA", "VIDYA")

    strategy.parameters:addGroup("ATR Calculation")
    strategy.parameters:addInteger("ATR", "Period", "", 14)
    strategy.parameters:addDouble("Multiplier", "Multiplier", "", 2)

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
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
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

local ATR, Multiplier

local Indicator = {}
local Short = {}
local Source

local Direction

local first
local Price1, Price2, Price3
local Type1, Type2, Type3
local MA1, MA2, MA3

local OpenTime, CloseTime, ExitTime, ValidInterval, UseMandatoryClosing
local ToTime

--
function Prepare(nameOnly)
    Price1 = instance.parameters.Price1
    Price2 = instance.parameters.Price2
    Price3 = instance.parameters.Price3

    Type1 = instance.parameters.Type1
    Type2 = instance.parameters.Type2
    Type3 = instance.parameters.Type3

    MA1 = instance.parameters.MA1
    MA2 = instance.parameters.MA2
    MA3 = instance.parameters.MA3

    Multiplier = instance.parameters.Multiplier
    ATR = instance.parameters.ATR

    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct"

    Indicator["ATR"] = nil
    Indicator["MA1"] = nil
    Indicator["MA2"] = nil
    Indicator["MA3"] = nil

    -- NG: check TF1/TF2 instead of TF
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name()
    local i

    name = name .. ", " .. MA1 .. ", " .. MA2 .. ", " .. MA3 .. ", " .. ATR .. ", " .. Multiplier

    name = name .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    Indicator["ATR"] = core.indicators:create("ATR", Source, ATR)
    Short["ATR"] = Indicator["ATR"]:getStream(0)

    assert(core.indicators:findIndicator(Type1) ~= nil, Type1 .. " indicator must be installed");
    Indicator["MA1"] = core.indicators:create(Type1, Source[Price1], MA1)
    Short["MA1"] = Indicator["MA1"]:getStream(0)

    assert(core.indicators:findIndicator(Type2) ~= nil, Type2 .. " indicator must be installed");
    Indicator["MA2"] = core.indicators:create(Type2, Source[Price2], MA2)
    Short["MA2"] = Indicator["MA2"]:getStream(0)

    assert(core.indicators:findIndicator(Type3) ~= nil, Type3 .. " indicator must be installed");
    Indicator["MA3"] = core.indicators:create(Type3, Source[Price3], MA3)
    Short["MA3"] = Indicator["MA3"]:getStream(0)

    first = math.max(Short["ATR"]:first(), Short["MA1"]:first(), Short["MA2"]:first(), Short["MA3"]:first())

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

    if not (now >= OpenTime and now <= CloseTime) then
        return
    end

    Indicator["ATR"]:update(core.UpdateLast)
    Indicator["MA1"]:update(core.UpdateLast)
    Indicator["MA2"]:update(core.UpdateLast)
    Indicator["MA3"]:update(core.UpdateLast)

    if period < first + 1 then
        return
    end

    if
        Short["MA1"][period] > Short["MA2"][period] and Short["MA2"][period] > Short["MA3"][period] and
            Short["MA1"][period] - Short["MA2"][period] > Short["ATR"][period] * Multiplier and
            core.crossesOver(Source.close, Short["MA1"], period)
     then
        if Direction then
            BUY()
        else
            SELL()
        end
    elseif
        Short["MA1"][period] < Short["MA2"][period] and Short["MA2"][period] < Short["MA3"][period] and
            Short["MA2"][period] - Short["MA1"][period] > Short["ATR"][period] * Multiplier and
            core.crossesUnder(Source.close, Short["MA1"], period)
     then
        if Direction then
            SELL()
        else
            BUY()
        end
    end

    if core.crossesUnder(Source.close, Short["MA2"], period) then
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
    if core.crossesOver(Source.close, Short["MA2"], period) then
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
