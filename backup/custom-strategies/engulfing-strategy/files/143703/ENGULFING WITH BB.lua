-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=69984
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69809

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
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
    indicator.parameters:addStringAlternative(id, "Regression", "", "REGRESSION");
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA" or method == "REGRESSION"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end
function Init()
	indicator:name("Engulfing Bar")
	indicator:description("Bar Helper")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("Complet", "Use Complet candle", "", false)
	indicator.parameters:addBoolean("Same", "Same Color Filter", "", false)
	indicator.parameters:addBoolean("ma", "MA Filter", "", false)
	indicator.parameters:addBoolean("bb_filter", "BB Filter", "", false)
	indicator.parameters:addInteger("bb_period", "BB Period", "", 14, 2, 1000);
	indicator.parameters:addDouble("bb_deviations", "BB Deviations", "", 2.0, 0.1, 1000);

	indicator.parameters:addString("Show", "Up/Down Trend Filter", "", "Both")
	indicator.parameters:addStringAlternative("Show", "Both", "", "Both")
	indicator.parameters:addStringAlternative("Show", "Up", "", "Up")
	indicator.parameters:addStringAlternative("Show", "Down", "", "Down")

	indicator.parameters:addInteger("Period", "MA Period", "Period", 50)
	indicator.parameters:addString("Method", "MA Method", "Method", "MVA")
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")
	indicator.parameters:addBoolean("use_color_filter", "User Color Filter", "Red for bullish, green for bearish", true)
    indicator.parameters:addBoolean("use_ma_filter", "Use MA Filter", "", true);
    indicator.parameters:addInteger("ma_filter_period", "MA Filter Period", "", 14);
    AddAverages("ma_filter_method", "MA Filter Method", "MVA");

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("Top", "Color of Bullish bar", "Color of Bullish bar", core.rgb(255, 0, 255))
	indicator.parameters:addColor("Bottom", "Color of Bearish bar", "Color of Bearish bar", core.rgb(0, 0, 0))
	indicator.parameters:addString("Type", "Presentation Type", "", "Arrows")
	indicator.parameters:addStringAlternative("Type", "Arrows", "", "Arrows")
	indicator.parameters:addStringAlternative("Type", "Candles Color", "", "Color")
	indicator.parameters:addStringAlternative("Type", "Background", "", "bg")
	indicator.parameters:addColor("UP", "Color of Up Candle", "Color of Up Candle", core.COLOR_UPCANDLE)
	indicator.parameters:addColor("DOWN", "Color of Down Candle", "Color of Down Candle", core.COLOR_DOWNCANDLE)
	indicator.parameters:addInteger("Transparency", "Background transparency (%)", "", 80, 0, 100);
end

