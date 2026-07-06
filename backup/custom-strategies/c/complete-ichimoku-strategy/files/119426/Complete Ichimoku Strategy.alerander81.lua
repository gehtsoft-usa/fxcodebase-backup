-- Id: 21484
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=61121

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {};

function Init() --The strategy profile initialization
    strategy:name("Complete Ichimoku Strategy")
    strategy:description("")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addInteger("T", "Tenkan Period", "Tenkan Period", 9)
    strategy.parameters:addInteger("K", "Kijun Period", "Kijun Period", 26)
    strategy.parameters:addInteger("S", "Senkou Period", "Senkou Period", 52)

    CreateTradingParameters()
    trading:Init(strategy.parameters);
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn")
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn")
    strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live")

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true)
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "CISA81")

    strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2, 1, 100)
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100)

    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addInteger("stop_shift", "Pivot stop shift", "", 10)

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
local first = {}
local Tenkan
local Kijun
local Senkou
local ICH
local CustomID
local pivot;
local stop_shift

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime
--
function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    CustomID = instance.parameters.CustomID
    ExecutionType = instance.parameters.ExecutionType
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition
    stop_shift = instance.parameters.stop_shift

    Tenkan = instance.parameters.T
    Kijun = instance.parameters.K
    Senkou = instance.parameters.S

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    if ExecutionType == "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close")
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    ICH = core.indicators:create("ICH", Source, Tenkan, Kijun, Senkou)

    first["SL"] = ICH.SL:first()
    first["TL"] = ICH.TL:first()
    first["SA"] = ICH.SA:first()
    first["CS"] = ICH.CS:first()
    first["SB"] = ICH.SB:first()
    first["PRICE"] = Source:first()

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

    pivot = core.indicators:create("PIVOT", Source, "D1", "Pivot", "HIST");

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
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
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

function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end

local stop_moved = {};

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
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
    ICH:update(core.UpdateLast)
    pivot:update(core.UpdateLast)

    if period < first["PRICE"] + Kijun or period < first["CS"] + Kijun then
        return
    end

    local Up = true
    local Down = true

    if
        Source.close[period] < math.max(ICH.SA[period], ICH.SB[period]) or
            ICH.SA[period + Kijun] < ICH.SB[period + Kijun] or
            ICH.SL[period] < math.max(ICH.SA[period], ICH.SB[period]) or
            ICH.TL[period] < math.max(ICH.SA[period], ICH.SB[period]) or
            ICH.SL[period] < ICH.TL[period] or
            ICH.CS[period - Kijun] < Source.close[period - Kijun]
     then
        Up = false
    end

    if
        Source.close[period] > math.min(ICH.SA[period], ICH.SB[period]) or
            ICH.SA[period + Kijun] > ICH.SB[period + Kijun] or
            ICH.SL[period] > math.min(ICH.SA[period], ICH.SB[period]) or
            ICH.TL[period] > math.min(ICH.SA[period], ICH.SB[period]) or
            ICH.SL[period] > ICH.TL[period] or
            ICH.CS[period - Kijun] > Source.close[period - Kijun]
     then
        Down = false
    end

    if Up and core.crossesOver(ICH.SL, ICH.TL, period) then
        BUY()
        ONE = Source:serial(period)
    elseif Down and core.crossesUnder(ICH.SL, ICH.TL, period) then
        SELL()
        ONE = Source:serial(period)
    end

    if period > 0 and core.crossesOver(Source.close, pivot.R1, period) then
        local trades = trading:FindTrade()
            :WhenCustomID(CustomID)
            :WhenSide("B")
            :All();
        for _, trade in ipairs(trades) do
            if stop_moved[trade.TradeID] == nil then
                trading:MoveStop(pivot.R1[period] - stop_shift * Source:pipSize(), trade)
                core.host:trace("moving stop")
                stop_moved[trade.TradeID] = true;
            end
        end
    elseif period > 0 and core.crossesUnder(Source.close, pivot.S1, period) then
        local trades = trading:FindTrade()
            :WhenCustomID(CustomID)
            :WhenSide("S")
            :All();
        for _, trade in ipairs(trades) do
            if stop_moved[trade.TradeID] == nil then
                trading:MoveStop(pivot.S1[period] + stop_shift * Source:pipSize(), trade)
                core.host:trace("moving stop")
                stop_moved[trade.TradeID] = true;
            end
        end
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
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

