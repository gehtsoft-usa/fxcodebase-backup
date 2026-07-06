-- Id: 7183
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22632

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Volatility Channel");
    indicator:description("Volatility Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("twidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("tstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("tstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("bwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("bstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("bstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;
local T, B;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    T = instance:addInternalStream(0, 0);
		B = instance:addInternalStream(0, 0);
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.twidth);
        Top:setStyle(instance.parameters.tstyle);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.bwidth);
        Bottom:setStyle(instance.parameters.bstyle);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
	
	    T[period] = ( (  source.typical[period] * 2 ) - source.high[period]) ;
        B[period] = ( (  source.typical[period]  * 2 ) -  source.low[period]);  
		
		
	  if period >= first and source:hasData(period) then
	
	   local min, max;
	 
		
	    max = mathex.max (T, period-Period+1, period );
	    min = mathex.min (B, period-Period+1, period )
	   
        Top[period] = math.max(max, T[period]);
        Bottom[period] = math.min( min, B[period]);
    end
end

