-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=75406

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

function AddAverages(id, name, default)
    strategy.parameters:addString(id, name, "", default)
    strategy.parameters:addStringAlternative(id, "MVA", "", "MVA")
    strategy.parameters:addStringAlternative(id, "EMA", "", "EMA")
    strategy.parameters:addStringAlternative(id, "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative(id, "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative(id, "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative(id, "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative(id, "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative(id, "HMA", "", "HMA")
    strategy.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative(id, "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative(id, "T3", "", "T3")
    strategy.parameters:addStringAlternative(id, "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative(id, "Median", "", "Median")
    strategy.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative(id, "REMA", "", "REMA")
    strategy.parameters:addStringAlternative(id, "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative(id, "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth")
    strategy.parameters:addStringAlternative(id, "KAMA", "", "KAMA")
    strategy.parameters:addStringAlternative(id, "ARSI", "", "ARSI")
    strategy.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA")
    strategy.parameters:addStringAlternative(id, "HPF", "", "HPF")
    strategy.parameters:addStringAlternative(id, "VAMA", "", "VAMA")
    strategy.parameters:addStringAlternative(id, "Regression", "", "REGRESSION")
end
function CreateAverages(period, method, source)
    if
        method == "MVA" or method == "EMA" or method == "ARSI" or method == "KAMA" or method == "LWMA" or
            method == "SMMA" or
            method == "VIDYA" or
            method == "REGRESSION"
     then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period)
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator")
    return core.indicators:create("AVERAGES", source, method, period)
end

function Init() --The strategy profile initialization
    strategy:name("Price MA Cross with Volume Confirmation")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Strategy Parameters")

    AddAverages("Method", "MA Method", "MVA")
    strategy.parameters:addInteger("Period", "MA Period", "", 14, 2, 1000)

    AddAverages("Method2", "Second MA Method", "MVA")
    strategy.parameters:addInteger("Period2", "Second MA Period", "", 21, 2, 1000)

    strategy.parameters:addInteger("nlma_Length", "Non-Lag MA Length", "Length", 9)
    strategy.parameters:addInteger("nlma_Filter", "Non-Lag MA Filter", "Filter", 0)
    strategy.parameters:addInteger("nlma_ColorBarBack", "Non-Lag MA ColorBarBack", "ColorBarBack", 2)
    strategy.parameters:addDouble("nlma_Deviation", "Non-Lag MA Deviation", "Deviation", 0)

    strategy.parameters:addInteger("Threshold", "Volume Threshold ", "", 0)

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
        "123"
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
local ma
local Method, Period, Threshold

local CustomID

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime
local ma2, nlma;
--
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition

    Method = instance.parameters.Method
    Period = instance.parameters.Period
    Threshold = instance.parameters.Threshold

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name =
        profile:id() ..
        "( " .. instance.bid:name() .. "," .. Method .. "," .. Period .. "," .. Threshold .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()
    local profile = core.indicators:findIndicator("NONLAGMA");
    assert(profile ~= nil, "Please, download and install " .. "NONLAGMA" .. ".LUA indicator");

    if nameOnly then
        return
    end

    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed")
    ma = core.indicators:create(Method, Source.close, Period)
    ma2 = core.indicators:create(instance.parameters.Method2, Source.close, instance.parameters.Period2)
    
    nlma = core.indicators:create("NONLAGMA", Source, instance.parameters.nlma_Length,
        instance.parameters.nlma_Filter, instance.parameters.nlma_ColorBarBack, instance.parameters.nlma_Deviation, false);

    first = ma.DATA:first() + 1

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

local Last
local LAST
local ONE

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
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

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)

    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    -- update indicators.
    ma:update(core.UpdateLast)
    ma2:update(core.UpdateLast)
    nlma:update(core.UpdateLast)

    if period < first then
        return
    end
    if nlma.buffUp:hasData(period) and not nlma.buffDn:hasData(period)
        and ma.DATA[period] > nlma.buffUp[period]
        and Source.volume[period] >= Threshold 
        and Source.close[period] > ma2.DATA[period]
    then
        BUY()
        ONE = Source:serial(period)
    elseif not nlma.buffUp:hasData(period) and nlma.buffDn:hasData(period)
        and ma.DATA[period] < nlma.buffDn[period]
        and Source.volume[period] >= Threshold 
        and Source.close[period] < ma2.DATA[period]
    then
        SELL()
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
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+