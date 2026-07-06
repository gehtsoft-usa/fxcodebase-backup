-- Id: 8438
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=31552

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Highly adaptable RSI Strategy")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

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

    strategy.parameters:addString("TF", "Time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Calculation")
    strategy.parameters:addInteger("Period", "Period", "", 14)
    strategy.parameters:addDouble("Level1", "1. Level", "", 70)
    strategy.parameters:addDouble("Level2", "2. Level", "", 30)

    strategy.parameters:addDouble("Level3", "3. Level", "", 65)
    strategy.parameters:addDouble("Level4", "4. Level", "", 35)

    strategy.parameters:addDouble("Level5", "5. Level", "", 55)
    strategy.parameters:addDouble("Level6", "6. Level", "", 45)

    strategy.parameters:addGroup("Selector")

    strategy.parameters:addString("Action" .. 1, "1. Line  Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 1, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 1, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 1, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 1, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 1, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 2, "1. Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 2, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 2, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 2, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 2, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 2, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 3, "2. Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 3, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 3, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 3, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 3, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 3, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 4, "2. Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 4, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 4, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 4, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 4, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 4, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 5, "3. Line  Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 5, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 5, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 5, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 5, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 5, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 6, "3. Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 6, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 6, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 6, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 6, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 6, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 7, "4. Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 7, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 7, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 7, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 7, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 7, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 8, "4. Line Cross  Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 8, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 8, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 8, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 8, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 8, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 9, "5. Line  Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 9, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 9, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 9, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 9, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 9, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 10, "5. Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 10, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 10, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 10, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 10, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 10, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 11, "6. Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 11, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 11, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 11, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 11, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 11, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 12, "6. Line Cross  Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 12, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 12, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 12, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 12, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 12, "Alert", "", "Alert")

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
        "HARS"
    )

    strategy.parameters:addInteger(
        "MaxNumberOfPositionInAnyDirection",
        "Max Number Of Open Position In Any Direction",
        "",
        10,
        1,
        10000
    )
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 5, 1, 10000)

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
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 10000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", true)

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

local Source
local ExecutionType, TickSource
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
local CustomID
local CloseOnOpposite
local MaxNumberOfPositionInAnyDirection
local MaxNumberOfPosition
local Exit

local Action = {}

local Indicators = {}
local Direction
local first

local Price, Period, Level1, Level2, Level3, Level4, Level5, Level6

local first

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
    Exit = instance.parameters.Exit

    Price = instance.parameters.Price
    Period = instance.parameters.Period
    Level1 = instance.parameters.Level1
    Level2 = instance.parameters.Level2
    Level3 = instance.parameters.Level3
    Level4 = instance.parameters.Level4
    Level5 = instance.parameters.Level5
    Level6 = instance.parameters.Level6

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name()
    local i

    for i = 1, 12, 1 do
        Action[i] = instance.parameters:getString("Action" .. i)
    end

    name = name .. " )"
    instance:name(name)

    if nameOnly then
        return
    end

    PrepareTrading()

    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    Indicators[1] = core.indicators:create("RSI", Source[Price], Period)

    first = Indicators[1].DATA:first()
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
        return now >= openTime and now <= closeTime
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime
    end

    return now == openTime
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

    if period < 0 then
        return
    end

    if ExecutionType == "Live" then
        if id ~= 1 then
            return
        end

        period = core.findDate(Source.close, TickSource:date(period), false)

        if ONE == Source:serial(period) then
            return
        end
    else
        if id ~= 2 then
            return
        end
    end

    if period < 0 then
        return
    end

    Indicators[1]:update(core.UpdateLast)
    if not Indicators[1].DATA:hasData(period - 1) then
        return;
    end

    if core.crossesOver(Indicators[1].DATA, Level1, period) then
        ACTION(1, Level1, "Over", period)
    end
    if core.crossesUnder(Indicators[1].DATA, Level1, period) then
        ACTION(2, Level1, "Under", period)
    end
    if core.crossesOver(Indicators[1].DATA, Level2, period) then
        ACTION(3, Level2, "Over", period)
    end
    if core.crossesUnder(Indicators[1].DATA, Level2, period) then
        ACTION(4, Level2, "Under", period)
    end
    if core.crossesOver(Indicators[1].DATA, Level3, period) then
        ACTION(5, Level3, "Over", period)
    end
    if core.crossesUnder(Indicators[1].DATA, Level3, period) then
        ACTION(6, Level3, "Under", period)
    end
    if core.crossesOver(Indicators[1].DATA, Level4, period) then
        ACTION(7, Level4, "Over", period)
    end
    if core.crossesUnder(Indicators[1].DATA, Level4, period) then
        ACTION(8, Level4, "Under", period)
    end

    if core.crossesOver(Indicators[1].DATA, Level5, period) then
        ACTION(9, Level5, "Over", period)
    end
    if core.crossesUnder(Indicators[1].DATA, Level5, period) then
        ACTION(10, Level5, "Under", period)
    end

    if core.crossesOver(Indicators[1].DATA, Level6, period) then
        ACTION(11, Level6, "Over", period)
    end
    if core.crossesUnder(Indicators[1].DATA, Level6, period) then
        ACTION(12, Level6, "Under", period)
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

function ACTION(Flag, Line, Label, period)
    ONE = Source:serial(period)

    if Action[Flag] == "NO" then
        return
    elseif Action[Flag] == "BUY" then
        BUY()
    elseif Action[Flag] == "SELL" then
        SELL()
    elseif Action[Flag] == "CLOSE" then
        if AllowTrade then
            if haveTrades("B") then
                exitSpecific("B")
                Signal("Close Long")
            end

            if haveTrades("S") then
                exitSpecific("S")
                Signal("Close Short")
            end
        else
            Signal("Close All")
        end
    elseif Action[Flag] == "Alert" then
        Signal(Line .. " Line Cross" .. Label)
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
