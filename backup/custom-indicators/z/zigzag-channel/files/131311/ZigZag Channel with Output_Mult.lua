-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60727
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

    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    indicator.parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    indicator.parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    indicator.parameters:addFile("signaler_sound_file", "Sound File", "", "");
    indicator.parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    indicator.parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    indicator.parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    indicator.parameters:addString("signaler_email", "Email", "", "");
    indicator.parameters:setFlag("signaler_email", core.FLAG_EMAIL);
end
local Depth
local Deviation
local Backstep
local use_poolback;
local first
local source = nil
local ZigC
local ZagC
local out
local pipSize
local zz;
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

function FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (STRATEGY_NAME or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, _ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function Signal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if _show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if _sound_file ~= nil then
        terminal:alertSound(_sound_file, _recurrent_sound);
    end

    if _email ~= nil then
        terminal:alertEmail(_email, profile:id().. " : " .. message, FormatEmail(source, NOW, message));
    end
end

function CheckAlerts()
    local lines = 0;
    local last_peakPeriod_1, last_peak_1;
    local last_peakPeriod_2, last_peak_2;
    local peaks = zz:EnumPeaks();
    while (peaks:Next()) do
        local peakPeriod, peak, searchMode = peaks:GetData();
        if last_peak_2 ~= nil then
            if searchMode == -1 then
                if source.high[peakPeriod] > source.high[last_peakPeriod_2] 
                    and lines <= 2
                then
                    if source.close[NOW] > source.high[peakPeriod] and source.open[NOW] < source.high[peakPeriod] and not UpTriggered(peakPeriod) then
                        Signal("Long-term Up Break", source);
                    end
                    lines = lines + 1;
                end
            else
                if source.low[peakPeriod] < source.low[last_peakPeriod_2] 
                    and lines <= 2
                then
                    if source.close[NOW] < source.low[peakPeriod] and source.open[NOW] > source.low[peakPeriod] and not DownTriggered(peakPeriod) then
                        Signal("Long-term Down Break", source);
                    end
                    lines = lines + 1;
                end
            end
        end
        last_peakPeriod_2 = last_peakPeriod_1;
        last_peak_2 = last_peak_1;
        last_peakPeriod_1 = peakPeriod;
        last_peak_1 = peak;
        if lines >= 2 then
            return;
        end
    end
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
    CheckAlerts();
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
	if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
		instance:updateFrom(0);
	end
end