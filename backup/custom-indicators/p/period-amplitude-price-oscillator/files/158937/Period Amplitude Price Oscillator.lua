-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75822

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright � 2025, Gehtsoft USA LLC  | 
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
-- Custom Oscillator za FXCM TS2 s metodama izglađivanja

function Init()
    indicator:name("Period, Amplitude, Price Oscillator")
    indicator:description("Calculates period range, amplitude and price within range with smoothing")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("N", "Period Length", "Number of bars in period", 14, 1, 1000)
    indicator.parameters:addString("Method", "Smoothing Method", "Method", "MVA")
    indicator.parameters:addStringAlternative("Method", "MVA", "Simple Moving Average", "MVA")
    indicator.parameters:addStringAlternative("Method", "EMA", "Exponential Moving Average", "EMA")
    indicator.parameters:addStringAlternative("Method", "LWMA", "Linear Weighted MA", "LWMA")
    indicator.parameters:addStringAlternative("Method", "SMMA", "Smoothed MA", "SMMA")

    indicator.parameters:addInteger("SmoothPeriod", "Smoothing Period", "Period for smoothing the oscillator", 5, 1, 100)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Oscillator Color", "", core.rgb(0, 128, 255))
    indicator.parameters:addInteger("width", "Line Width", "", 2, 1, 5)
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);			
end

local source = nil
local period_length = 14
local first = 0
local osc_stream = nil
local smoothed_stream = nil
local method, smooth_period
local MA

function Prepare(onlyName)
    source = instance.source
    period_length = instance.parameters.N
    method = instance.parameters.Method
    smooth_period = instance.parameters.SmoothPeriod

    local name = "Oscillator(" .. source:name() .. ", " .. period_length .. ", " .. method .. ", " .. smooth_period .. ")"
    instance:name(name)

    if onlyName then
        return
    end

    first = source:first() + period_length
    osc_stream = instance:addInternalStream(first)

    MA = core.indicators:create(method, osc_stream, smooth_period)
    smoothed_stream = instance:addStream("OSC", core.Line, name, "OSC", instance.parameters.color, MA.DATA:first())
    smoothed_stream:setWidth(instance.parameters.width)
    smoothed_stream:setStyle(instance.parameters.style)
    smoothed_stream:setPrecision(math.max(2, instance.source:getPrecision()));	
	smoothed_stream:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	smoothed_stream:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	smoothed_stream:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
end

function Update(period)
    if period >= first then
        local high = core.max(source.high, core.rangeTo(period, period_length))
        local low = core.min(source.low, core.rangeTo(period, period_length))
        local amplitude = high - low
        local price = source.close[period]

        if amplitude ~= 0 then
            osc_stream[period] = ((price - low) / amplitude) * 100
        else
            osc_stream[period] = 50  -- neutral if amplitude is zero
        end

        MA:update(core.UpdateLast)
        if period >= MA.DATA:first() then
            smoothed_stream[period] = MA.DATA[period]
        end
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75822

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright � 2025, Gehtsoft USA LLC  | 
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