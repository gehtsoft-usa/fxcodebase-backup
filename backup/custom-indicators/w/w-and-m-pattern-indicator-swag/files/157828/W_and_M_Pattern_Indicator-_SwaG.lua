-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75504

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
    indicator:name("W and M Pattern Indicator- SwaG");
    indicator:description("W and M Pattern Indicator- SwaG");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Upper Limit", "", 70);
    indicator.parameters:addInteger("param2", "Lower Limit", "", 40);
end

local source;
local plot1;
local plot2;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["upper_limit"] = instance.parameters.param1;
    vars["lower_limit"] = instance.parameters.param2;
    vars["RSI1"] = core.indicators:create("RSI", source.close, 50);
    vars["rsi"] = instance:addInternalStream(0, 0);
    plot1 = instance:createTextOutput("plot1", "", "Wingdings", 12, core.H_Center, core.V_Bottom, core.colors().Green);
    plot2 = instance:createTextOutput("plot2", "", "Wingdings", 12, core.H_Center, core.V_Top, core.colors().Red);
end

function Update(period, mode)
    vars["RSI1"]:update(mode);
    SafeSetFloat(vars["rsi"], period, vars["RSI1"].DATA:tick(period));
    if vars["rsi"]:first() > period - (1) then return; end
    if vars["rsi"]:first() > period - (10) then return; end
    if vars["rsi"]:first() > period - (22) then return; end
    if vars["rsi"]:first() > period - (2) then return; end
    w_pattern = (SafeLess(SafeGetFloat(vars["rsi"], period), SafeGetFloat(vars["rsi"], period - 1)) and SafeGreater(SafeGetFloat(vars["rsi"], period - 10), SafeGetFloat(vars["rsi"], period - 22)) and SafeLess(SafeGetFloat(vars["rsi"], period - 2), vars["lower_limit"]));
    if vars["rsi"]:first() > period - (9) then return; end
    if vars["rsi"]:first() > period - (1) then return; end
    if vars["rsi"]:first() > period - (5) then return; end
    if vars["rsi"]:first() > period - (7) then return; end
    m_pattern = (SafeGreater(SafeGetFloat(vars["rsi"], period), SafeGetFloat(vars["rsi"], period - 9)) and SafeLess(SafeGetFloat(vars["rsi"], period - 1), SafeGetFloat(vars["rsi"], period - 5)) and SafeGreater(SafeGetFloat(vars["rsi"], period - 7), vars["upper_limit"]));
    PlotShape:SetValue(plot1, period, source, w_pattern, "\217", "", "belowbar");
    PlotShape:SetValue(plot2, period, source, m_pattern, "\218", "", "abovebar");
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

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75504

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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