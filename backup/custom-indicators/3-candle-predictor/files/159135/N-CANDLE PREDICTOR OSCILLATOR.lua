-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75859

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
    indicator:name("N-CANDLE PREDICTOR OSCILLATOR")
    indicator:description("N-CANDLE PREDICTOR OSCILLATOR")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Settings")
    indicator.parameters:addInteger("PatternLength", "Pattern Length (number of candles)", "Number of candles to form a pattern", 10, 1, 10)
 	

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UpColor", "Predicted UP Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownColor", "Predicted DOWN Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
 
end

local source, first, patternLength
local upColor, downColor, neutralColor, defaultColor
local predictionUp, predictionDown, predictionUpNeutral, predictionDownNeutral, predictionNeutral

function Prepare(nameOnly)
    source = instance.source
    patternLength = instance.parameters.PatternLength
    first = source:first() + patternLength + 1

    local name = "N Candle Predictor (" .. source:name() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    upColor = instance.parameters.UpColor
    downColor = instance.parameters.DownColor 
	 
    
	
    upCount = instance:addStream("upCount", core.Line, name, "upCount", upColor, first) 
    upCount:setWidth(instance.parameters.width)
    upCount:setStyle(instance.parameters.style)		
    upCount:setPrecision(math.max(2, instance.source:getPrecision()));	
 
    downCount = instance:addStream("downCount", core.Line, name, "downCount", downColor, first) 
    downCount:setWidth(instance.parameters.width)
    downCount:setStyle(instance.parameters.style)		
    downCount:setPrecision(math.max(2, instance.source:getPrecision()));		
end

function Update(period)

 

    if period < first then return end

    local pattern = {}
    for i = patternLength, 1, -1 do
        if source.close[period - i] > source.open[period - i] then
            pattern[#pattern + 1] = "U"
        else
            pattern[#pattern + 1] = "D"
        end
    end

    upCount[period] = 0;
	downCount[period] = 0
    for i = first, period - patternLength do
        local match = true
        for j = 1, patternLength do
            local pastDir = source.close[i + j - 1] > source.open[i + j - 1] and "U" or "D"
            if pattern[j] ~= pastDir then
                match = false
                break
            end
        end

        if match then
            if source.close[i + patternLength] > source.open[i + patternLength] then
                upCount[period] = upCount[period] + 1
            else
                downCount[period] = downCount[period] + 1
            end
        end
    end

    
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75859

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