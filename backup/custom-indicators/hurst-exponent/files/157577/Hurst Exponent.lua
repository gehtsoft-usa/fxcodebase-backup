-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75433

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
 
 
-- Hurst Exponent Indicator for FXCM TS2 Trading Platform
-- This script calculates the Hurst Exponent of a given price series.


-- **Description:**
-- The Hurst Exponent is a statistical indicator used to measure the long-term memory of time series data.
-- It helps determine whether a price series is trending, mean-reverting, or following a random walk.
-- Values of H > 0.5 suggest a trending market, H < 0.5 indicates mean reversion, and H = 0.5 implies a random walk.

-- **Usage:**
-- - Use the 'Period' parameter to define the window size for the Hurst calculation.
-- - Customize the line color, width, and style for better visibility on charts.
-- - Enable optional smoothing to reduce noise and get a cleaner Hurst Exponent curve.
--
-- **Parameters:**
-- - **Period**: Number of bars to use for the Hurst calculation.
-- - **Line Color**: Customizable line color for the indicator.
-- - **Line Width**: Thickness of the line on the chart.
-- - **Line Style**: Line style (solid, dashed, dotted) for the indicator.
-- - **Use Smoothing**: Boolean option to enable smoothing.
-- - **Smoothing Period**: Number of periods used for smoothing the Hurst Exponent.

-- Required constants and inputs
function Init()
    indicator:name("Hurst Exponent")
    indicator:description("Calculates the Hurst Exponent of a price series.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Calculation period for the Hurst Exponent", "", 100)
	
    indicator.parameters:addGroup("Smoothing");
    indicator.parameters:addBoolean("UseSmoothing", "Apply smoothing to the Hurst Exponent", "", false);
    indicator.parameters:addInteger("SmoothingPeriod", "Smoothing period", "", 10);	
	
    indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("LineColor", "Line color for the Hurst Exponent", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("LineWidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("LineStyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
    

end

-- Global variables
local first
local source
local period
local useSmoothing
local smoothingPeriod

-- Prepare function initializes the indicator
function Prepare()
    period = instance.parameters.Period
    source = instance.source
    useSmoothing = instance.parameters.UseSmoothing
    smoothingPeriod = instance.parameters.SmoothingPeriod
    first = period + source:first() - 1
    
    local name = string.format("Hurst Exponent (%d)", period)
    instance:name(name)
	
    Source = instance:addInternalStream(0, 0);	
    
    H = instance:addStream("H", core.Line, name, "H", instance.parameters.LineColor, first)
    H:setWidth(instance.parameters.LineWidth)
    H:setStyle(instance.parameters.LineStyle)
end

-- Update function calculates the Hurst Exponent for each new bar
function Update(period, mode)
    if period < first then
        return
    end
    
    local N = instance.parameters.Period
    
    -- Extract the price series for the given period
    local prices = {}
    for i = period - N + 1, period do
        table.insert(prices, source.close[i])
    end
    
    -- Calculate the log returns
    local logReturns = {}
    for i = 2, #prices do
        logReturns[i-1] = math.log(prices[i] / prices[i-1])
    end
    
    -- Calculate the rescaled range (R/S) for different sub-periods
    local rescaledRange = calculateRescaledRange(logReturns, N)
    
    -- Calculate the Hurst Exponent using the slope of log(R/S) vs log(N)
    Source[period] = calculateHurstExponent(rescaledRange, N)
    
    if useSmoothing then
        H[period] = applySmoothing(Source, period, smoothingPeriod, hurstValue)
    else
        H[period] = Source[period]
    end
end

-- Function to calculate the rescaled range (R/S) for a given log return series
function calculateRescaledRange(logReturns, N)
    local cumulativeDeviation = {}
    local mean = 0
    for i = 1, #logReturns do
        mean = mean + logReturns[i]
    end
    mean = mean / #logReturns
    
    cumulativeDeviation[1] = logReturns[1] - mean
    for i = 2, #logReturns do
        cumulativeDeviation[i] = cumulativeDeviation[i-1] + (logReturns[i] - mean)
    end
    
    local R = math.max(unpack(cumulativeDeviation)) - math.min(unpack(cumulativeDeviation))
    local S = standardDeviation(logReturns)
    
    if S == 0 then
        return 0
    else
        return R / S
    end
end

-- Function to calculate the standard deviation of a series
function standardDeviation(values)
    local mean = 0
    for i = 1, #values do
        mean = mean + values[i]
    end
    mean = mean / #values
    
    local variance = 0
    for i = 1, #values do
        variance = variance + (values[i] - mean) ^ 2
    end
    variance = variance / (#values - 1)
    
    return math.sqrt(variance)
end

-- Function to calculate the Hurst Exponent from rescaled range values
function calculateHurstExponent(rescaledRange, N)
    if rescaledRange == 0 then
        return 0.5 -- Random walk case
    end
    
    -- Calculate log(R/S) and log(N)
    local logRS = math.log(rescaledRange)
    local logN = math.log(N)
    
    -- Slope of log(R/S) vs log(N) gives the Hurst Exponent
    return logRS / logN
end

-- Function to apply optional smoothing to the Hurst Exponent values
function applySmoothing(stream, period, smoothingPeriod, value)
    local sum = 0
    local count = 0
    for i = math.max(period - smoothingPeriod + 1, 0), period do
        sum = sum + stream[i]
        count = count + 1
    end
    return sum / count
end

-- Available @ http://fxcodebase.com/ 

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