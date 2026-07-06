
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65015http://fxcodebase.com/code/viewtopic.php?f=31&t=65015

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

local Modules = {};
trading = {};
trading.Name = "Trading";
trading.Version = "1.4.2";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopLimitParameters = true;
trading.AddDirectionParameter = true;
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
    if self.AddStopLimitParameters then
        parameters:addBoolean("set_limit", "Set Limit Orders", "", false);
        parameters:addInteger("limit", "Limit Order in pips", "", 30);
        parameters:addBoolean("set_stop", "Set Stop Orders", "", false);
        parameters:addInteger("stop", "Stop Order in pips", "", 30);
        parameters:addBoolean("trailing_stop", "Trailing stop order", "", false);
        parameters:addInteger("trailing", "Trailing in pips", "", 1);
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
    if self.AddStopLimitParameters then
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
        if valuemap.BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -limit;
        end
    end
    if stop ~= nil then
        valuemap.PegTypeStop = stop_type or "O";
        if valuemap.BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -stop;
        else
            valuemap.PegPriceOffsetPipsStop = stop;
        end
        valuemap.TrailStepStop = trailing_stop;
    end
    for _, module in pairs(self._all_modules) do
        if module.BlockOrder ~= nil and module:BlockOrder(valuemap) then
            self:trace("Creation of order blocked by " .. module.Name);
            return;
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
            return;
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
function Init()
    strategy:name("TD Lines Strategy");
    strategy:description("TD Lines Strategy");
    strategy.parameters:addBoolean("td_lines_price_type", "TD lines price type", "desc", true);
    strategy.parameters:setFlag("td_lines_price_type", core.FLAG_BIDASK);
    strategy.parameters:addString("td_lines_timeframe", "TD lines timeframe", "desc", "H4");
    strategy.parameters:setFlag("td_lines_timeframe", core.FLAG_PERIODS);
    strategy.parameters:addString("action_1", "Action on Color Line Up crossing over", "", "none");
    strategy.parameters:addStringAlternative("action_1", "None", "", "none");
    strategy.parameters:addStringAlternative("action_1", "Buy", "", "buy");
    strategy.parameters:addStringAlternative("action_1", "Sell", "", "sell");
    strategy.parameters:addStringAlternative("action_1", "Exit", "", "exit");
    strategy.parameters:addString("action_2", "Action on Color Line Up crossing under", "", "none");
    strategy.parameters:addStringAlternative("action_2", "None", "", "none");
    strategy.parameters:addStringAlternative("action_2", "Buy", "", "buy");
    strategy.parameters:addStringAlternative("action_2", "Sell", "", "sell");
    strategy.parameters:addStringAlternative("action_2", "Exit", "", "exit");
    strategy.parameters:addString("action_3", "Action on Color Line Dn crossing over", "", "none");
    strategy.parameters:addStringAlternative("action_3", "None", "", "none");
    strategy.parameters:addStringAlternative("action_3", "Buy", "", "buy");
    strategy.parameters:addStringAlternative("action_3", "Sell", "", "sell");
    strategy.parameters:addStringAlternative("action_3", "Exit", "", "exit");
    strategy.parameters:addString("action_4", "Action on Color Line Dn crossing under", "", "none");
    strategy.parameters:addStringAlternative("action_4", "None", "", "none");
    strategy.parameters:addStringAlternative("action_4", "Buy", "", "buy");
    strategy.parameters:addStringAlternative("action_4", "Sell", "", "sell");
    strategy.parameters:addStringAlternative("action_4", "Exit", "", "exit");
    strategy.parameters:addString("action_5", "Action on On target line cross", "", "none");
    strategy.parameters:addStringAlternative("action_5", "None", "", "none");
    strategy.parameters:addStringAlternative("action_5", "Buy", "", "buy");
    strategy.parameters:addStringAlternative("action_5", "Sell", "", "sell");
    strategy.parameters:addStringAlternative("action_5", "Exit", "", "exit");
    trading:Init(strategy.parameters);
    trading_logic:Init(strategy.parameters);
