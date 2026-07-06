-- Id: 7431
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23558

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
    indicator:name("Trend Trigger Factor");
    indicator:description("Trend Trigger Factor");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculate");
    indicator.parameters:addInteger("Period", "Period", "Period", 15);
	indicator.parameters:addDouble("OB", "OB/OS Level", "", 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TTF_color", "Color of TTF", "Color of TTF", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Zcolor", "OS/OB Level Line Color", "OS/OB Level Line Color", core.rgb(128, 128, 128));
	 indicator.parameters:addInteger("Zwidth", "OS/OB Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Zstyle", "OS/OB Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Zstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local OB;
local first;
local source = nil;

-- Streams block
local TTF = nil;

-- Routine
function Prepare(nameOnly)
    OB = instance.parameters.OB;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+2*Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        TTF = instance:addStream("TTF", core.Line, name, "TTF", instance.parameters.TTF_color, first);
    TTF:setPrecision(math.max(2, instance.source:getPrecision()));
		TTF:setWidth(instance.parameters.width);
        TTF:setStyle(instance.parameters.style);
		TTF:addLevel(OB, instance.parameters.Zstyle, instance.parameters.Zwidth, instance.parameters.Zcolor);    
		TTF:addLevel(-OB, instance.parameters.Zstyle, instance.parameters.Zwidth, instance.parameters.Zcolor);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
    
     local bp =mathex.max (source.high,period-Period+1,  period)- mathex.min (source.low,period-2*Period+1,  period-Period+1); 
	 local sp =mathex.max (source.high,period-2*Period+1,  period-Period+1)- mathex.min (source.low,period-Period+1,  period); 

    TTF[period]=((bp-sp)/(0.5*(bp+sp)))*100;  
    
end