local UP, DOWN
local Method
local first
local source = nil
local ma, MA
-- Streams block
local up = nil
local down = nil
local Period
local Same = nil
local Bar = nil
local Type
local open = nil
local close = nil
local high = nil
local low = nil
local Complet
local Show
local bb, ma_filter
-- Routine
function Prepare(nameOnly)
	source = instance.source
	Complet = instance.parameters.Complet
	Type = instance.parameters.Type
	Same = instance.parameters.Same
	Method = instance.parameters.Method
	ma = instance.parameters.ma
	UP = instance.parameters.UP
	DOWN = instance.parameters.DOWN
	Period = instance.parameters.Period
	Show = instance.parameters.Show

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if (nameOnly) then
		return
	end
    if instance.parameters.use_ma_filter then
        ma_filter = CreateAverages(instance.parameters.ma_filter_period, instance.parameters.ma_filter_method, source);
    end

	if instance.parameters.bb_filter then
		bb = core.indicators:create("BB", source, instance.parameters.bb_period, instance.parameters.bb_deviations);
	end
	MA = core.indicators:create(Method, source.close, Period)

	first = MA.DATA:first()

	if Type == "Arrows" then
		down = instance:createTextOutput("Up", "Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.Bottom, 0)
		up = instance:createTextOutput("Down", "Down", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.Top, 0)
	elseif Type == "Color" then
		open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
		high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
		low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
		close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
		instance:createCandleGroup("Bars", "", open, high, low, close)
	end
	instance:ownerDrawn(true);
end

local up_pen = 1;
local up_brush = 2;
local down_pen = 3;
local down_brush = 4;
local init = false;
local Transparency;
function Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    if not init then
        context:createPen(up_pen, context.SOLID, 1, UP);
        context:createSolidBrush(up_brush, UP);
        context:createPen(down_pen, context.SOLID, 1, DOWN);
		context:createSolidBrush(down_brush, DOWN);
		Transparency = context:convertTransparency(instance.parameters.Transparency);
        init = true;
	end
	
	if Type == "bg" then
		for p = context:firstBar(), context:lastBar(), 1 do
			local signal = GetSignal(p);
			if signal == 1 then
				local x, x1, x2 = context:positionOfBar(p);
				local _, y1 = context:pointOfPrice(source.high[p]);
				local _, y2 = context:pointOfPrice(source.low[p]);
				context:drawRectangle(up_pen, up_brush, x1, y1, x2, y2, Transparency);
			elseif signal == -1 then
				local x, x1, x2 = context:positionOfBar(p);
				local _, y1 = context:pointOfPrice(source.high[p]);
				local _, y2 = context:pointOfPrice(source.low[p]);
				context:drawRectangle(down_pen, down_brush, x1, y1, x2, y2, Transparency);
			end
		end
	end
	local hh = source.high[NOW];
	local ll = source.low[NOW];
	for p = source:size() - 1, 0, -1 do
		local signal = GetSignal(p);
		if signal ~= 0 then
			local x, x1, x2 = context:positionOfBar(p);
			if source.high[p] >= hh then
				local _, y1 = context:pointOfPrice(source.high[p]);
				context:drawLine(up_pen, x, y1, context:right(), y1);
			end
			if source.low[p] <= ll then
				local _, y1 = context:pointOfPrice(source.low[p]);
				context:drawLine(down_pen, x, y1, context:right(), y1);
			end
		end
		hh = math.max(hh, source.high[p]);
		ll = math.min(ll, source.low[p]);
	end
end

function GetSignal(period)
	if period < first + 1 then
		return nil;
	end
	if Same and
			((source.close[period] > source.open[period] and source.close[period - 1] < source.open[period - 1]) or
				(source.close[period] < source.open[period] and source.close[period - 1] > source.open[period - 1]))
	then
		return nil;
	end

	local Filter = nil
	if ma then
		MA:update(mode)
		if source.close[period] > MA.DATA[period] then
			Filter = true
		elseif source.close[period] < MA.DATA[period] then
			Filter = false
		end
	end

	if (B1(period) or B2(period)) 
		and (Filter == nil or Filter == true) 
		and Show ~= "Down" 
		and (not use_color_filter or source.close[period] < source.open[period])
		and (bb == nil or source.low[period] <= bb.BL[period])
		and (ma_filter == nil or source.low[period] <= ma_filter.DATA[period])
	then
		return 1;
	end

	if (S1(period) or S2(period)) 
		and (Filter == nil or Filter == false) 
		and Show ~= "Up" 
		and (not use_color_filter or source.close[period] > source.open[period])
		and (bb == nil or source.high[period] >= bb.TL[period])
		and (ma_filter == nil or source.high[period] >= ma_filter.DATA[period])
	then
		return -1;
	end
	return nil;
end

function Update(period, mode)
	if bb ~= nil then
		bb:update(mode);
	end
    if ma_filter ~= nil then
        ma_filter:update(core.UpdateLast);
    end
	if Type == "Arrows" then
		up:setNoData(period)
		down:setNoData(period)
		local signal = GetSignal(period);
		if signal == 1 then
			up:set(period, source.low[period], "\225")
		elseif signal == -1 then
			down:set(period, source.high[period], "\226")
		end
	elseif Type == "Color" then
		high[period] = source.high[period]
		low[period] = source.low[period]
		close[period] = source.close[period]
		open[period] = source.open[period]

		if source.close[period] > source.open[period] then
			open:setColor(period, UP)
		else
			open:setColor(period, DOWN)
		end
		local signal = GetSignal(period);
		if signal == 1 then
			open:setColor(period, instance.parameters.Top)
		elseif signal == -1 then
			open:setColor(period, instance.parameters.Bottom)
		end
	end
end

function B1(period)
	if not Complet then
		return false
	end

	if source.low[period] <= math.min(source.low[period - 1], source.high[period - 1]) and
			source.close[period] > math.max(source.low[period - 1], source.high[period - 1])
	then
		return true
	end
end

function S1(period)
	if not Complet then
		return false
	end

	if source.high[period] >= math.max(source.low[period - 1], source.high[period - 1]) and
			source.close[period] < math.min(source.low[period - 1], source.high[period - 1])
	then
		return true
	end
end

function B2(period)
	if Complet then
		return false
	end

	if source.open[period] <= math.min(source.open[period - 1], source.close[period - 1]) and
			source.close[period] > math.max(source.open[period - 1], source.close[period - 1])
	then
		return true
	end
end

function S2(period)
	if Complet then
		return false
	end

	if source.open[period] >= math.max(source.open[period - 1], source.close[period - 1]) and
			source.close[period] < math.min(source.open[period - 1], source.close[period - 1])
	then
		return true
	end
end
