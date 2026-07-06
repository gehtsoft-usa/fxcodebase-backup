//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76002

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
local vars = {};
function Init()
    indicator:name("title");
    indicator:description("title");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("param1", "USI Length:", "", 28, 1);
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
end

local source;
local plot1;
local plot2;
function Create_UltimateSmoother_f_i(src, period)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            a1 = math.exp((-1.414) * math.pi / period);
            c2 = SafeMultiply(SafeMultiply(2.0, a1), SafeCos(1.414 * math.pi / period));
            c3 = SafeMultiply(SafeNegative(a1), a1);
            c1 = SafeDivide((SafeMinus(SafePlus(1.0, c2), c3)), 4.0);
            local_vars["us"] = src.DATA:tick(period);
            if (period >= 4) then
                local_vars["us"] = SafePlus(SafeMultiply((SafeMinus(1.0, c1)), src.DATA:tick(period)), SafePlus(SafeMinus(SafeMultiply((SafeMinus(SafeMultiply(2.0, c1), c2)), src.DATA:tick(period - 1)), SafeMultiply((SafePlus(c1, c3)), src.DATA:tick(period - 2))), SafePlus(SafeMultiply(c2, Nz(local_vars["us"])), SafeMultiply(c3, Nz(local_vars["us"])))));
            end
            return local_vars["us"];
        end
    };
