-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65069

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
trading = {};
trading.Name = "Trading";
trading.Version = "1.5.0";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameters = false;
trading.AddLimitParameters = true;
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
    if self.AddStopParameters then
        parameters:addBoolean("set_stop", "Set Stop Orders", "", false);
        parameters:addInteger("stop", "Stop Order in pips", "", 30);
        parameters:addBoolean("trailing_stop", "Trailing stop order", "", false);
        parameters:addInteger("trailing", "Trailing in pips", "", 1);
    end
    if self.AddLimitParameters then
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
    if cookie == self._ids_start + 1 then
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
    if valuemap.BuySell == "B" then
        valuemap.PegPriceOffsetPipsLimit = self._limit;
    else
        valuemap.PegPriceOffsetPipsLimit = -self._limit;
    end
end
function trading:addStop(valuemap)
    if self._stop == nil then
        return;
    end
    valuemap.PegTypeStop = "O";
    if valuemap.BuySell == "B" then
        valuemap.PegPriceOffsetPipsStop = -self._stop;
    else
        valuemap.PegPriceOffsetPipsStop = self._stop;
    end
    valuemap.TrailStepStop = self._trailing_stop;
end
function trading:getOppositeSide(side)
    if side == "B" then
        return "S";
    end
    return "B";
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
function trading:FindFirstPosition(instrument, side, account_id, custom_id)
    local enum = core.host:findTable("trades"):enumerator();
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
function trading:CreateEntryOrderCustom(instrument, buy_sell, entry_price, amount, limit_type, peg_limit, limit, stop_type, peg_stop, stop, trailing_stop, custom_id)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    if self._reverse_side then
        buy_sell = self:getOppositeSide(buy_sell);
    end
    if buy_sell == "B" then
        valuemap.OrderType = offer.Ask > entry_price and "LE" or "SE";
    else
        valuemap.OrderType = offer.Bid > entry_price and "SE" or "LE";
    end

    local message = string.format("Creating %s %s for %s at %f", buy_sell, valuemap.OrderType, instrument, entry_price);
    if custom_id ~= nil then
        message = message .. " CustomID: " .. custom_id;
    end
    self:trace(message);

    if limit ~= nil then
        if peg_limit then
            valuemap.PegTypeLimit = limit_type or "M";
            valuemap.PegPriceOffsetPipsLimit = buy_sell == "B" and limit or -limit;
        else
            valuemap.RateLimit = limit;
        end
    end

    if stop ~= nil then
        if peg_stop then
            valuemap.PegTypeStop = stop_type or "M";
            valuemap.PegPriceOffsetPipsLimit = buy_sell == "B" and -stop or stop;
        else
            valuemap.RateStop = stop;
        end
        valuemap.TrailStepStop = trailing_stop;
    end
    valuemap.Rate = entry_price;
    local base_size = core.host:execute("getTradingProperty", "baseUnitSize", instrument, self._account);
    valuemap.OfferID = offer.OfferID;
    valuemap.AcctID = self._account;
	valuemap.Quantity = (amount or self:calculateAmount()) * base_size;
    valuemap.BuySell = buy_sell;
    valuemap.CustomID = custom_id;
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
function trading:CreateMarketOrderCustom(instrument, buy_sell, amount, limit_type, limit, stop_type, stop, trailing_stop)
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
	valuemap.Quantity = (amount or self:calculateAmount()) * base_size;
	valuemap.BuySell = buy_sell;
    if limit ~= nil then
        valuemap.PegTypeLimit = limit_type or "O";
        valuemap.PegPriceOffsetPipsLimit = buy_sell == "B" and limit or -limit;
    end
    if stop ~= nil then
        valuemap.PegTypeStop = stop_type or "O";
        valuemap.PegPriceOffsetPipsLimit = buy_sell == "B" and -stop or stop;
        valuemap.TrailStepStop = trailing_stop;
    end
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
trading_time = {};
trading_time.Name = "Trading time";
trading_time.Debug = false;
trading_time.Version = "1.0";
trading_time._ids_start = nil;
trading_time._tz = nil;
trading_time._start_time = nil;
trading_time._stop_time = nil;
function trading_time:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading_time:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end
function trading_time:Init(parameters)
    parameters:addString("trading_start_time", "Start Time for Trading", "", "00:00:00");
    parameters:addString("trading_stop_time", "Stop Time for Trading", "", "24:00:00");
