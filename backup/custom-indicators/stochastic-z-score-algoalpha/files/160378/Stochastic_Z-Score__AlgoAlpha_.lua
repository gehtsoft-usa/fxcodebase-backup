-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76274

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

local vars = {};
function Init()
    indicator:name("Stochastic Z-Score [AlgoAlpha]");
    indicator:description("Stochastic Z-Score [AlgoAlpha]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addString("param1", "Source", "Price series used for all calculations. Changing it alters the base values from which the Z-score and momentum are derived.", "typical");
    indicator.parameters:addStringAlternative("param1", "Open", "", "open");
    indicator.parameters:addStringAlternative("param1", "High", "", "high");
    indicator.parameters:addStringAlternative("param1", "Low", "", "low");
    indicator.parameters:addStringAlternative("param1", "Close", "", "close");
    indicator.parameters:addStringAlternative("param1", "Median", "", "median");
    indicator.parameters:addStringAlternative("param1", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param1", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param1", "OHLC4", "", "ohlc4");
    indicator.parameters:addStringAlternative("param1", "HLCC4", "", "hlcc4");
    indicator.parameters:addInteger("param2", "Length", "Look-back period for moving averages and deviations. Higher values give smoother, slower signals; lower values make the oscillator faster and more sensitive.", 21);
    indicator.parameters:addBoolean("param3", "Show Histogram", "Toggle display of the raw, unsmoothed Z-score as columns. Useful for visualising noise layer beneath the smoothed oscillator.", false);
    indicator.parameters:addColor("param4", "Bullish Colour", "Primary colour for bullish visual elements. Adjust for preferred palette ? affects bars, fills, and labels when momentum is positive.", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 255, 187), 0)));
    indicator.parameters:addColor("param5", "Bearish Colour", "Primary colour for bearish visual elements. Adjust for preferred palette ? affects bars, fills, and labels when momentum is negative.", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    signaler:Init(indicator.parameters);
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7;
local plot8;
local plot9;
local plot10;
local plot11;
local plot12;
local plot13;
local plot14;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param1);
    vars["len"] = instance.parameters.param2;
    vars["hist"] = instance.parameters.param3;
    core.colors().Green = Graphics:AddTransparency(instance.parameters.param4, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 255, 187), 0)));
    core.colors().Red = Graphics:AddTransparency(instance.parameters.param5, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    vars["MVA1"] = core.indicators:create("MVA", vars["src"], vars["len"]);
    vars["zscore"] = instance:addInternalStream(0, 0);
    vars["__stochastic1"] = CreateStochastic(vars["zscore"], vars["zscore"], vars["zscore"], vars["len"]);
    vars["smoothed_scaled"] = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator("PINESCRIPT HMA") ~= nil, "Please, download and install PINESCRIPT HMA.lua indicator");
    vars["PINESCRIPT HMA1_source"] = instance:addInternalStream(0, 0);
    vars["PINESCRIPT HMA1"] = core.indicators:create("PINESCRIPT HMA", vars["PINESCRIPT HMA1_source"], vars["len"]);
    vars["PINESCRIPT ALMA1"] = core.indicators:create("PINESCRIPT ALMA", vars["zscore"], vars["len"], 0, 0.1, false);
    plot1 = instance:addStream("plot1", core.Bar, "Z-Score", "Z-Score", core.colors().Blue, 0, 0);
    plot1:setWidth(2);
    plot2 = instance:addStream("plot2", core.Line, "Smoothed Oscillator", "Smoothed Oscillator", core.colors().Blue, 0, 0);
    plot2:setWidth(3);
    plot2:setStyle(core.LINE_SOLID);
    vars["main"] = plot2;
    plot3 = instance:addStream("plot3", core.Line, "Oscillator (Lag 1)", "Oscillator (Lag 1)", core.colors().Blue, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    vars["main1"] = plot3;
    plot4 = instance:addStream("plot4", core.Line, "Long-Term Momentum (ALMA)", "Long-Term Momentum (ALMA)", core.colors().Blue, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    vars["longtm"] = plot4;
    plot5 = instance:addStream("plot5", core.Line, "Zero Line", "Zero Line", core.colors().Blue, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_SOLID);
    vars["mid"] = plot5;
    plot6 = instance:addStream("plot6", core.Line, "Upper", "Upper", core.colors().Blue, 0, 0);
    plot6:setWidth(3);
    plot6:setStyle(core.LINE_SOLID);
    vars["u"] = plot6;
    plot7 = instance:addStream("plot7", core.Line, "Down", "Down", core.colors().Blue, 0, 0);
    plot7:setWidth(3);
    plot7:setStyle(core.LINE_SOLID);
    vars["d"] = plot7;
    plot8 = instance:addStream("plot8", core.Line, "Upper Outer", "Upper Outer", core.colors().Blue, 0, 0);
    plot8:setWidth(3);
    plot8:setStyle(core.LINE_SOLID);
    vars["u1"] = plot8;
    plot9 = instance:addStream("plot9", core.Line, "Down Outer", "Down Outer", core.colors().Blue, 0, 0);
    plot9:setWidth(3);
    plot9:setStyle(core.LINE_SOLID);
    vars["d1"] = plot9;
    vars["cross_1_y_src"] = instance:addInternalStream(0, 0);
    plot10 = instance:createTextOutput("plot10", "plot10", "Verdana", 10, core.H_Center, core.V_Top, core.COLOR_LABEL, 0);
    vars["cross_2_y_src"] = instance:addInternalStream(0, 0);
    plot11 = instance:createTextOutput("plot11", "plot11", "Verdana", 10, core.H_Center, core.V_Top, core.colors().Green, 0);
    vars["cross_3_y_src"] = instance:addInternalStream(0, 0);
    plot12 = instance:createTextOutput("plot12", "plot12", "Verdana", 10, core.H_Center, core.V_Top, core.colors().Red, 0);
    vars["cross_4_y_src"] = instance:addInternalStream(0, 0);
    plot13 = instance:createTextOutput("plot13", "Bullish Trend", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Green + math.floor(50 / 100 * 255) * 16777216);
    vars["cross_5_y_src"] = instance:addInternalStream(0, 0);
    plot14 = instance:createTextOutput("plot14", "Bearish Trend", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red + math.floor(50 / 100 * 255) * 16777216);
    vars["channel1_top"] = instance:addStream("channel1_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel1_bottom"] = instance:addInternalStream(0, 0);
    vars["channel1_top_value"] = 2.5;
    vars["channel1_bottom_value"] = 2;
    channel1_color = core.colors().Blue;
    instance:createChannelGroup("channel1", "channel1", vars["channel1_top"], vars["channel1_bottom"], channel1_color, channel1_color and 100 - Graphics:GetTransparencyPercent(channel1_color) or 100, true);
    vars["channel2_top"] = instance:addStream("channel2_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel2_bottom"] = instance:addInternalStream(0, 0);
    channel2_color = core.colors().Blue;
    instance:createChannelGroup("channel2", "channel2", vars["channel2_top"], vars["channel2_bottom"], channel2_color, channel2_color and 100 - Graphics:GetTransparencyPercent(channel2_color) or 100, true);
    channel3_color = core.colors().Blue;
    instance:createChannelGroup("channel3", "channel3", vars["main"], vars["main1"], Graphics:GetColor(channel3_color), channel3_color and 100 - Graphics:GetTransparencyPercent(channel3_color) or 100, true);
    vars["channel4_top"] = instance:addStream("channel4_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel4_bottom"] = instance:addInternalStream(0, 0);
    vars["channel4_bottom_value"] = 0;
    channel4_color = core.colors().Blue;
    instance:createChannelGroup("channel4", "channel4", vars["channel4_top"], vars["channel4_bottom"], channel4_color, channel4_color and 100 - Graphics:GetTransparencyPercent(channel4_color) or 100, true);
    signaler:Prepare(nameOnly);
    vars["cross_6_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_7_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_8_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_11_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_12_x_src"] = instance:addInternalStream(0, 0);
end

function Update(period, mode)
    PineScriptUtils:UpdateSources(period, mode);
    vars["MVA1"]:update(mode);
    basis = vars["MVA1"].DATA:tick(period);
    if vars["src"]:first() > period - (vars["len"]) then return; end
    SafeSetFloat(vars["zscore"], period, SafeDivide((SafeMinus(vars["src"]:tick(period), basis)), mathex.stdev(vars["src"], core.rangeTo(period, vars["len"]))));
    stochZ = vars["__stochastic1"]:get(period);
    scaledSZ = SafeMinus(SafeDivide(stochZ, 25), 2);
    SafeSetFloat(vars["PINESCRIPT HMA1_source"], period, scaledSZ);
    vars["PINESCRIPT HMA1"]:update(mode);
    SafeSetFloat(vars["smoothed_scaled"], period, vars["PINESCRIPT HMA1"].DATA:tick(period));
    vars["PINESCRIPT ALMA1"]:update(mode);
    ltm = vars["PINESCRIPT ALMA1"].DATA:tick(period);
    zscore_color = Color:FromGradient(SafeGetFloat(vars["zscore"], period), (-2), 2, core.colors().Red, core.colors().Green) + math.floor(SafeMax(SafeMin(Int(SafeMultiply((SafeMinus(1, SafeDivide(SafeAbs(SafeGetFloat(vars["zscore"], period)), 4))), 100)), 70), 70) / 100 * 255) * 16777216;
    plot1[period] = SafeGetFloat(vars["zscore"], period);
    plot1:setColor(period, zscore_color);
    smoothed_scaled_prev = SafeGetFloat(vars["smoothed_scaled"], period - 1);
    smoothed_scaled_color = core.colors().Gray + math.floor(Triary(SafeGreater(SafeGetFloat(vars["smoothed_scaled"], period), smoothed_scaled_prev), 0, 50) / 100 * 255) * 16777216;
    plot2[period] = SafeGetFloat(vars["smoothed_scaled"], period);
    plot2:setColor(period, smoothed_scaled_color);
    plot3[period] = smoothed_scaled_prev;
    plot3:setColor(period, core.colors().Gray + math.floor(Triary(SafeGreater(SafeGetFloat(vars["smoothed_scaled"], period), smoothed_scaled_prev), 20, 70) / 100 * 255) * 16777216);
    ltm_color = Triary(SafeGreater(ltm, 0), core.colors().Green, core.colors().Red) + math.floor(70 / 100 * 255) * 16777216;
    plot4[period] = ltm;
    plot4:setColor(period, ltm_color);
    plot5[period] = 0;
    upper_color = Color:FromGradient(SafeMax(0, SafeGetFloat(vars["smoothed_scaled"], period)), 0, 2, core.colors().Gray, core.colors().Red) + math.floor(70 / 100 * 255) * 16777216;
    lower_color = Color:FromGradient(SafeMin(0, SafeGetFloat(vars["smoothed_scaled"], period)), (-2), 0, core.colors().Green, core.colors().Gray) + math.floor(70 / 100 * 255) * 16777216;
    plot6[period] = 2;
    plot6:setColor(period, upper_color);
    plot7[period] = (-2);
    plot7:setColor(period, lower_color);
    plot8[period] = 2.5;
    plot8:setColor(period, Color:FromGradient(SafeMax(0, SafeGetFloat(vars["smoothed_scaled"], period)), 0, 2.5, core.colors().Gray, core.colors().Red));
    plot9[period] = (-2.5);
    plot9:setColor(period, Color:FromGradient(SafeMin(0, SafeGetFloat(vars["smoothed_scaled"], period)), (-2.5), 0, core.colors().Green, core.colors().Gray));
    SafeSetFloat(vars["cross_1_y_src"], period, smoothed_scaled_prev);
    PlotChar:SetValue(plot10, period, source, Triary(SafeCrosses(vars["smoothed_scaled"], vars["cross_1_y_src"], period), smoothed_scaled_prev, nil), "?", "", "absolute");
    SafeSetFloat(vars["cross_2_y_src"], period, smoothed_scaled_prev);
    PlotChar:SetValue(plot11, period, source, Triary(SafeCrossesOver(vars["smoothed_scaled"], vars["cross_2_y_src"], period) and SafeGreater(ltm, 0) and SafeLess(smoothed_scaled_prev, (-2)), (-3), nil), "?", "", "absolute");
    SafeSetFloat(vars["cross_3_y_src"], period, smoothed_scaled_prev);
    PlotChar:SetValue(plot12, period, source, Triary(SafeCrossesUnder(vars["smoothed_scaled"], vars["cross_3_y_src"], period) and SafeLess(ltm, 0) and SafeGreater(smoothed_scaled_prev, 2), 3, nil), "?", "", "absolute");
    SafeSetFloat(vars["cross_4_y_src"], period, smoothed_scaled_prev);
    PlotShape:SetValue(plot13, period, source, SafeCrossesOver(vars["smoothed_scaled"], vars["cross_4_y_src"], period) and SafeGreater(ltm, 0) and SafeLess(smoothed_scaled_prev, (-2)), "?", "?", "belowbar");
    SafeSetFloat(vars["cross_5_y_src"], period, smoothed_scaled_prev);
    PlotShape:SetValue(plot14, period, source, SafeCrossesUnder(vars["smoothed_scaled"], vars["cross_5_y_src"], period) and SafeLess(ltm, 0) and SafeGreater(smoothed_scaled_prev, 2), "?", "?", "abovebar");
    upper_fill_color = Color:FromGradient(SafeMax(0, SafeGetFloat(vars["smoothed_scaled"], period)), 0, 2, core.COLOR_BACKGROUND, core.colors().Red) + math.floor(50 / 100 * 255) * 16777216;
    upper_fill_color_100 = Color:FromGradient(SafeMax(0, SafeGetFloat(vars["smoothed_scaled"], period)), 0, 2, core.COLOR_BACKGROUND, core.colors().Red) + math.floor(100 / 100 * 255) * 16777216;
    lower_fill_color = Color:FromGradient(SafeMin(0, SafeGetFloat(vars["smoothed_scaled"], period)), (-2), 0, core.colors().Green, core.COLOR_BACKGROUND) + math.floor(100 / 100 * 255) * 16777216;
    lower_fill_color_50 = Color:FromGradient(SafeMin(0, SafeGetFloat(vars["smoothed_scaled"], period)), (-2), 0, core.colors().Green, core.COLOR_BACKGROUND) + math.floor(50 / 100 * 255) * 16777216;
    vars["channel1_top"][period] = vars["u1"][period];
    vars["channel1_bottom"][period] = vars["u"][period];
    channel1_avg = (vars["channel1_top"][period] + vars["channel1_bottom"][period]) / 2;
    if (channel1_avg <= vars["channel1_top_value"] and channel1_avg >= vars["channel1_bottom_value"]) then
        vars["channel1_top"]:setColor(period, Color:FromGradient(channel1_avg, vars["channel1_bottom_value"], vars["channel1_top_value"], upper_fill_color_100, upper_fill_color));
    end
    vars["channel2_top"][period] = vars["d"][period];
    vars["channel2_bottom"][period] = vars["d1"][period];
    channel2_avg = (vars["channel2_top"][period] + vars["channel2_bottom"][period]) / 2;
    vars["channel2_top_value"] = (-2);
    vars["channel2_bottom_value"] = (-2.5);
    if (channel2_avg <= vars["channel2_top_value"] and channel2_avg >= vars["channel2_bottom_value"]) then
        vars["channel2_top"]:setColor(period, Color:FromGradient(channel2_avg, vars["channel2_bottom_value"], vars["channel2_top_value"], lower_fill_color_50, lower_fill_color));
    end
    vars["main"]:setColor(period, core.colors().Gray + math.floor(Triary(SafeGreater(SafeGetFloat(vars["smoothed_scaled"], period), smoothed_scaled_prev), 20, 70) / 100 * 255) * 16777216);
    vars["channel4_top"][period] = vars["longtm"][period];
    vars["channel4_bottom"][period] = vars["mid"][period];
    channel4_avg = (vars["channel4_top"][period] + vars["channel4_bottom"][period]) / 2;
    vars["channel4_top_value"] = ltm;
    if (channel4_avg <= vars["channel4_top_value"] and channel4_avg >= vars["channel4_bottom_value"]) then
        vars["channel4_top"]:setColor(period, Color:FromGradient(channel4_avg, vars["channel4_bottom_value"], vars["channel4_top_value"], Triary(SafeGreater(ltm, 0), core.colors().Green, core.colors().Red) + math.floor(90 / 100 * 255) * 16777216, ltm_color));
    end
    SafeSetFloat(vars["cross_6_y_src"], period, smoothed_scaled_prev);
    if SafeCrosses(vars["smoothed_scaled"], vars["cross_6_y_src"], period) and period == source:size() - 1 then
        signaler:SignalEx(1, "Stochastic Z-Score momentum direction changed.", period, source);
    end
    SafeSetFloat(vars["cross_7_y_src"], period, smoothed_scaled_prev);
    if SafeCrossesOver(vars["smoothed_scaled"], vars["cross_7_y_src"], period) and SafeGreater(ltm, 0) and SafeLess(smoothed_scaled_prev, (-2)) and period == source:size() - 1 then
        signaler:SignalEx(2, "Bullish reversal detected (oscillator crosses up while long-term momentum is positive).", period, source);
    end
    SafeSetFloat(vars["cross_8_y_src"], period, smoothed_scaled_prev);
    if SafeCrossesUnder(vars["smoothed_scaled"], vars["cross_8_y_src"], period) and SafeLess(ltm, 0) and SafeGreater(smoothed_scaled_prev, 2) and period == source:size() - 1 then
        signaler:SignalEx(3, "Bearish reversal detected (oscillator crosses down while long-term momentum is negative).", period, source);
    end
    if SafeCrossesOver(vars["smoothed_scaled"], 0, period) and period == source:size() - 1 then
        signaler:SignalEx(4, "Oscillator crossed above the zero line (bullish momentum).", period, source);
    end
    if SafeCrossesUnder(vars["smoothed_scaled"], 0, period) and period == source:size() - 1 then
        signaler:SignalEx(5, "Oscillator crossed below the zero line (bearish momentum).", period, source);
    end
    SafeSetFloat(vars["cross_11_x_src"], period, ltm);
    if SafeCrossesOver(vars["cross_11_x_src"], 0, period) and period == source:size() - 1 then
        signaler:SignalEx(6, "Long-term momentum (ALMA) crossed above zero.", period, source);
    end
    SafeSetFloat(vars["cross_12_x_src"], period, ltm);
    if SafeCrossesUnder(vars["cross_12_x_src"], 0, period) and period == source:size() - 1 then
        signaler:SignalEx(7, "Long-term momentum (ALMA) crossed below zero.", period, source);
    end
    if SafeGreater(SafeGetFloat(vars["smoothed_scaled"], period), 2.5) and period == source:size() - 1 then
        signaler:SignalEx(8, "Oscillator entered overbought zone (> 2.5).", period, source);
    end
    if SafeLess(SafeGetFloat(vars["smoothed_scaled"], period), (-2.5)) and period == source:size() - 1 then
        signaler:SignalEx(9, "Oscillator entered oversold zone (< -2.5).", period, source);
    end
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
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
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil then
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
function CreateStochastic(source, high, low, length)
    local stoch = {};
    stoch.Source = source;
    stoch.High = high;
    stoch.Low = low;
    stoch.Length = length;
    function stoch:get(period)
        if period + self.Length >= self.Source:first() then
            return nil;
        end
        local low = mathex.min(self.Low, core.rangeTo(period, self.Length));
        local high = mathex.max(self.High, core.rangeTo(period, self.Length));
        if low == high then
            return 100;
        end
        return 100 * (self.Source[period] - low) / (high - low);
    end
    return stoch;
end
Color = {};
function Color:GetR(color)
    return color % 256;
end
function Color:GetG(color)
    local R = Color:GetR(color);
    return ((color - R) / 256) % 256;
end
function Color:GetB(color)
    local R = Color:GetR(color);
    local G = Color:GetG(color);
    return ((color - R - G*256) /(256 * 256)) % 256;
end
function Color:GetRGB(color)
    local R = Color:GetR(color);
    local G = Color:GetG(color);
    return R, G, ((color - R - G*256) /(256 * 256)) % 256;
end
function Color:FromGradient(value, bottom_value, top_value, bottom_color, top_color)
    if (value == nil or top_value == nil) then
        return bottom_color;
    end
    if (bottom_value == nil) then
        return top_color;
    end
    local range = top_value - bottom_value;
    local rate = (value - bottom_value) / range;
    if (rate > 1) then
        return bottom_color;
    end
    if (rate < 0) then
        return top_color;
    end
    
    local bottomR, bottomG, bottomB = Color:GetRGB(bottom_color);
    local topR, topG, topB = Color:GetRGB(top_color);
    return core.rgb(bottomR + math.floor(rate * (topR - bottomR)), 
        bottomG + math.floor(rate * (topG - bottomG)), 
        bottomB + math.floor(rate * (topB - bottomB)), 0);
end
PlotChar = {};
function PlotChar:SetValue(plot, period, source, value, text, label, location)
    if not value then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label);
        return;
    end
    plot:set(period, value, text, label);
end

PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location)
    if not value then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label);
        return;
    end
    plot:set(period, value, text, label);
end
signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};
signaler.lastIndexSerial = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) 
    if modules == nil then
        self._ids_start = 100; 
        return;
    end
    for _, module in pairs(modules) do 
        self:OnNewModule(module); 
        module:OnNewModule(self); 
    end 
    modules[#modules + 1] = self; 
    self._ids_start = (#modules) * 100; 
end

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
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        end
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
function signaler:getSource(source)
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
    return source;
end
function signaler:SignalEx(index, message, period, source)
    source = self:getSource(source);
    if index ~= nil then
        if (self.lastIndexSerial[index] == source:serial(period)) then
            return;
        end
        self.lastIndexSerial[index] = source:serial(period);
    end
    local interval = string.find(message, "{{interval}}");
    if interval ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. source:barSize()
            .. string.sub(message, interval + string.len("{{interval}}"));
    end
    local close = string.find(message, "{{close}}");
    if close ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. win32.formatNumber(source.close[period], false, source:getDisplayPrecision())
            .. string.sub(message, interval + string.len("{{close}}"));
    end
    self:Signal(message, source);
end
function signaler:Signal(message, source)
    source = self:getSource(source);
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
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
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
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
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
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
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76274

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 