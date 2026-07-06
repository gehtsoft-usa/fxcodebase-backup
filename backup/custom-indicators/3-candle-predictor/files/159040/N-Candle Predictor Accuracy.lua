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
    indicator:name("N-Candle Predictor Accuracy")
    indicator:description("Predict next candle direction based on historical N-candle patterns and calculate accuracy")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Settings")
    indicator.parameters:addInteger("PatternLength", "Pattern Length (number of candles)", "Number of candles to form a pattern", 3, 1, 10)
    indicator.parameters:addInteger("Lookback", "Accuracy Lookback (number of candles)", "Number of candles to calculate accuracy over", 10, 5, 100)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("HighAccuracyColor", "High Accuracy Line Color (>70%)", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("LowAccuracyColor", "Low Accuracy Line Color (<30%)", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("MediumAccuracyColor", "Medium Accuracy Line Color (30%-70%)", "", core.rgb(255, 255, 0))
end

local source, first, patternLength, lookback, accuracyStream
local highColor, lowColor, mediumColor

function Prepare(nameOnly)
    source = instance.source
    patternLength = instance.parameters.PatternLength
    lookback = instance.parameters.Lookback
    first = source:first() + patternLength + 1

    local name = "N-Candle Predictor Accuracy (" .. source:name() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    accuracyStream = instance:addStream("Accuracy", core.Line, name, "Accuracy", instance.parameters.HighAccuracyColor, first)
    accuracyStream:setPrecision(2)

    highColor = instance.parameters.HighAccuracyColor
    lowColor = instance.parameters.LowAccuracyColor
    mediumColor = instance.parameters.MediumAccuracyColor
end

function getPrediction(period)
    local pattern = {}
    for i = patternLength, 1, -1 do
        pattern[#pattern + 1] = source.close[period - i] > source.open[period - i] and "U" or "D"
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

    if upCount > downCount then
        return "U"
    elseif downCount > upCount then
        return "D"
    else
        return "N"
    end
end

function Update(period)
    if period < first + lookback then
        return
    end

    local correct = 0

    for i = period - lookback + 1, period do
        local pred = getPrediction(i - 1)
        local actual = source.close[i] > source.open[i] and "U" or "D"

        if pred == actual then
            correct = correct + 1
        end
    end

    local accuracy = (correct / lookback) * 100
    accuracyStream[period] = accuracy

    if accuracy > 70 then
        accuracyStream:setColor(period, highColor)
    elseif accuracy < 30 then
        accuracyStream:setColor(period, lowColor)
    else
        accuracyStream:setColor(period, mediumColor)
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