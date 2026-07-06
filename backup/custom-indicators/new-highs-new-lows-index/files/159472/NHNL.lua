-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=22579&start=10
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
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("New High  New Low Index")
    indicator:description("New High  New Low Index")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "Period", 20)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("C_color_pos", "Positive Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("C_color_neg", "Negative Color", "", core.rgb(255, 128, 64))
    indicator.parameters:addBoolean("use_channel", "Fill background", "", true)
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("H_color", "Color of New Low", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("H_width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("H_style", "Line style", "", core.LINE_NONE)
    indicator.parameters:setFlag("H_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("L_color", "Color of New High", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("L_width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("L_style", "Line style", "", core.LINE_NONE)
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period

local first
local source = nil

-- Streams block
local c, h, l

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period
    source = instance.source
    first = source:first() + Period

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")"
    instance:name(name)

    if (not (nameOnly)) then
        c = instance:addStream("C", core.Line, name, "C", instance.parameters.C_color_pos, first)
        c:setPrecision(math.max(2, instance.source:getPrecision()))
        c:setWidth(instance.parameters.width)
        c:setStyle(instance.parameters.style)
        h = instance:addStream("H", core.Line, name, "H", instance.parameters.H_color, first)
        h:setPrecision(math.max(2, instance.source:getPrecision()))
        h:setWidth(instance.parameters.H_width)
        h:setStyle(instance.parameters.H_style)
        l = instance:addStream("L", core.Line, name, "L", instance.parameters.L_color, first)
        l:setPrecision(math.max(2, instance.source:getPrecision()))
        l:setWidth(instance.parameters.L_width)
        l:setStyle(instance.parameters.L_style)
        zero = instance:addInternalStream(0, 0);

        if (instance.parameters.use_channel) then
            instance:createChannelGroup("Channel", "Channel", c, zero, instance.parameters.C_color_pos, 50, true);
        end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
        return
    end
    zero[period] = 0;
    h[period] = HIGH(period)
    l[period] = LOW(period)
    c[period] = h[period] + l[period]
    
    -- Set color based on C value using parameters
    if c[period] >= 0 then
        c:setColor(period, instance.parameters.C_color_pos)
    else
        c:setColor(period, instance.parameters.C_color_neg)
    end
end

function HIGH(period)
    local i
    local count = 0

    for i = period - Period + 1, period, 1 do
        if source.high[i] > source.high[i - 1] then
            count = count + 1
        end
    end

    return count
end

function LOW(period)
    local i
    local count = 0

    for i = period - Period + 1, period, 1 do
        if source.low[i] < source.low[i - 1] then
            count = count - 1
        end
    end

    return count
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=22579&start=10
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