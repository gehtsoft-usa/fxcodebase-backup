-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33104
-- Id: 8714

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
    indicator:name("Natenberg's Volatility");
    indicator:description("Natenberg's Volatility");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	 
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("NV_color", "Color of NV", "Color of NV", core.rgb(255, 0, 0));
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
 
-- Streams block
local NV = nil;
local Raw;
local Ratio;
local Period;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    
	Period= instance.parameters.Period;
	first = source:first()+Period;
	
	local s2, e2, s1, e1;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
    s2, e2 = core.getcandle("D1", core.now(), 0, 0);
	
	Ratio = (e1-s1)/(e2-s2);

    local name = profile:id() .. "(" .. source:name()    .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Raw = instance:addInternalStream(0, 0);
        NV = instance:addStream("NV", core.Line, name, "NV", instance.parameters.NV_color, first );
    NV:setPrecision(math.max(2, instance.source:getPrecision()));
		NV:setWidth(instance.parameters.width);
        NV:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    Raw[period]=  math.log( source.close[period] / source.close[period-1] )
	
    if period < first  then
	return;
	end
	
        NV[period] = mathex.stdev(Raw, period-Period+1, period)* math.sqrt( 365 / Ratio );
    
end

