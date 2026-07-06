-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76474
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.

local vars = {};
function Init()
    indicator:name("ORB Smart Candle finder [With Volume Candle] with EXTEND");
    indicator:description("ORB Smart Candle finder [With Volume Candle] with EXTEND");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Candle Size", "", 40);
    indicator.parameters:addString("param2", "Time", "", "0915-1045");
    indicator.parameters:addString("param3", "Time", "", "0915-1045");
    indicator.parameters:addInteger("param4", " Voulme EMA Length", "", 20);
    indicator.parameters:addDouble("param5", "Volume Factor %", "", 0.25);
    indicator.parameters:addBoolean("param6", "Extend Line", "", true);
    indicator.parameters:addInteger("param7", "Extend Value", "", 5);
end

local source;
local plot1_open;
local plot1_high;
local plot1_low;
local plot1_close;
local plot2;
local plot3;
function Create_InSession_s(sessionTimesZ)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return not (PineScriptUtils:Time(period, Timeframe:Period(), sessionTimesZ, "America/New_York") == nil);
        end
    };
end
function Create_f_y_given_x()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(_x1, _y1, _x2, _y2, _new_x, period, mode)
            local_vars["_m"] = SafeDivide((SafeMinus(_y2, _y1)), (_x2 - _x1));
            local_vars["_b"] = SafeMinus(_y1, SafeMultiply(local_vars["_m"], _x1));
            local_vars["_new_y"] = SafePlus(SafeMultiply(local_vars["_m"], _new_x), local_vars["_b"]);
            return local_vars["_new_y"];
        end
    };
