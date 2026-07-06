-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=76449
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
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
    indicator:name("SuperTrend STRATEGY");
    indicator:description("SuperTrend STRATEGY");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "ATR Period", "", 10);
    indicator.parameters:addString("param2", "Source", "", "median");
    indicator.parameters:addStringAlternative("param2", "Open", "", "open");
    indicator.parameters:addStringAlternative("param2", "High", "", "high");
    indicator.parameters:addStringAlternative("param2", "Low", "", "low");
    indicator.parameters:addStringAlternative("param2", "Close", "", "close");
    indicator.parameters:addStringAlternative("param2", "Median", "", "median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param2", "OHLC4", "", "ohlc4");
    indicator.parameters:addStringAlternative("param2", "HLCC4", "", "hlcc4");
    indicator.parameters:addDouble("param3", "ATR Multiplier", "", 3.0);
    indicator.parameters:addBoolean("param4", "Change ATR Calculation Method ?", "", true);
    indicator.parameters:addBoolean("param5", "Show Buy/Sell Signals ?", "", false);
    indicator.parameters:addBoolean("param6", "Highlighter On/Off ?", "", true);
    indicator.parameters:addBoolean("param7", "Bar Coloring On/Off ?", "", true);
    indicator.parameters:addInteger("param8", "From Month", "", 9, 1, 12);
    indicator.parameters:addInteger("param9", "From Day", "", 1, 1, 31);
    indicator.parameters:addInteger("param10", "From Year", "", 2018, 999);
    indicator.parameters:addInteger("param11", "To Month", "", 1, 1, 12);
    indicator.parameters:addInteger("param12", "To Day", "", 1, 1, 31);
    indicator.parameters:addInteger("param13", "To Year", "", 9999, 999);
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7_c;
local plot7;
local signal1;
local signal2;
local plot8_open;
local plot8_high;
local plot8_low;
local plot8_close;
function Create_window()
    local local_vars = {};
    time = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                time[period] = source:date(period) * 86400000;
            else
                time[period] = source:date(period) * 86400000;
            end
            return Triary(SafeGE(time:tick(period), vars["start"]) and SafeLE(time:tick(period), vars["finish"]), true, false);
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
    vars["Periods"] = instance.parameters.param1;
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param2);
    vars["Multiplier"] = instance.parameters.param3;
    vars["changeATR"] = instance.parameters.param4;
    vars["showsignals"] = instance.parameters.param5;
    vars["highlighting"] = instance.parameters.param6;
    vars["barcoloring"] = instance.parameters.param7;
    vars["MVA1_source"] = instance:addInternalStream(0, 0);
    vars["MVA1"] = core.indicators:create("MVA", vars["MVA1_source"], vars["Periods"]);
    vars["ATR1"] = core.indicators:create("ATR", source, vars["Periods"]);
    vars["!up_stream"] = instance:addInternalStream(0, 0);
    vars["!dn_stream"] = instance:addInternalStream(0, 0);
    vars["trend"] = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Line, "Up Trend", "Up Trend", core.colors().Green, 0, 0);
    plot1:setWidth(2);
    vars["upPlot"] = plot1;
    plot2 = instance:createTextOutput("plot2", "UpTrend Begins", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Green);
    plot3 = instance:createTextOutput("plot3", "Buy", "Arial", 12, core.H_Center, core.V_Center, core.colors().Green);
    plot4 = instance:addStream("plot4", core.Line, "Down Trend", "Down Trend", core.colors().Red, 0, 0);
    plot4:setWidth(2);
    vars["dnPlot"] = plot4;
    plot5 = instance:createTextOutput("plot5", "DownTrend Begins", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Red);
    plot6 = instance:createTextOutput("plot6", "Sell", "Arial", 12, core.H_Center, core.V_Center, core.colors().Red);
    plot7_c = instance:createTextOutput("plot7", "", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    plot7 = instance:addInternalStream(0, 0);
    vars["mPlot"] = plot7;
    vars["!channel1_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel1_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel1_1_c"] = core.colors().Green;
    instance:createChannelGroup("channel1_1", "channel1_1", vars["!channel1_1_u"], vars["!channel1_1_d"], Graphics:GetColor(vars["!channel1_1_c"]), vars["!channel1_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel1_1_c"]) or 100);
    vars["!channel1_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel1_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel1_2_c"] = core.colors().White;
    instance:createChannelGroup("channel1_2", "channel1_2", vars["!channel1_2_u"], vars["!channel1_2_d"], Graphics:GetColor(vars["!channel1_2_c"]), vars["!channel1_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel1_2_c"]) or 100);
    vars["!channel2_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel2_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel2_1_c"] = core.colors().Red;
    instance:createChannelGroup("channel2_1", "channel2_1", vars["!channel2_1_u"], vars["!channel2_1_d"], Graphics:GetColor(vars["!channel2_1_c"]), vars["!channel2_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel2_1_c"]) or 100);
    vars["!channel2_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel2_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel2_2_c"] = core.colors().White;
    instance:createChannelGroup("channel2_2", "channel2_2", vars["!channel2_2_u"], vars["!channel2_2_d"], Graphics:GetColor(vars["!channel2_2_c"]), vars["!channel2_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel2_2_c"]) or 100);
    vars["FromMonth"] = instance.parameters.param8;
    vars["FromDay"] = instance.parameters.param9;
    vars["FromYear"] = instance.parameters.param10;
    vars["ToMonth"] = instance.parameters.param11;
    vars["ToDay"] = instance.parameters.param12;
    vars["ToYear"] = instance.parameters.param13;
    vars["windowFunc1"] = Create_window();
    signal1 = PineStrategy:CreateEntrySignalV5("BUY");
    vars["windowFunc2"] = Create_window();
    signal2 = PineStrategy:CreateEntrySignalV5("SELL");
    vars["buy1"] = instance:addInternalStream(0, 0);
    vars["__barssince1"] = CreateBarsSince();
    vars["sell1"] = instance:addInternalStream(0, 0);
    vars["__barssince2"] = CreateBarsSince();
    plot8_open = instance:addStream("plot8_open", core.Line, "Open", "Open", core.colors().Black, 0, 0);
    plot8_high = instance:addStream("plot8_high", core.Line, "High", "High", core.colors().Black, 0, 0);
    plot8_low = instance:addStream("plot8_low", core.Line, "Low", "Low", core.colors().Black, 0, 0);
    plot8_close = instance:addStream("plot8_close", core.Line, "Close", "Close", core.colors().Black, 0, 0);
    instance:createCandleGroup("plot8", "plot8", plot8_open, plot8_high, plot8_low, plot8_close);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        vars["windowFunc1"].Clear();
        vars["windowFunc2"].Clear();
    else
    end
    PineScriptUtils:UpdateSources(period, mode);
    SafeSetFloat(vars["MVA1_source"], period, GetTrueRange(source, period));
    vars["MVA1"]:update(mode);
    vars["atr2"] = vars["MVA1"].DATA:tick(period);
    vars["ATR1"]:update(mode);
    vars["atr"] = Triary(vars["changeATR"], vars["ATR1"].DATA:tick(period), vars["atr2"]);
    vars["up"] = SafeMinus(vars["src"]:tick(period), (SafeMultiply(vars["Multiplier"], vars["atr"])));
    SafeSetFloat(vars["!up_stream"], period, vars["up"]);
    vars["!up_stream_index"] = 1;
    vars["up1"] = Nz(SafeGetFloat(vars["!up_stream"], period - vars["!up_stream_index"]), vars["up"]);
    vars["up"] = Triary(SafeGreater(source.close:tick(period - 1), vars["up1"]), SafeMax(vars["up"], vars["up1"]), vars["up"]);
    vars["dn"] = SafePlus(vars["src"]:tick(period), (SafeMultiply(vars["Multiplier"], vars["atr"])));
    SafeSetFloat(vars["!dn_stream"], period, vars["dn"]);
    vars["!dn_stream_index"] = 1;
    vars["dn1"] = Nz(SafeGetFloat(vars["!dn_stream"], period - vars["!dn_stream_index"]), vars["dn"]);
    vars["dn"] = Triary(SafeLess(source.close:tick(period - 1), vars["dn1"]), SafeMin(vars["dn"], vars["dn1"]), vars["dn"]);
    SafeSetFloat(vars["trend"], period, 1);
    SafeSetFloat(vars["trend"], period, Nz(SafeGetFloat(vars["trend"], period - 1), SafeGetFloat(vars["trend"], period)));
    SafeSetFloat(vars["trend"], period, Triary((SafeGetFloat(vars["trend"], period) == (-1)) and SafeGreater(source.close:tick(period), vars["dn1"]), 1, Triary((SafeGetFloat(vars["trend"], period) == 1) and SafeLess(source.close:tick(period), vars["up1"]), (-1), SafeGetFloat(vars["trend"], period))));
    Plot:SetValue(plot1, period, Triary((SafeGetFloat(vars["trend"], period) == 1), vars["up"], nil));
    vars["buySignal"] = (SafeGetFloat(vars["trend"], period) == 1) and (SafeGetFloat(vars["trend"], period - 1) == (-1));
    PlotShape:SetValue(plot2, period, source, Triary(vars["buySignal"], vars["up"], nil), "\161", "", "absolute", core.colors().Green);
    PlotShape:SetValue(plot3, period, source, Triary(vars["buySignal"] and vars["showsignals"], vars["up"], nil), "Buy", "Buy", "absolute", core.colors().Green);
    Plot:SetValue(plot4, period, Triary((SafeGetFloat(vars["trend"], period) == 1), nil, vars["dn"]));
    vars["sellSignal"] = (SafeGetFloat(vars["trend"], period) == (-1)) and (SafeGetFloat(vars["trend"], period - 1) == 1);
    PlotShape:SetValue(plot5, period, source, Triary(vars["sellSignal"], vars["dn"], nil), "\161", "", "absolute", core.colors().Red);
    PlotShape:SetValue(plot6, period, source, Triary(vars["sellSignal"] and vars["showsignals"], vars["dn"], nil), "Sell", "Sell", "absolute", core.colors().Red);
    plot7_series = (source.open:tick(period) + source.high:tick(period) + source.low:tick(period) + source.close:tick(period)) / 4;
    plot7[period] = PlotShape:SetValue(plot7_c, period, source, plot7_series, "\161", "", nil, core.colors().Blue);
    vars["longFillColor"] = Triary(vars["highlighting"], (Triary((SafeGetFloat(vars["trend"], period) == 1), core.colors().Green, core.colors().White)), core.colors().White);
    vars["shortFillColor"] = Triary(vars["highlighting"], (Triary((SafeGetFloat(vars["trend"], period) == (-1)), core.colors().Red, core.colors().White)), core.colors().White);
    channel1_from = vars["mPlot"];
    channel1_to = vars["upPlot"];
    channel1_c = vars["longFillColor"];
    Fill:SetValue(vars["!channel1_1_u"], vars["!channel1_1_d"], channel1_from, channel1_to, vars["!channel1_1_c"] == channel1_c, period);
    Fill:SetValue(vars["!channel1_2_u"], vars["!channel1_2_d"], channel1_from, channel1_to, vars["!channel1_2_c"] == channel1_c, period);
    channel2_from = vars["mPlot"];
    channel2_to = vars["dnPlot"];
    channel2_c = vars["shortFillColor"];
    Fill:SetValue(vars["!channel2_1_u"], vars["!channel2_1_d"], channel2_from, channel2_to, vars["!channel2_1_c"] == channel2_c, period);
    Fill:SetValue(vars["!channel2_2_u"], vars["!channel2_2_d"], channel2_from, channel2_to, vars["!channel2_2_c"] == channel2_c, period);
    vars["start"] = Timestamp(vars["FromYear"], vars["FromMonth"], vars["FromDay"], 00, 00, 0);
    vars["finish"] = Timestamp(vars["ToYear"], vars["ToMonth"], vars["ToDay"], 23, 59, 0);
    vars["longCondition"] = vars["buySignal"];
    if (vars["longCondition"]) then
        signal1:Execute(period, "BUY", true, nil, nil, nil, "", "oca.none", nil, vars["windowFunc1"].GetValue(period, mode), nil);
    end
    vars["shortCondition"] = vars["sellSignal"];
    if (vars["shortCondition"]) then
        signal2:Execute(period, "SELL", false, nil, nil, nil, "", "oca.none", nil, vars["windowFunc2"].GetValue(period, mode), nil);
    end
    SafeSetFloat(vars["buy1"], period, vars["__barssince1"]:set(period, vars["buySignal"]));
    SafeSetFloat(vars["sell1"], period, vars["__barssince2"]:set(period, vars["sellSignal"]));
    vars["color1"] = Triary(SafeLess(SafeGetFloat(vars["buy1"], period - 1), SafeGetFloat(vars["sell1"], period - 1)), core.colors().Green, Triary(SafeGreater(SafeGetFloat(vars["buy1"], period - 1), SafeGetFloat(vars["sell1"], period - 1)), core.colors().Red, nil));
    plot8_color = Triary(vars["barcoloring"], vars["color1"], nil);
    if plot8_color then
        plot8_open[period] = source.open[period];
        plot8_high[period] = source.high[period];
        plot8_low[period] = source.low[period];
        plot8_close[period] = source.close[period];
        plot8_open:setColor(period, Graphics:GetColor(plot8_color));
    else
        plot8_open:setNoData(period);
        plot8_high:setNoData(period);
        plot8_low:setNoData(period);
        plot8_close:setNoData(period);
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
Plot = {};
function Plot:SetValueWithColor(plot, period, value, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if Plot:SetValue(plot, period, value) then
        plot:setColor(plot, clr)
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
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value or transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label, clr);
        return source.high[period];
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label, clr);
        return source.low[period];
    end
    plot:set(period, value, text, label, clr);
    return value;
