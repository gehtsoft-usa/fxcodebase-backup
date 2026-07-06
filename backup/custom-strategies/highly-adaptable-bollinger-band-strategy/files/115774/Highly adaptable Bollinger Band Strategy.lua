-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=63644
--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Highly adaptable Bollinger Band Strategy")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Calculation")
    strategy.parameters:addInteger("Period", "Period", "", 20)
    strategy.parameters:addDouble("Deviation", "Deviation", "", 2)

    strategy.parameters:addGroup("Selector")

    strategy.parameters:addString("Action" .. 1, "Top Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 1, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 1, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 1, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 1, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 1, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 2, "Top Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 2, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 2, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 2, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 2, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 2, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 3, "Central Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 3, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 3, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 3, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 3, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 3, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 4, "Central Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 4, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 4, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 4, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 4, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 4, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 5, "Bottom Line  Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 5, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 5, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 5, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 5, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 5, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 6, "Bottom Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 6, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 6, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 6, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 6, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 6, "Alert", "", "Alert")

    strategy.parameters:addBoolean("confirm_with_trendstop", "Confirm Using Trendstop", "", false)
    strategy.parameters:addString("trendstop_tf", "Trendstop's Time Frame", "", "m1")
    strategy.parameters:setFlag("trendstop_tf", core.FLAG_PERIODS)
    strategy.parameters:addInteger("trendstop_period", "Trendstop's Period", "Period", 10)
    strategy.parameters:addString("trendstop_type", "Triger", "", "Close")
    strategy.parameters:addStringAlternative("trendstop_type", "Close", "", "Close")
    strategy.parameters:addStringAlternative("trendstop_type", "High/Low", "", "High")

    strategy.parameters:addGroup("Trailing Stop Parameters")
    strategy.parameters:addBoolean("use_multilevel_trailing", "Use multi-level trailing", "", false)
    strategy.parameters:addInteger("TPLevel1", "Trade Profit level1 (pips)", "", 20, 0.1, 1000)
    strategy.parameters:addInteger("TPLevel2", "Trade Profit level2 (pips)", "", 20, 0.1, 1000)
    strategy.parameters:addInteger("TPLevel3", "Trade Profit level3 (pips)", "", 20, 0.1, 1000)
    strategy.parameters:addInteger("TPLevel4", "Trade Profit level4 (pips)", "", 20, 0.1, 1000)
    strategy.parameters:addInteger("TPLevel5", "Trade Profit level5 (pips)", "", 30, 0.1, 1000)

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
        "HABBS"
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
local Exit
local Direction
local CustomID

local Action = {}
local Indicators
local Deviation, Period

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime
local trend_stop
local trendstop_source

local TICK_SOURCE_ID = 1
local MAIN_SOURCE_ID = 2
local TRENDSTOP_SOURCE_ID = 3