end
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["barsize"] = instance.parameters.param1;
    vars["sessionTime"] = instance.parameters.param3;
    vars["InSessionFunc1"] = Create_InSession_s(vars["sessionTime"]);
    vars["avg_vol_len"] = instance.parameters.param4;
    vars["factor"] = instance.parameters.param5;
    vars["MVA1_source"] = instance:addInternalStream(0, 0);
    vars["MVA1"] = core.indicators:create("MVA", vars["MVA1_source"], vars["avg_vol_len"]);
    vars["__barssince1"] = CreateBarsSince();
    vars["!candlerange1_stream"] = instance:addInternalStream(0, 0);
    vars["__barssince2"] = CreateBarsSince();
    vars["InSessionFunc2"] = Create_InSession_s(vars["sessionTime"]);
    plot1_open = instance:addStream("plot1_open", core.Line, "Open", "Open", core.colors().Black, 0, 0);
    plot1_high = instance:addStream("plot1_high", core.Line, "High", "High", core.colors().Black, 0, 0);
    plot1_low = instance:addStream("plot1_low", core.Line, "Low", "Low", core.colors().Black, 0, 0);
    plot1_close = instance:addStream("plot1_close", core.Line, "Close", "Close", core.colors().Black, 0, 0);
    instance:createCandleGroup("plot1", "plot1", plot1_open, plot1_high, plot1_low, plot1_close);
    vars["barhigh2"] = Variable:Create();
    vars["barlow2"] = Variable:Create();
    vars["InSessionFunc3"] = Create_InSession_s(vars["sessionTime"]);
    plot2_color = nil;
    plot2 = instance:addStream("plot2", core.Line, "", "", plot2_color or core.colors().Blue, 0, 0);
    plot2:setWidth(1);
    if (plot2_color == nil) then
        plot2:setStyle(core.LINE_NONE);
    else
        plot2:setStyle(core.LINE_SOLID);
    end
    vars["barhigh3"] = plot2;
    plot3_color = nil;
    plot3 = instance:addStream("plot3", core.Line, "", "", plot3_color or core.colors().Blue, 0, 0);
    plot3:setWidth(1);
    if (plot3_color == nil) then
        plot3:setStyle(core.LINE_NONE);
    else
        plot3:setStyle(core.LINE_SOLID);
    end
    vars["barlow3"] = plot3;
    vars["!channel1_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel1_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel1_1_c"] = core.colors().Blue + math.floor(50 / 100 * 255) * 16777216;
    if (vars["!channel1_1_c"] ~= nil) then
        instance:createChannelGroup("channel1_1", "channel1_1", vars["!channel1_1_u"], vars["!channel1_1_d"], Graphics:GetColor(vars["!channel1_1_c"]), vars["!channel1_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel1_1_c"]) or 100);
    end
    vars["extendonoff1"] = instance.parameters.param6;
    vars["extend"] = instance.parameters.param7;
    vars["ma_line1"] = Variable:Create();
    Line:Prepare(50);
    vars["ma_line2"] = Variable:Create();
    vars["f_y_given_xFunc4"] = Create_f_y_given_x();
    vars["f_y_given_xFunc5"] = Create_f_y_given_x();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        vars["InSessionFunc1"].Clear();
        vars["InSessionFunc2"].Clear();
        vars["barhigh2"]:Clear();
        vars["barlow2"]:Clear();
        vars["InSessionFunc3"].Clear();
        vars["ma_line1"]:Clear();
        vars["ma_line2"]:Clear();
        vars["f_y_given_xFunc4"].Clear();
        vars["f_y_given_xFunc5"].Clear();
    else
    end
    vars["highbar1"] = source.open:tick(period);
    vars["lowbar1"] = source.close:tick(period);
    vars["sessionTime"] = instance.parameters.param2;
    vars["barvalue"] = math.abs(vars["highbar1"] - vars["lowbar1"]);
    vars["candlerange"] = SafeLess(vars["barvalue"], vars["barsize"]);
    vars["candlerange1"] = nil;
    vars["candlerange1"] = SafeLess(vars["barvalue"], vars["barsize"]) and vars["InSessionFunc1"].GetValue(period, mode);
    SafeSetFloat(vars["MVA1_source"], period, source.volume:tick(period));
    vars["MVA1"]:update(mode);
    vars["pesado"] = SafeGreater(source.volume:tick(period), SafeMultiply(vars["MVA1"].DATA:tick(period), vars["factor"]));
    SafeSetBool(vars["!candlerange1_stream"], period, vars["candlerange1"]);
    vars["!candlerange1_stream_index1"] = 1;
    vars["!candlerange1_stream_index2"] = 2;
    vars["draw"] = SafeLess(vars["__barssince1"]:set(period, vars["candlerange1"]), vars["__barssince2"]:set(period, (SafeGetBool(vars["!candlerange1_stream"], period - vars["!candlerange1_stream_index1"]) or SafeGetBool(vars["!candlerange1_stream"], period - vars["!candlerange1_stream_index2"])))) and vars["candlerange1"] and vars["pesado"];
    if vars["InSessionFunc2"].GetValue(period, mode) and vars["draw"] and vars["pesado"] then
        vars["barcolor"] = core.colors().Black;
    else
        vars["barcolor"] = nil;
    end
    plot1_color = vars["barcolor"];
    if plot1_color then
        plot1_open[period] = source.open[period];
        plot1_high[period] = source.high[period];
        plot1_low[period] = source.low[period];
        plot1_close[period] = source.close[period];
        plot1_open:setColor(period, Graphics:GetColor(plot1_color));
    else
        plot1_open:setNoData(period);
        plot1_high:setNoData(period);
        plot1_low:setNoData(period);
        plot1_close:setNoData(period);
    end
    if not vars["barhigh2"]:IsInitialized() then
        vars["barhigh2"]:Set(nil);
    end
    if not vars["barlow2"]:IsInitialized() then
        vars["barlow2"]:Set(nil);
    end
    if vars["InSessionFunc3"].GetValue(period, mode) and vars["candlerange1"] and (vars["draw"]) and vars["pesado"] then
        vars["barhigh2"]:Set(period, vars["highbar1"]);
        vars["barlow2"]:Set(period, vars["lowbar1"]);
    end
    Plot:SetValue(plot2, period, vars["barhigh2"]:Get(period));
    Plot:SetValue(plot3, period, vars["barlow2"]:Get(period));
    channel1_from = vars["barhigh3"][period];
    channel1_to = vars["barlow3"][period];
    channel1_c = core.colors().Blue + math.floor(50 / 100 * 255) * 16777216;
    Fill:SetValue(vars["!channel1_1_u"], vars["!channel1_1_d"], channel1_from, channel1_to, vars["!channel1_1_c"] == channel1_c, period);
    if not vars["ma_line1"]:IsInitialized() then
        vars["ma_line1"]:Set(Line:New(nil, nil, nil, nil):SetColor(core.colors().Blue):SetExtend("none"):SetStyle("solid"));
    end
    if not vars["ma_line2"]:IsInitialized() then
        vars["ma_line2"]:Set(Line:New(nil, nil, nil, nil):SetColor(core.colors().Blue):SetExtend("none"):SetStyle("solid"));
    end
    vars["x1"] = period - 1;
    vars["y1"] = vars["barhigh2"]:Get(period, 1);
    vars["x2"] = period;
    vars["y2"] = vars["barhigh2"]:Get(period);
    vars["x3"] = period + vars["extend"];
    vars["y3"] = vars["f_y_given_xFunc4"].GetValue(vars["x1"], vars["y1"], vars["x2"], vars["y2"], vars["x3"], period, mode);
    Line:SetXY1(Triary(vars["extendonoff1"], vars["ma_line1"]:Get(period), nil), vars["x1"], vars["y1"]);
    Line:SetXY2(Triary(vars["extendonoff1"], vars["ma_line1"]:Get(period), nil), vars["x3"], vars["y3"]);
    vars["y22"] = vars["barlow2"]:Get(period, 1);
    vars["y33"] = vars["barlow2"]:Get(period);
    vars["y44"] = vars["f_y_given_xFunc5"].GetValue(vars["x1"], vars["y22"], vars["x2"], vars["y33"], vars["x3"], period, mode);
    Line:SetXY1(Triary(vars["extendonoff1"], vars["ma_line2"]:Get(period), nil), vars["x1"], vars["y22"]);
    Line:SetXY2(Triary(vars["extendonoff1"], vars["ma_line2"]:Get(period), nil), vars["x3"], vars["y44"]);
