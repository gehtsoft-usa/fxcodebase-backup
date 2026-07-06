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
    indicator:name("Real time Forecast N Candle Predictor")
    indicator:description("Predict next candle direction based on historical pattern of N candles")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

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

    local name = "Real time N Candle Predictor (" .. source:name() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    upColor = instance.parameters.UpColor
    downColor = instance.parameters.DownColor
    neutralColor = instance.parameters.NeutralColor
    defaultColor = instance.parameters.DefaultColor
    Size = instance.parameters.Size

    predictionUp = instance:createTextOutput("Prediction Up", "Prediction Up", "Wingdings", Size, core.H_Center, core.V_Bottom, upColor, first)
    predictionDown = instance:createTextOutput("Prediction Down", "Prediction Down", "Wingdings", Size, core.H_Center, core.V_Top, downColor, first)
    predictionUpNeutral = instance:createTextOutput("Prediction Up Neutral", "Prediction Up Neutral", "Wingdings", Size, core.H_Center, core.V_Bottom, neutralColor, first)
    predictionDownNeutral = instance:createTextOutput("Prediction Down Neutral", "Prediction Down Neutral", "Wingdings", Size, core.H_Center, core.V_Top, neutralColor, first)
    predictionNeutral = instance:createTextOutput("Prediction Neutral", "Prediction Neutral", "Wingdings", Size, core.H_Center, core.V_Center, defaultColor, first)
end

-- Update() function - modified to sample only closed candles (no influence of current forming candle)

function Update(period)
    predictionUp:setNoData(period)
    predictionDown:setNoData(period)
    predictionNeutral:setNoData(period)
    predictionUpNeutral:setNoData(period)
    predictionDownNeutral:setNoData(period)

    if period < first then return end

    -- Create pattern from the last completed candles (excluding current forming candle)
    local pattern = {}
    for i = patternLength, 1, -1 do
        if source.close[period - i - 1] > source.open[period - i - 1] then
            pattern[#pattern + 1] = "U"
        else
            pattern[#pattern + 1] = "D"
        end
    end

    local upCount, downCount = 0, 0
    
    -- Search historical matches (excluding current forming candle)
    for i = first, period - patternLength - 1 do
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

    -- Draw prediction for the forming candle
    local y1 = (source.high[period] + source.low[period]) / 2 
    local y2= source.high[period]
    local y3 = source.low[period] 
    if upCount >downCount  then
	
	    if source.close[period] >source.open[period] then
        predictionUp:set(period,y3, "\233")
		else
        predictionUpNeutral:set(period,y3, "\233")		
		end
		
		
    elseif downCount > upCount  then

		
	    if source.close[period] <source.open[period] then
        predictionDown:set(period,y2,"\234" )
		else
        predictionDownNeutral:set(period,y2,"\234" )
		end		
    else
	    predictionNeutral:set(period,y1, "\253")
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