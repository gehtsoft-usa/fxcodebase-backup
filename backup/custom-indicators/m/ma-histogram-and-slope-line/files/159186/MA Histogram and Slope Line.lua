-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75920

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
function Init()
    indicator:name("MA Histogram and Slope Line")
    indicator:description("Histogram: MA1 - MA2\nSlope Line: MA1 - MA2[Shift]")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("PeriodFast", "Fast MA Period", "", 10, 1, 500)
	
	indicator.parameters:addString("MethodFast", "MA Method", "Method" , "VIDYA");
    indicator.parameters:addStringAlternative("MethodFast", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MethodFast", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MethodFast", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MethodFast", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MethodFast", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MethodFast", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MethodFast", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MethodFast", "WMA", "WMA" , "WMA");

	
    indicator.parameters:addInteger("PeriodSlow", "Slow MA Period", "", 12, 1, 500)
	indicator.parameters:addString("MethodSlow", "MA Method", "Method" , "VIDYA");
    indicator.parameters:addStringAlternative("MethodSlow", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MethodSlow", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MethodSlow", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MethodSlow", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MethodSlow", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MethodSlow", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MethodSlow", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MethodSlow", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("SlopeOffset", "Slope Offset (in periods)", "", 3, 1, 50)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UpColor", "Histogram Up Color", "", core.rgb(0, 0, 255))   -- Blue
    indicator.parameters:addColor("DownColor", "Histogram Down Color", "", core.rgb(255, 0, 0)) -- Red
    indicator.parameters:addColor("SlopeColor", "Slope Line Color", "", core.rgb(255, 165, 0))  -- Orange
	
    indicator.parameters:addInteger("width", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
end

local source, vidyaFast, vidyaSlow, slopeVidya
local histStream, slopeStream
local slopeOffset

function Prepare(nameOnly)
    local name = "VIDYA_Histogram_Slope"
    instance:name(name)

    if nameOnly then return end

    source = instance.source
    slopeOffset = instance.parameters.SlopeOffset

    vidyaFast = core.indicators:create(instance.parameters.MethodFast, source, instance.parameters.PeriodFast)
    vidyaSlow = core.indicators:create(instance.parameters.MethodSlow, source, instance.parameters.PeriodSlow)

    local first = math.max(vidyaFast.DATA:first(), vidyaSlow.DATA:first()) + slopeOffset

    histStream = instance:addStream("Histogram", core.Bar, name .. "_Hist", "Hist", instance.parameters.UpColor, first)
    histStream:setPrecision(math.max(2, instance.source:getPrecision()));

    slopeStream = instance:addStream("Slope", core.Line, name .. "_Slope", "Slope", instance.parameters.SlopeColor, first)
    slopeStream:setPrecision(math.max(2, instance.source:getPrecision()));
    slopeStream:setWidth(instance.parameters.width)
    slopeStream:setStyle(instance.parameters.style)	
	
end

function Update(period, mode)
    vidyaFast:update(mode)
    vidyaSlow:update(mode)

    if period >= slopeOffset and vidyaFast.DATA:hasData(period) and vidyaSlow.DATA:hasData(period) and vidyaSlow.DATA:hasData(period - slopeOffset) then
        local hist = vidyaFast.DATA[period] - vidyaSlow.DATA[period]
        histStream[period] = hist

        if hist > 0 then
            histStream:setColor(period, instance.parameters.UpColor)
        else
            histStream:setColor(period, instance.parameters.DownColor)
        end

        slopeStream[period] = vidyaSlow.DATA[period] - vidyaSlow.DATA[period - slopeOffset]
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75920

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