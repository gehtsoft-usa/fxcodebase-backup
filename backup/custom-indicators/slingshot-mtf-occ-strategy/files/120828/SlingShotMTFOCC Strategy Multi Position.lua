-- Id: 22187
-- Id: 22194
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66599

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {};

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function Init()
    indicator:name("SlingShot + MTF + Open Close Cross Strategy");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("ae", "Show Aggressive Entry?, Or Use as Alert To Potential Conservative Entry?", "", true)
    indicator.parameters:addBoolean("sce", "Show Conservative Entry", "", true)
    indicator.parameters:addBoolean("st", "Show Trend Arrows at Top and Bottom of Screen", "", true)
    indicator.parameters:addBoolean("def", "Only Choose 1 - Either Conservative Entry Arrows or 'B'-'S' Letters", "", false);
    indicator.parameters:addBoolean("pa", "Show Conservative Entry Arrows?", "", true);
    indicator.parameters:addBoolean("sl", "Show 'B'-'S' Letters?", "", false);
    indicator.parameters:addBoolean("useRes", "Use Alternate Resolution? ( recommended )", "", true);
    indicator.parameters:addString("stratRes", "Set Resolution ( should not be lower than chart )", "", "H2");
    indicator.parameters:setFlag("stratRes", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("useMA", "Use MA? ( otherwise use simple Open/Close data )", "", true);
    AddAverages("basisType", "MA Type", "DEMA");
    indicator.parameters:addInteger("basisLen", "MA Period", "", 14);

    indicator.parameters:addBoolean("useCurrentRes", "Use Current Chart Resolution?", "", true);
    indicator.parameters:addString("resCustom", "Use Different Timeframe? Uncheck Box Above", "", "D1");
    indicator.parameters:setFlag("resCustom", core.FLAG_BARPERIODS);
    indicator.parameters:addInteger("len", "Moving Average Length - LookBack Period", "", 20);
    AddAverages("atype", "MA Type", "MVA");
    indicator.parameters:addBoolean("spc", "Show Price Crossing 1st Mov Avg - Highlight Bar?", "", false);
    indicator.parameters:addBoolean("cc", "Change Color Based On Direction?", "", true);
    indicator.parameters:addInteger("smoothe", "Color Smoothing - Setting 1 = No Smoothing", "", 2);
    indicator.parameters:addBoolean("cc2", "Change Color Based On Direction 2nd MA?", "", true);
    indicator.parameters:addBoolean("warn", "***You Can Turn On The Show Dots Parameter Below Without Plotting 2nd MA to See Crosses***", "", false);
    indicator.parameters:addBoolean("warn2", "***If Using Cross Feature W/O Plotting 2ndMA - Make Sure 2ndMA Parameters are Set Correctly***", "", false);
    indicator.parameters:addBoolean("sd", "Show Dots on Cross of Both MA's", "", false);

    indicator.parameters:addGroup("Trading");
    trading:Init(indicator.parameters);
    indicator.parameters:addGroup("Alert");
    signaler:Init(indicator.parameters);
end

local emaSlow;
local emaFast;
local p1;
local p2;
local source;
local avg;
local out1;
local basisType;
local res;
local basisType_open;
local basisType_close;
local trendState;
local src_loading = false;
local res_loading = false;
local o;
local h;
local l;
local c;
local trades = {};

function Prepare(onlyName)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    local name = profile:id();
    instance:name(name);
    if onlyName then
        return;
    end
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 

    source = instance.source;
    emaSlow = core.indicators:create("EMA", source.close, 62);
    emaFast = core.indicators:create("EMA", source.close, 38);

    p1 = instance:addStream("SlowMA", core.Line, "Slow", "Slow", core.colors().Yellow, emaSlow.DATA:first());
    p1:setWidth(4);
    p2 = instance:addStream("FastMA", core.Line, "Fast", "Fast", core.colors().Yellow, emaFast.DATA:first());
    p2:setWidth(2);
    pc1 = instance:addInternalStream(0, 0);
    pc2 = instance:addInternalStream(0, 0);
    instance:createChannelGroup("channel1", "channel1", pc1, pc2, core.colors().Silver, 70);
    out1 = instance:addStream("MTFMA", core.Line, "Multi-Timeframe Moving Avg", "Multi-Timeframe Moving Avg", core.colors().Yellow, 0);
    out1:setWidth(4);

    if not instance.parameters.useCurrentRes then
        src = core.host:execute("getSyncHistory", source:instrument(), instance.parameters.resCustom, source:isBid(), 0, 2000, 2100);
        avg = core.indicators:create("AVERAGES", src.close, instance.parameters.avg, instance.parameters.len);
        src_loading = true;
    else
        avg = core.indicators:create("AVERAGES", source.close, instance.parameters.avg, instance.parameters.len);
    end

    trendState = instance:addInternalStream(0, 0);
    closeSeries = instance:addStream("CS", core.Line, "Close Line", "Close Line", core.rgb(0, 128, 0), 0);
    closeSeries:setWidth(2);
    openSeries = instance:addStream("OS", core.Line, "Open Line", "Open Line", core.rgb(128, 0, 0), 0);
    openSeries:setWidth(2);
    if instance.parameters.useRes then
        res = core.host:execute("getSyncHistory", source:instrument(), instance.parameters.stratRes, source:isBid(), 0, 2001, 2101);
        res_loading = true;
    end
    if instance.parameters.useMA then
        if res ~= nil then
            basisType_open = core.indicators:create("AVERAGES", res.open, instance.parameters.basisType, instance.parameters.basisLen);
            basisType_close = core.indicators:create("AVERAGES", res.close, instance.parameters.basisType, instance.parameters.basisLen);
        else
            basisType_open = core.indicators:create("AVERAGES", source.open, instance.parameters.basisType, instance.parameters.basisLen);
            basisType_close = core.indicators:create("AVERAGES", source.close, instance.parameters.basisType, instance.parameters.basisLen);
        end
    end
    
    closePlotU = instance:addInternalStream(0, 0);
    openPlotU = instance:addInternalStream(0, 0);
    closePlotD = instance:addInternalStream(0, 0);
    openPlotD = instance:addInternalStream(0, 0);
    instance:createChannelGroup("channel2", "Up Trend Fill", closePlotU, openPlotU, core.rgb(0, 128, 0), 40);
    instance:createChannelGroup("channel3", "Down Trend Fill", openPlotD, openPlotD, core.rgb(128, 0, 0), 40);
    o = instance:addInternalStream(0, 0);
    h = instance:addInternalStream(0, 0);
    l = instance:addInternalStream(0, 0);
    c = instance:addInternalStream(0, 0);
    instance:createCandleGroup("candle", "candle", o, h, l, c);
    
    instance:ownerDrawn(true);

    for i = 1, 5 do
        local trade = {};
        trade.open = instance.parameters:getBoolean("open_" .. i);
        trade.amount = instance.parameters:getInteger("amount_" .. i);
        trade.set_limit = instance.parameters:getBoolean("set_limit_" .. i);
        trade.limit = instance.parameters:getInteger("limit_" .. i);
        trade.set_stop = instance.parameters:getBoolean("set_stop_" .. i);
        trade.stop = instance.parameters:getInteger("stop_" .. i);
        trade.use_trailing = instance.parameters:getBoolean("use_trailing_" .. i);
        trade.trailing = instance.parameters:getInteger("trailing_" .. i);
        trade.use_breakeven = instance.parameters:getBoolean("use_breakeven_" .. i);
        trade.breakeven_when = instance.parameters:getInteger("breakeven_when_" .. i);
        trades[#trades + 1] = trade;
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == 2101 then
        res_loading = true;
        instance:updateFrom(0);
    elseif cookie == 2001 then
        res_loading = false;
    elseif cookie == 2000 then
        src_loading = false;
        instance:updateFrom(0);
    elseif cookie == 2100 then
        src_loading = true;
    end
end

local LIME_PEN = 1;
local LIME_BRUSH = 2;
local RED_PEN = 3;
local RED_BRUSH = 4;
local YELLOW_PEN = 5;
local YELLOW_BRUSH = 6;
local init;

function ma_down(period)
    if period - instance.parameters.smoothe < 0 then
        return false;
    end
    return out1[period] < out1[period - instance.parameters.smoothe];
end

function get_trendState(period)
    if closeSeries[period] > openSeries[period] then
        return 1;
    end
    if closeSeries[period] < openSeries[period] then
        return -1;
    end
    if period == 0 then
        return 1;
    end
    return trendState[period - 1];
end

function Draw(stage, context)
    if stage ~= 0 then
        return;
    end

    if src_loading or res_loading then
        return;
    end

    if not init then
        context:createPen(LIME_PEN, context.SOLID, 1, core.colors().Lime);
        context:createSolidBrush(LIME_BRUSH, core.colors().Lime);
        context:createPen(RED_PEN, context.SOLID, 1, core.colors().Red);
        context:createSolidBrush(RED_BRUSH, core.colors().Red);
        context:createPen(YELLOW_PEN, context.SOLID, 1, core.colors().Yellow);
        context:createSolidBrush(YELLOW_BRUSH, core.colors().Yellow);
        init = true
    end

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());

    local first = math.max(source:first(), context:firstBar(), 1)
    local last = math.min(context:lastBar(), emaSlow.DATA:size() - 1, emaFast.DATA:size() - 1);

    for index = first, last, 1 do
        x, x1, x2 = context:positionOfBar(index)
        if core.crossesOver(emaFast.DATA, emaSlow.DATA, index) then
            context:drawRectangle(LIME_PEN, LIME_BRUSH, x1, context:top(), x2, context:bottom(), context:convertTransparency(30));
        elseif core.crossesUnder(emaFast.DATA, emaSlow.DATA, index) then
            context:drawRectangle(RED_PEN, RED_BRUSH, x1, context:top(), x2, context:bottom(), context:convertTransparency(30));
        elseif emaFast.DATA[index] < emaSlow.DATA[index] then
            context:drawRectangle(RED_PEN, RED_BRUSH, x1, context:top(), x2, context:bottom(), context:convertTransparency(85));
        elseif emaFast.DATA[index] > emaSlow.DATA[index] and ma_down(index) and get_trendState(index) ~= 1 then
            context:drawRectangle(YELLOW_PEN, YELLOW_BRUSH, x1, context:top(), x2, context:bottom(), context:convertTransparency(80));
        elseif emaFast.DATA[index] > emaSlow.DATA[index] then
            context:drawRectangle(LIME_PEN, LIME_BRUSH, x1, context:top(), x2, context:bottom(), context:convertTransparency(97));
        end
    end
end

local last_serial;
function Update(period, mode)
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(1, source, period); end end
    if src_loading or res_loading then
        return;
    end
    emaSlow:update(mode);
    emaFast:update(mode);
    avg:update(mode);
    p1[period] = emaSlow.DATA[period];
    p2[period] = emaFast.DATA[period];
    pc1[period] = emaSlow.DATA[period];
    pc2[period] = emaFast.DATA[period];
    if not emaSlow.DATA:hasData(period) or not emaFast.DATA:hasData(period) then
        return;
    end
    if emaFast.DATA[period] > emaSlow.DATA[period] then
        p1:setColor(period, core.colors().Lime);
        p2:setColor(period, core.colors().Lime);
    elseif emaFast.DATA[period] < emaSlow.DATA[period] then
        p1:setColor(period, core.colors().Red);
        p2:setColor(period, core.colors().Red);
    else
        p1:setColor(period, core.colors().Yellow);
        p2:setColor(period, core.colors().Yellow);
    end
    local index = core.findDate(out1, p1:date(period), false);
    if index ~= -1 then
        out1[period] = avg.DATA[index];
        local ma_up = out1[period] >= out1[period - instance.parameters.smoothe];
        if instance.parameters.cc then
            if ma_up then
                out1:setColor(period, core.colors().Lime);
            else
                out1:setColor(period, core.colors().Red);
            end
        else
            out1:setColor(period, core.colors().Aqua);
        end
    end
    
    if basisType_open ~= nil then
        basisType_open:update(mode);
        basisType_close:update(mode);
        if res ~= nil then
            local index = core.findDate(res, p1:date(period), false);
            if index ~= -1 then
                closeSeries[period] = basisType_close.DATA[index];
                openSeries[period] = basisType_open.DATA[index];
            end
        else
            closeSeries[period] = basisType_close.DATA[period];
            openSeries[period] = basisType_open.DATA[period]
        end
    else
        if res ~= nil then
            local index = core.findDate(res, p1:date(period), false);
            if index ~= -1 then
                closeSeries[period] = res.close[index];
                openSeries[period] = res.open[index];
            end
        else
            closeSeries[period] = source.close[period];
            openSeries[period] = source.open[period];
        end
    end
    trendState[period] = get_trendState(period);
    if trendState[period] == 1 then
        closePlotU[period] = closeSeries[period];
        openPlotU[period] = openSeries[period];
    else
        closePlotD[period] = closeSeries[period];
        openPlotD[period] = openSeries[period];
    end

    o[period] = source.open[period];
    h[period] = source.high[period];
    l[period] = source.low[period];
    c[period] = source.close[period];
    if closeSeries[period] > openSeries[period] then
        o:setColor(period, core.rgb(0, 128, 0));
    else
        o:setColor(period, core.rgb(128, 0, 0));
    end

    if period < source:size() - 1 or last_serial == source:serial(period) then
        return
    end
    if core.crossesOver(emaFast.DATA, emaSlow.DATA, period - 1) then
        if instance.parameters.allow_trade then
            if instance.parameters.close_on_opposite then
                trading:FindTrade()
                    :WhenSide("S")
                    :WhenCustomID(custom_id)
                    :Do(function (trade) trading:Close(trade); end );
            end
            if instance.parameters.position_cap then
                local positions = trading:FindTrade()
                    :WhenSide("B")
                    :WhenCustomID(custom_id)
                    :Count();
                if positions >= instance.parameters.no_of_positions then
                    signaler:Signal("Positions limit has been reached");
                    return;
                end
            end
            for i, trade in ipairs(trades) do
                if trade.open then
                    local command = trading:MarketOrder(source:instrument())
                        :SetSide("B")
                        :SetAccountID(instance.parameters.account)
                        :SetAmount(trade.amount)
                        :SetCustomID(custom_id);
                    if trade.set_stop then 
                        command = command:SetPipStop(nil, trade.stop, trade.use_trailing and trade.trailing or nil);
                    end
                    if trade.set_limit then 
                        command = command:SetLimitStop(nil, trade.limit);
                    end
                    local res = command:Execute();
                    if trade.use_breakeven then
                        breakeven:CreateController()
                            :SetWhen(trade.breakeven_when)
                            :SetTo(0)
                            :SetRequestID(res.RequestID);
                    end
                end
            end
        end
        signaler:Signal("Opening buy position");
        last_serial = source:serial(period);
    elseif core.crossesUnder(emaFast.DATA, emaSlow.DATA, period - 1) then
        if instance.parameters.allow_trade then
            if instance.parameters.close_on_opposite then
                trading:FindTrade()
                    :WhenSide("B")
                    :WhenCustomID(custom_id)
                    :Do(function (trade) trading:Close(trade); end );
            end
            if instance.parameters.position_cap then
                local positions = trading:FindTrade()
                    :WhenSide("S")
                    :WhenCustomID(custom_id)
                    :Count();
                if positions >= instance.parameters.no_of_positions then
                    signaler:Signal("Positions limit has been reached");
                    return;
                end
            end
            for i, trade in ipairs(trades) do
                if trade.open then
                    local command = trading:MarketOrder(source:instrument())
                        :SetSide("S")
                        :SetAccountID(instance.parameters.account)
                        :SetAmount(trade.amount)
                        :SetCustomID(custom_id);
                    if trade.set_stop then 
                        command = command:SetPipStop(nil, trade.stop, trade.use_trailing and trade.trailing or nil);
                        end
                    if trade.set_limit then 
                        command = command:SetPipLimit(nil, trade.limit);
                    end
                    local res = command:Execute();
                    if trade.use_breakeven then
                        breakeven:CreateController()
                            :SetWhen(trade.breakeven_when)
                            :SetTo(0)
                            :SetRequestID(res.RequestID);
                    end
                end
            end
        end
        signaler:Signal("Opening sell position");
        last_serial = source:serial(period);
    end
end

trading = {};
trading.Name = "Trading";
trading.Version = "4.6.0";
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

function AddTrade(i)
    indicator.parameters:addGroup("Trade " .. i);
    indicator.parameters:addBoolean("open_" .. i, "Open trade " .. i, "", false);
    indicator.parameters:addInteger("amount_" .. i, "Trade " .. i, "", 1, 1, 100);
    indicator.parameters:addBoolean("set_limit_" .. i, "Set Limit for Trade " .. i, "", false);
    indicator.parameters:addInteger("limit_" .. i, "Limit for Trade " .. i .. ", in pips", "", 30, 1, 10000);
    indicator.parameters:addBoolean("set_stop_" .. i, "Set Stop for Trade " .. i, "", false);
    indicator.parameters:addInteger("stop_" .. i, "Stop for Trade " .. i, "", 10, 1, 10000);
    indicator.parameters:addBoolean("use_trailing_" .. i, "Trailing Stop order for Trade " .. i, "", false);
    indicator.parameters:addInteger("trailing_" .. i, "Trailing for Trade " .. i .. ", in pips", "", 10);
    indicator.parameters:addBoolean("use_breakeven_" .. i, "Breakeaven for Trade " .. i, "", false);
    indicator.parameters:addInteger("breakeven_when_" .. i, "Min Profit for Trade " .. i, "", 10);
end

function trading:Init(parameters)
    parameters:addBoolean("allow_trade", "Allow strategy to trade", "", true);
    parameters:setFlag("allow_trade", core.FLAG_ALLOW_TRADE);
    parameters:addString("account", "Account to trade on", "", "");
    parameters:setFlag("account", core.FLAG_ACCOUNT);
    AddTrade(1);
    AddTrade(2);
    AddTrade(3);
    AddTrade(4);
    AddTrade(5);
    parameters:addBoolean("close_on_opposite", "Close on Opposite", "", true);
    parameters:addBoolean("position_cap", "Position Cap", "", false);
    parameters:addInteger("no_of_positions", "No of open positions", "", 1);

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
    for i = 1, 5 do
        local trade = {};
        trade.open = instance.parameters:getBoolean("open_" .. i);
        trade.amount = instance.parameters:getInteger("amount_" .. i);
        trade.set_limit = instance.parameters:getBoolean("set_limit_" .. i);
        trade.limit = instance.parameters:getInteger("limit_" .. i);
        trade.set_stop = instance.parameters:getBoolean("set_stop_" .. i);
        trade.stop = instance.parameters:getInteger("stop_" .. i);
        trade.use_trailing = instance.parameters:getBoolean("use_trailing_" .. i);
        trade.trailing = instance.parameters:getInteger("trailing_" .. i);
        trade.use_breakeven = instance.parameters:getBoolean("use_breakeven_" .. i);
        trade.breakeven_when = instance.parameters:getInteger("breakeven_when_" .. i);
        trades[#trades + 1] = trade;
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

function trading:CreateStopOrder(trade, stop_rate, trailing)
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

function trading:CreateLimitOrder(trade, limit_rate)
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

function trading:ChangeOrder(order, rate, trailing)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = trailing;
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

function trading:MoveStop(trade, stop_rate, trailing)
    local order = self:FindStopOrder(trade);
    if order == nil then
        if trailing == 0 then
            trailing = nil;
        end
        return self:CreateStopOrder(trade, stop_rate, trailing);
    else
        if trailing == 0 then
            if order.TrlMinMove ~= 0 then
                trailing = order.TrlMinMove
            else
                trailing = nil;
            end
        end
        return self:ChangeOrder(order, stop_rate, trailing);
    end
end

function trading:MoveLimit(trade, limit_rate)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(trade, limit_rate);
    else
        return self:ChangeOrder(order, limit_rate);
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

function trading:GetCustomID(qtxt)
    if qtxt == nil then
        return nil;
    end
    local metadata = self:GetMetadata(qtxt);
    if metadata == nil then
        return qtxt;
    end
    return metadata.CustomID;
end

function trading:FindOrder()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenRate(rate) self.Rate = rate; return self; end
    function search:WhenOrderType(orderType) self.OrderType = orderType; return self; end
    function search:Do(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then action(row); end
            row = enum:next();
        end
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
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
    function search:Do(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then action(row); end
            row = enum:next();
        end
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
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
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then 
                return true;
            end
            row = enum:next();
        end
        return false;
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
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return true;
            end
            row = enum:next();
        end
        return false;
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
    local id = self:getId();
    if account.Hedging == "Y" then
        local valuemap = core.valuemap();
        valuemap.BuySell = trade.BS == "B" and "S" or "B";
        valuemap.OrderType = "CM";
        valuemap.OfferID = trade.OfferID;
        valuemap.AcctID = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = math.min(amount, trade.Lot);
        local success, msg = terminal:execute(id, valuemap);
        if success then
            local res = trading:ClosePartialSuccessResult(msg);
            self._waiting_requests[id] = res;
            return res;
        end
        return trading:ClosePartialFailResult(msg);
    end

    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = math.min(amount, trade.Lot);
    valuemap.BuySell = trading:getOppositeSide(trade.BS);
    local success, msg = terminal:execute(id, valuemap);
    if success then
        local res = trading:ClosePartialSuccessResult(msg);
        self._waiting_requests[id] = res;
        return res;
    end
    return trading:ClosePartialFailResult(msg);
end

function trading:ClosePartialSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:ClosePartialFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    return res;
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

function trading:JsonToObject(json)
    local position = 1;
    local result;
    local results;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            if results ~= nil then
                position = position + 1;
                results[#results + 1] = result;
            else
                return result;
            end
        elseif ch == "," then
            position = position + 1;
        elseif ch == "[" then
            position = position + 1;
            results = {};
        elseif ch == "]" then
            return results;
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

function trading:GetMetadata(qtxt)
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

function trading:GetTradeMetadata(trade)
    return self:GetMetadata(trade.QTXT);
end

trading:RegisterModule(Modules);

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.3.0";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label, self:FormatEmail(source, NOW, label));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize());
    end

    if self._show_popup == true then
        local subject, text = self:FormatEmail(source, NOW, label);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end
signaler:RegisterModule(Modules);
breakeven = {};
-- public fields
breakeven.Name = "Breakeven";
breakeven.Version = "1.5.0";
breakeven.Debug = false;
breakeven.Default_breakeven_when = 2;
breakeven.Default_use_breakeven = false;
breakeven.Default_breaeven_to = 1;
--private fields
breakeven._breakeven_when = 2;
breakeven._use_breakeven = false;
breakeven._breaeven_to = 1;
breakeven._moved_stops = {};
breakeven._request_id = nil;
breakeven._used_stop_orders = {};
breakeven._ids_start = nil;
breakeven._source_id = nil;
breakeven._trading = nil;
breakeven._controllers = {};

function breakeven:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function breakeven:OnNewModule(module)
    if module.Name == "Trading" then self._trading = module; end
end
function breakeven:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function breakeven:Init(parameters)
    parameters:addBoolean("use_breakeven", "Use Breakeven", "", self.Default_use_breakeven);
    parameters:addDouble("breakeven_when", "Breakeven Activation Value, in pips", "", self.Default_breakeven_when);
    parameters:addDouble("breakeven_to", "Breakeven To, in pips", "", self.Default_breaeven_to);
end

function breakeven:Prepare(nameOnly)
    self._breakeven_when = instance.parameters.breakeven_when;
    self._use_breakeven = instance.parameters.use_breakeven;
    self._breaeven_to = instance.parameters.breakeven_to;
    if self._use_breakeven == nil or self._use_breakeven == true then
        self._source_id = self._ids_start + 1;
        --ExtSubscribe(self._source_id, nil, "t1", true, "tick");
    end
    self:trace(string.format("Use breakeven: %s. Profit for trigger breakeven: %s. Breakeven target: %s",
        tostring(self._use_breakeven), tostring(self._breakeven_when), tostring(self._breaeven_to)));
end

function breakeven:ExtUpdate(id, source, period)
    for _, controller in ipairs(self._controllers) do
        controller:DoBreakeven();
    end
end

function breakeven:CreateController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetTrade(trade)
        self._trade = trade;
        return self;
    end
    function controller:SetDynamicTo(dynamicTo)
        self._dynamicTo = dynamicTo;
        return self;
    end
    function controller:SetTo(to)
        self._to = to;
        return self;
    end
    function controller:SetTrailing(trailing)
        self._trailing = trailing
        return self;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
        end
        return self._trade;
    end
    function controller:getTo()
        local trade = self:GetTrade();
        if self._dynamicTo ~= nil then
            return self._dynamicTo(trade);
        end
        local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
        if trade.BS == "B" then
            return offer.Bid - (trade.PL - self._to) * offer.PointSize;
        else
            return offer.Ask + (trade.PL - self._to) * offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL >= self._when then
            self._parent._trading:MoveStop(trade, self:getTo(), self._trailing);
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateTrailingOnProfitController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    controller._trailing = 0;
    function controller:SetTrade(trade)
        self._trade = trade;
        return self;
    end
    function controller:SetProfitPercentage(profit_pr, min_profit)
        self._profit_pr = profit_pr;
        self._min_profit = min_profit;
        return self;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
        end
        return self._trade;
    end
    function controller:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self._request_id);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function controller:getStopPips(trade)
        local stop = trading:FindStopOrder(trade);
        if stop == nil then
            return nil;
        end
        local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
        if trade.BS == "B" then
            return (stop.Rate - trade.Open) / offer.PointSize;
        else
            return (trade.Open - stop.Rate) / offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        if self._move_command ~= nil and not self._move_command.Finished then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            if self:GetClosedTrade() ~= nil then
                self._executed = true;
            end
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL < self._min_profit then
            return true;
        end
        local new_stop = trade.PL * (self._profit_pr / 100);
        local current_stop = self:getStopPips(trade);
        if current_stop == nil or current_stop < new_stop then
            local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
            if trade.BS == "B" then
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open + new_stop * offer.PointSize);
            else
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open - new_stop * offer.PointSize);
            end
            return true;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end
breakeven:RegisterModule(Modules);