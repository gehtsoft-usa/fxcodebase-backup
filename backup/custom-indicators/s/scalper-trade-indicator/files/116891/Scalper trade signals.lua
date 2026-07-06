-- Id: 20300
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65610

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

local Modules = {};
trading_logic = {};
-- public fields
trading_logic.Name = "Trading logic";
trading_logic.Version = "1.1.1";
trading_logic.Debug = false;
trading_logic.DoTrading = nil;
trading_logic.MainSource = nil;
--private fields
trading_logic._ids_start = nil;
trading_logic._trading_source_id = nil;
function trading_logic:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading_logic:OnNewModule(module) end
function trading_logic:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end
function trading_logic:Init(parameters)

    parameters:addGroup("Calculation");
	parameters:addInteger("Period", "Period","",20);
	parameters.parameters:addInteger("k", "k","",48);
	
    parameters:addGroup("Price");
    parameters:addBoolean("is_bid", "Price Type","", true);
    parameters:setFlag("is_bid", core.FLAG_BIDASK);
    parameters:addString("timeframe", "Time frame", "", "m1");
    parameters:setFlag("timeframe", core.FLAG_PERIODS);
    parameters:addString("entry_execution_type", "Entry Execution Type", "", "Live");
    parameters:addStringAlternative("entry_execution_type", "End of Turn", "", "EndOfTurn");
    parameters:addStringAlternative("entry_execution_type", "Live", "", "Live");
end
function trading_logic:GetLastPeriod(source_period, source, target)
    if source_period < 0 or target:size() < 2 then
        return nil;
    end
    local s1, e1 = core.getcandle(source:barSize(), source:date(source_period), -7, 0);
    local s2, e2 = core.getcandle(target:barSize(), target:date(NOW - 1), -7, 0);
    if e1 == e2 then
        return target:size() - 2;
    else
        return target:size() - 1;
    end
end
function trading_logic:GetPeriod(source_period, source, target)
    if source_period < 0 then
        return nil;
    end
    local source_date = source:date(source_period);
    local index = core.findDate(target, source_date, false);
    if index == -1 then
        return nil;
    end
    return index;
end
function trading_logic:Prepare(name_only)
    if name_only then
        return;
    end
    if instance.parameters.entry_execution_type == "Live" then
        self._trading_source_id = self._ids_start + 1;
        ExtSubscribe(self._trading_source_id, nil, "t1", instance.parameters.is_bid, "close");
        self:trace("Trading on tick (live data)");
    else
        self._trading_source_id = self._ids_start + 2;
        self:trace(string.format("Trading on %s bar", instance.parameters.timeframe));
     end
    self.MainSource = ExtSubscribe(self._ids_start + 2, nil, instance.parameters.timeframe, instance.parameters.is_bid, "bar");
end
function trading_logic:ExtUpdate(id, source, period)
    if id == self._trading_source_id and self.DoTrading ~= nil then
        if source ~= self.MainSource then
            period = core.findDate(self.MainSource, source:date(period), false);
            if period == -1 then
                return;
            end
        end
        self.DoTrading(self.MainSource, period);
    end
end
trading_logic:RegisterModule(Modules);
trading = {};
trading.Name = "Trading";
trading.Version = "2.0.1";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading.AddDirectionParameter = true;
trading.CustomID = nil;
trading._ids_start = nil;
trading._signaler = nil;
trading._allow_trade = false;
trading._account = nil;
trading._amount = 1;
trading._all_modules = {};
trading._reverse_side = false;
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
    if self.AddDirectionParameter then
        parameters:addString("orders_direction", "Type of Signal / Trade", "", "direct");
        parameters:addStringAlternative("orders_direction", "Direct", "", "direct");
        parameters:addStringAlternative("orders_direction", "Reverse", "", "reverse");
    end
    if self.AddStopParameter then
        parameters:addBoolean("set_stop", "Set Stop Orders", "", false);
        parameters:addInteger("stop", "Stop Order in pips", "", 30);
        parameters:addBoolean("trailing_stop", "Trailing stop order", "", false);
        parameters:addInteger("trailing", "Trailing in pips", "", 1);
    end
    if self.AddLimitParameter then
        parameters:addBoolean("set_limit", "Set Limit Orders", "", false);
        parameters:addInteger("limit", "Limit Order in pips", "", 30);
    end