end
Fill = {};
function Fill:SetValue(up_channel, dn_channel, value1, value2, mineColor, period)
    if not value1:hasData(period) or not value2:hasData(period) or mineColor ~= true then
        up_channel:setNoData(period);
        dn_channel:setNoData(period);
        return;
    end
    up_channel[period] = math.max(value1[period], value2[period]);
    dn_channel[period] = math.min(value1[period], value2[period]);
end
PineStrategy = {};
PineStrategy.streams = {};
function PineStrategy:CreateEntrySignalV4(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateEntrySignalV5(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateCloseSignalV4(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal " .. id, "Close Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, when, qty, qty_percent, comment, alert_message)
        if when then
            self.stream[period] = 1;
        end
    end
    return signal;
end
function PineStrategy:CreateCloseSignalV5(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal " .. id, "Close Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
        if immediately then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateExitSignalV4(id)
    local signal = {};
    local stream_id_1 = "exit_signal" .. id .. "_tp";
    local stream_id_2 = "exit_signal" .. id .. "_sl";
    if self.streams[stream_id_1] == nil then
        self.streams[stream_id_1] = instance:addStream(stream_id_1, core.Line, "TP Signal " .. id, "TP Signal " .. id, core.colors().Red, 0, 0);
        self.streams[stream_id_2] = instance:addStream(stream_id_2, core.Line, "SL Signal " .. id, "SL Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream_tp = self.streams[stream_id_1];
    signal.stream_sl = self.streams[stream_id_2];
    function signal:Execute(period, id, from_entry, qty, qty_percent, profit, limit, loss, stop, trail_price, trail_points, trail_offset, oca_name, comment, when, alert_message)
        if when then
            self.stream_sl[period] = limit;
            self.stream_tp[period] = stop;
        end
    end
    return signal;
end
function PineStrategy:CreateExitSignalV5(id)
    local signal = {};
    local stream_id_1 = "exit_signal" .. id .. "_tp";
    local stream_id_2 = "exit_signal" .. id .. "_sl";
    if self.streams[stream_id_1] == nil then
        self.streams[stream_id_1] = instance:addStream(stream_id_1, core.Line, "TP Signal " .. id, "TP Signal " .. id, core.colors().Red, 0, 0);
        self.streams[stream_id_2] = instance:addStream(stream_id_2, core.Line, "SL Signal " .. id, "SL Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream_tp = self.streams[stream_id_1];
    signal.stream_sl = self.streams[stream_id_2];
    function signal:Execute(period, id, from_entry, qty, qty_percent, profit, limit, loss, stop, trail_price, trail_points, trail_offset, oca_name, comment, 
            comment_profit, comment_loss, comment_trailing, alert_message, alert_profit, alert_loss, alert_trailing, disable_alert)
        self.stream_sl[period] = limit;
        self.stream_tp[period] = stop;
    end
    return signal;
end
function PineStrategy:EntryV4(id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:EntryV5(id, direction, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV4(id, when, qty, qty_percent, comment, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV5(id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
    if disable_alert == true then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:Equity(account)
    local accounts = core.host:findTable("accounts");
    if account == nil then
        local enum = accounts:enumerator();
        local row = enum:next();
        while row ~= nil do
            return row.Equity;
        end
        return 0;
    end
    return accounts:find("AccountID", account).Equity;
end
function PineStrategy:PositionSize(symbol)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    local total = 0;
    while row ~= nil do
        if row.Instrument == symbol then
            if row.BS == "B" then
                total = total + row.Lot;
            else
                total = total - row.Lot;
            end
        end
        row = enum:next();
    end
    return total;
end
function PineStrategy:PositionAvgPrice(symbol)
    return 0;
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=76449
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
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