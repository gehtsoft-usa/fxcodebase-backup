-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73105

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("WSO WRO")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addInteger("Length", "Length", "", 9, 1, 2000)

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color1", "WSO Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("color2", "WRO Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("color3", "Middle Line Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addBoolean("color_bars", "Use bar coloring", "", false)
    indicator.parameters:addColor("up_color", "Up Bar Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("dn_color", "Down Bar Color", "", core.rgb(255, 0, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Length, Center
local S = {}
local R = {}
local MiddleLine;
local open, high, low, close, volume;
local color_bars, up_color, dn_color;

-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length
    Center = (Length - 1) / 2

    source = instance.source

    local name = profile:id() .. "(" .. instance.source:name() .. "," .. Length .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    color_bars = instance.parameters.color_bars;
    up_color = instance.parameters.up_color;
    dn_color = instance.parameters.dn_color;

    first = source:first() + Length

    for i = 1, 6, 1 do
        S[i] = instance:addInternalStream(0, 0)
        R[i] = instance:addInternalStream(0, 0)
    end

    WSO = instance:addStream("WSO", core.Line, name, "WSO", instance.parameters.color1, first)
    WSO:setPrecision(math.max(2, instance.source:getPrecision()))
    WSO:setWidth(instance.parameters.width)
    WSO:setStyle(instance.parameters.style)
    WSO:addLevel(0)

    WRO = instance:addStream("WRO", core.Line, name, "WRO", instance.parameters.color2, first)
    WRO:setPrecision(math.max(2, instance.source:getPrecision()))
    WRO:setWidth(instance.parameters.width)
    WRO:setStyle(instance.parameters.style)
    WRO:addLevel(0)

    MiddleLine = instance:addStream("Middle", core.Line, name, "Middle", instance.parameters.color3, first)
    MiddleLine:setPrecision(math.max(2, instance.source:getPrecision()))
    MiddleLine:setWidth(instance.parameters.width)
    MiddleLine:setStyle(instance.parameters.style)
    MiddleLine:addLevel(0)
    if color_bars then
        open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
        high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
        low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
        close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
        volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);
        instance:createCandleGroup("candles", "candles", open, high, low, close, volume)
        core.host:execute("attachOuputToChart", "candles")
    end
end

function Update(period, mode)
    for i = 1, 6, 1 do
        S[i][period] = source.low[period]
        R[i][period] = source.high[period]
    end

    if period <= first then
        return
    end

    local min, max, minpos, maxpos = mathex.minmax(source, period - Length + 1, period)

    for i = 1, 6, 1 do
        S[i][period] = S[i][period - 1]
        R[i][period] = R[i][period - 1]
    end

    if (minpos == period - Center) then
        S[1][period] = min
        S[2][period] = S[1][period - 1]
        S[3][period] = S[2][period - 1]
        S[4][period] = S[3][period - 1]
        S[5][period] = S[4][period - 1]
        S[6][period] = S[5][period - 1]
    end
    if (maxpos == period - Center) then
        R[1][period] = max
        R[2][period] = R[1][period - 1]
        R[3][period] = R[2][period - 1]
        R[4][period] = R[3][period - 1]
        R[5][period] = R[4][period - 1]
        R[6][period] = R[5][period - 1]
    end

    WSO[period] =
        100 *
        (1 -
            (MathInt(S[1][period] / source.close[period]) + MathInt(S[2][period] / source.close[period]) +
                MathInt(S[3][period] / source.close[period]) +
                MathInt(S[4][period] / source.close[period]) +
                MathInt(S[5][period] / source.close[period]) +
                MathInt(S[6][period] / source.close[period])) /
                6.0)
    WRO[period] =
        100 *
        (1 -
            (MathInt(R[1][period] / source.close[period]) + MathInt(R[2][period] / source.close[period]) +
                MathInt(R[3][period] / source.close[period]) +
                MathInt(R[4][period] / source.close[period]) +
                MathInt(R[5][period] / source.close[period]) +
                MathInt(R[6][period] / source.close[period])) /
                6.0)
    MiddleLine[period] = (WSO[period] + WRO[period]) / 2
    if open ~= nil then
        open[period] = source.open[period];
        low[period] =  source.low[period];   
        close[period]= source.close[period];  
        high[period] = source.high[period];  
        volume[period] = source.volume[period];
        if MiddleLine[period] > 50 then
            open:setColor(period, up_color);
        else
            open:setColor(period, dn_color);
        end
    end
end

function MathInt(number)
    if (number >= 1.0) then
        return (1)
    else
        return (0)
    end
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
