-- Id: 12702
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2533

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Stochastic Strategy With Filters")
    strategy:description(
        "Signals BUY / SELL when the stochastic K% or D% Line crosses under/over the overbought/oversold level, stochastic K%, D% Lines crosses  Each other.."
    )
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addInteger("K", "%K Period", "", 5, 2, 1000)
    strategy.parameters:addInteger("D", "%D Period", "", 3, 1, 1000)
    strategy.parameters:addInteger("SD", "%D slowing periods", "", 3, 1, 1000)

    strategy.parameters:addString("A1", "Smoothing method for %K", "", "MVA")
    strategy.parameters:addStringAlternative("A1", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("A1", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("A1", "MetaTrader", "", "MT")

    strategy.parameters:addString("A2", "Smoothing method for %D", "", "MVA")
    strategy.parameters:addStringAlternative("A2", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("A2", "EMA", "", "EMA")

    strategy.parameters:addString("L", "Signal Type", "", "K")
    strategy.parameters:addStringAlternative("L", "%K Overbought/ Oversold", "", "K")
    strategy.parameters:addStringAlternative("L", "%D Overbought/ Oversold", "", "D")
    strategy.parameters:addStringAlternative("L", "%K / %D Cross", "", "C")
    strategy.parameters:addStringAlternative("L", "%K / %D Cross in Overbought/ Oversold", "", "B")

    strategy.parameters:addInteger("OS", "Oversold level", "", 20, 1, 100)
    strategy.parameters:addInteger("OB", "Overbought level", "", 80, 1, 100)

    strategy.parameters:addGroup("MA Filter Selector")
    strategy.parameters:addBoolean("MA", "USE MA Filter", "", false)

    strategy.parameters:addString("MAMethod", "MA Method", "Method", "EMA")
    strategy.parameters:addStringAlternative("MAMethod", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("MAMethod", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("MAMethod", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("MAMethod", "TMA", "TMA", "TMA")
    strategy.parameters:addStringAlternative("MAMethod", "SMMA", "SMMA", "SMMA")
    strategy.parameters:addStringAlternative("MAMethod", "KAMA", "KAMA", "KAMA")
    strategy.parameters:addStringAlternative("MAMethod", "VIDYA", "VIDYA", "VIDYA")
    strategy.parameters:addStringAlternative("MAMethod", "WMA", "WMA", "WMA")

    strategy.parameters:addInteger("MAPeriod", "MAPeriod", "MAPeriod", 50, 2, 2000)

    strategy.parameters:addGroup("HA Selector")
    strategy.parameters:addBoolean("use_ha", "Use HA", "", true);
    strategy.parameters:addString("ha_tf", "HA Timeframe", "", "m5");
    strategy.parameters:setFlag("ha_tf", core.FLAG_PERIODS);

    strategy.parameters:addGroup("ADX Filter Selector")
    strategy.parameters:addBoolean("ADX", "USE ADX Filter", "", false)
    strategy.parameters:addInteger("ADXPeriod", "ADX Period", "", 14, 2, 2000)
    strategy.parameters:addDouble("ADXLevel", "ADX Level", "", 25, 0, 100)

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
        "SSF"
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
local MA, ADX
local indicator = nil

local Line1, Line2
local OS, OB
local PARAMETARS
local ma, adx, MAPeriod, MAMethod
local ADXLevel, ADXPariod

local CustomID

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime, use_ha, ha, ha_Source
--
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    MAMethod = instance.parameters.MAMethod
    MAPeriod = instance.parameters.MAPeriod

    ADXLevel = instance.parameters.ADXLevel
    ADXPeriod = instance.parameters.ADXPeriod

    MA = instance.parameters.MA
    ADX = instance.parameters.ADX

    OS = instance.parameters.OS
    OB = instance.parameters.OB
    use_ha = instance.parameters.use_ha;

    local PARAMETARS =
        instance.parameters.K ..
        "," ..
            instance.parameters.D ..
                "," ..
                    instance.parameters.SD ..
                        "," .. instance.parameters.A1 .. "," .. instance.parameters.A2 .. "," .. OS .. "," .. OB

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. PARAMETARS .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    if use_ha then
        ha_Source = ExtSubscribe(3, nil, instance.parameters.ha_tf, instance.parameters.Type == "Bid", "bar")
        ha = core.indicators:create("HA", ha_Source);
    end
    local iprofile = core.indicators:findIndicator("STOCHASTIC")
    local iparams = iprofile:parameters()
    iparams:setInteger("K", instance.parameters:getInteger("K"))
    iparams:setInteger("SD", instance.parameters:getInteger("SD"))
    iparams:setInteger("D", instance.parameters:getInteger("D"))
    iparams:setString("MVAT_K", instance.parameters:getString("A1"))
    iparams:setString("MVAT_D", instance.parameters:getString("A2"))
    indicator = iprofile:createInstance(Source, iparams)

    Line1 = indicator:getStream(0) -- %K
    Line2 = indicator:getStream(1) -- %D

    assert(core.indicators:findIndicator(MAMethod) ~= nil, MAMethod .. " indicator must be installed");
    ma = core.indicators:create(MAMethod, Source.close, MAPeriod)
    adx = core.indicators:create("ADX", Source, ADXPeriod)

    first = math.max(Line2:first(), ma.DATA:first(), adx.DATA:first()) + 1

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
    indicator:update(core.UpdateLast)
    ma:update(core.UpdateLast)
    adx:update(core.UpdateLast)
    if use_ha then
        ha:update(core.UpdateLast);
    end

    if period < first or (ADX and adx.DATA[period] < ADXLevel) then
        return
    end

    if instance.parameters.L == "K" then
        if core.crossesOver(Line1, OS, period) and (not MA or (MA and Source.close[period] > ma.DATA[period])) and (not use_ha or ha.close[NOW] > ha.open[NOW]) then
            BUY()
            ONE = Source:serial(period)
        elseif core.crossesUnder(Line1, OB, period) and (not MA or (MA and Source.close[period] < ma.DATA[period])) and (not use_ha or ha.close[NOW] < ha.open[NOW]) then
            SELL()
            ONE = Source:serial(period)
        end
    end

    if instance.parameters.L == "D" then
        if core.crossesOver(Line2, OS, period) and (not MA or (MA and Source.close[period] > ma.DATA[period])) and (not use_ha or ha.close[NOW] > ha.open[NOW]) then
            BUY()
            ONE = Source:serial(period)
        elseif core.crossesUnder(Line2, OB, period) and (not MA or (MA and Source.close[period] < ma.DATA[period])) and (not use_ha or ha.close[NOW] < ha.open[NOW]) then
            SELL()
            ONE = Source:serial(period)
        end
    end

    if (instance.parameters.L == "C") then
        if core.crossesOver(Line1, Line2, period) and (not MA or (MA and Source.close[period] > ma.DATA[period])) and (not use_ha or ha.close[NOW] > ha.open[NOW]) then
            BUY()
            ONE = Source:serial(period)
        elseif core.crossesUnder(Line1, Line2, period) and (not MA or (MA and Source.close[period] < ma.DATA[period])) and (not use_ha or ha.close[NOW] < ha.open[NOW]) then
            SELL()
            ONE = Source:serial(period)
        end
    end

    if (instance.parameters.L == "B") then
        if
            core.crossesOver(Line1, Line2, period) and Line1[period - 1] < OS and Line2[period] < OS and
                (not MA or (MA and Source.close[period] > ma.DATA[period])) and (not use_ha or ha.close[NOW] > ha.open[NOW]) 
         then
            BUY()
            ONE = Source:serial(period)
        elseif
            core.crossesUnder(Line1, Line2, period) and Line1[period - 1] > OB and Line2[period] > OB and
                (not MA or (MA and Source.close[period] < ma.DATA[period])) and (not use_ha or ha.close[NOW] < ha.open[NOW]) 
         then
            SELL()
            ONE = Source:serial(period)
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