trading = {};
trading.Name = "Trading";
trading.Version = "3.1.0";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading._ids_start = nil;
trading._signaler = nil;
trading._allow_trade = false;
trading._account = nil;
trading._amount = 1;
trading._all_modules = {};
trading._limit = nil;
trading._stop = nil;
trading._trailing_stop = nil;
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function trading:Init(parameters)
    parameters:addBoolean("allow_trade", "Allow strategy to trade", "", true);
    parameters:setFlag("allow_trade", core.FLAG_ALLOW_TRADE);
    parameters:addString("account", "Account to trade on", "", "");
    parameters:setFlag("account", core.FLAG_ACCOUNT);
    if self.AddAmountParameter then
        parameters:addInteger("amount", "Trade Amount in Lots", "", 1);
    end
    if self.AddStopParameter then
        parameters:addBoolean("set_stop", "Set Stop Orders", "", false);
        parameters:addInteger("stop", "Stop Order in pips", "", 30);
        parameters:addBoolean("use_trailing", "Trailing stop order", "", false);
        parameters:addInteger("trailing", "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    end
    if self.AddLimitParameter then
        parameters:addBoolean("set_limit", "Set Limit Orders", "", false);
        parameters:addInteger("limit", "Limit Order in pips", "", 30);
    end
    parameters:addBoolean("close_on_opposite", "Close on Opposite", "", false);
end

function trading:Prepare(name_only)
    --do what you usually do in prepare
    if name_only then return; end
    self._account = instance.parameters.account;
    if self.AddAmountParameter then self._amount = instance.parameters.amount; end
    self._allow_trade = instance.parameters.allow_trade;
    if instance.parameters.set_limit then self._limit = instance.parameters.limit; end
    if instance.parameters.set_stop then
        self._stop = instance.parameters.stop;
        if instance.parameters.use_trailing then
            self._trailing_stop = instance.parameters.trailing;
        end
    end
end

function trading:OnNewModule(module)
    if module.Name == "Signaler" then self._signaler = module; end
    self._all_modules[#self._all_modules + 1] = module;
end

function trading:AsyncOperationFinished(cookie, success, message, message1, message2)
    local res = self._waiting_requests[cookie];
    if res ~= nil then
        res.Finished = true;
        res.Success = success;
        res.Error = not success and message or nil;
        if not success then
            self:trace(string.format("Failed request %s", tostring(message)));
        end
        self._waiting_requests[cookie] = nil;
    elseif cookie == self._order_update_id then
        for _, order in ipairs(self._monitored_orders) do
            if order.RequestID == message2 then
                order.FixStatus = message1;
            end
        end
    elseif cookie == self._ids_start + 2 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Close order failed: " .. message);
            else
                self:trace("Close order failed: " .. message);
            end
        end
    end
end

function trading:calculateAmount()
    return self._amount;
end

function trading:getOppositeSide(side) if side == "B" then return "S"; end return "B"; end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then return id; end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(stop_rate, trade, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = stop_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end

    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "S";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    self._request_id[trade.TradeID] = msg;
    return res;
end

function trading:CreateLimitOrder(limit_rate, trade)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = limit_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "L";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
    else
        valuemap.OrderType = "LE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end
    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, limit_rate, "Failed create limit " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
end

function trading:ChangeOrder(rate, order)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = order.TrlMinMove ~= 0 and order.TrlMinMove or nil;
        valuemap.Rate = rate;
        local id = self:getId();
        local success, msg = terminal:execute(id, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            self:trace(message);
            if self._signaler ~= nil then
                self._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        self._waiting_requests[id] = res;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function trading:IsLimitOrderType(order_type) return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE"; end

function trading:IsStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function trading:FindLimitOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.LimitOrderID ~= nil and trade.LimitOrderID ~= "" then
            order_id = trade.LimitOrderID;
            self:trace("Using limit order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching limit order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and IsLimitOrderType(row.Type) and self._used_limit_orders[row.OrderID] ~= true then
                self._used_limit_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
            self:trace("Using stop order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching stop order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and self:IsStopOrderType(row.Type) and self._used_stop_orders[row.OrderID] ~= true then
                self._used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:MoveStop(stop_rate, trade)
    local order = self:FindStopOrder(trade);
    if order == nil then
        self:trace("Stop order not found, creating a new one");
        return self:CreateStopOrder(stop_rate, trade);
    else
        return self:ChangeOrder(stop_rate, order);
    end
end

function trading:MoveLimit(limit_rate, trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(limit_rate, trade);
    else
        return self:ChangeOrder(limit_rate, order);
    end
end

function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then self:trace("No stop"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then self:trace("No limit"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:DeleteOrder(order)
    self:trace(string.format("Deleting order %s", order.OrderID));
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = order.OrderID;

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Delete order failed: " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    return res;
end

function trading:FindOrder()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenRate(rate) self.Rate = rate; return self; end
    function search:WhenOrderType(orderType) self.OrderType = orderType; return self; end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (row.QTXT == self.CustomID or not self.CustomID)
            and (row.Rate == self.Rate or not self.Rate)
            and (row.Type == self.OrderType or not self.OrderType);
    end
    function search:All()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local orders = {};
        while (row ~= nil) do
            if self:PassFilter(row) then orders[#orders + 1] = row; end
            row = enum:next();
        end
        return orders;
    end
    function search:First()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpen(open) self.Open = open; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (row.QTXT == self.CustomID or not self.CustomID)
            and (row.Open == self.Open or not self.Open)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:Count()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0;
        while (row ~= nil) do
            if self:PassFilter(row) then count = count + 1; end
            row = enum:next();
        end
        return count;
    end
    function search:First()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindClosedTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (row.QTXT == self.CustomID or not self.CustomID)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:First()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:ParialClose(trade, amount)
    -- not finished
    local account = core.host:findTable("accounts"):find("AccountID", trade.AccountID);
    if account.Hedging == "Y" then
        local valuemap = core.valuemap();
        valuemap.BuySell = trade.BS == "B" and "S" or "B";
        valuemap.OrderType = "CM";
        valuemap.OfferID = trade.OfferID;
        valuemap.AcctID = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = math.min(amount, trade.Lot);
        local success, msg = terminal:execute(self._ids_start + 3, valuemap);
        if not(success) then
            if self._signaler ~= nil then self._signaler:Signal("Close failed: " .. msg); end
            return false;
        end

        return true;
    end

    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = math.min(amount, trade.Lot);
    valuemap.BuySell = trading:getOppositeSide(trade.BS);
    local success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
    return true;
end

function trading:Close(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(self._ids_start + 3, valuemap);
    if not(success) then
        if self._signaler ~= nil then self._signaler:Signal("Close failed: " .. msg); end
        return false;
    end

    return true;
end

function trading:ObjectToJson(obj)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    
    local first = true;
    for idx,t in pairs(obj) do
        local stype = type(t)
        if stype == "number" then json:AddNumber(idx, t);
        elseif stype == "string" then json:AddStr(idx, t);
        elseif stype == "boolean" then json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then --do nothing
        else core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function trading:CreateEntryOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:IsOrderExecuted()
        return self.FixStatus ~= nil and self.FixStatus == "F";
    end
    function res:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self.RequestID);
            if self._order == nil then return nil; end
        end
        if not self._order:refresh() then return nil; end
        return self._order;
    end
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:CreateEntryOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetOrder() return nil; end
    function res:GetClosedTrade() return nil; end
    function res:IsOrderExecuted() return false; end
    return res;
end

function trading:EntryOrder(instrument)
    local builder = {};
    builder.Offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OfferID = builder.Offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end

    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetDefaultAmount() self.valuemap.Quantity = self.Parent:calculateAmount() * self:_GetBaseUnitSize(); return self; end
    function builder:SetAmount(amount) self.valuemap.Quantity = amount * self:_GetBaseUnitSize(); return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetRate(rate) if self.valuemap.BuySell == "B" then self.valuemap.OrderType = self.Offer.Ask > rate and "LE" or "SE"; else self.valuemap.OrderType = self.Offer.Bid > rate and "SE" or "LE"; end self.valuemap.Rate = rate; return self; end
    function builder:SetPipLimit(limit_type, limit) self.valuemap.PegTypeLimit = limit_type or "M"; self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit; return self; end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop) self.valuemap.PegTypeStop = stop_type or "O"; self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:UseDefaultCustomId() self.valuemap.CustomID = self.Parent.CustomID; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:Execute()
        local desc = string.format("Creating %s %s for %s at %f", self.valuemap.BuySell, self.valuemap.OrderType, self.Instrument, self.valuemap.Rate);
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self.valuemap.RateStop ~= nil then
            desc = desc .. " stop " .. self.valuemap.RateStop;
        end
        if self.valuemap.RateLimit ~= nil then
            desc = desc .. " limit " .. self.valuemap.RateLimit;
        end
        self.Parent:trace(desc);
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._PercentOfEquityAmount / 100.0;
            local stop = math.abs(self.valuemap.RateStop - self.valuemap.Rate) / self.Offer.PointSize;
            local possible_loss = self.Offer.PipCost * stop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * self:_GetBaseUnitSize();
        end

        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return trading:CreateEntryOrderFailResult("Creation of order blocked by " .. module.Name);
            end
        end
        if not self.Parent._allow_trade then
            local message = string.format("%s signal for %s", self.valuemap.BuySell, self.Instrument);
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then self.Parent._signaler:Signal(message); end
            return trading:CreateEntryOrderSuccessResult();
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then module:OnOrder(self.valuemap); end
        end
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then self.Parent._signaler:Signal(message); end
            return trading:CreateEntryOrderFailResult(message);
        end
        local res = trading:CreateEntryOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:StoreMarketOrderResults(res)
    local str = "[";
    for i, t in ipairs(res) do
        local json = t:ToJSON();
        if str == "[" then str = str .. json; else str = str .. "," .. json; end
    end
    return str .. "]";
end
function trading:RestoreMarketOrderResults(str)
    local results = {};
    local position = 2;
    local result;
    while (position < str:len()) do
        local ch = string.sub(str, position, position);
        if ch == "{" then
            result = trading:CreateMarketOrderSuccessResult();
            position = position + 1;
        elseif ch == "}" then
            results[#results + 1] = result;
            result = nil;
            position = position + 1;
        elseif ch == "," then
            position = position + 1;
        else
            local name, value = string.match(str, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return results;
end
function trading:CreateMarketOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        local json = {};
        function json:AddStr(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
        end
        function json:AddNumber(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
        end
        function json:AddBool(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
        end
        function json:ToString() return "{" .. (self.str or "") .. "}"; end
        
        local first = true;
        for idx,t in pairs(self) do
            local stype = type(t)
            if stype == "number" then json:AddNumber(idx, t);
            elseif stype == "string" then json:AddStr(idx, t);
            elseif stype == "boolean" then json:AddBool(idx, t);
            elseif stype == "function" or stype == "table" then --do nothing
            else core.host:trace(tostring(idx) .. " " .. tostring(stype));
            end
        end
        return json:ToString();
    end
    return res;
end
function trading:CreateMarketOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetTrade() return nil; end
    return res;
end

function trading:MarketOrder(instrument)
    local builder = {};
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OrderType = "OM";
    builder.valuemap.OfferID = offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount)
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID);
        self.valuemap.Quantity = amount * base_size;
        return self;
    end
    function builder:SetDefaultAmount()
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        self.valuemap.Quantity = self.Parent:calculateAmount() * base_size;
        return self;
    end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "O";
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit;
        return self;
    end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop)
        self.valuemap.PegTypeStop = stop_type or "O";
        self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return trading:CreateMarketOrderFailResult("Creation of order blocked by " .. module.Name);
            end
        end
        if not self.Parent._allow_trade then
            local message = string.format("%s signal for %s", self.valuemap.BuySell, self.Instrument);
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return trading:CreateMarketOrderSuccessResult();
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then
                module:OnOrder(self.valuemap);
            end
        end
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return trading:CreateMarketOrderFailResult(message);
        end
        local res = trading:CreateMarketOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:JsonToObj(json)
    local position = 1;
    local result;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            return result;
        elseif ch == "," then
            position = position + 1;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(json, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetTradeMetadata(trade)
    local qtxt = trade.QTXT;
    if qtxt == "" then
        return nil;
    end
    local position = 1;
    local result;
    while (position < qtxt:len() + 1) do
        local ch = string.sub(qtxt, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            return result;
        elseif ch == "," then
            position = position + 1;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(qtxt, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end
trading:RegisterModule(Modules);