end
function Create_UltimateStrengthIndex_f_i_i(src, l1, l2)
    local local_vars = {};
    local_vars["eps"] = SymInfo:GetMintick();
    vars["MVA1_source"] = instance:addInternalStream(0, 0);
    local_vars["MVA1"] = core.indicators:create("MVA", vars["MVA1_source"], l2);
    local_vars["UltimateSmootherFunc2"] = Create_UltimateSmoother_f_i(local_vars["MVA1"], l1);
    vars["MVA2_source"] = instance:addInternalStream(0, 0);
    local_vars["MVA2"] = core.indicators:create("MVA", vars["MVA2_source"], l2);
    local_vars["UltimateSmootherFunc3"] = Create_UltimateSmoother_f_i(local_vars["MVA2"], l1);
    local_vars["USI"] = 0.0;
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["UltimateSmootherFunc2"].Clear();
                local_vars["UltimateSmootherFunc3"].Clear();
            else
            end
            diff = SafeMinus(SafeGetFloat(src, period), SafeGetFloat(src, period - 1));
            SU = Triary(SafeGreater(diff, 0.0), diff, 0.0);
            SD = Triary(SafeLess(diff, 0.0), SafeNegative(diff), 0.0);
            SafeSetFloat(vars["MVA1_source"], period, SU);
            local_vars["MVA1"]:update(mode);
            USU = local_vars["UltimateSmootherFunc2"].GetValue(period, mode);
            SafeSetFloat(vars["MVA2_source"], period, SD);
            local_vars["MVA2"]:update(mode);
            USD = local_vars["UltimateSmootherFunc3"].GetValue(period, mode);
            local_vars["USI"] = Nz(local_vars["USI"]);
            if (SafePlus(USU, USD) ~= 0) and SafeGreater(USU, local_vars["eps"]) and SafeGreater(USD, local_vars["eps"]) then
                local_vars["USI"] = SafeDivide((SafeMinus(USU, USD)), (SafePlus(USU, USD)));
            end
            return local_vars["USI"];
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
    vars["title"] = "TASC 2024.11 Ultimate Strength Index";
    vars["stitle"] = "USI";
    vars["length1"] = instance.parameters.param1;
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param2);
    vars["UltimateStrengthIndexFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["UltimateStrengthIndexFunc1"] = Create_UltimateStrengthIndex_f_i_i(vars["UltimateStrengthIndexFunc1_param1"], vars["length1"], 4);
    plot1 = instance:addStream("plot1", core.Line, "USI", "USI", Graphics:AddTransparency(core.rgb(55, 126, 184), 0), 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    vars["usiLine"] = plot1;
    plot2 = instance:addStream("plot2", core.Line, "Zero Line", "Zero Line", core.colors().Silver, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    vars["midLine"] = plot2;
    vars["channel1_top"] = instance:addStream("channel1_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel1_bottom"] = instance:addInternalStream(0, 0);
    vars["channel1_top_value"] = 1;
    vars["channel1_bottom_value"] = 0;
    channel1_color = core.rgb(77, 175, 74) + math.floor(50 / 100 * 255) * 16777216;
    instance:createChannelGroup("channel1", "channel1", vars["channel1_top"], vars["channel1_bottom"], core.colors().Blue, 100 - Graphics:GetTransparencyPercent(channel1_color), true);
    vars["channel2_top"] = instance:addStream("channel2_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel2_bottom"] = instance:addInternalStream(0, 0);
    vars["channel2_top_value"] = 0;
    vars["channel2_bottom_value"] = (-1);
    channel2_color = core.rgb(228, 26, 28) + math.floor(100 / 100 * 255) * 16777216;
    instance:createChannelGroup("channel2", "channel2", vars["channel2_top"], vars["channel2_bottom"], core.colors().Blue, 100 - Graphics:GetTransparencyPercent(channel2_color), true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        vars["UltimateStrengthIndexFunc1"].Clear();
    else
    end
    PineScriptUtils:UpdateSources(period, mode);
    SafeSetFloat(vars["UltimateStrengthIndexFunc1_param1"], period, vars["src"]:tick(period));
    usi = vars["UltimateStrengthIndexFunc1"].GetValue(period, mode);
    plot1[period] = usi;
    plot2[period] = 0;
    vars["channel1_top"][period] = vars["usiLine"][period];
    vars["channel1_bottom"][period] = vars["midLine"][period];
    channel1_avg = (vars["channel1_top"][period] + vars["channel1_bottom"][period]) / 2;
    if (channel1_avg <= vars["channel1_top_value"] and channel1_avg >= vars["channel1_bottom_value"]) then
        vars["channel1_top"]:setColor(period, Color:FromGradient(channel1_avg, vars["channel1_bottom_value"], vars["channel1_top_value"], core.rgb(77, 175, 74) + math.floor(100 / 100 * 255) * 16777216, core.rgb(77, 175, 74) + math.floor(50 / 100 * 255) * 16777216));
    end
    vars["channel2_top"][period] = vars["usiLine"][period];
    vars["channel2_bottom"][period] = vars["midLine"][period];
    channel2_avg = (vars["channel2_top"][period] + vars["channel2_bottom"][period]) / 2;
    if (channel2_avg <= vars["channel2_top_value"] and channel2_avg >= vars["channel2_bottom_value"]) then
        vars["channel2_top"]:setColor(period, Color:FromGradient(channel2_avg, vars["channel2_bottom_value"], vars["channel2_top_value"], core.rgb(228, 26, 28) + math.floor(50 / 100 * 255) * 16777216, core.rgb(228, 26, 28) + math.floor(100 / 100 * 255) * 16777216));
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
SymInfo = {};
function SymInfo:GetMintick()
    return instance.source:pipSize();
end
function SymInfo:GetType()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    if offer.InstrumentType == 1 then
        return "forex";
    elseif offer.InstrumentType == 2 then
        return "index";
    elseif offer.InstrumentType == 3 then
        return "commodity";
    elseif offer.InstrumentType == 4 then
        return "";
    elseif offer.InstrumentType == 5 then
        return "";
    elseif offer.InstrumentType == 6 then
        return "";
    elseif offer.InstrumentType == 7 then
        return "";
    elseif offer.InstrumentType == 8 then
        return "";
    elseif offer.InstrumentType == 9 then
        return "crypto";
    end
    return "";
end
function SymInfo:GetBaseCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.ContractCurrency;
end
function SymInfo:GetCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.Instrument;
end
function SymInfo:GetTicker()
    return instance.source:instrument();
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76002

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