end
function trading_time:ParseTime(time)
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
function trading_time:Prepare(name_only)
    local valid;
    self._start_time, valid = self:ParseTime(instance.parameters.trading_start_time);
    assert(valid, "Time " .. instance.parameters.trading_start_time .. " is invalid");
    self._stop_time, valid = self:ParseTime(instance.parameters.trading_stop_time);
    assert(valid, "Time " .. instance.parameters.trading_stop_time .. " is invalid");
    if name_only then
        return;
    end
end
function trading_time:OnNewModule(module)
    if module.Name == "Timezone Parameter" then
        self._tz = module;
    end
end
function trading_time:BlockTrading(id, source, period)
    --do what you usually do in Update
    local now = core.host:execute("getServerTime");
    if self._tz ~= nil then
        now = core.host:execute("convertTime", core.TZ_EST, self._tz.Selected_timezone, now);
    end
    -- get only time
    now = now - math.floor(now);
    if not (now >= self._start_time and now <= self._stop_time) then  
        return true;
    end
    return false;
end
trading_time:RegisterModule(Modules);
mandatory_closing = {};
mandatory_closing.Name = "Mandatory Closing";
mandatory_closing.Debug = false;
mandatory_closing.Version = "1.0";
mandatory_closing.Default_use_mandatory_closing = false;
mandatory_closing.Default_mandatory_closing_exit_time = "23:59:00";
mandatory_closing._ids_start = nil;
mandatory_closing._use_mandatory_closing = nil;
mandatory_closing._exit_time = nil;
mandatory_closing._interval = nil;
mandatory_closing._timer_id = nil;
mandatory_closing._tz = nil;
mandatory_closing._signaler = nil;
function mandatory_closing:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function mandatory_closing:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end
function mandatory_closing:Init(parameters)
    parameters:addBoolean("use_mandatory_closing", "Use Mandatory Closing", "", self.Default_use_mandatory_closing);
    parameters:addString("mandatory_closing_exit_time", "Mandatory Closing Time", "", self.Default_mandatory_closing_exit_time);
    parameters:addInteger("mandatory_closing_valid_interval", "Valid Interval for Operation, in second", "", 60);
end
function mandatory_closing:ParseTime(time)
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
function mandatory_closing:Prepare(name_only)
    self._use_mandatory_closing = instance.parameters.use_mandatory_closing;
    self._interval = instance.parameters.mandatory_closing_valid_interval;
    local exit_time = instance.parameters.mandatory_closing_exit_time;
    self._exit_time, valid = self:ParseTime(exit_time);
    assert(valid, "Time " .. exit_time .. " is invalid");
    if name_only then
        return;
    end
    if self._use_mandatory_closing then
        self._timer_id = self._ids_start + 1;
        core.host:execute("setTimer", self._timer_id, math.max(self._interval / 2, 1));
    end
    self:trace(string.format("Use mandatory closing: %s. Time of mandatory closing: %s. Interval: %s",
        tostring(self._use_mandatory_closing), tostring(exit_time), tostring(self._interval)));
end
function mandatory_closing:OnNewModule(module)
    if module.Name == "Timezone Parameter" then
        self._tz = module;
    elseif module.Name == "Signaler" then
        self._signaler = module;
    end
end
function mandatory_closing:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._timer_id then
        now = core.host:execute("getServerTime");
        if self._tz ~= nil then
            now = core.host:execute("convertTime", core.TZ_EST, self._tz.Selected_timezone, now);
        end
        -- get only time
        now = now - math.floor(now);
        
        -- check whether the time is in the exit time period
        if now >= self._exit_time and now < self._exit_time + (self._interval / 86400.0) then
            if not checkReady("trades") then
                return ;
            end  
            if haveTrades("B") then
                exitSpecific("B");
                if self._signaler ~= nil then
                    self._signaler:Signal("Close Long");
                end
            end
                    
            if haveTrades("S") then
                exitSpecific("S");
                if self._signaler ~= nil then
                    self._signaler:Signal("Close Short");
                end
            end
        end
    end
