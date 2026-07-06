-- Id: 20398
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65654

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Set stop by ATR Stop Dots");
    strategy:description("");

    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addDouble("Percentage", "Risk Percentage", "", 1.0);
    strategy.parameters:addDouble("Multiplier", "ATR Multiplier", "", 1.5);
    strategy.parameters:addDouble("pMultiplier", "Profit Multiplier", "", 2.0);
    strategy.parameters:addInteger("Period", "ATR Period", "", 14);
    strategy.parameters:addBoolean("trail_stops", "Trail stops", "", false);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("timeframe", "Timeframe", "", "m1");
    strategy.parameters:setFlag("timeframe", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("TradeAll", "Watch all trades", "If Yes, the strategy will be watched on all trades, otherwise, one of the trade should be selected.", true);
    strategy.parameters:addString("Trade", "Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
end

local tradeExist = true;
local first = true;
local stopOrder = nil;      -- the identifier of the stop order
local tsource = nil;
local timer;
local minChange;
local executing = false;
local tradeAll;
local EntryExecutionType;
local atr_stop;
local trail_stops;

function Prepare(onlyName)
    local name;
    tradeAll = instance.parameters.TradeAll;
    trail_stops = instance.parameters.trail_stops;
    
    local tradeCaption = instance.parameters.Trade;
    if tradeAll == true then
        tradeCaption = "All Trades";
    end
    EntryExecutionType = instance.parameters.EntryExecutionType;
    
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.timeframe  .. "]" ..
                           tradeCaption .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    minChange = math.pow(10, -instance.bid:getPrecision());

    ExtSetupSignal(name .. ":", true);
    tsource = ExtSubscribe(1, nil, instance.parameters.timeframe, instance.parameters.Type == "Bid", "bar");

    assert(core.indicators:findIndicator("ATR_STOP_DOTS") ~= nil, "Please, download and install ATR_STOP_DOTS.LUA indicator");
    atr_stop = core.indicators:create("ATR_STOP_DOTS", tsource,
        instance.parameters.Percentage, instance.parameters.Multiplier,
        instance.parameters.pMultiplier, instance.parameters.Period,
        5, true);

    core.host:execute("subscribeTradeEvents", 110, "trades");
end

trading = {};
trading.Name = "Trading";
trading.Version = "2.1.1";
trading.CustomID = nil;
trading._ids_start = 300;
trading._account = nil;
trading._amount = 1;
trading._reverse_side = false;
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end

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
    elseif cookie == self._ids_start + 1 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Open order failed: " .. message);
            else
                self:trace("Open order failed: " .. message);
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

function trading:getOppositeSide(side)
    if side == "B" then
        return "S";
    end
    return "B";
end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then
            return id;
        end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(stop_rate, trade)
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
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, stop_rate, "Failed create stop " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
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
        local success, msg = terminal:execute(200, valuemap);
        if not(success) then
            terminal:alertMessage(order.Instrument, rate, "Failed change order " .. msg, core.now());
        end
    end
end

function trading:IsLimitOrderType(order_type)
    return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE";
end

function trading:IsStopOrderType(order_type)
    return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE";
end

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
        if order_id ~= nil then
            return core.host:findTable("orders"):find("OrderID", order_id);
        end
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
        if order_id ~= nil then
            return core.host:findTable("orders"):find("OrderID", order_id);
        end
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
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then
        -- =======================================================================
        --                           CREATE NEW ORDER                           --
        -- =======================================================================
        self:trace("Order not found, creating a new one");
        self:CreateStopOrder(stop_rate, trade);
    else
        -- =======================================================================
        --                      CHANGE EXISTING ORDER                           --
        -- =======================================================================
        self:ChangeOrder(stop_rate, order);
    end
end

function trading:MoveLimit(limit_rate, trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        -- =======================================================================
        --                           CREATE NEW ORDER                           --
        -- =======================================================================
        self:trace("Order not found, creating a new one");
        self:CreateLimitOrder(limit_rate, trade);
    else
        -- =======================================================================
        --                      CHANGE EXISTING ORDER                           --
        -- =======================================================================
        self:ChangeOrder(limit_rate, order);
    end
end

function trading:MoveOrder(order, new_rate)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(new_rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(new_rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.Rate = new_rate;
        local success, msg = terminal:execute(200, valuemap);
        if not(success) then
            terminal:alertMessage(order.Instrument, new_rate, "Failed change stop " .. msg, core.now());
        end
    end
end

function trading:FindFirstOrder(instrument, side, account_id, custom_id)
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if (row.Instrument == instrument or not instrument)
                and (row.BS == side or not side)
                and (row.AccountID == account_id or not account_id)
                and (row.QTXT == custom_id or not custom_id) then
            return row;
        end
        row = enum:next();
    end
    return nil;
end

function trading:FindOrder()
    local search = {};
    function search:SetCustomID(custom_id)
        self.CustomID = custom_id;
        return self;
    end
    function search:SetSide(bs)
        self.Side = bs;
        return self;
    end
    function search:SetInstrument(instrument)
        self.Instrument = instrument;
        return self;
    end
    function search:SetAccountID(account_id)
        self.AccountID = account_id;
        return self;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (row.QTXT == self.CustomID or not self.CustomID);
    end
    function search:All()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local orders = {};
        while (row ~= nil) do
            if self:PassFilter(row) then
                orders[#orders + 1] = row;
            end
            row = enum:next();
        end
        return orders;
    end
    function search:First()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return row;
            end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindTrade()
    local search = {};
    function search:SetCustomID(custom_id)
        self.CustomID = custom_id;
        return self;
    end
    function search:SetSide(bs)
        self.Side = bs;
        return self;
    end
    function search:SetInstrument(instrument)
        self.Instrument = instrument;
        return self;
    end
    function search:SetAccountID(account_id)
        self.AccountID = account_id;
        return self;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (row.QTXT == self.CustomID or not self.CustomID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then
                trades[#trades + 1] = row;
            end
            row = enum:next();
        end
        return trades;
    end
    function search:First()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return row;
            end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindFirstPosition(instrument, side, account_id, custom_id)
    return self:FindTrade()
        :SetInstrument(instrument)
        :SetSide(side)
        :SetAccountID(account_id)
        :SetCustomID(custom_id)
        :First();
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
    function builder:_GetBaseUnitSize()
        if self._base_size == nil then
            self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        end
        return self._base_size;
    end

    function builder:SetDefaultAmount()
        self.valuemap.Quantity = self.Parent:calculateAmount() * self:_GetBaseUnitSize();
        return self;
    end
    function builder:SetAmount(amount)
        self.valuemap.Quantity = amount * self:_GetBaseUnitSize();
        return self;
    end
    function builder:SetPercentOfEquityAmount(percent)
        self._PercentOfEquityAmount = percent;
        return self;
    end
    function builder:SetSide(buy_sell)
        if self.Parent._reverse_side then
            buy_sell = self.Parent:getOppositeSide(buy_sell);
        end
        self.valuemap.BuySell = buy_sell;
        return self;
    end
    function builder:SetRate(rate)
        if self.valuemap.BuySell == "B" then
            self.valuemap.OrderType = self.Offer.Ask > rate and "LE" or "SE";
        else
            self.valuemap.OrderType = self.Offer.Bid > rate and "SE" or "LE";
        end
        self.valuemap.Rate = rate;
        return self;
    end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "M";
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit;
        return self;
    end
    function builder:SetLimit(limit)
        self.valuemap.RateLimit = limit;
        return self;
    end
    function builder:SetPipStop(stop_type, stop, trailing_stop)
        self.valuemap.PegTypeStop = stop_type or "O";
        self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:SetStop(stop)
        self.valuemap.RateStop = stop;
        return self;
    end
    function builder:UseDefaultCustomId()
        self.valuemap.CustomID = self.Parent.CustomID;
        return self;
    end
    function builder:SetCustomID(custom_id)
        self.valuemap.CustomID = custom_id;
        return self;
    end
    function builder:GetValueMap()
        return self.valuemap;
    end
    function builder:Execute()
        local desc = string.format("Creating %s %s for %s at %f", self.valuemap.BuySell, self.valuemap.OrderType, self.Instrument, self.valuemap.Rate);
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
                return false;
            end
        end
        if not self.Parent._allow_trade then
            local message = string.format("%s signal for %s", self.valuemap.BuySell, self.Instrument);
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return true;
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then
                module:OnOrder(self.valuemap);
            end
        end
        local success, msg = terminal:execute(self.Parent._ids_start + 1, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return false;
        end
        return true;
    end
    return builder;
end

function UpdateStop(trade, period)
    if trade.BS == "B" then
        trading:MoveStop(atr_stop:getStream(1):tick(period), trade);
    else
        trading:MoveStop(atr_stop:getStream(0):tick(period), trade);
    end
end

function UpdateLimit(trade, period)
    if trade.BS == "B" then
        trading:MoveLimit(atr_stop:getStream(2):tick(period), trade);
    else
        trading:MoveLimit(atr_stop:getStream(3):tick(period), trade);
    end
end

function ExtUpdate(id, source, period)
    if not instance.parameters.AllowTrade then
        return;
    end
    atr_stop:update(core.UpdateLast);
    if trail_stops then
        if tradeAll == true then
            local tradesEnum = core.host:findTable("trades"):enumerator();
            local tradeRow = tradesEnum:next();
            while tradeRow ~= nil and tradeRow.Instrument == tsource:instrument() do
                UpdateStop(tradeRow, period);
                tradeRow = tradesEnum:next();
            end
        else
            local tradeRow = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade);
            if tradeRow ~= nil and tradeRow.Instrument == tsource:instrument() then
                UpdateStop(tradeRow, period);
            end
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
    trading:AsyncOperationFinished(id, success, message);
    if id == 200 then
        executing = false;
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message, instance.bid:date(NOW));
        end
    elseif id == 110 then
        local trade_id = message;
        local close_trade = success;
        if not close_trade then
            local trade = core.host:findTable("trades"):find("TradeID", trade_id);
            if trade ~= nil and trade.Instrument == tsource:instrument() then
                atr_stop:update(core.UpdateLast);
                UpdateStop(trade, atr_stop.DATA:size() - 1);
                UpdateLimit(trade, atr_stop.DATA:size() - 1);
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
