-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74646

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


local vars = {};
function Init()
    indicator:name("Madrid Trend Squeeze");
    indicator:description("Madrid Trend Squeeze");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("param1", "Length", "", 34);
end

local source;
local src;
local plot1;
local plot2_open;
local plot2_high;
local plot2_low;
local plot2_close;
local plot3_open;
local plot3_high;
local plot3_low;
local plot3_close;
local plot4_open;
local plot4_high;
local plot4_low;
local plot4_close;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["len"] = instance.parameters.param1;
    vars["ref"] = 13;
    vars["sqzLen"] = 5;
    src = instance:addInternalStream(0, 0);
    vars["EMA1"] = core.indicators:create("EMA", src, vars["len"]);
    vars["EMA2"] = core.indicators:create("EMA", src, vars["ref"]);
    vars["EMA3"] = core.indicators:create("EMA", src, vars["sqzLen"]);
    plot1 = instance:addStream("plot1", core.Line, "", "", core.rgb(128, 128, 128), 0, 0);
    plot1:setStyle(core.LINE_NONE);
    plot1:setPrecision(math.max(5, instance.source:getPrecision()));	
    plot1:addLevel(0, core.LINE_SOLID, 1, core.rgb(128, 128, 128));
	
    plot2_open = instance:addStream("plot2_open", core.Line, "Open", "Open", core.rgb(0, 255, 0), 0, 0);
    plot2_open:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot2_high = instance:addStream("plot2_high", core.Line, "High", "High", core.rgb(0, 0, 255), 0, 0);
    plot2_high:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot2_low = instance:addStream("plot2_low", core.Line, "Low", "Low", core.rgb(128, 128, 128), 0, 0);
    plot2_low:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot2_close = instance:addStream("plot2_close", core.Line, "Close", "Close", core.rgb(255, 0, 0), 0, 0);
    plot2_close:setPrecision(math.max(5, instance.source:getPrecision()));
	
    --instance:createCandleGroup("plot2", "plot2", plot2_open, plot2_high, plot2_low, plot2_close);
	
    plot3_open = instance:addStream("plot3_open", core.Line, "Open", "Open",  core.rgb(0, 255, 0), 0, 0);
    plot3_open:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot3_high = instance:addStream("plot3_high", core.Line, "High", "High", core.rgb(0, 0, 255), 0, 0);
    plot3_high:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot3_low = instance:addStream("plot3_low", core.Line, "Low", "Low", core.rgb(128, 128, 128), 0, 0);
    plot3_low:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot3_close = instance:addStream("plot3_close", core.Line, "Close", "Close", core.rgb(0, 255, 0), 0, 0);
    plot3_close:setPrecision(math.max(5, instance.source:getPrecision()));
	
    --instance:createCandleGroup("plot3", "plot3", plot3_open, plot3_high, plot3_low, plot3_close);
	
    plot4_open = instance:addStream("plot4_open", core.Line, "Open", "Open",  core.rgb(0, 255, 0), 0, 0);
    plot4_open:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot4_high = instance:addStream("plot4_high", core.Line, "High", "High", core.rgb(0, 0, 255), 0, 0);
    plot4_high:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot4_low = instance:addStream("plot4_low", core.Line, "Low", "Low", core.rgb(128, 128, 128), 0, 0);
    plot4_low:setPrecision(math.max(5, instance.source:getPrecision()));
	
    plot4_close = instance:addStream("plot4_close", core.Line, "Close", "Close", core.rgb(0, 0, 255), 0, 0);
    plot4_close:setPrecision(math.max(5, instance.source:getPrecision()));	
    --instance:createCandleGroup("plot4", "plot4", plot4_open, plot4_high, plot4_low, plot4_close);
end

function Update(period, mode)
    SafeSetFloat(src, period, source.close:tick(period));
    vars["EMA1"]:update(mode);
    ma = vars["EMA1"].DATA:tick(period);
    closema = SafeMinus(source.close:tick(period), ma);
    vars["EMA2"]:update(mode);
    refma = SafeMinus(vars["EMA2"].DATA:tick(period), ma);
    vars["EMA3"]:update(mode);
    sqzma = SafeMinus(vars["EMA3"].DATA:tick(period), ma);
    plot2_open_value = 0;
    plot2_close_value = closema;
    plot2_color = Triary(SafeGE(closema, 0), core.colors().Aqua, core.colors().Fuchsia);
    if plot2_color then
        plot2_open[period] = plot2_open_value;
        plot2_high[period] = closema;
        plot2_low[period] = 0;
        plot2_close[period] = plot2_close_value;
        plot2_open:setColor(period, plot2_color);
    else
        plot2_open:setNoData(period);
        plot2_high:setNoData(period);
        plot2_low:setNoData(period);
        plot2_close:setNoData(period);
    end
    plot3_open_value = 0;
    plot3_close_value = sqzma;
    plot3_color = Triary(SafeGE(sqzma, 0), core.colors().Lime, core.colors().Red);
    if plot3_color then
        plot3_open[period] = plot3_open_value;
        plot3_high[period] = sqzma;
        plot3_low[period] = 0;
        plot3_close[period] = plot3_close_value;
        plot3_open:setColor(period, plot3_color);
    else
        plot3_open:setNoData(period);
        plot3_high:setNoData(period);
        plot3_low:setNoData(period);
        plot3_close:setNoData(period);
    end
    plot4_open_value = 0;
    plot4_close_value = refma;
    plot4_color = Triary(((SafeGE(refma, 0) and SafeLess(closema, refma)) or (SafeLess(refma, 0) and SafeGreater(closema, refma))), core.colors().Yellow, Triary(SafeGE(refma, 0), core.colors().Green, core.colors().Maroon));
    if plot4_color then
        plot4_open[period] = plot4_open_value;
        plot4_high[period] = refma;
        plot4_low[period] = 0;
        plot4_close[period] = plot4_close_value;
        plot4_open:setColor(period, plot4_color);
    else
        plot4_open:setNoData(period);
        plot4_high:setNoData(period);
        plot4_low:setNoData(period);
        plot4_close:setNoData(period);
    end
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

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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