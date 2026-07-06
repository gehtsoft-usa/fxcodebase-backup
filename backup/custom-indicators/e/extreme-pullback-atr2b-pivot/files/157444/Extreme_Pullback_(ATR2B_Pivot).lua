-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75404

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid, instrument)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    if tf == nil then
        tf = source:barSize()
    end
	if isBid == nil then
		isBid = source:isBid()
    end
    if instrument == nil then
        instrument = source:instrument();
    end

	self.items[id] = core.host:execute("getSyncHistory", instrument, tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end
local ADROpenHour = 0;
local ADRCloseHour = 24;

function Init()
    indicator:name("Extreme Pullback");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Pivot Settings");
    indicator.parameters:addString("timeframe", "Pivot Timeframe", "", "H1");
    indicator.parameters:setFlag("timeframe", core.FLAG_PERIODS);
    indicator.parameters:addBoolean("PivotAverage", "PivotAverage", "", false);
    indicator.parameters:addInteger("NumPivotsToAve", "NumPivotsToAve", "", 3);
    indicator.parameters:addColor("PPAveColour", "PPAveColour", "", core.colors().Blue);
    indicator.parameters:addBoolean("PredictedPivot", "PredictedPivot", "", false);
    indicator.parameters:addColor("ExtremeSupportColour", "ExtremeSupportColour", "", core.colors().LightGreen);
    indicator.parameters:addColor("ExtremeResistanceColour", "ExtremeResistanceColour", "", core.colors().LightCoral);

    indicator.parameters:addGroup("ROUNDNUMBERSSETTINGS");
    indicator.parameters:addInteger("NumLinesAboveBelow", "NumLinesAboveBelow", "", 100)
    indicator.parameters:addInteger("SweetSpotMainLevels", "SweetSpotMainLevels", "", 100)
    indicator.parameters:addColor("LineColorMain", "LineColorMain", "", core.colors().Gold);
    indicator.parameters:addInteger("LineStyleMain", "LineStyleMain", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyleMain", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("ShowSubLevels", "ShowSubLevels", "", true)
    indicator.parameters:addInteger("sublevels", "sublevels", "", 250)
    indicator.parameters:addColor("LineColorSub", "LineColorSub", "", core.colors().Gold);
    indicator.parameters:addInteger("LineStyleSub", "LineStyleSub", "", core.LINE_DOT);
    indicator.parameters:setFlag("LineStyleSub", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("ADRSETTINGS");
    indicator.parameters:addInteger("ATRPeriod", "Period for ATR", "", 5);
    indicator.parameters:addBoolean("UseManualADR", "allows use of manual value for range", "", false);
    indicator.parameters:addInteger("ManualADRValuePips", "manual value for range", "", 0)
    indicator.parameters:addInteger("LineStyle", "LineStyle", "", 2)
    indicator.parameters:addInteger("LineThickness1", "normal thickness", "", 1)
    indicator.parameters:addColor("LineColor1", "normal color", "", core.colors().Orange)
    indicator.parameters:addInteger("LineThickness2", "thickness for range reached state", "", 2)
    indicator.parameters:addColor("LineColor2", "color for range reached state", "", core.colors().Blue)
    indicator.parameters:addInteger("BarForLabels", "number of bars from right, where lines labels will be shown", "", -10)
    indicator.parameters:addInteger("First_av", "First_av", "", 5)
    indicator.parameters:addInteger("Second_av", "Second_av", "", 10)
    indicator.parameters:addInteger("Third_av", "Third_av", "", 20)
    indicator.parameters:addInteger("RoundNumLimitX", "RoundNumLimitX", "", 0)
    indicator.parameters:addInteger("RoundNumLimitX1", "RoundNumLimitX1", "", 25)
    indicator.parameters:addInteger("RoundNumLimitY", "RoundNumLimitY", "", 100)
    indicator.parameters:addInteger("RoundNumLimitY1", "RoundNumLimitY1", "", 290)
    indicator.parameters:addInteger("PivotsLimitX", "PivotsLimitX", "", 50);
    indicator.parameters:addInteger("PivotsLimitX1", "PivotsLimitX1", "", 75);
    indicator.parameters:addInteger("PivotsLimitY", "PivotsLimitY", "", 100);
    indicator.parameters:addInteger("PivotsLimitY1", "PivotsLimitY1", "", 290)
    indicator.parameters:addInteger("ADRAllX", "ADRAllX", "", 100);
    indicator.parameters:addInteger("ADRAllX1", "ADRAllX1", "", 125);
    indicator.parameters:addInteger("ADRAllY", "ADRAllY", "", 100);
    indicator.parameters:addInteger("ADRAllY1", "ADRAllY1", "", 290);
end

local source;
local Hourly, FourHourly, Daily, Weekly, Monthly, Yearly, PivotAverage, NumPivotsToAve, PPAveColour, Alarm, PredictedPivot;
local ExtremeSupportColour, ExtremeResistanceColour, NumLinesAboveBelow, SweetSpotMainLevels, LineColorMain, LineStyleMain, ShowSubLevels;
local sublevels, LineColorSub, LineStyleSub, ATRPeriod, UseManualADR, ManualADRValuePips, LineStyle, LineThickness1, LineColor1, LineThickness2;
local LineColor2, BarForLabels, First_av, Second_av, Third_av, RoundNumLimitX, RoundNumLimitX1, RoundNumLimitY, RoundNumLimitY1, PivotsLimitX;
local PivotsLimitX1, PivotsLimitY, PivotsLimitY1, ADRAllX, ADRAllX1, ADRAllY, ADRAllY1;
local d1;
local pivot, pivot_source, tradingWeekOffset, tradingDayOffset;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    Hourly = instance.parameters.Hourly;
    FourHourly = instance.parameters.FourHourly;
    Daily = instance.parameters.Daily;
    Weekly = instance.parameters.Weekly;
    Monthly = instance.parameters.Monthly;
    Yearly = instance.parameters.Yearly;
    PivotAverage = instance.parameters.PivotAverage;
    NumPivotsToAve = instance.parameters.NumPivotsToAve;
    PPAveColour = instance.parameters.PPAveColour;
    Alarm = instance.parameters.Alarm;
    PredictedPivot = instance.parameters.PredictedPivot;
    ExtremeSupportColour = instance.parameters.ExtremeSupportColour;
    ExtremeResistanceColour = instance.parameters.ExtremeResistanceColour;
    NumLinesAboveBelow = instance.parameters.NumLinesAboveBelow;
    SweetSpotMainLevels = instance.parameters.SweetSpotMainLevels;
    LineColorMain = instance.parameters.LineColorMain;
    LineStyleMain = instance.parameters.LineStyleMain;
    ShowSubLevels = instance.parameters.ShowSubLevels;
    sublevels = instance.parameters.sublevels;
    LineColorSub = instance.parameters.LineColorSub;
    LineStyleSub = instance.parameters.LineStyleSub;
    ATRPeriod = instance.parameters.ATRPeriod;
    UseManualADR = instance.parameters.UseManualADR;
    ManualADRValuePips = instance.parameters.ManualADRValuePips;
    LineStyle = instance.parameters.LineStyle;
    LineThickness1 = instance.parameters.LineThickness1;
    LineColor1 = instance.parameters.LineColor1;
    LineThickness2 = instance.parameters.LineThickness2;
    LineColor2 = instance.parameters.LineColor2;
    BarForLabels = instance.parameters.BarForLabels;
    First_av = instance.parameters.First_av;
    Second_av = instance.parameters.Second_av;
    Third_av = instance.parameters.Third_av;
    RoundNumLimitX = instance.parameters.RoundNumLimitX;
    RoundNumLimitX1 = instance.parameters.RoundNumLimitX1;
    RoundNumLimitY = instance.parameters.RoundNumLimitY;
    RoundNumLimitY1 = instance.parameters.RoundNumLimitY1;
    PivotsLimitX = instance.parameters.PivotsLimitX;
    PivotsLimitX1 = instance.parameters.PivotsLimitX1;
    PivotsLimitY = instance.parameters.PivotsLimitY;
    PivotsLimitY1 = instance.parameters.PivotsLimitY1;
    ADRAllX = instance.parameters.ADRAllX;
    ADRAllX1 = instance.parameters.ADRAllX1;
    ADRAllY = instance.parameters.ADRAllY;
    ADRAllY1 = instance.parameters.ADRAllY1;
    if (not ShowSubLevels) then
        sublevels = sublevels * 2;
    end

    d1 = sources:Request(1, source, "D1");
    pivot_source = sources:Request(2, source, instance.parameters.timeframe);
    pivot = core.indicators:create("PIVOT", pivot_source, instance.parameters.timeframe, "Pivot", "HIST");

    instance:ownerDrawn(true);

    core.host:execute("addCommand", 40, "Show/hide ADR", "Show/hide ADR");
    core.host:execute("addCommand", 41, "Show/hide Round Numbers", "Show/hide Round Numbers");
    core.host:execute("addCommand", 42, "Show/hide Pivots", "Show/hide Pivots");
end
local show_adr = true;
local show_round_numbers = true;
local show_pivots = true;

function Update(period, mode)
    pivot:update(mode);
end

local font = 1;
local level_pen1 = 2;
local level_pen2 = 4;
local line_main = 5;
local line_sub = 6;
local pp_pen = 7;
local PredictedCPP_pen = 8;
local M3_pen = 9;
local R1_pen = 10;
local M4_pen = 11;
local R3_pen = 12;
local M2_pen = 13;
local S1_pen = 14;
local S2_pen = 15;
local S3_pen = 16;
local PPAverageTrend_pen = 17;
local start_day_pen = 3;
local init = false;
function Draw(stage, context)
    if not sources:IsAllLoaded() then
        return;
    end
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createFont(font, "Arial", 0, context:pointsToPixels(8), context.LEFT);
        context:createPen(level_pen1, context:convertPenStyle(LineStyle), LineThickness1, LineColor1)
        context:createPen(level_pen2, context:convertPenStyle(LineStyle), LineThickness2, LineColor2)
        context:createPen(start_day_pen, context:convertPenStyle(core.LINE_DOT), 1, core.colors().DarkGray)
        
        context:createPen(line_main, context:convertPenStyle(LineStyleMain), 1, LineColorMain)
        context:createPen(line_sub, context:convertPenStyle(LineStyleSub), 1, LineColorSub)
        context:createPen(pp_pen, context:convertPenStyle(core.LINE_SOLID), 3, core.colors().Black)
        context:createPen(PredictedCPP_pen, context:convertPenStyle(core.LINE_DASH), 1, core.colors().Black)
        context:createPen(M3_pen, context:convertPenStyle(core.LINE_SOLID), 1, core.colors().Red)
        context:createPen(R1_pen, context:convertPenStyle(core.LINE_SOLID), 1, core.colors().Red)
        context:createPen(M4_pen, context:convertPenStyle(core.LINE_SOLID), 1, ExtremeResistanceColour)
        context:createPen(R3_pen, context:convertPenStyle(core.LINE_SOLID), 1, core.colors().Red)
        context:createPen(M2_pen, context:convertPenStyle(core.LINE_SOLID), 1, core.colors().Green)
        context:createPen(S1_pen, context:convertPenStyle(core.LINE_SOLID), 1, core.colors().Green)
        context:createPen(S2_pen, context:convertPenStyle(core.LINE_SOLID), 1, ExtremeSupportColour)
        context:createPen(S3_pen, context:convertPenStyle(core.LINE_SOLID), 1, core.colors().Green)
        context:createPen(PPAverageTrend_pen, context:convertPenStyle(core.LINE_DASH), 1, PPAveColour)
    end
    if show_adr then
        DrawADR(context);
    end
    if show_round_numbers then
        DrawRoundNumbers(context);
    end
    if show_pivots then
        DrawPivots(context);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    sources:AsyncOperationFinished(cookie, successful, message, message1, message2);
    if (cookie == 40) then
        show_adr = not show_adr;
    elseif (cookie == 41) then
        show_round_numbers = not show_round_numbers;
    elseif (cookie == 42) then
        show_pivots = not show_pivots;
    end
end

function Round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function TimeHour(date)
    local t = core.dateToTable(date);
    return t.hour;
end

function TimeDayOfWeek(date)
    local t = core.dateToTable(date);
    return t.wday;
end

function DrawADR(context)
    local idxfirstbaroftoday, idxfirstbarofyesterday, idxlastbarofyesterday = ComputeDayIndices();
    local startofday = source:date(idxfirstbaroftoday);
    local adr;
    if (UseManualADR) then
        adr = ManualADRValuePips * source:pipSize();
    else
        local R1=0;
        local R5=0;
        local R10=0;
        local R20=0;
        R1 = (d1.high[NOW - 1] - d1.low[NOW - 1]) / d1:pipSize();
        for i = 1, First_av do
            R5 = R5 + (d1.high[NOW - i] - d1.low[NOW - i]) / d1:pipSize();
        end
        for i = 1, Second_av do
            R10 = R10 + (d1.high[NOW - i] - d1.low[NOW - i]) / d1:pipSize();
        end
        for i = 1, Third_av do
            R20 = R20 + (d1.high[NOW - i] - d1.low[NOW - i]) / d1:pipSize();
        end

        R5 = R5 / First_av;
        R10 = R10 / Second_av;
        R20 = R20 / Third_av;
        adr = (R1 + R5 + R10 + R20) / 4;
        adr = adr * d1:pipSize();
    end

    local today_high;
    local today_low;
    local today_open = 0;
    local today_range;
    local lasthigh;
    local lastlow;
    local last;
    local to_long_adr = 0;
    local to_short_adr = 0;
    local adr_high = 0;
    local adr_low = 0;
    local adr_reached = false;
    local lastreached;

    for j = idxfirstbaroftoday, 0, -1 do
        local bartime = source:date(NOW - j);
        if (TimeHour(bartime) >= ADROpenHour and TimeHour(bartime) < ADRCloseHour) then
            if (today_open==0) then
                today_open = source.open[NOW - idxfirstbaroftoday];
                adr_high = today_open + adr;
                adr_low = today_open - adr;
                today_high = today_open;
                today_low = today_open;
            end
            for k = 0, 2 do
                local price;
                if k == 0 then
                    price = source.low[NOW - j];
                elseif k == 1 then
                    price = source.high[NOW - j];
                elseif k == 2 then
                    price = source.close[NOW - j];
                end
                lasthigh = today_high;
                lastlow = today_low;
                lastreached = adr_reached;
                  
                today_high = math.max(today_high, price);
                today_low = math.min(today_low, price);
                today_range = today_high - today_low;
                adr_reached = today_range >= adr - source:pipSize() / 2;
                if (not lastreached and not adr_reached) then
                    adr_high = today_low + adr;
                elseif (not lastreached and adr_reached and price >= lasthigh) then
                    adr_high= today_low + adr;
                elseif (not lastreached and adr_reached and price<lasthigh) then
                    adr_high= lasthigh;
                else
                    adr_high= adr_high;
                end
                if (not lastreached and not adr_reached) then
                    adr_low= today_high - adr;
                elseif (not lastreached and adr_reached and price >= lastlow) then
                    adr_low= today_low;
                elseif (not lastreached and adr_reached and price < lastlow) then
                    adr_low= lasthigh - adr;
                else
                    adr_low= adr_low;
                end

                to_long_adr= adr_high - source.close[NOW - j];
                to_short_adr= source.close[NOW - j] - adr_low;
            end
        end
    end
    SetTimeLine(context, idxfirstbaroftoday, core.colors().CadetBlue, tostring(source.low[NOW - idxfirstbaroftoday] - 10 * source:pipSize()));
    local col = LineColor1;
    local pen = level_pen1;
    if (adr_reached) then
        col = LineColor2;
        pen = level_pen2;
    end
    SetLevel(context, "ADR High", adr_high, col, pen, startofday);
    SetLevel(context, "ADR Low", adr_low, col, pen, startofday);
   
    local reached_str= "Yes";
    if (not adr_reached) then
        reached_str= "No";
    end
end

function ComputeDayIndices()
    local s, e = core.getcandle(source:barSize(), source:date(0), 0, 0);
    local barsperday = 1 / (e - s);
   
    local dayofweektoday = TimeDayOfWeek(source:date(NOW));
    local dayofweektofind = -1; 

    local idxfirstbaroftoday= 0;
    local idxfirstbarofyesterday= 0;
    local idxlastbarofyesterday= 0;
    if (dayofweektoday == 6 or dayofweektoday == 0 or dayofweektoday == 1) then
        dayofweektofind = 5;
    else
        dayofweektofind = dayofweektoday - 1;
    end
   
    for i = 0, barsperday + 1 do
        local timet = source:date(NOW - i);
        if (TimeDayOfWeek(timet) ~= dayofweektoday) then
            idxfirstbaroftoday= i-1;
            break;
        end
    end
    for j = 0, 2 * barsperday + 1 do
        local timey = source:date(NOW - (barsperday + 1 + j));
        if (TimeDayOfWeek(timey)==dayofweektofind) then
            idxlastbarofyesterday= barsperday + 1+j;
            break;
        end
    end
    for j = 1, barsperday do
        local timey2= source:date(NOW - (idxlastbarofyesterday+j));
        if (TimeDayOfWeek(timey2)~=dayofweektofind) then
            idxfirstbarofyesterday= idxlastbarofyesterday+j-1;
            break;
        end
    end
    return idxfirstbaroftoday, idxfirstbarofyesterday, idxlastbarofyesterday;
end

function SetLevel(context, text, level, col1, level_pen, startofday)
    local labelname= "[ADR] " .. text .. " Label";
    local linename= "[ADR] " .. text .. " Line";
    local pricelabel= " " .. text;
    if (ShowLevelPrices and tonumber(text)==0) then
        pricelabel= pricelabel .. ": " .. win32.formatNumber(level, false, source:getPrecision());
    end

    local x1 = context:positionOfDate(startofday);
    local x2 = context:positionOfDate(source:date(NOW))
    local _, y = context:pointOfPrice(level);
    context:drawLine(level_pen, x1, y, x2, y);

    local w, h = context:measureText(font, pricelabel, context.LEFT);
    local x2 = context:positionOfDate(source:date(NOW - BarForLabels))
    context:drawText(font, pricelabel, col1, -1, x2 - w, y - h, x2, y, context.LEFT);
end

function SetTimeLine(context, idx, col1, vleveltext) 
    local x = context:positionOfDate(source:date(NOW - idx));
    context:drawLine(start_day_pen, x, context:top(), x, context:bottom());
    local w, h = context:measureText(font, vleveltext, context.LEFT);
    context:drawText(font, vleveltext, col1, -1, x - w, context:top(), x, context:top() + h, context.LEFT);
end

function DrawRoundNumbers(context)
    local pen;
    local thickness;
    local ssp1;
    local ssp;
    local ds1;
    ssp1 = source.close[NOW] / source:pipSize();
    ssp1 = ssp1 - ssp1 % sublevels;
    for i = -NumLinesAboveBelow, NumLinesAboveBelow - 1 do
        ssp = ssp1 + (i * sublevels); 
        if (ssp % SweetSpotMainLevels == 0) then
            pen = line_main;
        else
            pen = line_sub;
        end
        
        thickness= 1;
        
        if (ssp%(SweetSpotMainLevels*10)==0) then
            thickness= 2;      
        end
        if (ssp%(SweetSpotMainLevels*100)==0) then
            thickness= 3;      
        end
        
        ds1 = ssp * source:pipSize();
        SetLevelNum(context, ds1, pen, thickness);
    end
end

function SetLevelNum(context, level, pen, thickness)
    local _, y = context:pointOfPrice(level)
    context:drawLine(pen, context:left(), y, context:right(), y);
    if thickness == 2 then
        context:drawLine(pen, context:left(), y - 1, context:right(), y - 1);
    elseif thickness == 3 then
        context:drawLine(pen, context:left(), y - 1, context:right(), y - 1);
        context:drawLine(pen, context:left(), y + 1, context:right(), y + 1);
    end
end

function DrawPivots(context)
    local Buf_CPP_MA = {};
    for i = 1, pivot.DATA:size() - 1 do
        PreviousHigh  = pivot_source.high[i - 1];
        PreviousLow   = pivot_source.low[i - 1];
        PreviousClose = pivot_source.close[i - 1];
        Pivot = ((PreviousHigh + PreviousLow + PreviousClose)/3);
        PredictedCPP = ((pivot_source.high[NOW] + pivot_source.low[NOW] + pivot_source.close[NOW]) / 3);

        R1 = (2*Pivot)-PreviousLow;
        S1 = (2*Pivot)-PreviousHigh;
        R2 = Pivot + PreviousHigh - PreviousLow;
        S2 = Pivot - PreviousHigh + PreviousLow;
        S3 = (PreviousLow - (2*(PreviousHigh-Pivot)));
        R3 = (PreviousHigh + (2*(Pivot-PreviousLow)));
        M0 = (S3+S2)/2;
        M1 = (S2+S1)/2;
        M2 = (S1+Pivot)/2;
        M3 = (Pivot+R1)/2;
        M4 = (R1+R2)/2;
        M5 = (R2+R3)/2; 

        local s, e = core.getcandle(pivot_source:barSize(), pivot_source:date(i), tradingDayOffset, tradingWeekOffset)
        local x1 = context:positionOfDate(s);
        local x2 = context:positionOfDate(e);
        local _, y = context:pointOfPrice(Pivot);
        context:drawLine(pp_pen, x1, y, x2, y);
        if (PredictedPivot) then
            local _, y = context:pointOfPrice(PredictedCPP);
            context:drawLine(PredictedCPP_pen, x1, y, x2, y);
        end
        
        local _, y = context:pointOfPrice(M3);
        context:drawLine(M3_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(R1);
        context:drawLine(R1_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(M4);
        context:drawLine(M4_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(R3);
        context:drawLine(R3_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(M2);
        context:drawLine(M2_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(S1);
        context:drawLine(S1_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(S2);
        context:drawLine(S2_pen, x1, y, x2, y);
        local _, y = context:pointOfPrice(S3);
        context:drawLine(S3_pen, x1, y, x2, y);

        Buf_CPP_MA[i] = Pivot;
    end

    if (PivotAverage == true) then
        for counter = NumPivotsToAve + 1, pivot_source:size() - 1 do
            local PPAverageTrend = 0;
            for index = 1, NumPivotsToAve do
                PPAverageTrend = PPAverageTrend + Buf_CPP_MA[counter + index - 1];
            end
            PPAverageTrend = PPAverageTrend/NumPivotsToAve;

            local s, e = core.getcandle(pivot_source:barSize(), pivot_source:date(counter), tradingDayOffset, tradingWeekOffset)
            local x1 = context:positionOfDate(s);
            local x2 = context:positionOfDate(e);
            local _, y = context:pointOfPrice(PPAverageTrend);
            context:drawLine(PPAverageTrend_pen, x1, y, x2, y);
        end
    end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+