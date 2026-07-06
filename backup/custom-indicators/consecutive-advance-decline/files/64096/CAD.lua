-- Id: 9222
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=38887

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
    indicator:name("Consecutive Advance / Decline");
    indicator:description("Consecutive Advance / Decline");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);


    indicator.parameters:addColor("Advance", "Color of Advance", "Color of Advance", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("Decline", "Color of Decline", "Color of Decline", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
 
local Advance, Decline;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first();
	 
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Advance = instance:addStream("Advance", core.Line, name, "Advance", instance.parameters.Advance, first);
    Advance:setPrecision(math.max(2, instance.source:getPrecision()));
		Advance:setWidth(instance.parameters.width1);
        Advance:setStyle(instance.parameters.style1);
		
		Decline = instance:addStream("Decline", core.Line, name, "Decline", instance.parameters.Decline, first);
    Decline:setPrecision(math.max(2, instance.source:getPrecision()));
		Decline:setWidth(instance.parameters.width2);
        Decline:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	if source[period]>source[period-1] then
	Advance[period]= Advance[period-1]+1;
	Decline[period]= 0;
	elseif source[period]<source[period-1] then
	Decline[period]= Decline[period-1]+1;
	Advance[period]= 0;
	else
	Advance[period]= 0;
	Decline[period]= 0;
	end
	
end

