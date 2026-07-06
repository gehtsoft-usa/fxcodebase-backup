-- Id: 7674
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=24415

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
    strategy:name("Cowabunga strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("Price", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("Price", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    Parameters(1, "m15")
    Parameters(2, "H4")

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

function Parameters(id, TF, MVA, PERIOD)
    strategy.parameters:addGroup(id .. ". Time Frame")

    strategy.parameters:addString("TF" .. id, "Time Frame", "", TF)
    strategy.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

    if id == 1 then
        strategy.parameters:addGroup("MA Parameters")
        strategy.parameters:addInteger("SP", "Short MA Period", "", 5)
        strategy.parameters:addString("Method1", "MA Method", "Method", "EMA")
        strategy.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
        strategy.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
        strategy.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
        strategy.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA")
        strategy.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")
        strategy.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA")
        strategy.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA")
        strategy.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA")

        strategy.parameters:addInteger("LP", "Long MA Period", "", 10)
        strategy.parameters:addString("Method2", "MA Method", "Method", "EMA")
        strategy.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA")
        strategy.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA")
        strategy.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA")
        strategy.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA")
        strategy.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA")
        strategy.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA")
        strategy.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA")
        strategy.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA")

        strategy.parameters:addInteger("RP", "RSI Period", "", 9)

        strategy.parameters:addGroup("MACD Parameters")
        strategy.parameters:addInteger("SN", "Short Period ", "", 12, 2, 1000)
        strategy.parameters:addInteger("LN", "Long Period", "", 26, 2, 1000)
        strategy.parameters:addInteger("IN", " Signal line Period", "", 9, 2, 1000)

        strategy.parameters:addGroup("Stochastic Parameters")

        strategy.parameters:addInteger("K", "Number of periods for %K", "", 10, 2, 1000)
        strategy.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000)
        strategy.parameters:addInteger("D", "The number of periods for %D.", "", 3, 2, 1000)

        strategy.parameters:addString("KS", "Smoothing type for %K", "", "MVA")
        strategy.parameters:addStringAlternative("KS", "MVA", "", "MVA")
        strategy.parameters:addStringAlternative("KS", "EMA", "", "EMA")
        strategy.parameters:addStringAlternative("KS", "MT4", "", "MT")

        strategy.parameters:addString("DS", "Smoothing type for %D", "", "MVA")
        strategy.parameters:addStringAlternative("DS", "MVA", "", "MVA")
        strategy.parameters:addStringAlternative("DS", "EMA", "", "EMA")
    else
        strategy.parameters:addGroup("Confirmation Parameters")
        strategy.parameters:addInteger("CP", "Confirmation MA Period", "", 10)
        strategy.parameters:addString("Method3", "MA Method", "Method", "EMA")
        strategy.parameters:addStringAlternative("Method3", "MVA", "MVA", "MVA")
        strategy.parameters:addStringAlternative("Method3", "EMA", "EMA", "EMA")
        strategy.parameters:addStringAlternative("Method3", "LWMA", "LWMA", "LWMA")
        strategy.parameters:addStringAlternative("Method3", "TMA", "TMA", "TMA")
        strategy.parameters:addStringAlternative("Method3", "SMMA", "SMMA", "SMMA")
        strategy.parameters:addStringAlternative("Method3", "KAMA", "KAMA", "KAMA")
        strategy.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA", "VIDYA")
        strategy.parameters:addStringAlternative("Method3", "WMA", "WMA", "WMA")
    end
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

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", false)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 29, 1, 10000)
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
--local Price;
local Indicator = {}
local Short = {}
local Source = {}

local Direction

local SP, LP, RP, SN, LN, IN, K, SD, D, KS, DS, CP, Method3, Method2, Method1

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime

