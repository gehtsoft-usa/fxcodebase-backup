-- Id: 15382
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=63107

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
    strategy:name("Multiple Indicator Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("RLW Calculation")
    strategy.parameters:addInteger("RLW_Period", "RLW Period", "", 14)

    strategy.parameters:addGroup("Bollinger Band  Bandwidth Calculation")
    strategy.parameters:addDouble("BB_N", "Number of periods", "Number of periods", 20.0)
    strategy.parameters:addDouble("BB_Dev", "Number of standard deviations", "Number of standard deviations", 2.0)

    strategy.parameters:addGroup("STOCH RSI Calculation")
    strategy.parameters:addInteger("N1", "Number of periods for RSI", "", 14, 1, 200)
    strategy.parameters:addInteger("K1", "%K Stochastic Periods", "", 14, 1, 200)
    strategy.parameters:addInteger("KS1", "%K Slowing Periods", "", 5, 1, 200)
    strategy.parameters:addInteger("D1", "%D Slowing Stochastic Periods", "", 3, 1, 200)

    strategy.parameters:addGroup("Aroon Calculation")
    strategy.parameters:addInteger("APeriod", "Aroon Period", "", 14, 1, 200)

    strategy.parameters:addGroup("Stochastic Calculation")
    strategy.parameters:addInteger(
        "Stochastic_K",
        "Number of periods for %K",
        "The number of periods for %K.",
        5,
        2,
        1000
    )
    strategy.parameters:addInteger(
        "Stochastic_SD",
        "%D slowing periods",
        "The number of periods for slow %D.",
        3,
        2,
        1000
    )
    strategy.parameters:addInteger(
        "Stochastic_D",
        "Number of periods for %D",
        "The number of periods for %D.",
        3,
        2,
        1000
    )

    strategy.parameters:addString(
        "Stochastic_MVAT_K",
        "Smoothing type for %K",
        "The type of smoothing algorithm for %K.",
        "MVA"
    )
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "KAMA", "", "KAMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "VIDYA", "", "VIDYA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_K", "WMA", "", "WMA")

    strategy.parameters:addString(
        "Stochastic_MVAT_D",
        "Smoothing type for %D",
        "The type of smoothing algorithm for %D.",
        "MVA"
    )
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "KAMA", "", "KAMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "VIDYA", "", "VIDYA")
    strategy.parameters:addStringAlternative("Stochastic_MVAT_D", "WMA", "", "WMA")

    strategy.parameters:addGroup("Stochastic Fast Calculation")
    strategy.parameters:addInteger("Fast_K", "K Period", "", 14, 2, 1000)
    strategy.parameters:addInteger("Fast_D", "D Period", "", 3, 2, 1000)

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
        "MIS"
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
    --  strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    --  strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    -- strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", false);

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
--local Limit;
local SetStop
--local Stop;
local TrailingStop
local ShowAlert
local Email
local SendEmail
local BaseSize
local ExecutionType
local CloseOnOpposite
local first
local RLW_Period, RLW
local BB, BB_N, BB_Dev
local N1, K1, KS1, D1, STOCHRSI1
local AROON, APeriod
local Short = {}
local Direction
local CustomID
local Stochastic_K, Stochastic_SD, Stochastic_D, Stochastic_MVAT_K, Stochastic_MVAT_D, Stochastic
local Fast_K, Fast_D, Stochastic_Fast

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime

--
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"

    RLW_Period = instance.parameters.RLW_Period

    BB_N = instance.parameters.BB_N
    BB_Dev = instance.parameters.BB_Dev

    N1 = instance.parameters.N1
    K1 = instance.parameters.K1
    KS1 = instance.parameters.KS1
    D1 = instance.parameters.D1

    APeriod = instance.parameters.APeriod
    Stochastic_K = instance.parameters.Stochastic_K
    Stochastic_SD = instance.parameters.Stochastic_SD
    Stochastic_D = instance.parameters.Stochastic_D
    Stochastic_MVAT_K = instance.parameters.Stochastic_MVAT_K
    Stochastic_MVAT_D = instance.parameters.Stochastic_MVAT_D

    Fast_D = instance.parameters.Fast_D
    Fast_K = instance.parameters.Fast_K

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    assert(
        core.indicators:findIndicator("BB-BANDWIDTH") ~= nil,
        "Please, download and install BB-BANDWIDTH.lua indicator"
    )
    assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "Please, download and install STOCHRSI.lua indicator")
    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    RLW = core.indicators:create("RLW", Source, RLW_Period)
    BB = core.indicators:create("BB-BANDWIDTH", Source.close, true, BB_N, BB_Dev)
    STOCHRSI1 = core.indicators:create("STOCHRSI", Source.close, N1, K1, KS1, D1)
    AROON = core.indicators:create("AROON", Source.close, APeriod)
    Stochastic =
        core.indicators:create(
        "STOCHASTIC",
        Source,
        Stochastic_K,
        Stochastic_SD,
        Stochastic_D,
        Stochastic_MVAT_K,
        Stochastic_MVAT_D
    )
    Stochastic_Fast = core.indicators:create("SFK", Source, Fast_K, Fast_D)
    first =
        math.max(
        RLW.DATA:first(),
        BB.DATA:first(),
        STOCHRSI1.D:first(),
        AROON.DATA:first(),
        Stochastic.D:first(),
        Stochastic_Fast.D:first()
    )

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
    --Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop
    -- Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop
end

local Last
local LAST
local ONE

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
    RLW:update(core.UpdateLast)
    BB:update(core.UpdateLast)
    STOCHRSI1:update(core.UpdateLast)
    AROON:update(core.UpdateLast)
    Stochastic:update(core.UpdateLast)
    Stochastic_Fast:update(core.UpdateLast)

    if period < first then
        return
    end

    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if
        RLW.DATA[period] > -5 and STOCHRSI1.K[period] == 100 and STOCHRSI1.D[period] >= 95 and AROON.UP[period] == 100 and
            AROON.DOWN[period] <= 50 and
            (BB.DATA[period] / Source:pipSize()) >= 50 and
            Stochastic.DATA[period] >= 65 and
            Stochastic_Fast.K[period] >= 90 and
            Stochastic_Fast.D[period] >= 90
     then
        if Direction then
            SELL(period)
        else
            BUY(period)
        end
        ONE = Source:serial(period)
    elseif
        RLW.DATA[period] < -95 and STOCHRSI1.K[period] == 0 and STOCHRSI1.D[period] <= 10 and AROON.UP[period] <= 50 and
            AROON.DOWN[period] == 100 and
            (BB.DATA[period] / Source:pipSize()) >= 50 and
            Stochastic.DATA[period] <= 35 and
            Stochastic_Fast.K[period] <= 10 and
            Stochastic_Fast.D[period] <= 10
     then
        if Direction then
            BUY(period)
        else
            SELL(period)
        end

        ONE = Source:serial(period)
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
function BUY(period)
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

        enter("B", period)
    else
        Signal("Buy Signal")
    end
end

function SELL(period)
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

        enter("S", period)
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
function enter(BuySell, period)
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

    return MarketOrder(BuySell, period)
end

-- enter into the specified direction
function MarketOrder(BuySell, period)
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

    local Limit = (BB.DATA[period] / Source:pipSize()) * 1.25
    local Stop = (BB.DATA[period] / Source:pipSize()) * 0.75

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
