-- Id: 19280
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

    strategy.parameters:addString("TF", "Time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("Live", "End of Turn / Live", "", "Live")
    strategy.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
    strategy.parameters:addStringAlternative("Live", "Live", "", "Live")

    strategy.parameters:addString("Price", "Price Source", "", "close")
    strategy.parameters:addStringAlternative("Price", "OPEN", "", "open")
    strategy.parameters:addStringAlternative("Price", "HIGH", "", "high")
    strategy.parameters:addStringAlternative("Price", "LOW", "", "low")
    strategy.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    strategy.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    strategy.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    strategy.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    strategy.parameters:addGroup("Calculation")
    strategy.parameters:addInteger("Period", "Period", "", 14)
    strategy.parameters:addDouble("Level1", "1st Level", "", 70)
    strategy.parameters:addDouble("Level2", "2nd Level", "", 30)
    strategy.parameters:addDouble("Level3", "3rd Level", "", 65)
    strategy.parameters:addDouble("Level4", "4th Level", "", 35)
    strategy.parameters:addDouble("Level5", "5th Level", "", 55)
    strategy.parameters:addDouble("Level6", "6th Level", "", 45)
    strategy.parameters:addDouble("Level7", "7th Level", "", 50)

    -- keep track of this as it is useful.
    strategy.parameters:addGroup("Selector")
    local i
    local LEVELS = 7
    for i = 1, LEVELS, 1 do
        AddLevel(i)
    end

    strategy.parameters:addGroup("MA Parameters")
    strategy.parameters:addBoolean(
        "MVAFilter",
        "Use MA Filter",
        "If enabled then only Long positions will be opened when Price > MA, opposite for Short positions.",
        false
    )
    strategy.parameters:addInteger("MVAPeriod", "Number of periods", "Number of periods", 200, 2, 1000)
    strategy.parameters:addString("MVAMethod", "Average Method", "", "MVA")
    strategy.parameters:addStringAlternative("MVAMethod", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("MVAMethod", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("MVAMethod", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("MVAMethod", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("MVAMethod", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("MVAMethod", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("MVAMethod", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("MVAMethod", "WMA", "WMA", "WMA")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addBoolean(
        "EntryOrders",
        "Entry Orders Only",
        "True for Entry Orders, False for Market Orders",
        false
    )
    strategy.parameters:addInteger(
        "EntryOrdersPips",
        "Entry Orders Gap",
        "The number of pips away to place entry orders",
        20,
        1,
        1000
    )
    strategy.parameters:addInteger(
        "EntryOrdersTrail",
        "Entry Orders Trailing",
        "The number of pips to trail entry orders entry price. Zero to not trail.",
        0,
        0,
        1000
    )
    strategy.parameters:addBoolean(
        "EntryOrdersGTC",
        "Good Till Cancelled",
        "If true, entry orders remain valid until cancelled. If false, they are only valid until the end of the day.",
        true
    )
    strategy.parameters:addString("Direction", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse")
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "123"
    )
    strategy.parameters:addBoolean(
        "CloseOnOpposite",
        "Close On Opposite",
        "Closes existing positions in one direction when an opposite direction entry signal is generated.",
        true
    )

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

function AddLevel(Level)
    local Number = Level * 2 - 1
    strategy.parameters:addString("Action" .. Number, "Level " .. Level .. " Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. Number, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. Number, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. Number, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. Number, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. Number, "Alert", "", "Alert")

    Number = Number + 1
    strategy.parameters:addString("Action" .. Number, "Level " .. Level .. " Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. Number, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. Number, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. Number, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. Number, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. Number, "Alert", "", "Alert")
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

    strategy.parameters:addBoolean(
        "AllowMultiple",
        "Allow Multiple",
        "Should we allow multiple positions in the same direction.",
        true
    )
    strategy.parameters:addInteger(
        "MultipleLimit",
        "Open Position Limit",
        "The number of open positions in the same direction allowed for each instance of this strategy. Zero for unlimited.",
        0,
        0,
        1000
    )
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
local MultipleLimit
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

local Action = {}
local Levels = {}

local Indicators = {}
local Direction
local first

local Price, Period
local MAX_LEVEL = 7
local MAX_LEVEL_2 = 14
local CustomID
local UseMandatoryClosing
local ValidInterval
local first
local EntryOrders
local EntryOrdersPips
local EntryOrdersGTC
local EntryOrdersTrail
local CloseOnOpposite
local MVAFilter
local MVAPeriod
local MVAMethod

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime

--
function Prepare(nameOnly)
    Direction = instance.parameters.Direction

    Price = instance.parameters.Price
    Period = instance.parameters.Period
    CustomID = instance.parameters.CustomID
    EntryOrders = instance.parameters.EntryOrders
    EntryOrdersPips = instance.parameters.EntryOrdersPips
    EntryOrdersGTC = instance.parameters.EntryOrdersGTC
    EntryOrdersTrail = instance.parameters.EntryOrdersTrail
    CloseOnOpposite = instance.parameters.CloseOnOpposite

    MVAFilter = instance.parameters.MVAFilter
    MVAPeriod = instance.parameters.MVAPeriod
    MVAMethod = instance.parameters.MVAMethod

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name =
        profile:id() ..
        "( " .. instance.bid:name() .. "," .. Period .. "," .. CustomID .. "," .. tostring(MVAFilter) .. ")"

    local i = 1
    while (i <= MAX_LEVEL) do
        Levels[i] = instance.parameters:getDouble("Level" .. i)
        Action[i] = instance.parameters:getString("Action" .. i)
        i = i + 1
    end

    while (i <= MAX_LEVEL_2) do
        Action[i] = instance.parameters:getString("Action" .. i)
        i = i + 1
    end

    name = name .. " )"
    instance:name(name)

    if nameOnly then
        return
    end

    PrepareTrading()

    if (EntryOrders) then
        -- check trading properties
        local property
        property = "canUseDynamicTrailingForEntryLimit"
        if core.host:execute("getTradingProperty", property, nil, nil) then
            core.host:trace("TradingProperty '" .. property .. "' is true.")
        else
            core.host:trace("TradingProperty '" .. property .. "' is false!!")
        end
        property = "canUseDynamicTrailingForEntryStop"
        if core.host:execute("getTradingProperty", property, nil, nil) then
            core.host:trace("TradingProperty '" .. property .. "' is true.")
        else
            core.host:trace("TradingProperty '" .. property .. "' is false!!")
        end
        property = "canUseFluctuateTrailingForEntryLimit"
        if core.host:execute("getTradingProperty", property, nil, nil) then
            core.host:trace("TradingProperty '" .. property .. "' is true.")
        else
            core.host:trace("TradingProperty '" .. property .. "' is false!!")
        end
        property = "canUseFluctuateTrailingForEntryStop"
        if core.host:execute("getTradingProperty", property, nil, nil) then
            core.host:trace("TradingProperty '" .. property .. "' is true.")
        else
            core.host:trace("TradingProperty '" .. property .. "' is false!!")
        end
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    Indicators[1] = core.indicators:create("RSI", Source[Price], Period)

    if (MVAFilter) then
        assert(core.indicators:findIndicator(MVAMethod) ~= nil, MVAMethod .. " indicator must be installed")
        Indicators[2] = core.indicators:create(MVAMethod, Source[Price], MVAPeriod)
        first = math.max(Indicators[1].DATA:first(), Indicators[2].DATA:first())
    else
        first = Indicators[1].DATA:first()
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
    MultipleLimit = instance.parameters.MultipleLimit
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

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if id ~= 1 or period < first + 1 then
        return
    end

    if instance.parameters.Live ~= "Live" then
        period = period - 1
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    Indicators[1]:update(core.UpdateLast)
    if (MVAFilter) then
        Indicators[2]:update(core.UpdateLast)
    end

    if not Indicators[1].DATA:hasData(period - 1) then
        return;
    end

    local currentLevel = 1
    local currentLevelValue
    while (currentLevel <= MAX_LEVEL) do
        currentLevelValue = Levels[currentLevel]
        if core.crossesOver(Indicators[1].DATA, currentLevelValue, period) then
            ACTION(currentLevel * 2 - 1, currentLevelValue, "Over", period)
        end

        if core.crossesUnder(Indicators[1].DATA, currentLevelValue, period) then
            ACTION(currentLevel * 2, currentLevelValue, "Under", period)
        end

        currentLevel = currentLevel + 1
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
    elseif cookie == 300 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Create entry order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

function ACTION(Flag, Line, Label, period)
    if Action[Flag] == "NO" then
        return
    elseif Action[Flag] == "BUY" then
        -- use the MVA Filter if required.
        if (not MVAFilter or (Source.close[period] > Indicators[2].DATA[period])) then
            BUY()
        end
    elseif Action[Flag] == "SELL" then
        -- use the MVA Filter if required.
        if (not MVAFilter or (Source.close[period] < Indicators[2].DATA[period])) then
            SELL()
        end
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
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    local count = tradesCount(BuySell)
    if (AllowMultiple) then
        -- if we allow multiple trades
        if (MultipleLimit > 0 and (count >= MultipleLimit)) then
            -- we have exceeded our multiple limit count.
            return true
        end
    else
        if count > 0 then
            -- if we have more than one trade and we aren't allowed multiple, abort.
            return true
        end
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal("Sell Signal")
    else
        Signal("Buy Signal")
    end

    -- support for entry orders.
    if (EntryOrders) then
        local distance = EntryOrdersPips
        if (BuySell == "S") then
            distance = -1 * distance
        end

        return EntryOrder(BuySell, distance)
    end

    return MarketOrder(BuySell)
end

-- creates and send an entry order
function EntryOrder(BuySell, Distance)
    -- create order
    local valuemap = core.valuemap()
    valuemap.Command = "CreateOrder"

    -- get the order type
    if BuySell == "B" and Distance < 0 then
        valuemap.OrderType = "LE"
    elseif BuySell == "B" and Distance > 0 then
        valuemap.OrderType = "SE"
    elseif BuySell == "S" and Distance < 0 then
        valuemap.OrderType = "SE"
    elseif BuySell == "S" and Distance > 0 then
        valuemap.OrderType = "LE"
    end

    if SetLimit then
        valuemap.PegTypeLimit = "O"
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end

    if SetStop then
        valuemap.PegTypeStop = "O"
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end

        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end

    if not (CanClose) and (SetStop or SetLimit) then
        -- if regular s/l orders aren't allowed - create ELS order
        valuemap.EntryLimitStop = "Y"
    end

    if Distance >= 0 then
        valuemap.Rate = instance.ask[NOW] + Distance * instance.ask:pipSize()
    else
        valuemap.Rate = instance.bid[NOW] + Distance * instance.ask:pipSize()
    end

    if (EntryOrdersTrail > 0) then
        valuemap.TrailUpdatePips = EntryOrdersTrail
    end

    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID

    if (EntryOrdersGTC) then
        valuemap.GTC = "GTC"
    else
        valuemap.GTC = "DAY"
    end

    local success, msg = terminal:execute(300, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Failed to create order" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
    else
        requestId = core.parseCsv(msg, ",")[0]
    end
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
        valuemap.TradeID = tradeRow.TradeID
        valuemap.Quantity = tradeRow.Lot
    else
        valuemap.NetQtyFlag = "Y" -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID
    success, msg = terminal:execute(201, valuemap)

    if not (success) then
        core.host:trace("Close order failed" .. msg)
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
