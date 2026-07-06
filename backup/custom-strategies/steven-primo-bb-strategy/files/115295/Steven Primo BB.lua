-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65157
-- Id: 19215
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=65157

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
trading.Version = "1.5.4";
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
function trading:EntryOrder(instrument)
    local builder = {};
    builder.Offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OfferID = builder.Offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:SetDefaultAmount()
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        self.valuemap.Quantity = self.Parent:calculateAmount() * base_size;
        return self;
    end
    function builder:SetAmount(amount)
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        self.valuemap.Quantity = amount * base_size;
        return self;
    end
    function builder:SetBuySell(buy_sell)
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
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and -stop or stop;
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
    function builder:SetCustomId(custom_id)
        self.valuemap.CustomID = custom_id;
        return self;
    end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s %s for %s at %f", self.valuemap.BuySell, self.valuemap.OrderType, self.Instrument, self.valuemap.Rate));
        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return false;
            end
        end
        if not self.Parent._allow_trade then
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(string.format("%s signal for %s", self.valuemap.BuySell, self.Instrument));
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
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal("Open order failed: " .. msg);
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
    function builder:SetBuySell(buy_sell)
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
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:SetStop(stop)
        self.valuemap.RateStop = stop;
        return self;
    end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return false;
            end
        end
        if not self.Parent._allow_trade then
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(string.format("%s signal for %s", self.valuemap.BuySell, self.Instrument));
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
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal("Open order failed: " .. msg);
            end
            return false;
        end
        return true;
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
    strategy:name("Steven Primo BB");
    strategy:description("Steven Primo's New and Advanced Ways to Trade Bollinger Band");
    strategy.parameters:addInteger("mva_n", "MVA periods", "", 50);
    strategy.parameters:addInteger("N1", "Number of periods for Top Midline", "", 20, 1, 10000);
    strategy.parameters:addInteger("N2", "Number of periods for Bottom Midline", "", 20, 1, 10000);
    strategy.parameters:addDouble("D1", "Deviation for Top Line", "", 2.0, 0.00001, 10000);
    strategy.parameters:addDouble("D2", "Deviation for Bottom Line", "", 2.0, 0.00001, 10000);
    strategy.parameters:addInteger("D1_Period", "Period for Top Line Deviation", "", 20, 1, 10000);
    strategy.parameters:addInteger("D2_Period", "Period for Bottom Line Deviation", "", 20, 1, 10000);
    strategy.parameters:addInteger("pivot_bars", "Number of pivot bars", "", 5, 1, 10000);

    trading_logic:Init(strategy.parameters);
    trading:Init(strategy.parameters);
end
local mva = nil;
local bb = nil;
local pivot = nil;
function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then return ; end
    assert(core.indicators:findIndicator("MVA") ~= nil, "Please, download and install MVA indicator");
    assert(core.indicators:findIndicator("FULLY CUSTOMIZABLE BOLLINGER BAND") ~= nil, "Please, download and install FULLY CUSTOMIZABLE BOLLINGER BAND indicator");
    assert(core.indicators:findIndicator("PIVOT_SIGNAL") ~= nil, "Please, download and install PIVOT_SIGNAL indicator");
    mva = core.indicators:create("MVA", trading_logic.MainSource, instance.parameters.mva_n);
    bb = core.indicators:create("FULLY CUSTOMIZABLE BOLLINGER BAND", trading_logic.MainSource, 
        instance.parameters.N1, instance.parameters.N2, instance.parameters.D1, instance.parameters.D2,
        instance.parameters.D1_Period, instance.parameters.D2_Period);
    pivot = core.indicators:create("PIVOT_SIGNAL", trading_logic.MainSource, instance.parameters.pivot_bars);
    trading_logic.DoTrading = EntryFunction;
end
function EntryFunction(source, period)
    mva:update(core.UpdateLast);
    bb:update(core.UpdateLast);
    pivot:update(core.UpdateLast);
    local _v1 = trading_logic:GetLastPeriod(period, source, source.close);
    if _v1 == nil then
        return;
    end
    local _v2 = trading_logic:GetLastPeriod(period, source, mva.DATA);
    local _v3 = trading_logic:GetLastPeriod(period, source, pivot.High);
    local _v4 = trading_logic:GetLastPeriod(period, source, bb.Top);
    if ((_v1 ~= nil and _v2 ~= nil and _v3 ~= nil and _v4 ~= nil) and (source.close:tick(_v1) > mva.DATA:tick(_v2) and pivot.High:tick(_v3) ~= nil and pivot.High:tick(_v3) >= bb.Top:tick(_v4))) then
        trading:EntryOrder(source:instrument()):SetBuySell("B"):SetDefaultAmount():SetRate(pivot.High:tick(_v3) + source:pipSize()):Execute();
    end
    if source.close:tick(_v1) < bb.Top:tick(_v4) then
        trading:CloseSideForInstrument(source:instrument(), "B");
        trading:DeleteOrders();
    end
    print(4);
    local _v5 = trading_logic:GetLastPeriod(period, source, pivot.Low);
    local _v6 = trading_logic:GetLastPeriod(period, source, bb.Bottom);
    if ((_v1 ~= nil and _v2 ~= nil and _v5 ~= nil and _v6 ~= nil) and (source.close:tick(_v1) < mva.DATA:tick(_v2) and pivot.Low:tick(_v5) ~= nil and pivot.Low:tick(_v5) <= bb.Bottom:tick(_v6))) then
        trading:EntryOrder(source:instrument()):SetBuySell("S"):SetDefaultAmount():SetRate(pivot.Low:tick(_v5) - source:pipSize()):Execute();
    end
    print(5);
    if source.close:tick(_v1) > bb.Bottom:tick(_v4) then
        trading:CloseSideForInstrument(source:instrument(), "S");
        trading:DeleteOrders();
    end
    print(6);
end
function ExtUpdate(id, source, period) for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
