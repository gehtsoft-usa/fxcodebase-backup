-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65006

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
trading = {};
trading.Name = "Trading";
trading.Version = "1.4";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopLimitParameters = false;
trading.AddDirectionParameter = false;

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
    local enum = core.host:findTable("accounts"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        self:CloseSideForInstrumentAndAccount(instrument, "B", row.AccountID);
        self:CloseSideForInstrumentAndAccount(instrument, "S", row.AccountID);
        row = enum:next();
    end
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
        return true;
    end
    self:trace(string.format("Closing all positions for instrument %s", tostring(instrument)));
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "CM";
    valuemap.OfferID = offer.OfferID;
    valuemap.BuySell = side;
    valuemap.AcctID = account_id;
    valuemap.NetQtyFlag = "y";
    local success, msg = terminal:execute(100, valuemap);
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
trading_logic.Version = "1.1";
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
    if source_period < 0 then
        return nil;
    end
    local s1, e1 = core.getcandle(source:barSize(), source:date(source_period), -7, 0);
    local s2, e2 = core.getcandle(target:barSize(), target:date(NOW), -7, 0);
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
    --do what you usually do in prepare
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
    strategy:name("BB MACD Strategy");
    strategy:description("BB MACD Strategy");
    trading:Init(strategy.parameters);
    trading_logic:Init(strategy.parameters);
end
local indicator_1 = nil;
local indicator_2 = nil;
local indicator_3 = nil;
local indicator_4 = nil;
function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then return ; end
    assert(core.indicators:findIndicator("MACD") ~= nil, "Please, download and install MACD indicator");
    assert(core.indicators:findIndicator("BB") ~= nil, "Please, download and install BB indicator");
    assert(core.indicators:findIndicator("RSI") ~= nil, "Please, download and install RSI indicator");
    assert(core.indicators:findIndicator("AVERAGE DAILY RANGE OSCILLATOR") ~= nil, "Please, download and install AVERAGE DAILY RANGE OSCILLATOR indicator");
    indicator_1 = core.indicators:create("MACD", trading_logic.MainSource, 12, 26, 9);
    indicator_2 = core.indicators:create("BB", trading_logic.MainSource, 12, 2);
    indicator_3 = core.indicators:create("RSI", trading_logic.MainSource);
    indicator_4 = core.indicators:create("AVERAGE DAILY RANGE OSCILLATOR", trading_logic.MainSource, "D1", 7, 1);
    trading_logic.DoTrading = EntryFunction;
end
function EntryFunction(source, period)
    indicator_1:update(core.UpdateLast);
    indicator_2:update(core.UpdateLast);
    indicator_3:update(core.UpdateLast);
    indicator_4:update(core.UpdateLast);
    if not indicator_1.MACD:hasData(period) 
        or not indicator_1.SIGNAL:hasData(period) 
        or not indicator_2.TL:hasData(period) 
        or not indicator_3.DATA:hasData(period) 
        or not indicator_4.ADR:hasData(NOW)
    then
        return;
    end
    if ((indicator_1.MACD:tick(trading_logic:GetLastPeriod(period, source, indicator_1.MACD)) > indicator_1.SIGNAL:tick(trading_logic:GetLastPeriod(period, source, indicator_1.SIGNAL)) and indicator_1.MACD:tick(trading_logic:GetLastPeriod(period, source, indicator_1.MACD)) > 0.0 and (source.close:size() >= 3 and indicator_2.TL:size() >= 2 and core.crossesOverOrTouch(source.close, indicator_2.TL, trading_logic:GetLastPeriod(period, source, source.close))) and indicator_3.DATA:tick(trading_logic:GetLastPeriod(period, source, indicator_3.DATA)) >= 70.0 and indicator_2.TL:tick(trading_logic:GetLastPeriod(period, source, indicator_2.TL)) > indicator_2.TL:tick(trading_logic:GetLastPeriod(period - 1, source, indicator_2.TL)))) then
        trading:CreateMarketOrderCustom(source:instrument(), "B", nil, nil, indicator_4.ADR:tick(NOW)*0.15, nil, indicator_4.ADR:tick(NOW)*0.1, nil);
    end
    if ((indicator_1.MACD:tick(trading_logic:GetLastPeriod(period, source, indicator_1.MACD)) < indicator_1.SIGNAL:tick(trading_logic:GetLastPeriod(period, source, indicator_1.SIGNAL)) and indicator_1.MACD:tick(trading_logic:GetLastPeriod(period, source, indicator_1.MACD)) < 0.0 and (source.close:size() >= 3 and indicator_2.BL:size() >= 2 and core.crossesUnderOrTouch(source.close, indicator_2.BL, trading_logic:GetLastPeriod(period, source, source.close))) and indicator_3.DATA:tick(trading_logic:GetLastPeriod(period, source, indicator_3.DATA)) <= 30.0 and indicator_2.TL:tick(trading_logic:GetLastPeriod(period, source, indicator_2.TL)) < indicator_2.TL:tick(trading_logic:GetLastPeriod(period - 1, source, indicator_2.TL)))) then
        trading:CreateMarketOrderCustom(source:instrument(), "S", nil, nil, indicator_4.ADR:tick(NOW)*0.15, nil, indicator_4.ADR:tick(NOW)*0.1, nil);
    end
    if ((indicator_1.MACD:size() >= 2 and indicator_1.SIGNAL:size() >= 2 and core.crossesUnder(indicator_1.MACD, indicator_1.SIGNAL, trading_logic:GetLastPeriod(period, source, indicator_1.MACD)))) then
        trading:CloseSideForInstrument(source:instrument(), "B");
    end
    if ((indicator_1.MACD:size() >= 2 and indicator_1.SIGNAL:size() >= 2 and core.crossesOver(indicator_1.MACD, indicator_1.SIGNAL, trading_logic:GetLastPeriod(period, source, indicator_1.MACD)))) then
        trading:CloseSideForInstrument(source:instrument(), "S");
    end
end
function ExtUpdate(id, source, period) for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
