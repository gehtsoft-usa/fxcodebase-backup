-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76405
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
    indicator:name("Trend Lines for RSI, CCI, Momentum, OBV");
    indicator:description("Trend Lines for RSI, CCI, Momentum, OBV");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addString("param1", "Indicator", "", "RSI");
    indicator.parameters:addStringAlternative("param1", "RSI", "", "RSI");
    indicator.parameters:addStringAlternative("param1", "CCI", "", "CCI");
    indicator.parameters:addStringAlternative("param1", "OBV", "", "OBV");
    indicator.parameters:addStringAlternative("param1", "Momentum", "", "Momentum");
    indicator.parameters:addString("param2", "Source", "", "close");
    indicator.parameters:addStringAlternative("param2", "Open", "", "open");
    indicator.parameters:addStringAlternative("param2", "High", "", "high");
    indicator.parameters:addStringAlternative("param2", "Low", "", "low");
    indicator.parameters:addStringAlternative("param2", "Close", "", "close");
    indicator.parameters:addStringAlternative("param2", "Median", "", "median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param2", "OHLC4", "", "ohlc4");
    indicator.parameters:addStringAlternative("param2", "HLCC4", "", "hlcc4");
    indicator.parameters:addInteger("param3", "RSI Length", "", 14, 1);
    indicator.parameters:addInteger("param4", "CCI Length", "", 20, 1);
    indicator.parameters:addInteger("param5", "Momentum Length", "", 10, 1);
    indicator.parameters:addInteger("param6", "Pivot Point Period", "", 10, 5, 50);
    indicator.parameters:addInteger("param7", "Number of Pivot Point to check", "", 3, 2, 3);
end

local source;
local plot1;
local plot2;
function Create_getloc()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(bar_i, period, mode)
            local_vars["_ret"] = SafeMinus(period + vars["prd"], bar_i);
            return local_vars["_ret"];
        end
    };
end
function Create_getloval()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(l1, l2, period, mode)
            local_vars["_ret1"] = Triary((l1 == 1), vars["b1val"], Triary((l1 == 2), vars["b2val"], Triary((l1 == 3), vars["b3val"], 0)));
            local_vars["_ret2"] = Triary((l2 == 1), vars["b1val"], Triary((l2 == 2), vars["b2val"], Triary((l2 == 3), vars["b3val"], 0)));
            return local_vars["_ret1"], local_vars["_ret2"];
        end
    };
end
function Create_getlopos()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(l1, l2, period, mode)
            local_vars["_ret1"] = Triary((l1 == 1), vars["b1pos"], Triary((l1 == 2), vars["b2pos"], Triary((l1 == 3), vars["b3pos"], 0)));
            local_vars["_ret2"] = Triary((l2 == 1), vars["b1pos"], Triary((l2 == 2), vars["b2pos"], Triary((l2 == 3), vars["b3pos"], 0)));
            return local_vars["_ret1"], local_vars["_ret2"];
        end
    };
end
function Create_gethival()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(l1, l2, period, mode)
            local_vars["_ret1"] = Triary((l1 == 1), vars["t1val"], Triary((l1 == 2), vars["t2val"], Triary((l1 == 3), vars["t3val"], 0)));
            local_vars["_ret2"] = Triary((l2 == 1), vars["t1val"], Triary((l2 == 2), vars["t2val"], Triary((l2 == 3), vars["t3val"], 0)));
            return local_vars["_ret1"], local_vars["_ret2"];
        end
    };
