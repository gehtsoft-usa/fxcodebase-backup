-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75386

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
local vars = {};
function Init()
    indicator:name("Belkhayate Iceberg 2.0");
    indicator:description("Belkhayate Iceberg 2.0");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("param1", "Source", "", "close");
    indicator.parameters:addStringAlternative("param1", "Open", "", "open");
    indicator.parameters:addStringAlternative("param1", "High", "", "high");
    indicator.parameters:addStringAlternative("param1", "Low", "", "low");
    indicator.parameters:addStringAlternative("param1", "Close", "", "close");
    indicator.parameters:addStringAlternative("param1", "Median", "", "median");
    indicator.parameters:addStringAlternative("param1", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param1", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param1", "OHLC4", "", "ohlc4");
    indicator.parameters:addString("param2", "Hull Variation", "", "Hma");
    indicator.parameters:addStringAlternative("param2", "Hma", "", "Hma");
    indicator.parameters:addStringAlternative("param2", "Thma", "", "Thma");
    indicator.parameters:addStringAlternative("param2", "Ehma", "", "Ehma");
    indicator.parameters:addInteger("param3", "Length(180-200 for floating S/R , 55 for swing entry)", "", 55);
    indicator.parameters:addBoolean("param4", "Color Hull according to trend?", "", true);
    indicator.parameters:addBoolean("param5", "Color candles based on Hull's Trend?", "", false);
    indicator.parameters:addBoolean("param6", "Show as a Band?", "", true);
    indicator.parameters:addInteger("param7", "Line Thickness", "", 1);
    indicator.parameters:addInteger("param8", "Band Transparency", "", 40);
end

local source;
local plot1;
local plot2;
local plot3_open;
local plot3_high;
local plot3_low;
local plot3_close;
function Create_HMA_sf_i(_src, _length)
    local local_vars = {};
    local_vars["WMA2"] = core.indicators:create("WMA", _src, _length / 2);
    local_vars["WMA3"] = core.indicators:create("WMA", _src, _length);
    local_vars["WMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["WMA1"] = core.indicators:create("WMA", local_vars["WMA1_source"], Round(math.sqrt(_length)));
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            local_vars["WMA2"]:update(mode);
            local_vars["WMA3"]:update(mode);
            SafeSetFloat(local_vars["WMA1_source"], period, SafeMinus(SafeMultiply(2, local_vars["WMA2"].DATA:tick(period)), local_vars["WMA3"].DATA:tick(period)));
            local_vars["WMA1"]:update(mode);
            return local_vars["WMA1"].DATA:tick(period);
        end
    };
end
function Create_EHMA_sf_i(_src, _length)
    local local_vars = {};
    local_vars["EMA2"] = core.indicators:create("EMA", _src, _length / 2);
    local_vars["EMA3"] = core.indicators:create("EMA", _src, _length);
    local_vars["EMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA1"] = core.indicators:create("EMA", local_vars["EMA1_source"], Round(math.sqrt(_length)));
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            local_vars["EMA2"]:update(mode);
            local_vars["EMA3"]:update(mode);
            SafeSetFloat(local_vars["EMA1_source"], period, SafeMinus(SafeMultiply(2, local_vars["EMA2"].DATA:tick(period)), local_vars["EMA3"].DATA:tick(period)));
            local_vars["EMA1"]:update(mode);
            return local_vars["EMA1"].DATA:tick(period);
        end
    };
end
function Create_THMA_sf_i(_src, _length)
    local local_vars = {};
    local_vars["WMA5"] = core.indicators:create("WMA", _src, _length / 3);
    local_vars["WMA6"] = core.indicators:create("WMA", _src, _length / 2);
    local_vars["WMA7"] = core.indicators:create("WMA", _src, _length);
    local_vars["WMA4_source"] = instance:addInternalStream(0, 0);
    local_vars["WMA4"] = core.indicators:create("WMA", local_vars["WMA4_source"], _length);
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            local_vars["WMA5"]:update(mode);
            local_vars["WMA6"]:update(mode);
            local_vars["WMA7"]:update(mode);
            SafeSetFloat(local_vars["WMA4_source"], period, SafeMinus(SafeMinus(SafeMultiply(local_vars["WMA5"].DATA:tick(period), 3), local_vars["WMA6"].DATA:tick(period)), local_vars["WMA7"].DATA:tick(period)));
            local_vars["WMA4"]:update(mode);
            return local_vars["WMA4"].DATA:tick(period);
        end
    };
