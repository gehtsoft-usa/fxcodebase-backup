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

local source = nil
local zz;

local indi_alerts = {};
indi_alerts.Version = "2.1";
indi_alerts.inverted_arrows = false;
local alerts = 
{ 
    {
        Stage = 2,
        UpCondition = function (period)
            peaks = zz:EnumPeaks();
            if not peaks:Next() or not peaks:Next() then
                return false;
            end
            local peakPeriod1, peak1, searchMode1 = peaks:GetData();
            if not peaks:Next() or peak1 == nil then
                return false;
            end
            local peakPeriod2, peak2, searchMode2 = peaks:GetData();
            return core.crossesUnderOrTouch(source, math.min(peak1, peak2), period);
        end,
        DownCondition = function (period)
            peaks = zz:EnumPeaks();
            if not peaks:Next() or not peaks:Next() then
                return false;
            end
            local peakPeriod1, peak1, searchMode1 = peaks:GetData();
            if not peaks:Next() or peak1 == nil then
                return false;
            end
            local peakPeriod2, peak2, searchMode2 = peaks:GetData();
            return core.crossesOverOrTouch(source, math.max(peak1, peak2), period);
        end,
        FormatMessage = function(source, period, level, label, isUp)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source.close[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        OnChange = true,
        Name = "Alert"
    }
};

function Init()
    indicator:name("ZigZag Channel")
    indicator:description(" ")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12)
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5)
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

    indicator.parameters:addInteger("Period", "Period", "Period", 1)

    indicator.parameters:addGroup("Zig Zag Line Style")
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addInteger("show_last", "Show Last", "", 2);
    indicator.parameters:addBoolean("use_poolback", "Use poolback", "", true);
    indicator.parameters:addDouble("pullback", "Pullback, %", "", 10);
    indicator.parameters:addColor("up_color", "Long-term Up Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("up_width", "Long-term Up Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("up_style", "Long-term Up Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("up_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("down_color", "Long-term Down Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("down_width", "Long-term Down Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("down_style", "Long-term Down Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("down_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("up_h_color", "Historical Long-term Up Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("up_h_width", "Historical Long-term Up Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("up_h_style", "Historical Long-term Up Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("up_h_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("down_h_color", "Historical Long-term Down Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("down_h_width", "Historical Long-term Down Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("down_h_style", "Historical Long-term Down Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("down_h_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("trend_up_hist_color", "Historical Up Trend Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("trend_up_hist_width", "Historical Up Trend Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("trend_up_hist_style", "Historical Up Trend Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("trend_up_hist_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("trend_down_hist_color", "Historical Down Trend Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("trend_down_hist_width", "Historical Down Trend Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("trend_down_hist_style", "Historical Down Trend Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("trend_down_hist_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("trend_up_color", "Trend Up Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("trend_up_width", "Trend Up Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("trend_up_style", "Trend Up Style", "Style", core.LINE_DOT);
    indicator.parameters:setFlag("trend_up_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("trend_down_color", "Trend Down Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("trend_down_width", "Trend Down Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("trend_down_style", "Trend Down Style", "Style", core.LINE_DOT);
    indicator.parameters:setFlag("trend_down_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("swing_color", "Swing Color", "Color", core.colors().Black);
    indicator.parameters:addInteger("swing_width", "Swing Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("swing_style", "Swing Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("swing_style", core.FLAG_LINE_STYLE);

    indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end
local Depth
local Deviation
local Backstep
local use_poolback;
local first
local ZigC
local ZagC
local out
local pipSize
local _show_alert, _sound_file, _recurrent_sound, _email;
local _ToTime;
local bid_source, ask_source;

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

local show_last;
local pullback;
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);
    Depth = instance.parameters.Depth
    use_poolback = instance.parameters.use_poolback;
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    source = instance.source
    first = source:first()
    _ToTime = instance.parameters.signaler_ToTime
    if _ToTime == 1 then
        _ToTime = core.TZ_EST
    elseif _ToTime == 2 then
        _ToTime = core.TZ_UTC
    elseif _ToTime == 3 then
        _ToTime = core.TZ_LOCAL
    elseif _ToTime == 4 then
        _ToTime = core.TZ_SERVER
    elseif _ToTime == 5 then
        _ToTime = core.TZ_FINANCIAL
    elseif _ToTime == 6 then
        _ToTime = core.TZ_TS
    end
    if instance.parameters.signaler_play_sound then
        _sound_file = instance.parameters.signaler_sound_file;
        assert(_sound_file ~= "", "Sound file must be chosen");
    end
    _show_alert = instance.parameters.signaler_show_alert;
    _recurrent_sound = instance.parameters.signaler_recurrent_sound;
    if instance.parameters.signaler_send_email then
        _email = instance.parameters.signaler_email;
        assert(_email ~= "", "E-mail address must be specified");
    end

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    if source:isBid() then
        bid_source = source;
        ask_source = sources:Request(1, source, nil, false);
    else
        ask_source = source;
        bid_source = sources:Request(1, source, nil, true);
    end

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)
    zz = CreateZigZag(out, Depth, Deviation, Backstep, instance.parameters.Zig_color, instance.parameters.Zag_color);
    show_last = instance.parameters.show_last;
    pullback = instance.parameters.pullback;

    instance:ownerDrawn(true);

    pipSize = source:pipSize()
end

local UP_TREND = 1;
local DOWN_TREND = 2;
local UP_TREND_HIST = 3;
local DOWN_TREND_HIST = 4;
local TREND_UP_HIST_LINE = 5;
local TREND_DN_HIST_LINE = 8;
local TREND_UP_LINE = 9;
local TREND_DN_LINE = 10;
local SWING_PEN = 6;
local FONT = 7;

function UpTriggered(period)
    for i = period, source:size() - 2 do
        if source.high[period] < source.high[i] then
            return true;
        end
    end
    return false;
end

function DownTriggered(period)
    for i = period, source:size() - 2 do
        if source.low[period] > source.low[i] then
            return true;
        end
    end
    return false;
end

function RegisterUp(context, period, hist)
    local ask_period = core.findDate(ask_source, source:date(period), false);
    local _, y = context:pointOfPrice(ask_source.high[ask_period]);
    local x = context:positionOfBar(period);
    if hist then
        context:drawLine(UP_TREND_HIST, x, y, context:right(), y);
    else
        context:drawLine(UP_TREND, x, y, context:right(), y);
    end
end

function RegisterDown(context, period, hist)
    local bid_period = core.findDate(bid_source, source:date(period), false);
    local _, y = context:pointOfPrice(bid_source.low[bid_period]);
    local x = context:positionOfBar(period);
    if hist then
        context:drawLine(DOWN_TREND_HIST, x, y, context:right(), y);
    else
        context:drawLine(DOWN_TREND, x, y, context:right(), y);
    end
end

function ExtendLine(context, pen, x1, y1, x2, y2)
    local a = (y2 - y1) / (x2 - x1);
    local b = y1 - a * x1;
                        
    if x1 > x2 then
        context:drawLine(pen, context:left(), context:left() * a + b, x1, y1);
    elseif x1 < x2 then
        context:drawLine(pen, context:right(), context:right() * a + b, x1, y1);
    end
end

local init = false;
function Draw(stage, context) 
    indi_alerts:Draw(stage, context, source);
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(UP_TREND, context:convertPenStyle(instance.parameters.up_style), instance.parameters.up_width, instance.parameters.up_color);
        context:createPen(DOWN_TREND, context:convertPenStyle(instance.parameters.down_style), instance.parameters.down_width, instance.parameters.down_color);
        context:createPen(UP_TREND_HIST, context:convertPenStyle(instance.parameters.up_h_style), instance.parameters.up_h_width, instance.parameters.up_h_color);
        context:createPen(DOWN_TREND_HIST, context:convertPenStyle(instance.parameters.down_h_style), instance.parameters.down_h_width, instance.parameters.down_h_color);
        context:createPen(TREND_UP_LINE, context:convertPenStyle(instance.parameters.trend_up_style), instance.parameters.trend_up_width, instance.parameters.trend_up_color);
        context:createPen(TREND_DN_LINE, context:convertPenStyle(instance.parameters.trend_down_style), instance.parameters.trend_down_width, instance.parameters.trend_down_color);
        context:createPen(TREND_UP_HIST_LINE, context:convertPenStyle(instance.parameters.trend_up_hist_style), instance.parameters.trend_up_hist_width, instance.parameters.trend_up_hist_color);
        context:createPen(TREND_DN_HIST_LINE, context:convertPenStyle(instance.parameters.trend_down_hist_style), instance.parameters.trend_down_hist_width, instance.parameters.trend_down_hist_color);
        context:createPen(SWING_PEN, context:convertPenStyle(instance.parameters.swing_style), instance.parameters.swing_width, instance.parameters.swing_color);
        context:createFont(FONT, "Arial", 0, context:pixelsToPoints(12), 0);
    end

    local lines = 0;
    local last_peakPeriod_1, last_peak_1;
    local last_peakPeriod_2, last_peak_2;
    local peaks = zz:EnumPeaks();
    while (peaks:Next()) do
        local peakPeriod, peak, searchMode = peaks:GetData();
        if last_peak_2 ~= nil then
            if searchMode == -1 then
                local current_pullback = math.abs(source.high[last_peakPeriod_2] - source.low[last_peakPeriod_1]) / math.abs(source.high[peakPeriod] - source.low[last_peakPeriod_1])
                if source.high[peakPeriod] > source.high[last_peakPeriod_2] 
                    and (lines < show_last or show_last == 0)
                    and (not use_poolback or (current_pullback * 100 >= pullback or lines < 2))
                then
                    RegisterUp(context, peakPeriod, lines >= 2);
                    local ask_last_peakPeriod_2 = core.findDate(ask_source, source:date(last_peakPeriod_2), false);
                    local _, y1 = context:pointOfPrice(ask_source.high[ask_last_peakPeriod_2]);
                    local x1 = context:positionOfBar(last_peakPeriod_2);
                    local ask_peakPeriod = core.findDate(ask_source, source:date(peakPeriod), false);
                    local _, y2 = context:pointOfPrice(ask_source.high[ask_peakPeriod]);
                    local x2 = context:positionOfBar(peakPeriod);
                    ExtendLine(context, lines >= 2 and TREND_UP_HIST_LINE or TREND_UP_LINE, x2, y2, x1, y1);
                    lines = lines + 1;
                end
            else
                local current_pullback = math.abs(source.high[last_peakPeriod_1] - source.low[last_peakPeriod_2]) / math.abs(source.high[last_peakPeriod_1] - source.low[peakPeriod])
                if source.low[peakPeriod] < source.low[last_peakPeriod_2] 
                    and (lines < show_last or show_last == 0) 
                    and (not use_poolback or (current_pullback * 100 >= pullback or lines < 2))
                then
                    RegisterDown(context, peakPeriod, lines >= 2);
                    local bid_last_peakPeriod_2 = core.findDate(bid_source, source:date(last_peakPeriod_2), false);
                    local _, y1 = context:pointOfPrice(bid_source.low[bid_last_peakPeriod_2]);
                    local x1 = context:positionOfBar(last_peakPeriod_2);
                    local bid_peakPeriod = core.findDate(bid_source, source:date(peakPeriod), false);
                    local _, y2 = context:pointOfPrice(bid_source.low[bid_peakPeriod]);
                    local x2 = context:positionOfBar(peakPeriod);
                    ExtendLine(context, lines >= 2 and TREND_DN_HIST_LINE or TREND_DN_LINE, x2, y2, x1, y1);
                    lines = lines + 1;
                end
            end
        end
        last_peakPeriod_2 = last_peakPeriod_1;
        last_peak_2 = last_peak_1;
        last_peakPeriod_1 = peakPeriod;
        last_peak_1 = peak;
    end

    peaks = zz:EnumPeaks();
    if not peaks:Next() or not peaks:Next() then
        return;
    end
    local peakPeriod1, peak1, searchMode1 = peaks:GetData();
    if not peaks:Next() or peak1 == nil then
        return;
    end
    local peakPeriod2, peak2, searchMode2 = peaks:GetData();
    local distance = (peak1 - peak2) / source:pipSize();
    local _, y1 = context:pointOfPrice(peak1);
    local x = context:positionOfBar(peakPeriod2);
    local _, y2 = context:pointOfPrice(peak2);
    context:drawLine(SWING_PEN, x, y1, context:right(), y1);
    context:drawLine(SWING_PEN, x, (y2 + y1) / 2, context:right(), (y2 + y1) / 2);
    context:drawLine(SWING_PEN, x, y2, context:right(), y2);
    local w, h = context:measureText(FONT, tostring(distance), 0);
    context:drawText(FONT, tostring(distance), core.COLOR_LABEL, -1, x, math.min(y1, y2) - h, x + w, math.min(y1, y2), 0);
end

function CreateZigZag(stream, Depth, Deviation, Backstep, ZigC, ZagC)
    local searchBoth = 0
    local searchPeak = 1
    local searchLawn = -1
    local zz = {};
    zz.out = stream;
    zz.Depth = Depth;
    zz.Deviation = Deviation;
    zz.Backstep = Backstep;
    zz.TotalPeaks = 0;
    zz.SearchMode = instance:addInternalStream(0, 0)
    zz.Peak = instance:addInternalStream(0, 0)
    zz.HighMap = instance:addInternalStream(0, 0)
    zz.LowMap = instance:addInternalStream(0, 0)
    function zz:ClearStreams(period)
        self.SearchMode:setNoData(period);
        self.Peak:setNoData(period);
        self.out:setNoData(period);
    end
    function zz:RemoveLast()
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        if bookmark == -1 then
            return;
        end
        self:ClearStreams(bookmark);
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index, nextBookmark);
            bookmark = nextBookmark;
            index = index + 1;
        end
        self.TotalPeaks = self.TotalPeaks - 1;
    end
    function zz:DrawLine()
        local period = self.out:getBookmark(1);
        local last = self.out:getBookmark(2);
        if last == -1 then
            return;
        end
        if self.SearchMode[period] == -1 then
            core.drawLine(self.out, core.range(last, period), self.Peak[last], last, self.Peak[period], period, ZagC)
            self.out:setColor(last, ZigC)
        else
            core.drawLine(self.out, core.range(last, period), self.Peak[last], last, self.Peak[period], period, ZigC)
            self.out:setColor(last, ZagC)
        end
    end
    function zz:RegisterPeak(period, mode, peak)
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        if (bookmark == period) then
            if mode ~= self.SearchMode[period] then
                self:RemoveLast();
                self:ReplaceLastPeak(period, mode, peak);
            end
            return;
        end
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index + 1, bookmark)
            bookmark = nextBookmark;
            index = index + 1;
        end
        
        self.TotalPeaks = index - 1;
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
        self:DrawLine();
    end
    function zz:EnumPeaks()
        local enum = {};
        enum.zz = self;
        enum.Index = 0;
        function enum:Next()
            self.Index = self.Index + 1;
            return self.Index <= self.zz.TotalPeaks;
        end
        function enum:GetData()
            local period = self.zz.out:getBookmark(self.Index);
            if period == -1 or period >= self.zz.Peak:size() then
                return nil;
            end
            return period, self.zz.Peak[period], self.zz.SearchMode[period];
        end
        return enum;
    end
    function zz:ReplaceLastPeak(period, mode, peak)
        local last = self.out:getBookmark(1);
        if last ~= -1 then
            self:ClearStreams(last);
        end
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
        self:DrawLine();
    end
    function zz:Clear()
        self.lastlow = nil
        self.lasthigh = nil
        self.TotalPeaks = 0;
    end
    function zz:Calc(period)
        if (period < self.Depth) then
            return;
        end
        local range = period - self.Depth + 1;
        local val = mathex.min(source.low, range, period)
        if val ~= self.lastlow then
            self.lastlow = val
            if (source.low[period] - val) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.LowMap[i] ~= 0) and (self.LowMap[i] > val) then
                        self.LowMap[i] = 0
                    end
                end
            end
            if source.low[period] == val then
                self.LowMap[period] = val
            else
                self.LowMap[period] = 0
            end
        end
        val = mathex.max(source.high, range, period)
        if val ~= lasthigh then
            self.lasthigh = val
            if (val - source.high[period]) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.HighMap[i] ~= 0) and (self.HighMap[i] < val) then
                        self.HighMap[i] = 0
                    end
                end
            end
            if source.high[period] == val then
                self.HighMap[period] = val
            else
                self.HighMap[period] = 0
            end
        end

        local prev_peak = self.out:getBookmark(2)
        local start = self.Depth
        local last_peak_i = self.out:getBookmark(1)
        if last_peak_i ~= -1 then
            start = last_peak_i
        end

        for i = start, period, 1 do
            if last_peak_i == -1 then
                if (self.HighMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                elseif (self.LowMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchPeak then
                if (self.LowMap[i] ~= 0 and self.LowMap[i] < self.Peak[last_peak_i]) then
                    last_peak_i = i
                    self:ReplaceLastPeak(i, searchPeak, self.LowMap[i])
                end
                if self.HighMap[i] ~= 0 and self.LowMap[i] == 0 then
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchLawn then
                if (self.HighMap[i] ~= 0 and self.HighMap[i] > self.Peak[last_peak_i]) then
                    last_peak_i = i
                    self:ReplaceLastPeak(i, searchLawn, self.HighMap[i])
                end
                if self.LowMap[i] ~= 0 and self.HighMap[i] == 0 then
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            end
        end
    end
    
    return zz;
end

local lastserial = -1

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    period = period - 1
    if period < 0 or source:serial(period) == lastserial then
        return
    end

    if mode == core.UpdateAll then
        zz:Clear();
    end

    lastserial = source:serial(period);
    zz:Calc(period);
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
	if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
		instance:updateFrom(0);
	end
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.UpCondition(period) and (not alert.OnChange or not alert.UpCondition(period - 1)) then
        alert:UpAlert(source, period, source.high[period], historical_period);
    elseif alert.DownCondition(period) and (not alert.OnChange or not alert.DownCondition(period - 1)) then
        alert:DownAlert(source, period, source.low[period], historical_period);
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts._alerts = {};
indi_alerts._advanced_alert_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addBoolean("strategy_output", "Output for strategies", "Used by the strategies", false);

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    indicator.parameters:addGroup("External Alerts");
    indicator.parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	indicator.parameters:addString("advanced_alert_key", "Advanced Alert Key",
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for Discord/other platform keys", "")
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._advanced_alert_timer and #self._alerts > 0 then if self._advanced_alert_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}', self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
function indi_alerts:ToJSON(item)
    local json = {};
    function json:AddStr(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value)); end
    function json:AddNumber(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0); end
    function json:AddBool(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false"); end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    local first = true; for idx,t in pairs(item) do  local stype = type(t) if stype == "number" then json:AddNumber(idx, t); elseif stype == "string" then json:AddStr(idx, t); elseif stype == "boolean" then json:AddBool(idx, t); elseif stype == "function" or stype == "table" then else core.host:trace(tostring(idx) .. " " .. tostring(stype)); end end
    return json:ToString();
end
function indi_alerts:ArrayToJSON(arr) local str = "["; for i, t in ipairs(self._alerts) do local json = self:ToJSON(t); if str == "[" then str = str .. json; else str = str .. "," .. json; end end return str .. "]"; end
function indi_alerts:AddAlert(label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. label .." Alert" , "", true);

    indicator.parameters:addString("drawing_mode" .. self.last_id, "Drawing mode", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Arrows", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Vertical lines", "", "vlines");

    indicator.parameters:addFile("Up" .. self.last_id, label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Up Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Up Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addFile("Down" .. self.last_id, label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("DownSymbol" .. self.last_id, "Down Symbol", "", 218);
    indicator.parameters:addColor("DownColor" .. self.last_id, "Down Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addString("Label" .. self.last_id, "Label", "", label);
end

function indi_alerts:AddSingleAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
end

function indi_alerts:DrawAlert(context, alert, period)
    if not alert.Alert:hasData(period) then
        return;
    end

    if alert.Alert[period] == 1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            core.host:trace(self._stages[alert.Stage].FONT_ID);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y;
                y2 = y + height;
            else
                y1 = y - height;
                y2 = y;
            end
			context:drawText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, alert.UpColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.UpLinePen, x, context:top(), x, context:bottom());
        end
	elseif alert.Alert[period] == -1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            core.host:trace(self._stages[alert.Stage].FONT_ID);
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y - height;
                y2 = y;
            else
                y1 = y;
                y2 = y + height;
            end
            context:drawText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, alert.DownColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.DownLinePen, x, context:top(), x, context:bottom());
        end
    end
end
indi_alerts.NextId = 11;
indi_alerts._stages = {};
function indi_alerts:Draw(stage, context)
    if self._stages[stage] == nil then
        self._stages[stage] = {};
        self._stages[stage].createFont = false;
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                if level.DrawingMode == "vlines" then
                    level.UpLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    level.DownLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    context:createPen(level.UpLinePen, context.SOLID, 1, level.UpColor);
                    context:createPen(level.DownLinePen, context.SOLID, 1, level.DownColor);
                else
                    self._stages[stage].createFont = true;
                end
            end
        end
        if self._stages[stage].createFont and self._stages[stage].FONT_ID == nil then
            self._stages[stage].FONT_ID = self.NextId;
			core.host:trace("Created " .. self._stages[stage].FONT_ID);
            self.NextId = self.NextId + 1;
            context:createFont(self._stages[stage].FONT_ID, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        end
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                self:DrawAlert(context, level, period);
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:GetTimezone()
    local tz = instance.parameters.ToTime;
    if tz == 1 then
        return core.TZ_EST
    elseif tz == 2 then
        return core.TZ_UTC
    elseif tz == 3 then
        return core.TZ_LOCAL
    elseif tz == 4 then
        return core.TZ_SERVER
    elseif tz == 5 then
        return core.TZ_FINANCIAL
    elseif tz == 6 then
        return core.TZ_TS
    end
end
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    self.ToTime = self:GetTimezone();
    
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.UpCondition = alerts[i].UpCondition;
        alert.FormatMessage = alerts[i].FormatMessage;
        alert.DownCondition = alerts[i].DownCondition;
        alert.OnChange = alerts[i].OnChange;
        alert.Stage = alerts[i].Stage;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = on;
        alert.DrawingMode = instance.parameters:getString("drawing_mode" .. i);
        alert.UpSymbol = string.char(instance.parameters:getInteger("UpSymbol" .. i));
        local down_symbol = instance.parameters:getInteger("DownSymbol" .. i);
        if down_symbol ~= nil then
            alert.DownSymbol = string.char(down_symbol);
        end
        alert.UpColor = instance.parameters:getColor("UpColor" .. i);
        alert.DownColor = instance.parameters:getColor("DownColor" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        if alert.DownSymbol == nil then
            alert.DownSymbol = alert.UpSymbol;
            alert.DownColor = alert.UpColor;
            alert.Down = alert.Up;
        end
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        if instance.parameters.strategy_output then
            alert.Alert = instance:addStream("strat_signal_" .. i, core.Dot, "strat_signal_" .. i, "Strategy signal #" .. i, core.rgb(0, 0, 0), 0, 0);
        else
            alert.Alert = instance:addInternalStream(0, 0);
        end
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:DownAlert(source, period, level, historical_period)
            local text = self.FormatMessage(source, period, level, self.Label, false);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:date(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.D = source:date(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Down);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:UpAlert(source, period, level, historical_period)
            local text = self.FormatMessage(source, period, level, self.Label, true);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:date(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.U = source:date(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Up);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:GetLast(period)
            for i = period, 0, -1 do
                if self.Alert:hasData(i) and self.Alert[i] ~= 0 then
                    return self.Alert[i], i, self.AlertLevel[i];
                end
            end
        end
        self.Alerts[#self.Alerts + 1] = alert;
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil;
    assert(not(self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified");
    self.RecurrentSound = instance.parameters.RecurrentSound;

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = 1234;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, self.source:instrument() .. " " .. label .. " : " .. note);
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return;
    end
    terminal:alertSound(Sound, self.RecurrentSound);
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end