function CreateTrailingController()
    local controller = {}
    controller._profitLevels = {}
    controller._limit = nil
    controller._stop = 0
    controller._trade_id = nil
    controller._request_id = nil
    function controller:AddTrailing(level)
        if self._limit == nil then
            self._limit = level
        end
        self._profitLevels[#self._profitLevels + 1] = level
        return self
    end
    function controller:SetTradeID(trade_id)
        self._trade_id = trade_id
        return self
    end
    function controller:SetRequestID(request_id)
        self._request_id = request_id
        return self
    end
    function controller:DoCheck()
        local trade
        if self._trade_id == nil then
            trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id)
        else
            trade = core.host:findTable("trades"):find("TradeID", self._trade_id)
        end
        if trade == nil then
            return false
        end
        DistTradeStop = core.host:execute("getTradingProperty", "conditionalDistanceStopForTrade", trade.Instrument)
        local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument)
        local min_change = offer.PointSize
        local stopValue = nil
        if trade.BS == "B" then
            stopValue = trade.Open + self._stop
            if stopValue > offer.Bid - DistTradeStop * min_change then
                stopValue = offer.Bid - (DistTradeStop - 1) * min_change
            end

            if offer.Ask >= trade.Open + self._limit then
                if #self._profitLevels > 0 then
                    self._stop = self._stop + self._limit
                    self._limit = self._limit + self._profitLevels[1]
                    table.remove(self._profitLevels, 1)
                else
                    self:closeTrade(trade)
                    return true
                end
            else
                return true
            end

            if stopValue >= offer.Bid then
                return true
            end
        else
            stopValue = trade.Open - self._stop
            if stopValue < offer.Ask + DistTradeStop * min_change then
                stopValue = offer.Ask + (DistTradeStop + 1) * min_change
            end

            if offer.Bid <= trade.Open - self._limit then
                if #self._profitLevels > 0 then
                    self._stop = self._stop + self._limit
                    self._limit = self._limit + self._profitLevels[1]
                    table.remove(self._profitLevels, 1)
                else
                    self:closeTrade(trade)
                    return true
                end
            else
                return true
            end

            if stopValue <= offer.Ask then
                return true
            end
        end
        self:MoveStop(stopValue, trade)
        return true
    end
    function controller:closeTrade(row)
        local valuemap, success, msg

        valuemap = core.valuemap()
        valuemap.OrderType = "CM"
        valuemap.OfferID = row.OfferID
        valuemap.AcctID = row.AccountID
        valuemap.NetQtyFlag = "N"
        valuemap.TradeID = row.TradeID
        valuemap.Quantity = row.Lot
        valuemap.BuySell = row.BS == "B" and "S" or "B"
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
    controller._request_id = nil
    function controller:CreateStopOrder(stop_rate, trade)
        local valuemap = core.valuemap()
        valuemap.Command = "CreateOrder"
        valuemap.OfferID = trade.OfferID
        valuemap.Rate = stop_rate
        if trade.BS == "B" then
            valuemap.BuySell = "S"
        else
            valuemap.BuySell = "B"
        end

        local can_close =
            core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID)
        if can_close then
            valuemap.OrderType = "S"
            valuemap.AcctID = trade.AccountID
            valuemap.TradeID = trade.TradeID
            valuemap.Quantity = trade.Lot
        else
            valuemap.OrderType = "SE"
            valuemap.AcctID = trade.AccountID
            valuemap.NetQtyFlag = "Y"
        end

        local success, msg = terminal:execute(200, valuemap)
        if not (success) then
            terminal:alertMessage(trade.Instrument, stop_rate, "Failed create stop " .. msg, core.now())
        else
            self._request_id = msg
        end
    end

    function controller:ChangeStopOrder(stop_rate, order)
        local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize
        if math.abs(stop_rate - order.Rate) > min_change then
            -- stop exists
            local valuemap = core.valuemap()
            valuemap.Command = "EditOrder"
            valuemap.AcctID = order.AccountID
            valuemap.OrderID = order.OrderID
            valuemap.Rate = stop_rate

            local success, msg = terminal:execute(200, valuemap)
            if not (success) then
                terminal:alertMessage(order.Instrument, stop_rate, "Failed change stop " .. msg, core.now())
            end
        end
    end

    function controller:IsStopOrderType(order_type)
        return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"
    end

    controller._used_stop_orders = {}
    function controller:FindStopOrder(trade)
        local can_close =
            core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID)
        if can_close then
            local order_id
            if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
                order_id = trade.StopOrderID
            elseif _request_id ~= nil then
                local order = core.host:findTable("orders"):find("RequestID", _request_id)
                if order ~= nil then
                    order_id = order.OrderID
                    _request_id = nil
                end
            end

            -- Check that order is stil exist
            if order_id ~= nil then
                return core.host:findTable("orders"):find("OrderID", order_id)
            end
        else
            local enum = core.host:findTable("orders"):enumerator()
            local row = enum:next()
            while (row ~= nil) do
                if
                    row.ContingencyType == 3 and self:IsStopOrderType(row.Type) and
                        self._used_stop_orders[row.OrderID] ~= true
                 then
                    self._used_stop_orders[row.OrderID] = true
                    return row
                end
                row = enum:next()
            end
        end
        return nil
    end

    function controller:MoveStop(stop_rate, trade)
        local order = self:FindStopOrder(trade)
        if order == nil then
            -- =======================================================================
            --                           CREATE NEW ORDER                           --
            -- =======================================================================
            self:CreateStopOrder(stop_rate, trade)
        else
            -- =======================================================================
            --                      CHANGE EXISTING ORDER                           --
            -- =======================================================================
            self:ChangeStopOrder(stop_rate, order)
        end
    end
    return controller
