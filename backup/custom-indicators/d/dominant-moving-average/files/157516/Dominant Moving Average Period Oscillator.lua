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
    indicator:name("Dominant Moving Average Period Oscillator")
    indicator:description("Identifies and returns the dominant moving average period as an oscillator.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    
    -- Input parameters
    indicator.parameters:addInteger("Min_Period", "Minimum Moving Average Period", "The minimum lookback period for the moving average.", 10, 1, 1000)
    indicator.parameters:addInteger("Max_Period", "Maximum Moving Average Period", "The maximum lookback period for the moving average.", 50, 1, 1000)
    indicator.parameters:addColor("clrDomPeriod", "Oscillator Line Color", "Color of the dominant period oscillator line", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("widthDomPeriod", "Oscillator Line Width", "Width of the oscillator line", 2, 1, 5)
    indicator.parameters:addInteger("styleDomPeriod", "Oscillator Line Style", "Style of the oscillator line", core.LINE_SOLID)
end

local minPeriod, maxPeriod, src
local dominantPeriodStream

function Prepare()
    -- Get input parameters
    minPeriod = instance.parameters.Min_Period
    maxPeriod = instance.parameters.Max_Period
    src = instance.source.close
    
    -- Indicator name
    local name = "Dominant MA Period Oscillator (" .. minPeriod .. ", " .. maxPeriod .. ")"
    instance:name(name)
    
    -- Create a stream to hold the dominant period as an oscillator
    dominantPeriodStream = instance:addStream("DominantPeriod", core.Line, name, "Dominant Period", instance.parameters.clrDomPeriod, src:first() + maxPeriod)
    dominantPeriodStream:setWidth(instance.parameters.widthDomPeriod)
    dominantPeriodStream:setStyle(instance.parameters.styleDomPeriod)
end

function Update(period)
    -- Make sure there is enough data to calculate all required moving averages
    if period < src:first() + maxPeriod then
        return
    end

    local bestVariance = math.huge -- Initialize with a large number
    local bestPeriod = 0

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
        end
    end

    -- Store the dominant moving average period
    dominantPeriodStream[period] = bestPeriod
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