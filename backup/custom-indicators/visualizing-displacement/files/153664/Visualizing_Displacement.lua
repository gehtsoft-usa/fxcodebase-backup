
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74438

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
function Init()
    indicator:name("Visualizing Displacement [TFO]");
    indicator:description("Visualizing Displacement [TFO]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addBoolean("param1", "Require FVG", "", true);
    indicator.parameters:addString("param2", "Displacement Type", "", "Open to Close");
    indicator.parameters:addStringAlternative("param2", "Open to Close", "", "Open to Close");
    indicator.parameters:addStringAlternative("param2", "High to Low", "", "High to Low");
    indicator.parameters:addInteger("param3", "Displacement Length", "", 100);
    indicator.parameters:addInteger("param4", "Displacement Strength", "", 4);
    indicator.parameters:addColor("param5", "Bar Color", "", core.colors().Yellow);
end

local source;
local vars = {};
local candle_range;
local std;
local plot1_open;
local plot1_high;
local plot1_low;
local plot1_close;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["require_fvg"] = instance.parameters.param1;
    vars["disp_type"] = instance.parameters.param2;
    vars["std_len"] = instance.parameters.param3;
    vars["std_x"] = instance.parameters.param4;
    vars["disp_color"] = instance.parameters.param5;
    candle_range = instance:addInternalStream(0, 0);
    std = instance:addInternalStream(0, 0);
    plot1_open = instance:addStream("plot1_open", core.Line, "Open", "Open", core.colors().Black, 0, SafeNegative(((vars["require_fvg"]) and ((-1)) or (nil))));
    plot1_high = instance:addStream("plot1_high", core.Line, "High", "High", core.colors().Black, 0, SafeNegative(((vars["require_fvg"]) and ((-1)) or (nil))));
    plot1_low = instance:addStream("plot1_low", core.Line, "Low", "Low", core.colors().Black, 0, SafeNegative(((vars["require_fvg"]) and ((-1)) or (nil))));
    plot1_close = instance:addStream("plot1_close", core.Line, "Close", "Close", core.colors().Black, 0, SafeNegative(((vars["require_fvg"]) and ((-1)) or (nil))));
    instance:createCandleGroup("plot1", "plot1", plot1_open, plot1_high, plot1_low, plot1_close);
end

function Update(period, mode)
    candle_range_value = (((vars["disp_type"] == "Open to Close")) and (math.abs(source.open:tick(period) - source.close:tick(period))) or (source.high:tick(period) - source.low:tick(period)));
    if candle_range_value then
        candle_range[period] = candle_range_value;
    else
        candle_range:setNoData(period);
    end
    if candle_range:first() > period - vars["std_len"] then return; end
    std_value = SafeMultiply(mathex.stdev(candle_range, core.rangeTo(period, vars["std_len"])), vars["std_x"]);
    if std_value then
        std[period] = std_value;
    else
        std:setNoData(period);
    end
    fvg = (((source.close:tick(period - 1) > source.open:tick(period - 1))) and ((source.high:tick(period - 2) < source.low:tick(period - 0))) or ((source.low:tick(period - 2) > source.high:tick(period - 0))));
    if candle_range:first() > period - 1 then return; end
    if std:first() > period - 1 then return; end
    displacement = ((vars["require_fvg"]) and (SafeGreater((candle_range:hasData(period - 1) and candle_range:tick(period - 1) or nil), (std:hasData(period - 1) and std:tick(period - 1) or nil)) and fvg) or (SafeGreater((candle_range:hasData(period) and candle_range:tick(period) or nil), (std:hasData(period) and std:tick(period) or nil))));
    plot1_color = ((displacement) and (vars["disp_color"]) or (nil));
    if plot1_color then
        plot1_open[period] = source.open[period];
        plot1_high[period] = source.high[period];
        plot1_low[period] = source.low[period];
        plot1_close[period] = source.close[period];
        plot1_open:setColor(period, plot1_color);
    else
        plot1_open:setNoData(period);
        plot1_high:setNoData(period);
        plot1_low:setNoData(period);
        plot1_close:setNoData(period);
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
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function Float(number)
    return number and number or 0.0;
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
    if defaulValue == nil then
        defaulValue = 0;
    end
    return value and value or defaultValue;
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