-- Id: 8315
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=29545

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
    strategy:name("Consensus of Five Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Selector")
    strategy.parameters:addBoolean("One", "Use DMI Filter", "", true)
    strategy.parameters:addBoolean("Two", "Use ADX Filter", "", true)
    strategy.parameters:addBoolean("Three", "Use CCI Filter", "", true)
    strategy.parameters:addBoolean("Four", "Use MACD Filter", "", true)
    strategy.parameters:addBoolean("Five", "Use Stochastic Filter", "", true)

    strategy.parameters:addGroup("DMI Calculation")
    strategy.parameters:addInteger("DMI", "Period", "", 14)

    strategy.parameters:addGroup("ADX Calculation")
    strategy.parameters:addInteger("ADX", "Period", "", 14)
    strategy.parameters:addDouble("ADX_Entry", "Entry Level", "", 20)
    strategy.parameters:addDouble("ADX_Exit", "Exit Level", "", 40)

    strategy.parameters:addGroup("CCI Calculation")
    strategy.parameters:addInteger("CCI", "Period", "", 14)
    strategy.parameters:addDouble("CCI_Buy", "Buy Level", "", 0)
    strategy.parameters:addDouble("CCI_Sell", "Sell Level", "", 0)

    strategy.parameters:addGroup("MACD Calculation")
    strategy.parameters:addInteger("MACD_Short", "Short Period", "", 12)
    strategy.parameters:addInteger("MACD_Long", "Long Period", "", 26)
    strategy.parameters:addDouble("MACD_Buy", "Buy Level", "", 0)
    strategy.parameters:addDouble("MACD_Sell", "Sell Level", "", 0)

    strategy.parameters:addString("MACD_Price", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("MACD_Price", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("MACD_Price", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("MACD_Price", "LOW", "", "low")
    strategy.parameters:addStringAlternative("MACD_Price", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("MACD_Price", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("MACD_Price", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("MACD_Price", "WEIGHTED", "", "weighted")

    strategy.parameters:addGroup("Stochastic Calculation")

    strategy.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000)
    strategy.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000)
    strategy.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000)

    strategy.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA")
    strategy.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT")
    strategy.parameters:addStringAlternative("MVAT_K", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("MVAT_K", "KAMA", "", "KAMA")
    strategy.parameters:addStringAlternative("MVAT_K", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("MVAT_K", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("MVAT_K", "VIDYA", "", "VIDYA")
    strategy.parameters:addStringAlternative("MVAT_K", "WMA", "", "WMA")

    strategy.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA")
    strategy.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("MVAT_D", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("MVAT_D", "KAMA", "", "KAMA")
    strategy.parameters:addStringAlternative("MVAT_D", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("MVAT_D", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("MVAT_D", "VIDYA", "", "VIDYA")
    strategy.parameters:addStringAlternative("MVAT_D", "WMA", "", "WMA")

    strategy.parameters:addDouble("OB", "OB Level", "", 80)
    strategy.parameters:addDouble("OS", "OS Level", "", 20)

    strategy.parameters:addGroup("Optional Exit")
    strategy.parameters:addBoolean("Exit", "Close position if neutral signal is given.", "", false)

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

local Exit
local One, Two, Three, Four, Five

local k
local d
local sd
local averageTypeK = nil
local averageTypeD = nil
local OB, OS
local Parameters = {}

local Indicator = {}
local Short = {}
local Source

local Direction

local first
local Price

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime
--
function Prepare(nameOnly)
    Exit = instance.parameters.Exit

    One = instance.parameters.One
    Two = instance.parameters.Two
    Three = instance.parameters.Three
    Four = instance.parameters.Four
    Five = instance.parameters.Five

    Parameters["DMI"] = instance.parameters.DMI
    Parameters["ADX"] = instance.parameters.ADX
    Parameters["ADX_Entry"] = instance.parameters.ADX_Entry
    Parameters["ADX_Exit"] = instance.parameters.ADX_Exit

    Parameters["CCI"] = instance.parameters.CCI
    Parameters["CCI_Buy"] = instance.parameters.CCI_Buy
    Parameters["CCI_Sell"] = instance.parameters.CCI_Sell

    Parameters["MACD_Short"] = instance.parameters.MACD_Short
    Parameters["MACD_Long"] = instance.parameters.MACD_Long
    Parameters["MACD_Buy"] = instance.parameters.MACD_Buy
    Parameters["MACD_Sell"] = instance.parameters.MACD_Sell
    Parameters["MACD_Price"] = instance.parameters.MACD_Price

    k = instance.parameters.K
    d = instance.parameters.D
    sd = instance.parameters.SD

    averageTypeK = instance.parameters.MVAT_K
    averageTypeD = instance.parameters.MVAT_D

    OB = instance.parameters.OB
    OS = instance.parameters.OS

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
    first = Source.close:first()

    if One then
        Indicator["DMI"] = core.indicators:create("DMI", Source, Parameters["DMI"])
        first = math.max(first, Indicator["DMI"].DATA:first())
    end

    if Two then
        Indicator["ADX"] = core.indicators:create("ADX", Source, Parameters["ADX"])
        first = math.max(first, Indicator["ADX"].DATA:first())
    end

    if Three then
        Indicator["CCI"] = core.indicators:create("CCI", Source, Parameters["CCI"])
        first = math.max(first, Indicator["CCI"].DATA:first())
    end

    if Four then
        Indicator["MACD"] =
            core.indicators:create(
            "MACD",
            Source[Parameters["MACD_Price"]],
            Parameters["MACD_Short"],
            Parameters["MACD_Long"]
        )
        first = math.max(first, Indicator["MACD"].DATA:first())
    end

    if Five then
        Indicator["STO"] = core.indicators:create("STOCHASTIC", Source, k, d, sd, averageTypeK, averageTypeD)
        first = math.max(first, Indicator["STO"].D:first())
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

    local current, previous
    current = Calculate(period)
    previous = Calculate(period - 1)

    if period < first + 1 then
        return
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    if current == 1 and previous ~= 1 then
        if Direction then
            BUY()
        else
            SELL()
        end
    elseif current == -1 and previous ~= -1 then
        if Direction then
            SELL()
        else
            BUY()
        end
    end

    if Exit and current == 0 then
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

function Calculate(period)
    local ONE = nil
    local TWO = nil
    local THREE_B = nil
    local THREE_S = nil
    local FOUR_B = nil
    local FOUR_S = nil
    local FIVE_B = nil
    local FIVE_S = nil

    if One then
        Indicator["DMI"]:update(core.UpdateLast)

        if Indicator["DMI"]:getStream(0)[period] > Indicator["DMI"]:getStream(1)[period] then
            ONE = true
        else
            ONE = false
        end
    end

    if Two then
        Indicator["ADX"]:update(core.UpdateLast)

        if
            Indicator["ADX"].DATA[period] > Parameters["ADX_Entry"] and
                Indicator["ADX"].DATA[period] < Parameters["ADX_Exit"]
         then
            TWO = true
        else
            TWO = false
        end
    end

    if Three then
        Indicator["CCI"]:update(core.UpdateLast)

        if Indicator["CCI"].DATA[period] > Parameters["CCI_Buy"] then
            THREE_B = true
        else
            THREE_B = false
        end

        if Indicator["CCI"].DATA[period] < Parameters["CCI_Sell"] then
            THREE_S = false
        else
            THREE_S = true
        end
    end

    if Four then
        Indicator["MACD"]:update(core.UpdateLast)

        if Indicator["MACD"].DATA[period] > Parameters["MACD_Buy"] then
            FOUR_B = true
        else
            FOUR_B = false
        end

        if Indicator["MACD"].DATA[period] < Parameters["MACD_Sell"] then
            FOUR_S = false
        else
            FOUR_S = true
        end
    end

    if Five then
        Indicator["STO"]:update(core.UpdateLast)

        if Indicator["STO"].K[period] > Indicator["STO"].D[period] and Indicator["STO"].D[period] < OB then
            FIVE_B = true
        else
            FIVE_B = false
        end

        if Indicator["STO"].K[period] < Indicator["STO"].D[period] and Indicator["STO"].D[period] > OS then
            FIVE_S = false
        else
            FIVE_S = true
        end
    end

    if
        ONE == nil and TWO == nil and THREE_B == nil and THREE_S == nil and FOUR_B == nil and FOUR_S == nil and
            FIVE_B == nil and
            FIVE_S == nil
     then
        return 0
    elseif
        (ONE == true or ONE == nil) and (TWO == true or TWO == nil) and (THREE_B == true or THREE_B == nil) and
            (FOUR_B == true or FOUR_B == nil) and
            (FIVE_B == true or FIVE_B == nil)
     then
        return 1
    elseif
        (ONE == false or ONE == nil) and (TWO == false or TWO == nil) and (THREE_S == false or THREE_S == nil) and
            (FOUR_S == false or FOUR_S == nil) and
            (FIVE_S == false or FIVE_S == nil)
     then
        return -1
    else
        return 0
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