end
function Draw(stage, context)
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
function SafeMinus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left - right;
end
function SafeMultiply(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left * right;
end
function SafePlus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left + right;
end
function SafeConcat(left, right)
    if left == nil then
        return right;
    end
    if right == nil then
        return left;
    end
    return left .. right;
end
function SafeDivide(left, right)
    if left == nil or right == nil or right == 0 then
        return nil;
    end
    return left / right;
end
function SafeGreater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeGE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left >= right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
function SafeLE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left <= right;
end
function SafeMax(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.max(left, right);
end
function SafeMin(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.min(left, right);
end
function SafeAbs(value)
    if value == nil then
        return nil;
    end
    return math.abs(value);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function SafeSetBool(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or period == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil or period == nil then
        return nil;
    end
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period];
end
function Float(number)
    return number and number or nil;
end
function Int(number)
    return number and number or nil;
end
function Color(color)
    return color and color or nil;
end
function ToLine(line)
    return line;
end
function ToBox(box)
    return box;
end
function Round(num, idp)
    if num == nil then
        return nil;
    end
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
function Nz(value, defaultValue)
    if defaultValue == nil then
        defaultValue = 0;
    end
    return value and value or defaultValue;
end
function Triary(condition, trueValue, falseValue)
    if condition == nil or condition == false then
        return falseValue;
    end
    return trueValue;
end
function SafeCrossesUnder(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesUnder(val1, val2, period);
end
function SafeCrossesOver(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesOver(val1, val2, period);
end
function SafeCrosses(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crosses(val1, val2, period);
end
function SafeCos(val)
    if val == nil then
        return nil;
    end
    return math.cos(val);
end
function SafeSin(val)
    if val == nil then
        return nil;
    end
    return math.sin(val);
end
function SafeMathExMax(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.max(source, core.rangeTo(period, length));
end
function SafeMathExMin(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.min(source, core.rangeTo(period, length));
end
function SafeMathExStdev(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.stdev(source, core.rangeTo(period, length));
end
function SafeSqrt(value)
    if value == nil then
        return nil;
    end
    return math.sqrt(value);
end
function SafeExp(value)
    if value == nil then
        return nil;
    end
    return math.exp(value);
end
PineScriptUtils = {};
PineScriptUtils.Sources = {};
function PineScriptUtils:CreateSource(source, sourceType)
    if sourceType ~= "ohlc4" then
        return source[sourceType];
    end
    local newSource = {};
    newSource.Stream = instance:addInternalStream(0, 0);
    function newSource:Update(period, mode)
        self.Stream[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
    end
    self.Sources[#self.Sources + 1] = newSource;
    return newSource.Stream;
end
function PineScriptUtils:UpdateSources(period, mode)
    for i, src in ipairs(self.Sources) do
        src:Update(period, mode);
    end
end
function PineScriptUtils:TimeframeFromLength(length)
    if length == "t" then
        return "t1"
    elseif length == "D" then
        return "D1";
    elseif length == "W" then
        return "W1";
    elseif length == "M" then
        return "M1";
    end
    local length_number = tonumber(length);
    if length_number < 3600 then
        return "m" .. tostring(length_number / 60);
    end
    return "H" .. tostring(length_number / 3600)
end
function PineScriptUtils:ParseSession(session)
    local session_info = {};
    local _, _, from_hour, from_minute, to_hour, to_minute = string.find(session, "(%d%d)(%d%d)-(%d%d)(%d%d)");
    session_info.from_hour = from_hour and tonumber(from_hour) or 0;
    session_info.from_minute = from_minute and tonumber(from_minute) or 0;
    session_info.from = (session_info.from_hour * 60.0 + session_info.from_minute) * 60.0;
    session_info.to_hour = to_hour and tonumber(to_hour) or 23;
    session_info.to_minute = to_minute and tonumber(to_minute) or 59;
    session_info.to = (session_info.to_hour * 60.0 + session_info.to_minute) * 60.0;
    function session_info:IsInRange(time)
        time = math.floor(time * 86400 + 0.5);
        if self.from < self.to then
            return time >= self.from and time <= self.to;
        end
        if self.from > self.to then
            return time > self.from or time < self.to;
        end
    
        return time == self.from;
    end
    return session_info;
end
function PineScriptUtils:Time(period, timeframe_length, session, timezone)
    local timeframe = PineScriptUtils:TimeframeFromLength(timeframe_length);
    if PineScriptUtils.tradingWeekOffset == nil then
        PineScriptUtils.tradingWeekOffset = core.host:execute("getTradingWeekOffset");
        PineScriptUtils.tradingDayOffset = core.host:execute("getTradingDayOffset");
    end
    local s, e = core.getcandle(timeframe, instance.source:date(period), PineScriptUtils.tradingDayOffset, PineScriptUtils.tradingWeekOffset);
    local session_info = PineScriptUtils:ParseSession(session);
    if not session_info:IsInRange(s % 1) then
        return nil;
    end
    
    return s * 86400000;
end
function PineScriptUtils:WeekOfYear(time, timezone)
    local time_ole = time / 86400000;
    local date_table = core.dateToTable(time_ole)
    date_table.month = 1;
    date_table.day = 1;
    date_table.hour = 0;
    date_table.min = 0;
    date_table.sec = 0;
    local first_day_ole = core.tableToDate(date_table);
    date_table = core.dateToTable(first_day_ole);
    first_day_ole = first_day_ole - date_table.wday + 1;
    return math.floor(time_ole - first_day_ole / 7);
end

function Timestamp(year, month, day, hour, minute, second, tz)
    local date = {};
    date.month = month;
    date.day = day;
    date.year = year;
    date.hour = hour;
    date.min = minute;
    date.sec = second;
    return core.tableToDate(date) * 86400000;
end

function BarSizeInMS(barSize)
    local s, e = core.getcandle(barSize, core.now(), 0, 0)
    return (e - s) * 86400000;
end

function NumberToBool(n)
    return n ~= nil and n ~= 0;
end

function GetTrueRange(source, period)
    if period == 0 then
        return nil;
    end
    local num1 = math.abs(source.high[period] - source.low[period]);
    local num2 = math.abs(source.high[period] - source.close[period - 1]);
    local num3 = math.abs(source.close[period - 1] - source.low[period]);
    return math.max(num1, num2, num3);
end
Timeframe = {};
function Timeframe:Period()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "t";
    elseif string.sub(bar_size, 1, 1) == "m" then
        local minutes = tonumber(string.sub(bar_size, 2));
        return tostring(minutes * 60);
    elseif string.sub(bar_size, 1, 1) == "H" then
        local minutes = 60 * tonumber(string.sub(bar_size, 2));
        return tostring(minutes * 60);
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "M";
    end
    return "0";
end
function Timeframe:IsIntraday()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "m" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "H" then
        return true;
    end
    return false;
end
function Timeframe:Interval()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "0";
    elseif string.sub(bar_size, 1, 1) == "m" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "H" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "1";
    end
    return "0";
end
function Timeframe:InSeconds(timeframe, source)
    if timeframe == "M" then
        return 86400 * 30;
    elseif timeframe == "D" then
        return 86400;
    elseif timeframe == "t" then
        return 1;
    else
        local minutes = tonumber(timeframe);
        if minutes == nil then
            return nil;
        end
        return minutes * 60;
    end
    return nil;
end
function Timeframe:GetBarSize(timeframe)
    if timeframe == "M" then
        return "M1";
    elseif timeframe == "D" then
        return "D1";
    elseif timeframe == "t" then
        return "t1";
    else
        local minutes = tonumber(timeframe);
        if minutes == 1 then
            return "m1";
        elseif minutes == 5 then
            return "m5";
        elseif minutes == 15 then
            return "m15";
        elseif minutes == 30 then
            return "m30";
        elseif minutes == 60 then
            return "h1";
        elseif minutes == 120 then
            return "h2";
        elseif minutes == 180 then
            return "h3";
        elseif minutes == 240 then
            return "h4";
        elseif minutes == 360 then
            return "h6";
        elseif minutes == 480 then
            return "h8";
        end
    end
    return nil;
end
function Timeframe:Change(timeframe, source, period)
    if period <= 0 then
        return false;
    end
    local barSize = Timeframe:GetBarSize(timeframe);
    if barSize == nil then
        return false;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    local currentDate = core.getcandle(barSize, source:date(period), tradingDayOffset, tradingWeekOffset);
    local prevDate = core.getcandle(barSize, source:date(period - 1), tradingDayOffset, tradingWeekOffset);
    return currentDate ~= prevDate;
end
function CreateBarsSince()
    local bs = {};
    bs.last_period = nil;
    function bs:set(period, condition)
        if condition then
            self.last_period = period;
        end
        if self.last_period == nil then
            return nil;
        end
        return period - self.last_period;
    end
    return bs;
end
Variable = {};
function Variable:Create()
    local var = {};
    var._init = false;
    var._hist = {};
    var._last_period = nil;
    function var:Clear()
        self._init = false;
        self._value = nil;
        self._hist = {};
    end
    function var:Get(period, shift)
        if (shift ~= nil) then
            local target_period = period - shift;
            local found_value = nil;
            for k, v in pairs(self._hist) do
                if k > target_period then
                    return found_value;
                end
                found_value = v;
            end
            return found_value;
        end
        return self._value;
    end
    function var:Set(period, value)
        if (self._last_period ~= period and self._last_period ~= nil) then
            self._hist[self._last_period] = self._value;
        end
        self._value = value;
        self._last_period = period;
        self._init = true;
    end
    function var:IsInitialized()
        return self._init;
    end
    return var;
end
Plot = {};
function Plot:SetValueWithColor(plot, period, value, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if Plot:SetValue(plot, period, value) then
        plot:setColor(period, clr)
    end
end
function Plot:SetValue(plot, period, value)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value then
        plot:setNoData(period);
        return false;
    end
    plot[period] = value;
    return true;
end
Graphics = {};
Graphics.NextId = 1;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    if color == nil then
        return -1;
    end
    for i, pen in ipairs(Graphics.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(style), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Graphics.NextId;
    newPen.Width = width;
    newPen.Color = color;

    context:createPen(newPen.Id, context:convertPenStyle(style), width, color);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Pens[#Graphics.Pens + 1] = newPen;
    return newPen.Id;
end
function Graphics:FindBrush(color, context)
    if color == nil then
        return -1;
    end
    for i, brush in ipairs(Graphics.Brushes) do
        if brush.Color == color then
            context:createSolidBrush(brush.Id, color)
            return brush.Id;
        end
    end
    local newBrush = {};
    newBrush.Id = Graphics.NextId;
    newBrush.Color = color;
    context:createSolidBrush(newBrush.Id, color)
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Brushes[#Graphics.Brushes + 1] = newBrush;
    return newBrush.Id;
end
function Graphics:FindFont(font, xSize, ySize, corner, context)
    for i, font in ipairs(self.Fonts) do
        if font.xSize == xSize and font.Name == font then
            return font.Id;
        end
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    newFont.xSize = xSize;
    newFont.Name = font;
    context:createFont(newFont.Id, font, 0, xSize, context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    if clr == nil then
        return nil, nil;
    end
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:GetColor(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return color;
end
function Graphics:GetTransparency(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return transparency;
end
function Graphics:GetTransparencyPercent(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    if transparency == nil then
        return nil;
    end
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil or transp == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
Fill = {};
function Fill:SetValue(up_channel, dn_channel, value1, value2, mineColor, period)
    if value1 == nil or value2 == nil or mineColor ~= true then
        up_channel:setNoData(period);
        dn_channel:setNoData(period);
        return;
    end
    up_channel[period] = math.max(value1, value2);
    dn_channel[period] = math.min(value1, value2);
end
Line = {};
Line.AllLines = {};
function Line:GetAll()
    local array = {};
    array.arr = Line.AllLines;
    return array;
end
function Line:Clear()
    Line.AllLines = {};
end
function Line:Prepare(max_lines_count)
    Line.max_lines_count = max_lines_count;
end
function Line:GetPrice(line, x)
    if line == nil then
        return nil;
    end
    return line:GetPrice(x);
end
function Line:SetXY1(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY1(x, y);
end
function Line:SetXY2(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY2(x, y);
end
function Line:SetX1(line, x)
    if line == nil then
        return;
    end
    line:SetX1(x);
end
function Line:SetX2(line, x)
    if line == nil then
        return;
    end
    line:SetX2(x);
end
function Line:SetY1(line, y)
    if line == nil then
        return;
    end
    line:SetY1(y);
end
function Line:SetY2(line, y)
    if line == nil then
        return;
    end
    line:SetY2(y);
end
function Line:GetX1(line)
    if line == nil then
        return;
    end
    return line:GetX1();
end
function Line:GetX2(line)
    if line == nil then
        return;
    end
    return line:GetX2();
end
function Line:GetY1(line)
    if line == nil then
        return;
    end
    return line:GetY1();
end
function Line:GetY2(line)
    if line == nil then
        return;
    end
    return line:GetY2();
end
function Line:SetColor(line, clr)
    if line == nil then
        return;
    end
    line:SetColor(clr);
end
function Line:SetWidth(line, width)
    if line == nil then
        return;
    end
    line:SetWidth(width);
end
function Line:SetStyle(line, style)
    if line == nil then
        return;
    end
    line:SetStyle(style);
end
function Line:SetExtend(line, extend)
    if line == nil then
        return;
    end
    line:SetExtend(extend);
end
function Line:SetXLoc(line, x1, x2, xloc)
    if line == nil then
        return;
    end
    line:SetXLoc(x1, x2, xloc);
end
function Line:Copy(line)
    if line == nil then
        return nil;
    end
    local newLine = Line:New(line.X1, line.Y1, line.X2, line.Y2);
    newLine.XLoc = line.XLoc;
    newLine.Color = line.Color;
    newLine.Width = line.Width;
    newLine.Extend = line.Extend;
    newLine.Style = line.Style;
    return newLine;
end
function Line:NewCP(p1, p2)
    return Line:New(p1.x, p1.y, p2.x, p2.y);
end
function Line:New(x1, y1, x2, y2)
    local newLine = {};
    newLine.X1 = x1;
    newLine.Y1 = y1;
    newLine.X2 = x2;
    newLine.Y2 = y2;
    function newLine:SetXY1(x, y)
        self.X1 = x;
        self.Y1 = y;
        return self;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
        return self;
    end
    function newLine:SetX1(x)
        self.X1 = x;
        return self;
    end
    function newLine:SetX2(x)
        self.X2 = x;
        return self;
    end
    newLine.XLoc = "bar_index";
    function newLine:SetXLoc(x1, x2, xloc)
        newLine.X1 = x1;
        newLine.X2 = x2;
        newLine.XLoc = xloc;
        return self;
    end
    function newLine:SetY1(y)
        self.Y1 = y;
        return self;
    end
    function newLine:SetY2(y)
        self.Y2 = y;
        return self;
    end
    function newLine:GetX1()
        return self.X1;
    end
    function newLine:GetX2()
        return self.X2;
    end
    function newLine:GetY1()
        return self.Y1;
    end
    function newLine:GetY2()
        return self.Y2;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.ColorTransparency = (math.floor(clr / 16777216) % 255);
        self.Color = clr - self.ColorTransparency * 16777216;
        self.PenId = nil;
        return self;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenId = nil;
        return self;
    end
    newLine.Extend = "none";
    function newLine:SetExtend(extend)
        self.Extend = extend;
        return self;
    end
    newLine.Style = "solid";
    function newLine:SetStyle(style)
        self.Style = style;
        self.PenId = nil;
        return self;
    end
    function newLine:GetPrice(x)
        local a, c = math2d.lineEquation(self.X1, self.Y1, self.X2, self.Y2);
        return a * x + c;
    end
    function newLine:getStyleForContext()
        if self.Style == "solid" or self.Style == "arrow_left" or self.Style == "arrow_both" or self.Style == "arrow_right" then
            return core.LINE_SOLID;
        elseif self.Style == "dotted" then
            return core.LINE_DOT;
        elseif self.Style == "dashed" then
            return core.LINE_DASH;
        end
        return core.LINE_SOLID;
    end
    function newLine:converXToPoints(context, x)
        if self.XLoc == "bar_time" then
            return context:positionOfDate(x / 86400000);
        end
        local _, x1 = context:positionOfBar(x);
        return x1;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil or self.Width == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        local x1;
        local x2;
        if (self.XLoc == "bar_time") then
            _, x1 = context:positionOfDate(self.X1 / 86400000.0)
            _, x2 = context:positionOfDate(self.X2 / 86400000.0)
        else
            x1 = self:converXToPoints(context, self.X1);
            x2 = self:converXToPoints(context, self.X2);
        end
        local _, y1 = context:pointOfPrice(self.Y1);
        local _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            if x1 == x2 then
                if y1 >= y2 then
                    context:drawLine(self.PenId, x1, y1, x1, context:top(), self.ColorTransparency);
                else
                    context:drawLine(self.PenId, x1, y1, x1, context:bottom(), self.ColorTransparency);
                end
            else
                local a, c = math2d.lineEquation(x1, y1, x2, y2);
                if a ~= nil and c ~= nil then
                    local y3 = a * context:right() + c;
                    context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
                end
            end
        end
        if self.Extend == "left" or self.Extend == "both" then
            if x1 == x2 then
                if y1 >= y2 then
                    context:drawLine(self.PenId, x1, y2, x1, context:bottom(), self.ColorTransparency);
                else
                    context:drawLine(self.PenId, x1, y2, x1, context:top(), self.ColorTransparency);
                end
            else
                local a, c = math2d.lineEquation(x1, y1, x2, y2);
                if a ~= nil and c ~= nil then
                    local y3 = a * context:left() + c;
                    context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
                end
            end
        end
    end
    Line:AddNewLine(newLine);
    return newLine;
end
function Line:AddNewLine(newLine)
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
end
function Line:Delete(line)
    for i = 1, #self.AllLines do
        if self.AllLines[i] == line then
            table.remove(self.AllLines, i);
            return;
        end
    end
end
function Line:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLines) do
        value:Draw(stage, context);
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76474
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.