end
function Create_gethipos()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(l1, l2, period, mode)
            local_vars["_ret1"] = Triary((l1 == 1), vars["t1pos"], Triary((l1 == 2), vars["t2pos"], Triary((l1 == 3), vars["t3pos"], 0)));
            local_vars["_ret2"] = Triary((l2 == 1), vars["t1pos"], Triary((l2 == 2), vars["t2pos"], Triary((l2 == 3), vars["t3pos"], 0)));
            return local_vars["_ret1"], local_vars["_ret2"];
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
    vars["indi"] = instance.parameters.param1;
    vars["Src"] = PineScriptUtils:CreateSource(source, instance.parameters.param2);
    vars["rsilen"] = instance.parameters.param3;
    vars["ccilen"] = instance.parameters.param4;
    vars["momlen"] = instance.parameters.param5;
    vars["prd"] = instance.parameters.param6;
    vars["PPnum"] = instance.parameters.param7;
    vars["RSI1"] = core.indicators:create("RSI", vars["Src"], vars["rsilen"]);
    vars["PINESCRIPT CCI1"] = core.indicators:create("PINESCRIPT CCI", vars["Src"], vars["ccilen"]);
    vars["PINESCRIPT CCI2"] = core.indicators:create("PINESCRIPT CCI", vars["Src"], vars["momlen"]);
    plot1 = instance:addStream("plot1", core.Line, "", "", core.colors().Blue, 0, 0);
    plot1:setStyle(core.LINE_NONE);
    vars["hline1"] = Triary((vars["indi"] == "RSI"), 70, Triary((vars["indi"] == "CCI"), 100, nil));
    plot1:addLevel(vars["hline1"], core.LINE_SOLID, 1, core.colors().Blue);
    vars["h1"] = vars["hline1"];
    vars["hline2"] = Triary((vars["indi"] == "RSI"), 30, Triary((vars["indi"] == "CCI"), (-100), nil));
    plot1:addLevel(vars["hline2"], core.LINE_SOLID, 1, core.colors().Blue);
    vars["h2"] = vars["hline2"];
    vars["channel1_from"] = instance:addInternalStream(0, 0);
    vars["channel1_to"] = instance:addInternalStream(0, 0);
    channel1_color = Graphics:AddTransparency(core.rgb(153, 21, 255), 0);
    instance:createChannelGroup("channel1", "channel1", vars["channel1_from"], vars["channel1_to"], Graphics:GetColor(channel1_color), channel1_color and 100 - Graphics:GetTransparencyPercent(channel1_color) or 100, true);
    plot2 = instance:addStream("plot2", core.Line, "", "", core.colors().Blue, 0, 0);
    plot2:setWidth(2);
    plot2:setStyle(core.LINE_SOLID);
    vars["__pivothigh1_source"] = instance:addInternalStream(0, 0);
    vars["__pivothigh1"] = CreatePivotHigh(vars["__pivothigh1_source"], vars["prd"], vars["prd"]);
    vars["__pivotlow1_source"] = instance:addInternalStream(0, 0);
    vars["__pivotlow1"] = CreatePivotLow(vars["__pivotlow1_source"], vars["prd"], vars["prd"]);
    vars["__valuewhen1"] = CreateValueWhen();
    vars["!src_stream"] = instance:addInternalStream(0, 0);
    vars["getlocFunc1"] = Create_getloc();
    vars["__valuewhen2"] = CreateValueWhen();
    vars["getlocFunc2"] = Create_getloc();
    vars["__valuewhen3"] = CreateValueWhen();
    vars["getlocFunc3"] = Create_getloc();
    vars["__valuewhen4"] = CreateValueWhen();
    vars["getlocFunc4"] = Create_getloc();
    vars["__valuewhen5"] = CreateValueWhen();
    vars["getlocFunc5"] = Create_getloc();
    vars["__valuewhen6"] = CreateValueWhen();
    vars["getlocFunc6"] = Create_getloc();
    vars["l1"] = Variable:Create();
    vars["l2"] = Variable:Create();
    vars["l3"] = Variable:Create();
    vars["t1"] = Variable:Create();
    vars["t2"] = Variable:Create();
    vars["t3"] = Variable:Create();
    vars["getlovalFunc7"] = Create_getloval();
    vars["getloposFunc8"] = Create_getlopos();
    vars["getlocFunc9"] = Create_getloc();
    vars["gethivalFunc10"] = Create_gethival();
    vars["gethiposFunc11"] = Create_gethipos();
    vars["getlocFunc12"] = Create_getloc();
    Line:Prepare(50);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        vars["getlocFunc1"].Clear();
        vars["getlocFunc2"].Clear();
        vars["getlocFunc3"].Clear();
        vars["getlocFunc4"].Clear();
        vars["getlocFunc5"].Clear();
        vars["getlocFunc6"].Clear();
        vars["l1"]:Clear();
        vars["l2"]:Clear();
        vars["l3"]:Clear();
        vars["t1"]:Clear();
        vars["t2"]:Clear();
        vars["t3"]:Clear();
        vars["getlovalFunc7"].Clear();
        vars["getloposFunc8"].Clear();
        vars["getlocFunc9"].Clear();
        vars["gethivalFunc10"].Clear();
        vars["gethiposFunc11"].Clear();
        vars["getlocFunc12"].Clear();
    else
    end
    PineScriptUtils:UpdateSources(period, mode);
    vars["RSI1"]:update(mode);
    vars["Rsi"] = vars["RSI1"].DATA:tick(period);
    vars["PINESCRIPT CCI1"]:update(mode);
    vars["Cci"] = vars["PINESCRIPT CCI1"].DATA:tick(period);
    vars["PINESCRIPT CCI2"]:update(mode);
    vars["Mom"] = vars["PINESCRIPT CCI2"].DATA:tick(period);
    vars["src"] = Triary((vars["indi"] == "RSI"), vars["Rsi"], Triary((vars["indi"] == "CCI"), vars["Cci"], Triary((vars["indi"] == "Momentum"), vars["Mom"], obv)));
    vars["hline1"] = Triary((vars["indi"] == "RSI"), 70, Triary((vars["indi"] == "CCI"), 100, nil));
    vars["hline2"] = Triary((vars["indi"] == "RSI"), 30, Triary((vars["indi"] == "CCI"), (-100), nil));
    SafeSetFloat(vars["channel1_from"], period, vars["h1"]);
    SafeSetFloat(vars["channel1_to"], period, vars["h2"]);
    plot2[period] = vars["src"];
    vars["ph"] = nil;
    vars["pl"] = nil;
    SafeSetFloat(vars["__pivothigh1_source"], period, vars["src"]);
    vars["ph"] = vars["__pivothigh1"]:get(period);
    SafeSetFloat(vars["__pivotlow1_source"], period, vars["src"]);
    vars["pl"] = vars["__pivotlow1"]:get(period);
    vars["t1pos"] = vars["__valuewhen1"]:set(period, vars["ph"], period, 0);
    SafeSetFloat(vars["!src_stream"], period, vars["src"]);
    vars["!src_stream_index"] = vars["getlocFunc1"].GetValue(vars["t1pos"], period, mode);
    vars["t1val"] = Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"]));
    vars["t2pos"] = vars["__valuewhen2"]:set(period, vars["ph"], period, 1);
    vars["!src_stream_index"] = vars["getlocFunc2"].GetValue(vars["t2pos"], period, mode);
    vars["t2val"] = Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"]));
    vars["t3pos"] = vars["__valuewhen3"]:set(period, vars["ph"], period, 2);
    vars["!src_stream_index"] = vars["getlocFunc3"].GetValue(vars["t3pos"], period, mode);
    vars["t3val"] = Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"]));
    vars["b1pos"] = vars["__valuewhen4"]:set(period, vars["pl"], period, 0);
    vars["!src_stream_index"] = vars["getlocFunc4"].GetValue(vars["b1pos"], period, mode);
    vars["b1val"] = Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"]));
    vars["b2pos"] = vars["__valuewhen5"]:set(period, vars["pl"], period, 1);
    vars["!src_stream_index"] = vars["getlocFunc5"].GetValue(vars["b2pos"], period, mode);
    vars["b2val"] = Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"]));
    vars["b3pos"] = vars["__valuewhen6"]:set(period, vars["pl"], period, 2);
    vars["!src_stream_index"] = vars["getlocFunc6"].GetValue(vars["b3pos"], period, mode);
    vars["b3val"] = Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"]));
    if not vars["l1"]:IsInitialized() then
        vars["l1"]:Set(nil);
    end
    if not vars["l2"]:IsInitialized() then
        vars["l2"]:Set(nil);
    end
    if not vars["l3"]:IsInitialized() then
        vars["l3"]:Set(nil);
    end
    if not vars["t1"]:IsInitialized() then
        vars["t1"]:Set(nil);
    end
    if not vars["t2"]:IsInitialized() then
        vars["t2"]:Set(nil);
    end
    if not vars["t3"]:IsInitialized() then
        vars["t3"]:Set(nil);
    end
    Line:Delete(vars["l1"]:Get());
    Line:Delete(vars["l2"]:Get());
    Line:Delete(vars["l3"]:Get());
    Line:Delete(vars["t1"]:Get());
    Line:Delete(vars["t2"]:Get());
    Line:Delete(vars["t3"]:Get());
    vars["countlinelo"] = 0;
    vars["countlinehi"] = 0;
    local for1_from = 1;
    local for1_to = vars["PPnum"] - 1;
    if for1_to ~= nil and for1_from ~= nil then
    local for1_step = for1_from < for1_to and 1 or -1;
    for p1 = for1_from, for1_to, for1_step do
        vars["uv1"] = 0.0;
        vars["uv2"] = 0.0;
        vars["up1"] = 0;
        vars["up2"] = 0;
        local for2_from = vars["PPnum"];
        local for2_to = p1 + 1;
        if for2_to ~= nil and for2_from ~= nil then
        local for2_step = for2_from < for2_to and 1 or -1;
        for p2 = for2_from, for2_to, for2_step do
            val1_ret_val, val2_ret_val = vars["getlovalFunc7"].GetValue(p1, p2, period, mode);
            vars["val1"] = val1_ret_val;
            vars["val2"] = val2_ret_val;
            pos1_ret_val, pos2_ret_val = vars["getloposFunc8"].GetValue(p1, p2, period, mode);
            vars["pos1"] = pos1_ret_val;
            vars["pos2"] = pos2_ret_val;
            if SafeGreater(vars["val1"], vars["val2"]) then
                vars["diff"] = SafeDivide((SafeMinus(vars["val1"], vars["val2"])), (SafeMinus(vars["pos1"], vars["pos2"])));
                vars["hline"] = SafePlus(vars["val2"], vars["diff"]);
                vars["lloc"] = period;
                vars["lval"] = vars["src"];
                vars["valid"] = true;
                local for3_from = SafeMinus(SafePlus(vars["pos2"], 1), vars["prd"]);
                local for3_to = period;
                if for3_to ~= nil and for3_from ~= nil then
                local for3_step = for3_from < for3_to and 1 or -1;
                for x = for3_from, for3_to, for3_step do
                    vars["!src_stream_index"] = vars["getlocFunc9"].GetValue(SafePlus(x, vars["prd"]), period, mode);
                    if SafeLess(Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"])), vars["hline"]) then
                        vars["valid"] = false;
                    end
                    vars["lloc"] = x;
                    vars["lval"] = vars["hline"];
                    vars["hline"] = SafePlus(vars["hline"], vars["diff"]);
                end
                end
                if vars["valid"] then
                    vars["uv1"] = vars["hline"];
                    vars["uv2"] = vars["val2"];
                    vars["up1"] = vars["lloc"];
                    vars["up2"] = vars["pos2"];
                    break;
                end
            end
        end
        end
        vars["dv1"] = 0.0;
        vars["dv2"] = 0.0;
        vars["dp1"] = 0;
        vars["dp2"] = 0;
        local for4_from = vars["PPnum"];
        local for4_to = p1 + 1;
        if for4_to ~= nil and for4_from ~= nil then
        local for4_step = for4_from < for4_to and 1 or -1;
        for p2 = for4_from, for4_to, for4_step do
            val1_ret_val, val2_ret_val = vars["gethivalFunc10"].GetValue(p1, p2, period, mode);
            vars["val1"] = val1_ret_val;
            vars["val2"] = val2_ret_val;
            pos1_ret_val, pos2_ret_val = vars["gethiposFunc11"].GetValue(p1, p2, period, mode);
            vars["pos1"] = pos1_ret_val;
            vars["pos2"] = pos2_ret_val;
            if SafeLess(vars["val1"], vars["val2"]) then
                vars["diff"] = SafeDivide((SafeMinus(vars["val2"], vars["val1"])), (SafeMinus(vars["pos1"], vars["pos2"])));
                vars["hline"] = SafeMinus(vars["val2"], vars["diff"]);
                vars["lloc"] = period;
                vars["lval"] = vars["src"];
                vars["valid"] = true;
                local for5_from = SafeMinus(SafePlus(vars["pos2"], 1), vars["prd"]);
                local for5_to = period;
                if for5_to ~= nil and for5_from ~= nil then
                local for5_step = for5_from < for5_to and 1 or -1;
                for x = for5_from, for5_to, for5_step do
                    vars["!src_stream_index"] = vars["getlocFunc12"].GetValue(SafePlus(x, vars["prd"]), period, mode);
                    if SafeGreater(Nz(SafeGetFloat(vars["!src_stream"], vars["!src_stream_index"])), vars["hline"]) then
                        vars["valid"] = false;
                        break;
                    end
                    vars["lloc"] = x;
                    vars["lval"] = vars["hline"];
                    vars["hline"] = SafeMinus(vars["hline"], vars["diff"]);
                end
                end
                if vars["valid"] then
                    vars["dv1"] = vars["hline"];
                    vars["dv2"] = vars["val2"];
                    vars["dp1"] = vars["lloc"];
                    vars["dp2"] = vars["pos2"];
                    break;
                end
            end
        end
        end
        if (vars["up1"] ~= 0) and (vars["up2"] ~= 0) then
            vars["countlinelo"] = vars["countlinelo"] + 1;
            vars["l1"]:Set(Triary((vars["countlinelo"] == 1), Line:New(SafeMinus(vars["up2"], vars["prd"]), vars["uv2"], vars["up1"], vars["uv1"]), vars["l1"]:Get()));
            vars["l2"]:Set(Triary((vars["countlinelo"] == 2), Line:New(SafeMinus(vars["up2"], vars["prd"]), vars["uv2"], vars["up1"], vars["uv1"]), vars["l2"]:Get()));
            vars["l3"]:Set(Triary((vars["countlinelo"] == 3), Line:New(SafeMinus(vars["up2"], vars["prd"]), vars["uv2"], vars["up1"], vars["uv1"]), vars["l3"]:Get()));
        end
        if (vars["dp1"] ~= 0) and (vars["dp2"] ~= 0) then
            vars["countlinehi"] = vars["countlinehi"] + 1;
            vars["t1"]:Set(Triary((vars["countlinehi"] == 1), Line:New(SafeMinus(vars["dp2"], vars["prd"]), vars["dv2"], vars["dp1"], vars["dv1"]), vars["t1"]:Get()));
            vars["t2"]:Set(Triary((vars["countlinehi"] == 2), Line:New(SafeMinus(vars["dp2"], vars["prd"]), vars["dv2"], vars["dp1"], vars["dv1"]), vars["t2"]:Get()));
            vars["t3"]:Set(Triary((vars["countlinehi"] == 3), Line:New(SafeMinus(vars["dp2"], vars["prd"]), vars["dv2"], vars["dp1"], vars["dv1"]), vars["t3"]:Get()));
        end
    end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
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
    return core.tableToDate(date);
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
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
function CreatePivotHigh(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
end
function CreatePivotLow(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
end
function CreateValueWhen()
    local vw = {};
    vw._stream = instance:addInternalStream(0, 0); 
    vw._count = 0;
    function vw:set(period, condition, value, occurrence)
        if self._count > 0 and self._stream:getBookmark(self._count) == period then
            self._stream:setBookmark(self._count, -1);
        end
        if condition then
            if self._count == 0 or self._stream:getBookmark(self._count) ~= -1 then
                self._count = self._count + 1;
            end
            self._stream:setBookmark(self._count, period);
            if value == nil then
                self._stream:setNoData(period);
            else
                self._stream[period] = value;
            end
        end
        if self._count <= occurrence then
            return nil;
        end
        return self._stream[self._stream:getBookmark(self._count - occurrence)];
    end
    return vw;
end
Variable = {};
function Variable:Create()
    local var = {};
    var._init = false;
    function var:Clear()
        self._init = false;
        self._value = nil;
    end
    function var:Get()
        return self._value;
    end
    function var:Set(value)
        self._value = value;
        self._init = true;
    end
    function var:IsInitialized()
        return self._value;
    end
    return var;
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
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
    return newLine;
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76405
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