local TF = {}
function Prepare(nameOnly)
    Price = instance.parameters.Price

    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct"

    SP = instance.parameters.SP
    LP = instance.parameters.LP
    RP = instance.parameters.RP
    SN = instance.parameters.SN
    LN = instance.parameters.LN
    IN = instance.parameters.IN
    K = instance.parameters.K
    SD = instance.parameters.SD
    D = instance.parameters.D
    KS = instance.parameters.KS
    DS = instance.parameters.DS
    CP = instance.parameters.CP
    Method1 = instance.parameters.Method1
    Method2 = instance.parameters.Method2
    Method3 = instance.parameters.Method3

    -- NG: check TF1/TF2 instead of TF
    local i
    for i = 1, 2, 1 do
        TF[i] = instance.parameters:getString("TF" .. i)
        assert(TF[i] ~= "t1", i .. ". The time frame must not be tick")
    end
    local name

    name =
        profile:id() ..
        ", " ..
            instance.bid:name() ..
                ", (" ..
                    TF[1] ..
                        ", " ..
                            SP ..
                                ", " ..
                                    Method1 ..
                                        ", " ..
                                            LP ..
                                                ", " ..
                                                    Method2 ..
                                                        ", " ..
                                                            RP ..
                                                                ", " ..
                                                                    SN ..
                                                                        ", " ..
                                                                            LN ..
                                                                                ", " ..
                                                                                    IN ..
                                                                                        ", " ..
                                                                                            K ..
                                                                                                ", " ..
                                                                                                    SD ..
                                                                                                        ", " ..
                                                                                                            D ..
                                                                                                                ", " ..
                                                                                                                    KS ..
                                                                                                                        ", " ..
                                                                                                                            DS ..
                                                                                                                                "), (" ..
                                                                                                                                    CP ..
                                                                                                                                        ", " ..
                                                                                                                                            Method3 ..
                                                                                                                                                " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    for i = 1, 2, 1 do
        Source[i] = ExtSubscribe(i, nil, TF[i], instance.parameters.Type == "Bid", "bar")

        if i == 1 then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
            Indicator["SA"] = core.indicators:create(Method1, Source[i][Price], SP)
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
            Indicator["LA"] = core.indicators:create(Method2, Source[i][Price], LP)
            Indicator["RSI"] = core.indicators:create("RSI", Source[i][Price], RP)
            Indicator["STO"] = core.indicators:create("STOCHASTIC", Source[i], K, SD, D, KS, DS)
            Indicator["MACD"] = core.indicators:create("MACD", Source[i][Price], SN, LN, IN)

            Short["SM"] = Indicator["SA"]:getStream(0)
            Short["LM"] = Indicator["LA"]:getStream(0)
            Short["RSI"] = Indicator["RSI"]:getStream(0)
            Short["STO"] = Indicator["STO"]:getStream(0)
            Short["MACD"] = Indicator["MACD"]:getStream(0)
        else
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
            Indicator["CA"] = core.indicators:create(Method3, Source[i][Price], CP)
            Short["CM"] = Indicator["CA"]:getStream(0)
        end
    end

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

    Indicator["SA"]:update(core.UpdateLast)
    Indicator["LA"]:update(core.UpdateLast)
    Indicator["RSI"]:update(core.UpdateLast)
    Indicator["STO"]:update(core.UpdateLast)
    Indicator["MACD"]:update(core.UpdateLast)
    Indicator["CA"]:update(core.UpdateLast)

    -- NG: condition to check the presense of the data is changed to proper
    --     crossover functions
    if
        Short["SM"]:size() <= Short["SM"]:first() + 3 or Short["LM"]:size() <= Short["LM"]:first() + 3 or
            Short["CM"]:size() <= Short["CM"]:first() + 3 or
            Short["STO"]:size() <= Short["STO"]:first() + 3 or
            Short["RSI"]:size() <= Short["RSI"]:first() + 3 or
            Short["MACD"]:size() <= Short["MACD"]:first() + 3
     then
        return
    end

    if
        core.crossesOver(Short["SM"], Short["LM"], Short["SM"]:size() - 2, Short["LM"]:size() - 2) and
            Short["CM"][Short["CM"]:size() - 2] > Short["CM"][Short["CM"]:size() - 3] and
            Short["RSI"][Short["RSI"]:size() - 2] > 50 and
            Short["STO"][Short["STO"]:size() - 2] > Short["STO"][Short["STO"]:size() - 3] and
            Short["STO"][Short["STO"]:size() - 2] < 80 and
            Short["MACD"][Short["MACD"]:size() - 2] > Short["MACD"][Short["MACD"]:size() - 3] and
            Short["MACD"][Short["MACD"]:size() - 2] < 0
     then
        if Direction then
            BUY()
        else
            SELL()
        end
    elseif
        core.crossesUnder(Short["SM"], Short["LM"], Short["SM"]:size() - 2, Short["LM"]:size() - 2) and
            Short["CM"][Short["CM"]:size() - 2] < Short["CM"][Short["CM"]:size() - 3] and
            Short["RSI"][Short["RSI"]:size() - 2] < 50 and
            Short["STO"][Short["STO"]:size() - 2] < Short["STO"][Short["STO"]:size() - 3] and
            Short["STO"][Short["STO"]:size() - 2] > 20 and
            Short["MACD"][Short["MACD"]:size() - 2] < Short["MACD"][Short["MACD"]:size() - 3] and
            Short["MACD"][Short["MACD"]:size() - 2] > 0
     then
        if Direction then
            SELL()
        else
            BUY()
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
