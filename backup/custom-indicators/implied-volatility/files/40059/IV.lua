-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23269
-- Id: 7357

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
    indicator:name("Implied volatility");
    indicator:description("Implied volatility");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
    indicator.parameters:addColor("IV_color", "Color of IV", "Color of IV", core.rgb(255, 0, 0));
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
local IV = nil;
local s1,e1;
local s2,e2;
local Size1, Size2, Ratio;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
   	
	 s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0); 
	 s2, e2 = core.getcandle("D1",  core.now(), 0, 0); 	
	 
	 Size1 = (e1-s1)*Period;
	 Size2 = (e2-s2)*365;
	 
	 Ratio= (Size2 / (Size1));
	 
	  first = source:first()+Period;
	 
    local name = profile:id() .. "(" .. source:name().. ", " .. tostring(Period)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        IV = instance:addStream("IV", core.Line, name, "IV", instance.parameters.IV_color, first);
		IV:setWidth(instance.parameters.width);
        IV:setStyle(instance.parameters.style);
		IV:setPrecision (4);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

--http://www.optionsplaybook.com/options-introduction/what-is-volatility/
    if period >= first and source:hasData(period) then
	
	--local Ratio= (Size2 / (Size1))	;	
	local SD = mathex.stdev(source.close, period - Period + 1, period);
	
	
        IV[period] = (SD* (365)^(1/2)) / (source.close[period] * (Ratio)^(1/2));
	
    end
end

