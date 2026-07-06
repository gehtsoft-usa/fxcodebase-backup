-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70389
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70389

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Traditional MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("MACD Settings");
    indicator.parameters:addInteger("FastEMA", "Fast EMA Period", "", 12);
    indicator.parameters:addInteger("SlowEMA", "Slow EMA Period", "", 26);
    indicator.parameters:addInteger("SignalEMA", "Signal EMA Period", "", 9);
    indicator.parameters:addBoolean("DisplayLines", "Display MACD and Signal lines", "", true)
    indicator.parameters:addBoolean("DisplayHistogram", "Display MACD Histogram", "", true)
    indicator.parameters:addInteger("lookback", "Look back this many bars for divergences", "", 10);

    indicator.parameters:addColor("macd_color", "MACD Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("macd_width", "MACD Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("macd_style", "MACD Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("macd_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("signal_color", "Signal Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("signal_width", "Signal Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("signal_style", "Signal Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("signal_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("HistogramRisingBull", "Histogram Rising Bull", "", core.colors().Lime);
    indicator.parameters:addColor("HistogramFallingBull", "Histogram Falling Bull", "", core.colors().DarkGreen);
    indicator.parameters:addColor("HistogramRisingBear", "Histogram Rising Bear", "", core.colors().Maroon);
    indicator.parameters:addColor("HistogramFallingBear", "Histogram Falling Bear", "", core.colors().Red);

    indicator.parameters:addGroup("Divergence Settings");
    indicator.parameters:addBoolean("ShowClassicDivergence", "Display Classic Divergence", "", true)
    indicator.parameters:addColor("CD_Bearish_color", "Classic Bearish Divergence Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("CD_Bearish_width", "Classic Bearish Divergence Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("CD_Bearish_style", "Classic Bearish Divergence Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("CD_Bearish_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("CD_Bullish_color", "Classic Bullish Divergence Color", "Color", core.colors().DarkGreen);
    indicator.parameters:addInteger("CD_Bullish_width", "Classic Bullish Divergence Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("CD_Bullish_style", "Classic Bullish Divergence Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("CD_Bullish_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("CD_DeleteCancelledLines", "Remove cancelled Classic Divergence lines", "", false)
    indicator.parameters:addInteger("CD_CacelledLine_width", "Cancelled Classic Divergence Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("CD_CacelledLine_style", "Cancelled Classic Divergence Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("CD_CacelledLine_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("ShowHiddenDivergence", "Display Hidden Divergence", "", true)
    indicator.parameters:addColor("HD_Bearish_color", "Hidden Bearish Divergence Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("HD_Bearish_width", "Hidden Bearish Divergence Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("HD_Bearish_style", "Hidden Bearish Divergence Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("HD_Bearish_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HD_Bullish_color", "Hidden Bullish Divergence Color", "Color", core.colors().DarkGreen);
    indicator.parameters:addInteger("HD_Bullish_width", "Hidden Bullish Divergence Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("HD_Bullish_style", "Hidden Bullish Divergence Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("HD_Bullish_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("HD_DeleteCancelledLines", "Remove cancelled Hidden Divergence lines", "", false)
    indicator.parameters:addInteger("HD_CacelledLine_width", "Cancelled Hidden Divergence Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("HD_CacelledLine_style", "Cancelled Hidden Divergence Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("HD_CacelledLine_style", core.FLAG_LINE_STYLE);
end

local source;
local FastEMA, SlowEMA, SignalEMA, DisplayLines, DisplayHistogram
local fast_ma, slow_ma, Histogram, signal, macd, CD_DeleteCancelledLines, HD_DeleteCancelledLines;
local HistogramRisingBull, HistogramFallingBull, HistogramRisingBear, HistogramFallingBear, SignalBuffer, ShowClassicDivergence, lookback
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    lookback = instance.parameters.lookback;
    HD_DeleteCancelledLines = instance.parameters.HD_DeleteCancelledLines;
    CD_DeleteCancelledLines = instance.parameters.CD_DeleteCancelledLines;
    FastEMA = instance.parameters.FastEMA;
    SlowEMA = instance.parameters.SlowEMA;
    SignalEMA = instance.parameters.SignalEMA;
    DisplayLines = instance.parameters.DisplayLines;
    DisplayHistogram = instance.parameters.DisplayHistogram;
    HistogramRisingBull = instance.parameters.HistogramRisingBull;
    HistogramFallingBull = instance.parameters.HistogramFallingBull;
    HistogramRisingBear = instance.parameters.HistogramRisingBear;
    HistogramFallingBear = instance.parameters.HistogramFallingBear;
    ShowClassicDivergence = instance.parameters.ShowClassicDivergence;
    fast_ma = core.indicators:create("EMA", source.close, FastEMA);
    slow_ma = core.indicators:create("EMA", source.close, SlowEMA);

	
	if DisplayLines then
    macd = instance:addStream("MACD", core.Line, "MACD", "MACD", instance.parameters.macd_color, 0, 0);
    macd:setWidth(instance.parameters.macd_width);
    macd:setStyle(instance.parameters.macd_style);
 
	else
	
	macd = instance:addInternalStream(0, 0);
	 
	end
	
	 signal_ma = core.indicators:create("EMA", macd, SlowEMA);

		
	if DisplayLines then
    
    signal = instance:addStream("Signal", core.Line, "Signal", "Signal", instance.parameters.signal_color, 0, 0);
    signal:setWidth(instance.parameters.signal_width);
    signal:setStyle(instance.parameters.signal_style);	
	else
	
 
	signal = instance:addInternalStream(0, 0);
	end
	
	
	if DisplayHistogram then
    Histogram = instance:addStream("Histogram", core.Bar, "Histogram", "Histogram", HistogramRisingBull, 0, 0);
	else
	Histogram = instance:addInternalStream(0, 0);
	end
	
    SignalBuffer = core.indicators:create("EMA", macd, SignalEMA);
    instance:ownerDrawn(true);
    instance:drawOnMainChart(true);
end

function FindCross(period)
    for i = period, 1, -1 do
        if core.crosses(Histogram, 0, i) then
            return i;
        end
    end
    return -1;
end

local cTroughs = 5;
local gLastBar = {};
local gMACD_Bar = {};
local gMACD_Value = {};
local gPriceBar = {};
local gPrice = {};
function GetBearishTroughs(period)
    for j = 0, cTroughs - 1 do
        local period = FindCross(period - 1);
        if period == -1 then
            return false;
        end
        gLastBar[j] = period;
        local period = FindCross(period - 1);
        if period == -1 then
            return false;
        end
        local value, bar = mathex.min(Histogram, core.range(period, gLastBar[j]));
        gMACD_Bar[j] = bar;
        gMACD_Value[j] = value;
        value, bar = mathex.min(source.low, core.range(period, gLastBar[j]));
        gPriceBar[j] = bar;
        gPrice[j] = value;
    end
    return true;
end
 
function GetBullishTroughs(period)
    for j = 0, cTroughs - 1 do
        local period = FindCross(period - 1);
        if period == -1 then
            return false;
        end
        gLastBar[j] = period;
        local period = FindCross(period - 1);
        if period == -1 then
            return false;
        end
        local value, bar = mathex.max(Histogram, core.range(period, gLastBar[j]));
        gMACD_Bar[j] = bar;
        gMACD_Value[j] = value;
        value, bar = mathex.max(source.high, core.range(period, gLastBar[j]));
        gPriceBar[j] = bar;
        gPrice[j] = value;
    end
    return true;
end

local lines = {};
local PEN_BEARISH_CANCELLED = 1;
local PEN_BEARISH = 2;
local PEN_HD_BEARISH_CANCELLED = 3;
local PEN_HD_BEARISH = 4;
local PEN_BULLISH_CANCELLED = 5;
local PEN_BULLISH = 6;
local PEN_HD_BULLISH_CANCELLED = 7;
local PEN_HD_BULLISH = 8;
local ShowHiddenDivergence, CD_DeleteCancelledLines, HD_DeleteCancelledLines;
local init1 = false;
local init2 = false;
function Draw(stage, context)
    if stage == 2 then
        if not init1 then
            init1 = true;
            ShowHiddenDivergence = instance.parameters.ShowHiddenDivergence;
            CD_DeleteCancelledLines = instance.parameters.CD_DeleteCancelledLines;
            HD_DeleteCancelledLines = instance.parameters.HD_DeleteCancelledLines;
            context:createPen(PEN_BEARISH, context:convertPenStyle(instance.parameters.CD_Bearish_style), instance.parameters.CD_Bearish_width, instance.parameters.CD_Bearish_color);
            context:createPen(PEN_BULLISH, context:convertPenStyle(instance.parameters.CD_Bullish_style), instance.parameters.CD_Bullish_width, instance.parameters.CD_Bullish_color);
            context:createPen(PEN_HD_BEARISH, context:convertPenStyle(instance.parameters.HD_Bearish_style), instance.parameters.HD_Bearish_width, instance.parameters.HD_Bearish_color);
            context:createPen(PEN_HD_BULLISH, context:convertPenStyle(instance.parameters.HD_Bullish_style), instance.parameters.HD_Bullish_width, instance.parameters.HD_Bullish_color);
            context:createPen(PEN_BEARISH_CANCELLED, context:convertPenStyle(instance.parameters.CD_CacelledLine_style), instance.parameters.CD_CacelledLine_width, instance.parameters.CD_Bearish_color);
            context:createPen(PEN_BULLISH_CANCELLED, context:convertPenStyle(instance.parameters.CD_CacelledLine_style), instance.parameters.CD_CacelledLine_width, instance.parameters.CD_Bullish_color);
            context:createPen(PEN_HD_BEARISH_CANCELLED, context:convertPenStyle(instance.parameters.HD_CacelledLine_style), instance.parameters.HD_CacelledLine_width, instance.parameters.HD_Bearish_color);
            context:createPen(PEN_HD_BULLISH_CANCELLED, context:convertPenStyle(instance.parameters.HD_CacelledLine_style), instance.parameters.HD_CacelledLine_width, instance.parameters.HD_Bullish_color);
        end
        for i, line in ipairs(lines) do
            if not line.IsPrice then
                local x1 = context:positionOfDate(line.Date);
                local x2 = context:positionOfDate(line.Date2);
                local _, y1 = context:pointOfPrice(line.Price);
                local _, y2 = context:pointOfPrice(line.Price2);
                context:drawLine(line.Pen, x1, y1, x2, y2);
            end
        end
    elseif stage == 102 then
        if not init2 then
            init2 = true;
            ShowHiddenDivergence = instance.parameters.ShowHiddenDivergence;
            CD_DeleteCancelledLines = instance.parameters.CD_DeleteCancelledLines;
            HD_DeleteCancelledLines = instance.parameters.HD_DeleteCancelledLines;
            context:createPen(PEN_BEARISH, context:convertPenStyle(instance.parameters.CD_Bearish_style), instance.parameters.CD_Bearish_width, instance.parameters.CD_Bearish_color);
            context:createPen(PEN_BULLISH, context:convertPenStyle(instance.parameters.CD_Bullish_style), instance.parameters.CD_Bullish_width, instance.parameters.CD_Bullish_color);
            context:createPen(PEN_HD_BEARISH, context:convertPenStyle(instance.parameters.HD_Bearish_style), instance.parameters.HD_Bearish_width, instance.parameters.HD_Bearish_color);
            context:createPen(PEN_HD_BULLISH, context:convertPenStyle(instance.parameters.HD_Bullish_style), instance.parameters.HD_Bullish_width, instance.parameters.HD_Bullish_color);
            context:createPen(PEN_BEARISH_CANCELLED, context:convertPenStyle(instance.parameters.CD_CacelledLine_style), instance.parameters.CD_CacelledLine_width, instance.parameters.CD_Bearish_color);
            context:createPen(PEN_BULLISH_CANCELLED, context:convertPenStyle(instance.parameters.CD_CacelledLine_style), instance.parameters.CD_CacelledLine_width, instance.parameters.CD_Bullish_color);
            context:createPen(PEN_HD_BEARISH_CANCELLED, context:convertPenStyle(instance.parameters.HD_CacelledLine_style), instance.parameters.HD_CacelledLine_width, instance.parameters.HD_Bearish_color);
            context:createPen(PEN_HD_BULLISH_CANCELLED, context:convertPenStyle(instance.parameters.HD_CacelledLine_style), instance.parameters.HD_CacelledLine_width, instance.parameters.HD_Bullish_color);
        end
        for i, line in ipairs(lines) do
            if line.IsPrice then
                local x1 = context:positionOfDate(line.Date);
                local x2 = context:positionOfDate(line.Date2);
                local _, y1 = context:pointOfPrice(line.Price);
                local _, y2 = context:pointOfPrice(line.Price2);
                context:drawLine(line.Pen, x1, y1, x2, y2);
            end
        end
    end
end

function FindLine(isPrice, date)
    for i, line in ipairs(lines) do
        if line.IsPrice == isPrice and line.Date == date then
            return line, i;
        end
    end
    return nil;
end

function ObjectDelete(isPrice, date)
    local line, linePos = FindLine(isPrice, date);
    if line == nil then
        return;
    end
    table.remove(lines, linePos);
end

function ChangeLineColor(isPrice, date, pen)
    local line = FindLine(isPrice, date);
    if line == nil then
        return;
    end
    line.Pen = pen;
end

function Update(period, mode)
    fast_ma:update(mode);
    slow_ma:update(mode);
	
	if period < math.max(fast_ma.DATA:first(), slow_ma.DATA:first()) then
	return;
	end
	
    macd[period] = fast_ma.DATA[period] - slow_ma.DATA[period];
	
	
    SignalBuffer:update(mode);
	if period < SignalBuffer.DATA:first()  then
	return;
	end
	
	
    Histogram[period] = macd[period] - SignalBuffer.DATA[period];
	
	
	signal[period]=SignalBuffer.DATA[period];
    if Histogram[period] >= 0 then
        if period == 0 or Histogram[period] >= Histogram[period - 1] then
            Histogram:setColor(period, HistogramRisingBull);
        else
            Histogram:setColor(period, HistogramFallingBull);
        end
    else
        if period == 0 or Histogram[period] >= Histogram[period - 1] then
            Histogram:setColor(period, HistogramRisingBear);
        else
            Histogram:setColor(period, HistogramFallingBear);
        end
    end

    local cross_period = FindCross(period);
    if cross_period == -1 then
        return;
    end
    if Histogram[period] > 0.0 then
        if not GetBullishTroughs(cross_period) then
            return;
        end
    else
        if not GetBearishTroughs(cross_period) then
            return;
        end
    end

    if period - cross_period > lookback then
        return;
    end

    if (Histogram[period] > 0.0) then
        MACD_Value, MACD_Bar = mathex.max(Histogram, core.range(cross_period, period));
        Price, PriceBar = mathex.max(source.high, core.range(cross_period, period));
        if (ShowClassicDivergence) then
            for t = 0, cTroughs - 1 do
                if ((Price < gPrice[t]) or (MACD_Value > gMACD_Value[t])) then
                    for k = period, cross_period, -1 do
                        if (not CD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_BEARISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_BEARISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                end
                if ((t > 0) and ((gMACD_Value[t - 1] > gMACD_Value[t]) or (gPrice[t - 1] > gPrice[t]))) then
                    break;
                end
                if ((PriceBar == period) and (Price > gPrice[t]) and (MACD_Value < gMACD_Value[t])) then
                    for k = (period - 1), cross_period, -1 do
                        if (not CD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_BEARISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_BEARISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                    DrawTrendLine(true, source:date(gPriceBar[t]), gPrice[t], source:date(PriceBar), Price, PEN_BEARISH);
                    DrawTrendLine(false, source:date(gMACD_Bar[t]), gMACD_Value[t], source:date(MACD_Bar), MACD_Value, PEN_BEARISH);
                    break;
                end
            end
        end
        if (ShowHiddenDivergence) then
            for t = 0, cTroughs - 1 do
                if (Price > gPrice[t]) then
                    for k = period, cross_period, -1 do
                        if (not HD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_HD_BEARISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_HD_BEARISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                end
                if (((PriceBar == period) or (MACD_Bar == period)) and (MACD_Value > gMACD_Value[t]) and (Price < gPrice[t])) then
                    for k = period - 1, cross_period, -1 do
                        if (not HD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_HD_BEARISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_HD_BEARISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                    DrawTrendLine(true, source:date(gPriceBar[t]), gPrice[t], source:date(PriceBar), Price, PEN_HD_BEARISH);
                    DrawTrendLine(false, source:date(gMACD_Bar[t]), gMACD_Value[t], source:date(MACD_Bar), MACD_Value, PEN_HD_BEARISH);
                    break;
                end
                if ((gMACD_Value[t] > MACD_Value) or (Price > gPrice[t])) then
                    break;
                end
            end
        end
    else
        MACD_Value, MACD_Bar = mathex.min(Histogram, core.range(cross_period, period));
        Price, PriceBar = mathex.min(source.low, core.range(cross_period, period));
        if (ShowClassicDivergence) then
            for t = 0, cTroughs - 1 do
                if ((Price > gPrice[t]) or (MACD_Value < gMACD_Value[t])) then
                    for k = period, cross_period, -1 do
                        if (not CD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_BULLISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_BULLISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                end
                if ((t > 0) and ((gMACD_Value[t-1] < gMACD_Value[t]) or (gPrice[t-1] < gPrice[t]))) then
                    break;
                end
                if ((PriceBar == period) and (Price < gPrice[t]) and (MACD_Value > gMACD_Value[t])) then
                    for k = period - 1, cross_period, -1 do
                        if (not CD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_BULLISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_BULLISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                    DrawTrendLine(true, source:date(gPriceBar[t]), gPrice[t], source:date(PriceBar), Price, PEN_BULLISH);
                    DrawTrendLine(false, source:date(gMACD_Bar[t]), gMACD_Value[t], source:date(MACD_Bar), MACD_Value, PEN_BULLISH);
                    break;
                end
            end
        end
        if (ShowHiddenDivergence) then
            for t = 0, cTroughs - 1 do
                if (Price < gPrice[t]) then
                    for k = period, cross_period, -1 do
                        if (not HD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_HD_BULLISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_HD_BULLISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                end
                if (((PriceBar == period) or (MACD_Bar == period)) and (MACD_Value < gMACD_Value[t]) and (Price > gPrice[t])) then
                    for k = period - 1, cross_period, -1 do
                        if (not HD_DeleteCancelledLines) then
                            ChangeLineColor(false, source:date(gMACD_Bar[t]), PEN_HD_BULLISH_CANCELLED);
                            ChangeLineColor(true, source:date(gPriceBar[t]), PEN_HD_BULLISH_CANCELLED);
                        else
                            ObjectDelete(false, source:date(gMACD_Bar[t]));
                            ObjectDelete(true, source:date(gPriceBar[t]));
                        end
                    end
                    DrawTrendLine(true, source:date(gPriceBar[t]), gPrice[t], source:date(PriceBar), Price, PEN_HD_BULLISH);
                    DrawTrendLine(false, source:date(gMACD_Bar[t]), gMACD_Value[t], source:date(MACD_Bar), MACD_Value, PEN_HD_BULLISH);
                    break;
                end
                if ((gMACD_Value[t] < MACD_Value) or (Price < gPrice[t])) then
                    break;
                end
            end
        end
    end
end

function DrawTrendLine(isPrice, date1, price1, date2, price2, pen)
    local line = {};
    line.Pen = pen;
    line.IsPrice = isPrice;
    line.Date = date1;
    line.Price = price1;
    line.Date2 = date2;
    line.Price2 = price2;
    lines[#lines + 1] = line;
end