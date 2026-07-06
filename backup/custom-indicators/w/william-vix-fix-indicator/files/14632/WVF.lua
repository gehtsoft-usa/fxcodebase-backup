-- Id: 4548
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6362

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name(" William Vix Fix indicator");
    indicator:description(" William Vix Fix indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 22);
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addString("Type", "Line Type", "Type" , "Line");
    indicator.parameters:addStringAlternative("Type", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Type", "Bar", "Bar" , "Bar");
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("WVF_color", "Color of WVF", "Color of WVF", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Type;
-- Streams block
local WVF = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Type = instance.parameters.Type;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Type).. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    if Type == "Line" then
        WVF = instance:addStream("WVF", core.Line, name, "WVF", instance.parameters.WVF_color, first);
    	WVF:setWidth(instance.parameters.width);
        WVF:setStyle(instance.parameters.style);
		else
		WVF = instance:addStream("WVF", core.Bar, name, "WVF", instance.parameters.WVF_color, first);
		end
        WVF:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
        WVF[period] = ((mathex.max (source.close, period- Period, period)- source.low[period])/mathex.max(source.close, period- Period, period))*100;
  
end