end

local controllers = {}

--
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    Direction = instance.parameters.Direction == "direct"

    Deviation = instance.parameters.Deviation
    Period = instance.parameters.Period

    for i = 1, 6, 1 do
        Action[i] = instance.parameters:getString("Action" .. i)
    end
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end
    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(TICK_SOURCE_ID, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(MAIN_SOURCE_ID, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    Indicators = core.indicators:create("BB", Source.close, Period, Deviation)
    first = Indicators.DATA:first()
    if instance.parameters.confirm_with_trendstop then
        trendstop_source =
            ExtSubscribe(
            TRENDSTOP_SOURCE_ID,
            nil,
            instance.parameters.trendstop_tf,
            instance.parameters.Type == "Bid",
            "bar"
        )
        trend_stop =
            core.indicators:create(
            "TRENDSTOP",
            trendstop_source,
            instance.parameters.trendstop_period,
            instance.parameters.trendstop_type
        )
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
    if openTime == closeTime then
        return true;
    end
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

function ConfirmLongWithTrendstop()
    if trend_stop == nil then
        return true
    end

    return core.crossesOver(
        trendstop_source.close,
        trend_stop.DATA,
        trendstop_source.close:size() - 2,
        trend_stop.DATA:size() - 2
    )
end

function ConfirmShortWithTrendstop()
    if trend_stop == nil then
        return true
    end

    return core.crossesUnder(
        trendstop_source.close,
        trend_stop.DATA,
        trendstop_source.close:size() - 2,
        trend_stop.DATA:size() - 2
    )
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)
    if not InRange(now, OpenTime, CloseTime) then
        return
    end

    for i, controller in ipairs(controllers) do
        controller:DoCheck()
    end

    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end
    if id == TRENDSTOP_SOURCE_ID then
        return
    end
    if period < 0 then
        return
    end
    if ExecutionType == "Live" and id == 1 then
        period = core.findDate(Source.close, TickSource:date(period), false)
    end
    if period < 0 then
        return
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
    if trend_stop ~= nil then
        trend_stop:update(core.UpdateLast)
    end
    Indicators:update(core.UpdateLast)
    if period < 2 or not Indicators:getStream(0):hasData(period - 1) then
        return
    end

    if core.crossesOver(Source.close, Indicators:getStream(0), period) then
        ACTION(1, "Top ", "Over")
        ONE = Source:serial(period)
    end
    if core.crossesUnder(Source.close, Indicators:getStream(0), period) then
        ACTION(2, "Top ", "Under")
        ONE = Source:serial(period)
    end
    if core.crossesOver(Source.close, Indicators:getStream(2), period) then
        ACTION(3, "Central ", "Over")
        ONE = Source:serial(period)
    end
    if core.crossesUnder(Source.close, Indicators:getStream(2), period) then
        ACTION(4, "Central ", "Under")
        ONE = Source:serial(period)
    end
    if core.crossesOver(Source.close, Indicators:getStream(1), period) then
        ACTION(5, "Bottom ", "Over")
        ONE = Source:serial(period)
    end
    if core.crossesUnder(Source.close, Indicators:getStream(1), period) then
        ACTION(6, "Bottom ", "Under")
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
    else
        if instance.parameters.use_multilevel_trailing then
            local controller = CreateTrailingController()
            controller:SetRequestID(msg)
            for i = 1, 5 do
                controller:AddTrailing(instance.parameters:getInteger("TPLevel" .. i) * instance.bid:pipSize())
            end
            controllers[#controllers + 1] = controller
        end
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

function ACTION(Flag, Line, Label)
    if Action[Flag] == "NO" then
        return
    elseif Action[Flag] == "BUY" and ConfirmLongWithTrendstop() then
        BUY()
    elseif Action[Flag] == "SELL" and ConfirmShortWithTrendstop() then
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
