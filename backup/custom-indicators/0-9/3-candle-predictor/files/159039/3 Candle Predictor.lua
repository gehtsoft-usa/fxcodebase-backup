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
    indicator:name("3 Candle Predictor")
    indicator:description("Predict next candle direction based on historical pattern of 3 candles")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UpColor", "Predicted UP Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownColor", "Predicted DOWN Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("NeutralColor", "Neutral Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addColor("DefaultColor", "Default Color", "", core.rgb(0, 0, 255))
	
	
   indicator.parameters:addInteger("Size", "Size", "", 12);
end

local source, first, upColor, downColor, neutralColor, defaultColor, prediction

function Prepare(nameOnly)
    source = instance.source
    first = source:first() + 4

    local name = "3 Candle Predictor (" .. source:name() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end
	
    downColor = instance.parameters.DownColor
    neutralColor = instance.parameters.NeutralColor
    defaultColor = instance.parameters.DefaultColor	
    upColor = instance.parameters.UpColor
	Size = instance.parameters.Size;
	
    predictionUp = instance:createTextOutput("Prediction Up", "Prediction Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.UpColor, first)
    predictionDown = instance:createTextOutput("Prediction Down", "Prediction Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.DownColor, first)	
    predictionUpNeutral = instance:createTextOutput("Prediction Up", "Prediction Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.NeutralColor, first)
    predictionDownNeutral = instance:createTextOutput("Prediction Down", "Prediction Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.NeutralColor, first)	
    predictionNeutral = instance:createTextOutput("Prediction Neutral", "Prediction Neutral", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.DefaultColor, first)		


end

function Update(period)


    predictionUp:setNoData(period);
	predictionDown:setNoData(period);
	predictionNeutral:setNoData(period);	
    predictionNeutral:setNoData(period);
	predictionDownNeutral:setNoData(period);	
			
    if period < first then return end

    local pattern = {}
    for i = 3, 1, -1 do
        if source.close[period - i] > source.open[period - i] then
            pattern[#pattern + 1] = "U"
        else
            pattern[#pattern + 1] = "D"
        end
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

    local predSymbol, predColor, position
    if upCount > downCount then
        predSymbol = "\233" 
        position = source.low[period] - 2 * source:pipSize()
		if  source.close[period] > source.open[period] then
        predictionUp:set(period, position, predSymbol)
        else
        predictionUpNeutral:set(period, position, predSymbol)		
        end	
    elseif downCount > upCount   then
        predSymbol = "\234"
        predColor = downColor
        position = source.high[period] + 2 * source:pipSize()
		
		if  source.close[period] < source.open[period] then
        predictionDown:set(period, position, predSymbol)
        else
        predictionDownNeutral:set(period, position, predSymbol)		
        end		
    else
        predSymbol = "\253"
        predColor = neutralColor
        position = source.median[period] + 2 * source:pipSize()
        predictionNeutral:set(period, position, predSymbol)		
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