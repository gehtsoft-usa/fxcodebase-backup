-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=75976

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
    indicator:name("N Candle Predictor Signal")
    indicator:description("Predict next candle direction based on historical pattern of N candles")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Settings")
    indicator.parameters:addInteger("PatternLength", "Pattern Length (number of candles)", "Number of candles to form a pattern", 3, 1, 10)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UpColor", "Predicted UP Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownColor", "Predicted DOWN Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("NeutralColor", "Neutral Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addColor("DefaultColor", "Default Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("Size", "Font Size", "Size of the prediction symbol", 12)
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
    neutralColor = instance.parameters.NeutralColor
    defaultColor = instance.parameters.DefaultColor
    Size = instance.parameters.Size

    Signal= instance:addStream("Signal", core.Line, name, "Signal", neutralColor, first) 
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period)
    Signal[period]=0;

    if period < first then return end

    local pattern = {}
    for i = patternLength, 1, -1 do
        if source.close[period - i] > source.open[period - i] then
            pattern[#pattern + 1] = "U"
        else
            pattern[#pattern + 1] = "D"
        end
    end

    local upCount, downCount = 0, 0
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
                upCount = upCount + 1
            else
                downCount = downCount + 1
            end
        end
    end

    local predSymbol, position
    if upCount > downCount then 
         
            Signal[period]=1;
        
    elseif downCount > upCount then 
            Signal[period]=-1;
        
    else
        
            Signal[period]=0
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=75976

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