end
function trading:Prepare(name_only)
    --do what you usually do in prepare
    if name_only then
        return;
    end
    self._account = instance.parameters.account;
    if self.AddAmountParameter then
        self._amount = instance.parameters.amount;
    end
    self._allow_trade = instance.parameters.allow_trade;
    if self.AddDirectionParameter then
        self._reverse_side = instance.parameters.orders_direction == "reverse";
    end
    if instance.parameters.set_limit then
        self._limit = instance.parameters.limit;
    end
    if instance.parameters.set_stop then
        self._stop = instance.parameters.stop;
        if instance.parameters.trailing_stop then
            self._trailing_stop = instance.parameters.trailing;
        end
    end
end
function trading:OnNewModule(module)
    if module.Name == "Signaler" then
        self._signaler = module;
    end
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
function trading:addLimit(valuemap)
    if self._limit == nil then
        return;
    end
    valuemap.PegTypeLimit = "O";
    valuemap.PegPriceOffsetPipsLimit = valuemap.BuySell == "B" and self._limit or -self._limit;
end
function trading:addStop(valuemap)
    if self._stop == nil then
        return;
    end
    valuemap.PegTypeStop = "O";
    valuemap.PegPriceOffsetPipsStop = valuemap.BuySell == "B" and -self._stop or self._stop;
    valuemap.TrailStepStop = self._trailing_stop;
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
            if row.ContingencyType == 3 and IsStopOrderType(row.Type) and self._used_stop_orders[row.OrderID] ~= true then
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
function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then
        self:trace("No stop");
        return nil;
    end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end
function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("No limit");
        return nil;
    end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
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
function trading:DeleteOrders(custom_id)
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if (row.QTXT == custom_id or not custom_id) and (row.Type == "LE" or row.Type == "SE") then
            -- we want to close the entry orders, not the stop or limit orders etc otherwise we will get errors as they close each other out.
            self:trace(string.format("Deleting order %s", row.OrderID));
            local valuemap = core.valuemap();
            valuemap.Command = "DeleteOrder";
            valuemap.OrderID = row.OrderID;
            local success, msg = terminal:execute(301, valuemap);
            if not(success) then
            end
        end
        row = enum:next();
    end
