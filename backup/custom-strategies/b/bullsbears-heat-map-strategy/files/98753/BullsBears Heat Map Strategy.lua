-- Id: 13637
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=61844

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
    strategy:name("Bulls&Bears Heat Map Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addGroup("Calculation")
    strategy.parameters:addInteger("Period", "Period ", "", 14)
    Parameters(1, "m15")
    Parameters(2, "m30")
    Parameters(3, "H1")
    Parameters(4, "H4")
    Parameters(5, "H8")

    strategy.parameters:addGroup("Exit Parameters")
    strategy.parameters:addBoolean("EXIT", "Use additional Exit Options", "", true)

    strategy.parameters:addInteger("Mode", "Type of Exit", "", 1)
    strategy.parameters:addIntegerAlternative("Mode", "Cumulative (All Selected)", "", 1)
    strategy.parameters:addIntegerAlternative("Mode", "Single Time Frame (Any Selected)", "", 2)

    local i
    for i = 1, 5, 1 do
        strategy.parameters:addBoolean("ON" .. i, i .. ". Use This Time Framel in  Exit Calculation", "", true)
    end

    strategy.parameters:addInteger("BL", "Long Exit Limit", "", 1)
    strategy.parameters:addInteger("SL", "Short Exit Limit", "", 1)

    CreateTradingParameters()
end

function Parameters(id, TF, MVA, PERIOD)
    strategy.parameters:addGroup(id .. ". Time Frame")

    if id > 1 then
        strategy.parameters:addBoolean("USE" .. id, "Use This Time Frame", "", true)
    end

    strategy.parameters:addString("TF" .. id, "Time Frame", "", TF)
    strategy.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addBoolean("CloseOnOpposite", "Bulls On Opposite", "", true)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "BBHMS"
    )

    strategy.parameters:addInteger(
        "MaxNumberOfPositionInAnyDirection",
        "Max Number Of Bears Position In Any Direction",
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
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", false)

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
local Mode
local Source
local Exit
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
local Bulls = {}
local Bears = {}
local Source = {}
local CustomID
local Direction

local BL, SL

local Period
local TF = {}
local Bears = {}
local Bulls = {}
local USE = {}
local ON = {}

local CloseOnOpposite
local MaxNumberOfPositionInAnyDirection
local MaxNumberOfPosition

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime

function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"

    Exit = instance.parameters.Exit
    Period = instance.parameters.Period
    Mode = instance.parameters.Mode
    local name
    name = profile:id() .. "( " .. instance.bid:name()

    BL = instance.parameters.BL
    SL = instance.parameters.SL

    -- NG: check TF1/TF2 instead of TF
    local i
    for i = 1, 5, 1 do
        TF[i] = instance.parameters:getString("TF" .. i)
        ON[i] = instance.parameters:getBoolean("ON" .. i)
        if i > 1 then
            USE[i] = instance.parameters:getBoolean("USE" .. i)
        end

        assert(TF[i] ~= "t1", i .. ". The time frame must not be tick")

        name = name .. "(" .. TF[i] .. ") "
    end

    name = name .. " )"
    instance:name(name)

    assert(core.indicators:findIndicator("BULLS") ~= nil, "Please, download and install BULLS.LUA indicator")
    assert(core.indicators:findIndicator("BEARS") ~= nil, "Please, download and install BEARS.LUA indicator")

    PrepareTrading()

    if nameOnly then
        return
    end

    for i = 1, 5, 1 do
        Source[i] = ExtSubscribe(i, nil, TF[i], instance.parameters.Type == "Bid", "bar")
        Bulls[i] = core.indicators:create("BULLS", Source[i], Period)
        Bears[i] = core.indicators:create("BEARS", Source[i], Period)
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
local Last
local LAST
local ONE

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

    local i
    for i = 1, 5, 1 do
        Bulls[i]:update(core.UpdateLast)
        Bears[i]:update(core.UpdateLast)
    end

    -- NG: condition to check the presense of the data is changed to proper
    --     crossover functions
    if
        Bulls[1].DATA:size() <= Bulls[1].DATA:first() + 2 or Bulls[2].DATA:size() <= Bulls[2].DATA:first() + 2 or
            Bulls[3].DATA:size() <= Bulls[3].DATA:first() + 2 or
            Bulls[4].DATA:size() <= Bulls[4].DATA:first() + 2 or
            Bulls[5].DATA:size() <= Bulls[5].DATA:first() + 2
     then
        return
    end

    if
        math.abs(Bears[1].DATA[Bears[1].DATA:size() - 2]) < math.abs(Bulls[1].DATA[Bulls[1].DATA:size() - 2]) and
            (math.abs(Bears[2].DATA[Bears[2].DATA:size() - 2]) < math.abs(Bulls[2].DATA[Bulls[2].DATA:size() - 2]) or
                not USE[2]) and
            (math.abs(Bears[3].DATA[Bears[3].DATA:size() - 2]) < math.abs(Bulls[3].DATA[Bulls[3].DATA:size() - 2]) or
                not USE[3]) and
            (math.abs(Bears[4].DATA[Bears[4].DATA:size() - 2]) < math.abs(Bulls[4].DATA[Bulls[4].DATA:size() - 2]) or
                not USE[4]) and
            (math.abs(Bears[5].DATA[Bears[5].DATA:size() - 2]) < math.abs(Bulls[5].DATA[Bulls[5].DATA:size() - 2]) or
                not USE[5])
     then
        if Direction then
            BUY()
        else
            SELL()
        end
    elseif
        math.abs(Bears[1].DATA[Bears[1].DATA:size() - 2]) > math.abs(Bulls[1].DATA[Bulls[1].DATA:size() - 2]) and
            (math.abs(Bears[2].DATA[Bears[2].DATA:size() - 2]) > math.abs(Bulls[2].DATA[Bulls[2].DATA:size() - 2]) or
                not USE[2]) and
            (math.abs(Bears[3].DATA[Bears[3].DATA:size() - 2]) > math.abs(Bulls[3].DATA[Bulls[3].DATA:size() - 2]) or
                not USE[3]) and
            (math.abs(Bears[4].DATA[Bears[4].DATA:size() - 2]) > math.abs(Bulls[4].DATA[Bulls[4].DATA:size() - 2]) or
                not USE[4]) and
            (math.abs(Bears[5].DATA[Bears[5].DATA:size() - 2]) > math.abs(Bulls[5].DATA[Bulls[5].DATA:size() - 2]) or
                not USE[5])
     then
        if Direction then
            SELL()
        else
            BUY()
        end
    end

    if EXIT then
        local S = 0
        local B = 0
        if Mode == 1 then
            if
                ((math.abs(Bears[1].DATA[Bears[1].DATA:size() - 2]) > math.abs(Bulls[1].DATA[Bulls[1].DATA:size() - 2])) and
                    ON[1])
             then
                B = B + 1
            end
            if
                ((math.abs(Bears[2].DATA[Bears[2].DATA:size() - 2]) > math.abs(Bulls[2].DATA[Bulls[2].DATA:size() - 2])) and
                    ON[2])
             then
                B = B + 1
            end
            if
                ((math.abs(Bears[3].DATA[Bears[3].DATA:size() - 2]) > math.abs(Bulls[3].DATA[Bulls[3].DATA:size() - 2])) and
                    ON[3])
             then
                B = B + 1
            end
            if
                ((math.abs(Bears[4].DATA[Bears[4].DATA:size() - 2]) > math.abs(Bulls[4].DATA[Bulls[4].DATA:size() - 2])) and
                    ON[4])
             then
                B = B + 1
            end
            if
                ((math.abs(Bears[5].DATA[Bears[5].DATA:size() - 2]) > math.abs(Bulls[5].DATA[Bulls[5].DATA:size() - 2])) and
                    ON[5])
             then
                B = B + 1
            end

            if
                ((math.abs(Bears[1].DATA[Bears[1].DATA:size() - 2]) < math.abs(Bulls[1].DATA[Bulls[1].DATA:size() - 2])) and
                    ON[1])
             then
                S = S + 1
            end
            if
                ((math.abs(Bears[2].DATA[Bears[2].DATA:size() - 2]) < math.abs(Bulls[2].DATA[Bulls[2].DATA:size() - 2])) and
                    ON[2])
             then
                S = S + 1
            end
            if
                ((math.abs(Bears[3].DATA[Bears[3].DATA:size() - 2]) < math.abs(Bulls[3].DATA[Bulls[3].DATA:size() - 2])) and
                    ON[3])
             then
                S = S + 1
            end
            if
                ((math.abs(Bears[4].DATA[Bears[4].DATA:size() - 2]) < math.abs(Bulls[4].DATA[Bulls[4].DATA:size() - 2])) and
                    ON[4])
             then
                S = S + 1
            end
            if
                ((math.abs(Bears[5].DATA[Bears[5].DATA:size() - 2]) < math.abs(Bulls[5].DATA[Bulls[5].DATA:size() - 2])) and
                    ON[5])
             then
                S = S + 1
            end

            if B >= BL then
                if Direction then
                    if haveTrades("B") then
                        exitSpecific("B")
                        Signal("Bulls Long")
                    end
                else
                    if haveTrades("S") then
                        exitSpecific("S")
                        Signal("Bulls Short")
                    end
                end
            end

            if S >= SL then
                if Direction then
                    if haveTrades("S") then
                        exitSpecific("S")
                        Signal("Bulls Short")
                    end
                else
                    if haveTrades("B") then
                        exitSpecific("B")
                        Signal("Bulls Long")
                    end
                end
            end
        else
            if
                ((math.abs(Bears[1].DATA[Bears[1].DATA:size() - 2]) > math.abs(Bulls[1].DATA[Bulls[1].DATA:size() - 2])) and
                    ON[1]) or
                    ((math.abs(Bears[2].DATA[Bears[2].DATA:size() - 2]) >
                        math.abs(Bulls[2].DATA[Bulls[2].DATA:size() - 2])) and
                        ON[2]) or
                    ((math.abs(Bears[3].DATA[Bears[3].DATA:size() - 2]) >
                        math.abs(Bulls[3].DATA[Bulls[3].DATA:size() - 2])) and
                        ON[3]) or
                    ((math.abs(Bears[4].DATA[Bears[4].DATA:size() - 2]) >
                        math.abs(Bulls[4].DATA[Bulls[4].DATA:size() - 2])) and
                        ON[4]) or
                    ((math.abs(Bears[5].DATA[Bears[5].DATA:size() - 2]) >
                        math.abs(Bulls[5].DATA[Bulls[5].DATA:size() - 2])) and
                        ON[5])
             then
                if Direction then
                    if haveTrades("B") then
                        exitSpecific("B")
                        Signal("Bulls Long")
                    end
                else
                    if haveTrades("S") then
                        exitSpecific("S")
                        Signal("Bulls Short")
                    end
                end
            end

            if
                ((math.abs(Bears[1].DATA[Bears[1].DATA:size() - 2]) < math.abs(Bulls[1].DATA[Bulls[1].DATA:size() - 2])) and
                    ON[1]) or
                    ((math.abs(Bears[2].DATA[Bears[2].DATA:size() - 2]) <
                        math.abs(Bulls[2].DATA[Bulls[2].DATA:size() - 2])) and
                        ON[2]) or
                    ((math.abs(Bears[3].DATA[Bears[3].DATA:size() - 2]) <
                        math.abs(Bulls[3].DATA[Bulls[3].DATA:size() - 2])) and
                        ON[3]) or
                    ((math.abs(Bears[4].DATA[Bears[4].DATA:size() - 2]) <
                        math.abs(Bulls[4].DATA[Bulls[4].DATA:size() - 2])) and
                        ON[4]) or
                    ((math.abs(Bears[5].DATA[Bears[5].DATA:size() - 2]) <
                        math.abs(Bulls[5].DATA[Bulls[5].DATA:size() - 2])) and
                        ON[5])
             then
                if Direction then
                    if haveTrades("S") then
                        exitSpecific("S")
                        Signal("Bulls Short")
                    end
                else
                    if haveTrades("B") then
                        exitSpecific("B")
                        Signal("Bulls Long")
                    end
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
            -- Bulls on opposite signal
            exitSpecific("S")
            Signal("Bulls Short")
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
            -- Bulls on opposite signal
            exitSpecific("B")
            Signal("Bulls Long")
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
            "Bears order failed" .. msg,
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
        -- Non-FIFO can Bulls each trade independantly.
        valuemap.TradeID = tradeRow.TradeID
        valuemap.Quantity = tradeRow.Lot
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y" -- this forces all trades to Bulls in the opposite direction.
    end
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID
    success, msg = terminal:execute(201, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Bulls order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return true
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
