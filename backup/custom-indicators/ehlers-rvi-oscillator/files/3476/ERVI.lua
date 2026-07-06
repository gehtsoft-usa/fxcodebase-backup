-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1735
-- Id: 1202

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Ehlers RVI oscillator");
    indicator:description("Ehlers RVI oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Frame", "Period", "Period", 10);
    indicator.parameters:addColor("RVI_color", "Color of RVI", "Color of RVI", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SIGNAL_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

-- Streams block
local RVI = nil;
local SIGNAL =nil;

local Value1=nil;
local Value2=nil;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
    source = instance.source;
    first = source:first()+3;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	Value1= instance:addInternalStream(0, 0);
	Value2=instance:addInternalStream(0, 0);
    RVI = instance:addStream("RVI", core.Line, name, "RVI", instance.parameters.RVI_color, first+ Frame );
    RVI:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.SIGNAL_color, first+ Frame );
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period > first and source:hasData(period) then

		
		local Num=0;
		local Denom=0;	

			Value1[period] = ((source.close[period] - source.open[period]) + 2*(source.close[period-1] - source.open[period-1]) + 2*(source.close[period-2] - source.open[period-2]) + (source.close[period-3] - source.open[period-3]))/6;
			Value2[period] = ((source.high[period] - source.low[period]) + 2*(source.high[period-1] - source.low[period-1]) + 2*(source.high[period-2] - source.low[period-2]) + (source.high[period-3] - source.low[period-3]))/6;
            
			
			if period > first+ Frame then
			
					Num = core.sum(Value1, core.range(period-Frame, period));
					Denom = core.sum(Value2, core.range(period-Frame, period));
					
					
					if Denom ~= 0 then 
					    RVI[period] = Num / Denom;						
												
					    if period > Frame + 3 then
					    SIGNAL[period] = (RVI[period] + 2*RVI[period-1] + 2*RVI[period-2] + RVI[period-3])/6;    
					    end
					end
			end
	end
   
end

