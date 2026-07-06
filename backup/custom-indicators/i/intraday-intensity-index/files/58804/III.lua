-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34513
-- Id: 8988

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
    indicator:name("Intraday Intensity Index");
    indicator:description("Intraday Intensity Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 21);
	indicator.parameters:addBoolean("Normalized"  , "Use Normalization", "", true);	
	
	indicator.parameters:addGroup("Style");		
    indicator.parameters:addColor("III_color", "Color of III", "Color of III", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
  
local first;
local source = nil;
local Period;
local Normalized;
-- Streams block
local III = nil;
local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Normalized = instance.parameters.Normalized;
    source = instance.source;
    first = source:first()+Period;
	
	 assert(source:supportsVolume(), "The source must have volume");

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Raw = instance:addInternalStream(0, 0);
        III = instance:addStream("III", core.Line, name, "III", instance.parameters.III_color, first);
    III:setPrecision(math.max(2, instance.source:getPrecision()));
		III:setWidth(instance.parameters.width);
        III:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    Raw[period] =  ((2*source.close[period]-source.high[period]-source.low[period])/(source.high[period]-source.low[period]))*source.volume[period];
   
    if period < first   then
	return;	
	end
	if  Normalized then	 
	III[period]= (mathex.sum(Raw, period-Period+1, period)/ mathex.sum(source.volume, period-Period+1, period))*100 ;
	else	
	III[period]= mathex.sum(Raw, period-Period+1, period);
	end
        
    
end

