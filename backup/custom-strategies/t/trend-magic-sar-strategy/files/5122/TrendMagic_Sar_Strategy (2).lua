-- Id: 6007
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2375

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
    strategy:name("Trend Magic + SAR Strategy")
    strategy:description("The strategy trades using Trend Magic and SAR indicators")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Trend Magic Parameters")
    strategy.parameters:addInteger("CCI", "CCI", "", 50)
    strategy.parameters:addInteger("ATR", "ATR", "", 5)

    strategy.parameters:addGroup("SAR Parameters")
    strategy.parameters:addDouble("Step", "Step", "", 0.02, 0.001, 1)
    strategy.parameters:addDouble("Max", "Max Step", "", 0.2, 0.001, 10)

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

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

    strategy.parameters:addGroup("Auto Lot")
    strategy.parameters:addBoolean("AutoLot", "Increase trade size after loss position", "", false)
    strategy.parameters:addInteger("IncStep", "Step to increase in lots", "", 1, 1, 100)
    strategy.parameters:addInteger("IncMax", "Maximum trade size in lots", "", 5, 1, 100)

    strategy.parameters:addGroup("Signal Parameters")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false)

    strategy.parameters:addGroup("Email Parameters")
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
    strategy.parameters:addString("Email", "Email address", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local ALLOWEDSIDE
local AllowMultiple

local ShowAlert
local SoundFile
local Email
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local BaseSize
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local RecurrentSound
local AutoLot
local IncStep
local IncMax
local tsource = nil
local TM = nil
local SAR = nil
local lastOpenRequest = nil -- the latest open request
local AutoLotCurr = 0
local lastExitPL = 0 -- profit loss on last exit call

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime

function Prepare(onlyName)
    AllowMultiple = instance.parameters.AllowMultiple
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE

    RecurrentSound = instance.parameters.Recurrent
    local SendEmail = instance.parameters.SendEmail
    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified")

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")
    assert(
        not (instance.parameters.PlaySound) or (instance.parameters.PlaySound and instance.parameters.SoundFile ~= ""),
        "Sound file must be chosen"
    )
    assert(core.indicators:findIndicator("TRENDMAGIC1") ~= nil, "Please download and install Trend Magic 1 indicator!")

    local name
    name =
        profile:id() ..
        "(" ..
            instance.bid:name() ..
                "." ..
                    instance.parameters.TF ..
                        "," ..
                            "TRENDMAGIC(" ..
                                instance.parameters.ATR ..
                                    "," ..
                                        instance.parameters.CCI ..
                                            ")," ..
                                                "SAR(" ..
                                                    instance.parameters.Step .. "," .. instance.parameters.Max .. "))"
    instance:name(name)

    ShowAlert = instance.parameters.ShowAlert
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end

    AllowTrade = instance.parameters.AllowTrade
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit * instance.bid:pipSize()
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop * instance.bid:pipSize()
        TrailingStop = instance.parameters.TrailingStop

        AutoLot = instance.parameters.AutoLot
        IncStep = instance.parameters.IncStep
        IncMax = instance.parameters.IncMax - Amount
    end

    if onlyName then
        return
    end

    tsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    TM = core.indicators:create("TRENDMAGIC1", tsource, instance.parameters.CCI, instance.parameters.ATR, true)
    SAR = core.indicators:create("SAR", tsource, instance.parameters.Step, instance.parameters.Max, true)

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

function checkReady(table)
    return core.host:execute("isTableFilled", table)
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
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function ExtUpdate(id, source, period)
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

    if id == 2 then
        TM:update(core.UpdateLast)
        SAR:update(core.UpdateLast)
        -- check whether the signal appears
        if SAR.UP:hasData(period - 1) and SAR.DN:hasData(period) and TM.SIG[period] == 1 then
            BUY()
        elseif SAR.DN:hasData(period - 1) and SAR.UP:hasData(period) and TM.SIG[period] == -1 then
            SELL()
        end
    end
end

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
        return
    end

    local profitable = true
    local enum, row, valuemap, success, msg

    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while count == 0 and row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and row.BS == BuySell then
            count = count + 1
        end
        row = enum:next()
    end

    -- do not enter if position in the
    -- specified direction already exists
    if count > 0 then
        return
    end

    -- check whether the previous trade was profitable (in case it closed
    -- earilier by stop or limit order
    -- the just closed trades are checked by exit procedure (see lastExitPL)
    if lastOpenRequest ~= nil then
        enum = core.host:findTable("closed trades"):enumerator()
        row = enum:next()
        profit = 0
        while row ~= nil do
            if row.OpenOrderReqID == lastOpenRequest then
                profit = profit + row.PL
            end
            row = enum:next()
        end
        profit = profit + lastExitPL
        if profit < 0 then
            profitable = false
        end
    end

    if AutoLot then
        if profitable then
            AutoLotCurr = 0
        else
            AutoLotCurr = AutoLotCurr + IncStep
            if AutoLotCurr > IncMax then
                AutoLotCurr = IncMax
            end
        end
    else
        AutoLotCurr = 0
    end
    lastExitPL = 0

    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = (Amount + AutoLotCurr) * BaseSize
    valuemap.BuySell = BuySell
    valuemap.PegTypeStop = "M"

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit
        end
    end

    if SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop
        else
            valuemap.RateStop = instance.bid[NOW] + Stop
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
        lastOpenRequest = nil
    else
        lastOpenRequest = msg -- keep latest open request id
    end
end

-- exit from the specified direction
function exit(BuySell)
    if not (AllowTrade) then
        return
    end

    local enum, row, valuemap, success, msg

    lastExitPL = 0
    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while count == 0 and row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and row.BS == BuySell then
            count = count + 1
            lastExitPL = lastExitPL + row.PL
        end
        row = enum:next()
    end

    if count > 0 then
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
        valuemap.TradeID = "all"
        valuemap.NetQtyFlag = "Y"
        valuemap.BuySell = BuySell
        success, msg = terminal:execute(101, valuemap)

        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                "Open order failed" .. msg,
                instance.bid:date(instance.bid:size() - 1)
            )
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
