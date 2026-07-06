-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75855

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
    indicator:name("TRAMA - Trend Regularity Adaptive Moving Average");
    indicator:description("TRAMA - Trend Regularity Adaptive Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Length", "", 15, 1);
    indicator.parameters:addDouble("param2", "Sensitivity", "", 2.5, 0.1);
    indicator.parameters:addString("param3", "Source", "", "typical");
    indicator.parameters:addStringAlternative("param3", "Open", "", "open");
    indicator.parameters:addStringAlternative("param3", "High", "", "high");
    indicator.parameters:addStringAlternative("param3", "Low", "", "low");
    indicator.parameters:addStringAlternative("param3", "Close", "", "close");
    indicator.parameters:addStringAlternative("param3", "Median", "", "median");
    indicator.parameters:addStringAlternative("param3", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param3", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param3", "OHLC4", "", "ohlc4");
    indicator.parameters:addString("param4", "Smoothing Type", "", "RMA");
    indicator.parameters:addStringAlternative("param4", "RMA", "", "RMA");
    indicator.parameters:addStringAlternative("param4", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("param4", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param4", "WMA", "", "WMA");
end

local source;
local plot1;
local plot2;
local plot3;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["length"] = instance.parameters.param1;
    vars["sensitivity"] = instance.parameters.param2;
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param3);
    vars["smoothing"] = instance.parameters.param4;
    vars["delta"] = instance:addInternalStream(0, 0);
    vars["EMA1"] = core.indicators:create("EMA", vars["delta"], vars["length"]);
    vars["trama"] = instance:addInternalStream(0, 0);
    vars["SMMA1"] = core.indicators:create("SMMA", vars["trama"], vars["length"]);
    vars["EMA2"] = core.indicators:create("EMA", vars["trama"], vars["length"]);
    vars["MVA1"] = core.indicators:create("MVA", vars["trama"], vars["length"]);
    vars["WMA1"] = core.indicators:create("WMA", vars["trama"], vars["length"]);
    vars["smoothLine"] = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Line, "TRAMA Line", "TRAMA Line", core.colors().Green, 0, 0);
    plot1:setWidth(2);
    plot1:setStyle(core.LINE_SOLID);
    plot2 = instance:createTextOutput("plot2", "Buy Signal", "Wingdings", 12, core.H_Center, core.V_Top, core.colors().Green);
    plot3 = instance:createTextOutput("plot3", "Sell Signal", "Wingdings", 12, core.H_Center, core.V_Top, core.colors().Red);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        SafeSetFloat(vars["trama"], period, nil);
    else
        SafeSetFloat(vars["trama"], period, SafeGetFloat(vars["trama"], period - 1));
    end
    PineScriptUtils:UpdateSources(period, mode);
    SafeSetFloat(vars["delta"], period, SafeAbs(SafeMinus(vars["src"]:tick(period), vars["src"]:tick(period - 1))));
    vars["EMA1"]:update(mode);
    volatility = vars["EMA1"].DATA:tick(period);
    weight = SafeMin(1.0, SafeDivide(SafeGetFloat(vars["delta"], period), (SafeMultiply(volatility, vars["sensitivity"]))));
    SafeSetFloat(vars["trama"], period, SafePlus(Nz(SafeGetFloat(vars["trama"], period - 1)), SafeMultiply(weight, (SafeMinus(vars["src"]:tick(period), Nz(SafeGetFloat(vars["trama"], period - 1)))))));
    if (vars["smoothing"] == "RMA") then
        vars["SMMA1"]:update(mode);
        SafeSetFloat(vars["smoothLine"], period, vars["SMMA1"].DATA:tick(period));
    elseif (vars["smoothing"] == "EMA") then
        vars["EMA2"]:update(mode);
        SafeSetFloat(vars["smoothLine"], period, vars["EMA2"].DATA:tick(period));
    elseif (vars["smoothing"] == "SMA") then
        vars["MVA1"]:update(mode);
        SafeSetFloat(vars["smoothLine"], period, vars["MVA1"].DATA:tick(period));
    elseif (vars["smoothing"] == "WMA") then
        vars["WMA1"]:update(mode);
        SafeSetFloat(vars["smoothLine"], period, vars["WMA1"].DATA:tick(period));
    else
        SafeSetFloat(vars["smoothLine"], period, SafeGetFloat(vars["trama"], period));
    end
    if vars["smoothLine"]:first() > period - (1) then return; end
    bullish = SafeGreater(SafeGetFloat(vars["smoothLine"], period), SafeGetFloat(vars["smoothLine"], period - 1));
    bearish = SafeLess(SafeGetFloat(vars["smoothLine"], period), SafeGetFloat(vars["smoothLine"], period - 1));
    trendColor = Triary(bullish, core.colors().Green, Triary(bearish, core.colors().Red, core.colors().Gray));
    colorChange = (trendColor ~= trendColor);
    plot1[period] = SafeGetFloat(vars["smoothLine"], period);
    plot1:setColor(period, trendColor);
    PlotShape:SetValue(plot2, period, source, Triary(colorChange and bullish, SafeGetFloat(vars["smoothLine"], period), nil), "\233", "", "abovebar");
    PlotShape:SetValue(plot3, period, source, Triary(colorChange and bearish, SafeGetFloat(vars["smoothLine"], period), nil), "\234", "", "abovebar");
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
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if not stream:hasData(period) then
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75855

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