end
local indicator_1 = nil;
local instrument_1 = nil;
local instrument_1_id = 1;
function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then return ; end
    assert(core.indicators:findIndicator("TDL") ~= nil, "Please, download and install TDL indicator");
    instrument_1 = ExtSubscribe(instrument_1_id, nil, instance.parameters.td_lines_timeframe, instance.parameters.td_lines_price_type, "bar");
    indicator_1 = core.indicators:create("TDL", instrument_1, false, true);
    trading_logic.DoTrading = EntryFunction;
end
local last_serial = nil;
function EntryFunction(source, period)
    indicator_1:update(core.UpdateLast);
    if not indicator_1.Target:hasData(period - 1) then
        return;
    end
    local _v1 = trading_logic:GetLastPeriod(period, source, source.close);
    local _v4 = trading_logic:GetLastPeriod(period, source, indicator_1.Target);
    if ((_v1 ~= nil and _v4 ~= nil) and (source.close:size() >= 3 and indicator_1.Target:size() >= 1 and core.crosses(source.close, indicator_1.Target:tick(_v4), _v1))) then
        DoAction(source:instrument(), instance.parameters.action_5);
    end
	if last_serial == indicator_1.Top:serial(NOW) then
        return;
    end
    local _v2 = trading_logic:GetLastPeriod(period, source, indicator_1.Top);
    if ((_v1 ~= nil and _v2 ~= nil) and (source.close:size() >= 3 and indicator_1.Top:size() >= 2 and core.crossesOver(source.close, indicator_1.Top, _v1, _v2))) then
        if DoAction(source:instrument(), instance.parameters.action_1) then
            last_serial = indicator_1.Top:serial(NOW);
        end
    end
    if ((_v1 ~= nil and _v2 ~= nil) and (source.close:size() >= 3 and indicator_1.Top:size() >= 2 and core.crossesUnder(source.close, indicator_1.Top, _v1, _v2))) then
        if DoAction(source:instrument(), instance.parameters.action_2) then
            last_serial = indicator_1.Top:serial(NOW);
        end
    end
    local _v3 = trading_logic:GetLastPeriod(period, source, indicator_1.Bottom);
    if ((_v1 ~= nil and _v3 ~= nil) and (source.close:size() >= 3 and indicator_1.Bottom:size() >= 2 and core.crossesOver(source.close, indicator_1.Bottom, _v1, _v3))) then
        if DoAction(source:instrument(), instance.parameters.action_3) then
            last_serial = indicator_1.Top:serial(NOW);
        end
    end
    if ((_v1 ~= nil and _v3 ~= nil) and (source.close:size() >= 3 and indicator_1.Bottom:size() >= 2 and core.crossesUnder(source.close, indicator_1.Bottom, _v1, _v3))) then
        if DoAction(source:instrument(), instance.parameters.action_4) then
            last_serial = indicator_1.Top:serial(NOW);
        end
    end
    local _v4 = trading_logic:GetLastPeriod(period, source, indicator_1.Target);
    if ((_v1 ~= nil and _v4 ~= nil) and (source.close:size() >= 3 and indicator_1.Target:size() >= 1 and core.crosses(source.close, indicator_1.Target:tick(_v4), _v1))) then
        if DoAction(source:instrument(), instance.parameters.action_5) then
            last_serial = indicator_1.Top:serial(NOW);
        end
    end
end
function DoAction(instrument, action)
    if action == "buy" then
        return trading:CreateMarketOrder(instrument, "B");
    elseif action == "sell" then
        return trading:CreateMarketOrder(instrument, "S");
    elseif action == "exit" then
        return trading:CloseAllForInstrument(instrument);
    end
    return false;
end
function ExtUpdate(id, source, period) for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