end
function Create_Mode_s_sf_i(modeSwitch, __src, len)
    local local_vars = {};
    local_vars["HMAFunc2_param1"] = instance:addInternalStream(0, 0);
    local_vars["HMAFunc2"] = Create_HMA_sf_i(local_vars["HMAFunc2_param1"], len);
    local_vars["EHMAFunc3_param1"] = instance:addInternalStream(0, 0);
    local_vars["EHMAFunc3"] = Create_EHMA_sf_i(local_vars["EHMAFunc3_param1"], len);
    local_vars["THMAFunc4_param1"] = instance:addInternalStream(0, 0);
    local_vars["THMAFunc4"] = Create_THMA_sf_i(local_vars["THMAFunc4_param1"], len / 2);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["HMAFunc2"].Clear();
                local_vars["EHMAFunc3"].Clear();
                local_vars["THMAFunc4"].Clear();
            else
            end
            SafeSetFloat(local_vars["HMAFunc2_param1"], period, SafeGetFloat(__src, period));
            SafeSetFloat(local_vars["EHMAFunc3_param1"], period, SafeGetFloat(__src, period));
            SafeSetFloat(local_vars["THMAFunc4_param1"], period, SafeGetFloat(__src, period));
            return Triary((modeSwitch.Value == "Hma"), local_vars["HMAFunc2"].GetValue(period, mode), Triary((modeSwitch.Value == "Ehma"), local_vars["EHMAFunc3"].GetValue(period, mode), Triary((modeSwitch.Value == "Thma"), local_vars["THMAFunc4"].GetValue(period, mode), nil)));
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
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param1);
    vars["modeSwitch"] = instance.parameters.param2;
    vars["length"] = instance.parameters.param3;
    vars["switchColor"] = instance.parameters.param4;
    vars["candleCol"] = instance.parameters.param5;
    vars["visualSwitch"] = instance.parameters.param6;
    vars["thicknesSwitch"] = instance.parameters.param7;
    vars["transpSwitch"] = instance.parameters.param8;
    vars["ModeFunc1_param1"] = {};
    vars["ModeFunc1_param2"] = instance:addInternalStream(0, 0);
    vars["ModeFunc1"] = Create_Mode_s_sf_i(vars["ModeFunc1_param1"], vars["ModeFunc1_param2"], vars["length"]);
    vars["HULL"] = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Line, "MHULL", "MHULL", Graphics:AddTransparency(core.rgb(0, 255, 0), 0), 0, 0);
    plot1:setWidth(vars["thicknesSwitch"]);
    plot1:setStyle(core.LINE_SOLID);
    vars["Fi1"] = plot1;
    plot2 = instance:addStream("plot2", core.Line, "SHULL", "SHULL", Graphics:AddTransparency(core.rgb(0, 255, 0), 0), 0, 0);
    plot2:setWidth(vars["thicknesSwitch"]);
    plot2:setStyle(core.LINE_SOLID);
    vars["Fi2"] = plot2;
    channel1_color = core.colors().Blue;
    instance:createChannelGroup("channel1", "channel1", vars["Fi1"], vars["Fi2"], Graphics:GetColor(channel1_color), 100 - vars["transpSwitch"], true);
    plot3_open = instance:addStream("plot3_open", core.Line, "Open", "Open", core.colors().Black, 0, 0);
    plot3_high = instance:addStream("plot3_high", core.Line, "High", "High", core.colors().Black, 0, 0);
    plot3_low = instance:addStream("plot3_low", core.Line, "Low", "Low", core.colors().Black, 0, 0);
    plot3_close = instance:addStream("plot3_close", core.Line, "Close", "Close", core.colors().Black, 0, 0);
    instance:createCandleGroup("plot3", "plot3", plot3_open, plot3_high, plot3_low, plot3_close);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        vars["ModeFunc1"].Clear();
    else
    end
    PineScriptUtils:UpdateSources(period, mode);
    vars["ModeFunc1_param1"].Value = vars["modeSwitch"];
    SafeSetFloat(vars["ModeFunc1_param2"], period, vars["src"]:tick(period));
    SafeSetFloat(vars["HULL"], period, vars["ModeFunc1"].GetValue(period, mode));
    if vars["HULL"]:first() > period - (0) then return; end
    MHULL = SafeGetFloat(vars["HULL"], period - 0);
    if vars["HULL"]:first() > period - (2) then return; end
    SHULL = SafeGetFloat(vars["HULL"], period - 2);
    if vars["HULL"]:first() > period - (2) then return; end
    hullColor = Triary(vars["switchColor"], (Triary(SafeGreater(SafeGetFloat(vars["HULL"], period), SafeGetFloat(vars["HULL"], period - 2)), Graphics:AddTransparency(core.rgb(0, 255, 0), 0), Graphics:AddTransparency(core.rgb(255, 0, 0), 0))), Graphics:AddTransparency(core.rgb(255, 152, 0), 0));
    plot1[period] = MHULL;
    plot1:setColor(period, Graphics:AddTransparency(core.rgb(0, 255, 0), 0));
    plot2[period] = Triary(vars["visualSwitch"], SHULL, nil);
    plot2:setColor(period, Graphics:AddTransparency(core.rgb(0, 255, 0), 0));
    vars["Fi1"]:setColor(period, hullColor);
    plot3_color = Triary(vars["candleCol"], (Triary(vars["switchColor"], hullColor, nil)), nil);
    if plot3_color then
        plot3_open[period] = source.open[period];
        plot3_high[period] = source.high[period];
        plot3_low[period] = source.low[period];
        plot3_close[period] = source.close[period];
        plot3_open:setColor(period, plot3_color);
    else
        plot3_open:setNoData(period);
        plot3_high:setNoData(period);
        plot3_low:setNoData(period);
        plot3_close:setNoData(period);
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