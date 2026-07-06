-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33549
-- Id: 8767

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
    indicator:name("Tick Volume difference");
    indicator:description("Tick Volume difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("Method", "Method", "Method" , "Bar");
    indicator.parameters:addStringAlternative("Method", "Bar", "Bar" , "Bar");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
    indicator.parameters:addColor("Up_color", "Color of TVD Up Line", "Color of TVD", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Dn_color", "Color of TVD Down Line", "Color of TVD", core.rgb(255, 0, 0));
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
local Method;
-- Streams block
local TVD = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
    first = source:first()+Period*2;
	
    assert(source:supportsVolume(), "The source must have volume");

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
	    if Method == "Bar" then
		 TVD = instance:addStream("TVD", core.Bar, name, "TVD", instance.parameters.Up_color, first);
    	else
        TVD = instance:addStream("TVD", core.Line, name, "TVD", instance.parameters.Up_color, first);
		TVD:setWidth(instance.parameters.width);
        TVD:setStyle(instance.parameters.style);
		end
        TVD:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
    
	local One=mathex.sum(source.volume, period-Period+1, period);
	local Two=mathex.sum(source.volume, period-Period+1-1 -Period+1, period-Period+1-1)
    TVD[period] = One-Two;
   core.host:execute ("setStatus", One .. " - " .. Two);
   if TVD[period] >TVD[period-1] then 
   TVD:setColor(period, instance.parameters.Up_color);
   else
    TVD:setColor(period, instance.parameters.Dn_color);
   end
end