end
mandatory_closing:RegisterModule(Modules);
function Init()
    strategy:name("MVA DNC Cross Strategy");
    strategy:description("MVA DNC Cross Strategy");
    strategy.parameters:addInteger("DNC_N", "DNC periods", "", 20);
    strategy.parameters:addInteger("MVA_N", "MVA periods short", "", 7);
    strategy.parameters:addInteger("MVA_N_2", "MVA periods long", "", 20);
    trading:Init(strategy.parameters);
    trading_logic:Init(strategy.parameters);
    trading_time:Init(strategy.parameters);
    mandatory_closing:Init(strategy.parameters);
end
local indicator_1 = nil;
local indicator_2 = nil;
local indicator_3 = nil;
function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then return ; end
    assert(core.indicators:findIndicator("DNC") ~= nil, "Please, download and install DNC indicator");
    assert(core.indicators:findIndicator("MVA") ~= nil, "Please, download and install MVA indicator");
    indicator_1 = core.indicators:create("DNC", trading_logic.MainSource, instance.parameters.DNC_N);
    indicator_2 = core.indicators:create("MVA", trading_logic.MainSource, instance.parameters.MVA_N);
    indicator_3 = core.indicators:create("MVA", trading_logic.MainSource, instance.parameters.MVA_N_2);
    trading.CustomID = "DNC_MVA";
    trading_logic.DoTrading = EntryFunction;
end
local _request_id = nil;
local _used_stop_orders = {};
function CreateStopOrder(stop_rate, trade)
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
        _request_id = msg;
    end
end

function ChangeStopOrder(stop_rate, order)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(stop_rate - order.Rate) > min_change then
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.Rate = stop_rate;

        local success, msg = terminal:execute(200, valuemap);
        if not(success) then
            terminal:alertMessage(order.Instrument, stop_rate, "Failed change stop " .. msg, core.now());
        end
    end
end

function IsStopOrderType(order_type)
    return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE";
end

function FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
        elseif _request_id ~= nil then
            local order = core.host:findTable("orders"):find("RequestID", _request_id);
            if order ~= nil then
                order_id = order.OrderID;
                _request_id = nil;
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
            if row.ContingencyType == 3 and IsStopOrderType(row.Type) and _used_stop_orders[row.OrderID] ~= true then
                _used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end
function MoveStop(stop_rate, trade)
	local order = FindStopOrder(trade);
	if order == nil then
		CreateStopOrder(stop_rate, trade);
	else
		ChangeStopOrder(stop_rate, order);
	end
end
function EntryFunction(source, period)
    indicator_1:update(core.UpdateLast);
    indicator_2:update(core.UpdateLast);
    indicator_3:update(core.UpdateLast);
    if not indicator_1.DATA:hasData(period) or not indicator_2.DATA:hasData(period - 1) or not indicator_3.DATA:hasData(period - 1) then
        return;
    end

    local _v1 = trading_logic:GetLastPeriod(period, source, indicator_2.DATA);
    local _v2 = trading_logic:GetLastPeriod(period, source, indicator_3.DATA);
    if ((_v1 ~= nil and _v2 ~= nil) and (indicator_2.DATA:size() >= 2 and indicator_3.DATA:size() >= 2 and core.crossesOver(indicator_2.DATA, indicator_3.DATA, _v1, _v2))) then
        local trade = trading:FindFirstPosition(source:instrument(), "B", nil, trading.CustomID);
        if trade ~= nil then
            MoveStop(indicator_1.DN:tick(NOW), trade);
        else
            trading:DeleteOrders(trading.CustomID);
            trading:CreateEntryOrderCustom(source:instrument(), "B", indicator_1.DU:tick(NOW), nil, nil, false, nil, nil, false, indicator_1.DN:tick(NOW), nil, trading.CustomID);
        end
    end
    if ((_v1 ~= nil and _v2 ~= nil) and (indicator_2.DATA:size() >= 2 and indicator_3.DATA:size() >= 2 and core.crossesUnder(indicator_2.DATA, indicator_3.DATA, _v1, _v2))) then
        local trade = trading:FindFirstPosition(source:instrument(), "S", nil, trading.CustomID);
        if trade ~= nil then
            MoveStop(indicator_1.DU:tick(NOW), trade);
        else
            trading:DeleteOrders(trading.CustomID);
            trading:CreateEntryOrderCustom(source:instrument(), "S", indicator_1.DN:tick(NOW), nil, nil, false, nil, nil, false, indicator_1.DU:tick(NOW), nil, trading.CustomID);
        end
    end
end
function ExtUpdate(id, source, period) for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
