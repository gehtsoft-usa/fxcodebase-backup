-- Id: 13734
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1355

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
    indicator:name("Fractal Adaptive Moving Average");
    indicator:description("Fractal Adaptive Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Frama Period", "Frama Period", 10,2,2000);	
	indicator.parameters:addInteger("Fast", "Fast Frama Period", "Fast Period", 2,2,2000);
	indicator.parameters:addInteger("Slow", "Slow Frama Period", "Frama Period", 100,2,2000);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Frama_color", "Color of Frama", "Color of Frama", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
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
local High1,High2,High3,Low1, Low2,Low3;
local N1,N2,N3;
local D=nil;
local Alpha=nil;
local Frama = nil;
local Slow;
local Fast;
 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Slow= instance.parameters.Slow;
	Fast= instance.parameters.Fast;	
	assert(Slow >= Fast, "Slow must be greater than Fast"); 
	Period=((Slow-Fast)*((Period-1)/(Slow-1)))+Fast;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Frama = instance:addStream("Frama", core.Line, name, "Frama", instance.parameters.Frama_color, first);
	Frama:setWidth(instance.parameters.width);
    Frama:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	 	
	  if period == first then
	  Frama[period-1]= source.median[period-1];
      end
		
	 High1= core.max(source.high,core.range (period-Period/2, period));
	 Low1= core.min(source.low,core.range (period-Period/2, period));
	 
	 High2= core.max(source.high,core.range (period-Period, period-Period/2));
	 Low2= core.min(source.low,core.range (period-Period, period-Period/2));
	 High3= core.max(source.high,core.range (period-Period, period));
	 Low3 = core.min(source.low,core.range (period-Period, period));
    
      N1=(High1-Low1)/(Period/2);
      N2=(High2-Low2)/(Period/2);
      N3=(High3-Low3)/(Period);
      D=(math.log(N1+N2)-math.log(N3))/math.log(2.0);
      Alpha=math.exp(-4.6*(D-1.0));
	 
	  
	  
      Frama[period] = Alpha*source.median[period]+(1-Alpha)*Frama[period-1];
       
   
end

