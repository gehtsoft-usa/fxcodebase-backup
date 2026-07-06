-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60923

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("True Strength Index Convergence Divergence")
    indicator:description(
        "Is a variation of the Relative Strength Indicator which uses a doubly-smoothed exponential moving average of price momentum to eliminate choppy price changes and spot trend changes."
    )
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
    indicator:setTag("group", "Oscillators")

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger(
        "N",
        "Long Term",
        "The number of periods to average the Price Momentum.",
        7,
        2,
        1000
    )
    indicator.parameters:addInteger(
        "M",
        "Short Term",
        "The number of periods to smooth the Average Momentum.",
        14,
        2,
        1000
    )

    indicator.parameters:addString("Method1", "TSI MA Method", "Method", "EMA")
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA")
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA")

    indicator.parameters:addInteger("S", "Signal Line Period", "", 14, 2, 1000)
    indicator.parameters:addString("Method2", "Signal MA Method", "Method", "EMA")
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA")
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor(
        "color1",
        "TSI Line Color",
        "The color of the True Strength Index line.",
        core.rgb(255, 0, 0)
    )
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color2", "Signal Line Color", "The color of the Signal line.", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)


    indicator.parameters:addColor(
        "color3",
        "Histogram Line Color",
        "The color of the Histogram line.",
        core.rgb(0, 0, 255)
    )
	
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)	

    indicator.parameters:addInteger("ob_level", "Overbought level", "", 50);
    indicator.parameters:addInteger("os_level", "Oversold level", "", -50);

    indicator.parameters:addGroup("Selector")	
	indicator.parameters:addBoolean("draw_tsi", "Draw TSI", "", true);
	indicator.parameters:addBoolean("draw_signal", "Draw Signal", "", true);	
	indicator.parameters:addBoolean("draw_histogram", "Draw Histogram", "", true);
	
    indicator.parameters:addGroup("Horizontal line")	
	indicator.parameters:addBoolean("draw_tsi_line", "Draw TSI", "", false);
	indicator.parameters:addBoolean("draw_signal_line", "Draw Signal", "", false);	
	indicator.parameters:addBoolean("draw_histogram_line", "Draw Histogram", "", false);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local S
local Method2
local n
local m
local Method1
local first
local source = nil
local delta = nil
local absDelta = nil
local ema_r1 = nil
local ema_r2 = nil
local ema_s1 = nil
local ema_s2 = nil
local deltaFirst = nil
local Signal, Histogram
local MA
-- Streams block
local TSI = nil

-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1
    Method2 = instance.parameters.Method2
    S = instance.parameters.S
    n = instance.parameters.N
    m = instance.parameters.M
    source = instance.source

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. n .. ", " .. m .. ", " .. Method1 .. ", " .. S .. ", " .. Method2 .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    delta = instance:addInternalStream(0, 0)
    absDelta = instance:addInternalStream(0, 0)
    deltaFirst = delta:first()

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed")
    ema_r1 = core.indicators:create(Method1, delta, n)
    ema_r2 = core.indicators:create(Method1, absDelta, n)
    ema_s1 = core.indicators:create(Method1, ema_r1.DATA, m)
    ema_s2 = core.indicators:create(Method1, ema_r2.DATA, m)

    first = ema_s1.DATA:first()
    if instance.parameters.draw_tsi then		
    TSI = instance:addStream("TSI", core.Line, name, "TSI", instance.parameters.color1, first)
    TSI:setPrecision(math.max(2, instance.source:getPrecision()))
    TSI:setWidth(instance.parameters.width1)
    TSI:setStyle(instance.parameters.style1)
    TSI:addLevel(0);
    TSI:addLevel(instance.parameters.os_level);
    TSI:addLevel(instance.parameters.ob_level);	
    else
        TSI = instance:addInternalStream(0, 0);
    end



    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed")
    MA = core.indicators:create(Method2, TSI, S)

    if instance.parameters.draw_signal then
    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, MA.DATA:first())
    Signal:setPrecision(math.max(2, instance.source:getPrecision()))
    Signal:setWidth(instance.parameters.width2)
    Signal:setStyle(instance.parameters.style2)
    else
        Signal = instance:addInternalStream(0, 0);
    end

    if instance.parameters.draw_histogram then
        Histogram =
            instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, MA.DATA:first())
        Histogram:setPrecision(math.max(2, instance.source:getPrecision()))
    else
        Histogram = instance:addInternalStream(0, 0);
    end
	
	instance:ownerDrawn(true);	
end

-- Indicator calculation routine
function Update(period, mode)
    if period < deltaFirst then
        return
    end
    delta[period] = source[period] - source[period - 1]
    absDelta[period] = math.abs(delta[period])

    ema_r1:update(mode)
    ema_r2:update(mode)
    ema_s1:update(mode)
    ema_s2:update(mode)

    if period < first then
        return
    end
    if ema_s2.DATA[period] == 0 then
        TSI[period] = 0
    else
        TSI[period] = 100 * ema_s1.DATA[period] / ema_s2.DATA[period]
    end
    MA:update(mode)

    if period < MA.DATA:first() then
        return
    end

    Signal[period] = MA.DATA[period]

    Histogram[period] = TSI[period] - Signal[period]
end


local init = false; 
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
 
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
		init =true;
		context:createPen (1, context:convertPenStyle ( instance.parameters.style1), context:pixelsToPoints ( instance.parameters.width1),  instance.parameters.color1);	 
		context:createPen (2, context:convertPenStyle ( instance.parameters.style2), context:pixelsToPoints ( instance.parameters.width2), instance.parameters.color2);
		context:createPen (3, context:convertPenStyle ( instance.parameters.style3), context:pixelsToPoints ( instance.parameters.width3), instance.parameters.color3);
	end
	
	if instance.parameters.draw_tsi_line then
	visible, y1= context:pointOfPrice (TSI[source:size()-1])
    context:drawLine (1, context:left(), y1,context:right(), y1);
	end
	
	if instance.parameters.draw_signal_line then
	visible, y2= context:pointOfPrice (Signal[source:size()-1])	
    context:drawLine (2, context:left(), y2,context:right(), y2); 
	end
	
	if instance.parameters.draw_histogram_line then
	visible, y3= context:pointOfPrice (Histogram[source:size()-1])
    context:drawLine (3, context:left(), y3,context:right(), y3); 	
	end
end	
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+