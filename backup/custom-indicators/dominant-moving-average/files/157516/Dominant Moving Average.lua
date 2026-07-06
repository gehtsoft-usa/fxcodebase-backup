-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75417

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 

function Init()
    indicator:name("Dominant Moving Average Period")
    indicator:description("Identifies the dominant moving average period that best tracks price movements.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    
    -- Input parameters
    indicator.parameters:addInteger("Min_Period", "Minimum Moving Average Period", "The minimum lookback period for the moving average.", 10, 1, 1000)
    indicator.parameters:addInteger("Max_Period", "Maximum Moving Average Period", "The maximum lookback period for the moving average.", 50, 1, 1000)
    indicator.parameters:addColor("clrDomMA", "Dominant MA Line Color", "Color of the dominant moving average line", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthDomMA", "Dominant MA Line Width", "Width of the dominant moving average line", 2, 1, 5)
    indicator.parameters:addInteger("styleDomMA", "Dominant MA Line Style", "Style of the dominant moving average line", core.LINE_SOLID)
end

local minPeriod, maxPeriod, src
local dominantPeriodStream, dominantMAStream

function Prepare()
    -- Get input parameters
    minPeriod = instance.parameters.Min_Period
    maxPeriod = instance.parameters.Max_Period
    src = instance.source.close
    
    -- Indicator name
    local name = "Dominant Moving Average (" .. minPeriod .. ", " .. maxPeriod .. ")"
    instance:name(name)
    
    -- Create internal streams for intermediate calculations
    dominantPeriodStream = instance:addStream("DominantPeriod", core.Line, name, "Dominant Period", core.rgb(0, 0, 255), src:first() + maxPeriod)
    dominantPeriodStream:setWidth(2)
    
    dominantMAStream = instance:addStream("DominantMA", core.Line, name, "Dominant Moving Average", instance.parameters.clrDomMA, src:first() + maxPeriod)
    dominantMAStream:setWidth(instance.parameters.widthDomMA)
    dominantMAStream:setStyle(instance.parameters.styleDomMA)
end

function Update(period)
    if period < src:first() + maxPeriod then
        return
    end

    local bestVariance = math.huge -- Initialize with a large number
    local bestPeriod = 0
    local bestMAValue = 0

    for p = minPeriod, maxPeriod do
        -- Calculate the moving average for the current period
        local sum = 0
        for i = 0, p - 1 do
            sum = sum + src[period - i]
        end
        local maValue = sum / p

        -- Calculate the variance between price and moving average
        local variance = 0
        for i = 0, p - 1 do
            local deviation = src[period - i] - maValue
            variance = variance + deviation * deviation
        end
        variance = variance / p

        -- Check if this period has the smallest variance
        if variance < bestVariance then
            bestVariance = variance
            bestPeriod = p
            bestMAValue = maValue
        end
    end

    -- Store the dominant moving average and dominant period
    dominantPeriodStream[period] = bestPeriod
    dominantMAStream[period] = bestMAValue
end
-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 