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
    indicator:name("3 Candle Predictor Accuracy")
    indicator:description("Calculates accuracy percentage of 3 Candle Predictor for last 10 candles")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("LineColor", "Oscillator Line Color", "", core.rgb(0, 0, 255))
end

local source, first, accuracyStream

function Prepare(nameOnly)
    source = instance.source
    first = source:first() + 14

    local name = "Predictor Accuracy (" .. source:name() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    accuracyStream = instance:addStream("Accuracy", core.Line, name, "Accuracy", instance.parameters.LineColor, first)
    accuracyStream:setPrecision(2)
end

-- Helper function to get prediction
function getPrediction(period)
    local pattern = {}
    for i = 3, 1, -1 do
        pattern[#pattern + 1] = source.close[period - i] > source.open[period - i] and "U" or "D"
    end

    local upCount, downCount = 0, 0
    for i = first, period - 4 do
        local match = true
        for j = 1, 3 do
            local pastDir = source.close[i + j - 1] > source.open[i + j - 1] and "U" or "D"
            if pattern[j] ~= pastDir then
                match = false
                break
            end
        end

        if match then
            if source.close[i + 3] > source.open[i + 3] then
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
    if period < first + 10 then
        return
    end

    local correct = 0
    local total = 10

    for i = period - 9, period do
        local pred = getPrediction(i - 1)
        local actual = source.close[i] > source.open[i] and "U" or "D"

        if pred == actual then
            correct = correct + 1
        end
    end

    accuracyStream[period] = (correct / total) * 100
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