end
function trading:CloseAllForInstrument(instrument)
    local have_actions = false;
    local enum = core.host:findTable("accounts"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if self:CloseSideForInstrumentAndAccount(instrument, "B", row.AccountID) then
            have_actions = true;
        end
        if self:CloseSideForInstrumentAndAccount(instrument, "S", row.AccountID) then
            have_actions = true;
        end
        row = enum:next();
    end
    return have_actions;
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
function trading:PositionExists(instrument, side, account_id)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if (row.Instrument == instrument or not instrument) and (row.BS == side or not side) and (row.AccountID == account_id or not account_id) then
            return true;
        end
        row = enum:next();
    end
    return false;
end
function trading:CloseSideForInstrument(instrument, side)
    local enum = core.host:findTable("accounts"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        self:CloseSideForInstrumentAndAccount(instrument, side, row.AccountID);
        row = enum:next();
    end
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
        if self._signaler ~= nil then
            self._signaler:Signal("Close failed: " .. msg);
        end
        return false;
    end
    return true;
end
function trading:CloseSideForInstrumentAndAccount(instrument, side, account_id)
    if not self:PositionExists(instrument, side, account_id) then
        self:trace(string.format("Nothing to close: %s, %s, %s", tostring(instrument), tostring(side), tostring(account_id)));
        return true;
    end
    self:trace(string.format("Closing all positions for instrument %s, %s, %s", tostring(instrument), tostring(side), tostring(account_id)));
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "CM";
    valuemap.OfferID = offer.OfferID;
    valuemap.BuySell = self:getOppositeSide(side);
    valuemap.AcctID = account_id;
    valuemap.NetQtyFlag = "Y";
    local success, msg = terminal:execute(self._ids_start + 2, valuemap);
    if not(success) then
        if self._signaler ~= nil then
            self._signaler:Signal("Exit failed: " .. msg);
        end
        return false;
    end
    return true;
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
    function builder:SetAmount(amount)
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        self.valuemap.Quantity = amount * base_size;
        return self;
    end
    function builder:SetDefaultAmount()
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        self.valuemap.Quantity = self.Parent:calculateAmount() * base_size;
        return self;
    end
    function builder:SetSide(buy_sell)
        if self.Parent._reverse_side then
            buy_sell = self.Parent:getOppositeSide(buy_sell);
        end
        self.valuemap.BuySell = buy_sell;
        return self;
    end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "O";
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
    function builder:SetCustomID(custom_id)
        self.valuemap.CustomID = custom_id;
        return self;
    end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                local res = {};
                res.Finished = true;
                res.Success = false;
                res.Error = "Creation of order blocked by " .. module.Name;
                function res:GetTrade()
                    return nil;
                end
                return res;
            end
        end
        if not self.Parent._allow_trade then
            local message = string.format("%s signal for %s", self.valuemap.BuySell, self.Instrument);
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = true;
            function res:GetTrade()
                return nil;
            end
            return res;
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
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            function res:GetTrade()
                return nil;
            end
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        function res:GetTrade()
            if self._trade == nil then
                self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
                if self._trade == nil then
                    return nil;
                end
            end
            if not self._trade:refresh() then
                return nil;
            end
            return self._trade;
        end
        function res:IsTradeClosed()
            return core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID) ~= nil;
        end
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end
function trading:CreateMarketOrderWithAmount(instrument, buy_sell, amount)
    self:trace(string.format("Creating %s OM for %s", buy_sell, instrument));
    if self._reverse_side then
        buy_sell = self:getOppositeSide(buy_sell);
    end
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    local base_size = core.host:execute("getTradingProperty", "baseUnitSize", instrument, self._account);
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer.OfferID;
    valuemap.AcctID = self._account;
    valuemap.Quantity = amount * base_size;
    valuemap.BuySell = buy_sell;
    self:addLimit(valuemap);
    self:addStop(valuemap);
    for _, module in pairs(self._all_modules) do
        if module.BlockOrder ~= nil and module:BlockOrder(valuemap) then
            self:trace("Creation of order blocked by " .. module.Name);
            return false;
        end
    end
    if not self._allow_trade then
        if self._signaler ~= nil then
            self._signaler:Signal(string.format("%s signal for %s", buy_sell, instrument));
        end
        return true;
    end
    for _, module in pairs(self._all_modules) do
        if module.OnOrder ~= nil then
            module:OnOrder(valuemap);
        end
    end
    local success, msg = terminal:execute(self._ids_start + 1, valuemap);
    if not(success) then
        if self._signaler ~= nil then
            self._signaler:Signal("Open order failed: " .. msg);
        end
        return false;
    end
    return true;
end
function trading:CreateMarketOrder(instrument, buy_sell)
    return self:CreateMarketOrderWithAmount(instrument, buy_sell, self:calculateAmount());
end
trading:RegisterModule(Modules);
function Init()
    strategy:name("Scalper trade signals");
    strategy:description("");
    trading_logic:Init(strategy.parameters);
    trading:Init(strategy.parameters);
end
local indi = nil;
function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then return ; end

    assert(core.indicators:findIndicator("SCALPER TRADE INDICATOR") ~= nil, "Please, download and install SCALPER TRADE INDICATOR indicator");
    indi = core.indicators:create("SCALPER TRADE INDICATOR", trading_logic.MainSource, instance.parameters.Period, instance.parameters.k);

    trading_logic.DoTrading = EntryFunction;
end
function EntryFunction(source, period)
    indi:update(core.UpdateLast);
    if indi.L[period] < indi.MB[period] and indi.L[period - 1] == indi.MB[period - 1] then
        trading:MarketOrder(source:instrument()):SetSide("B"):SetDefaultAmount():Execute();
    end
    if indi.H[period] < indi.MB[period] and indi.H[period - 1] == indi.MB[period - 1] then
        trading:MarketOrder(source:instrument()):SetSide("S"):SetDefaultAmount():Execute();
    end
end
function ExtUpdate(id, source, period) for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
