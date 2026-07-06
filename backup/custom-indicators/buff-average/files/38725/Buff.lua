-- Id: 7145
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22436

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
    indicator:name("Buff Averages");
    indicator:description("Buff Averages");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	
     indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("color", "Line color", "", core.rgb(255, 0, 0));
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
local Buff = nil;
local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Raw= instance:addInternalStream(0, 0);
        Buff = instance:addStream("Buff", core.Line, name, "Buff", instance.parameters.color, first);
		Buff:setWidth(instance.parameters.width);
        Buff:setStyle(instance.parameters.style);		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    Raw[period]= source.volume[period]*source.close[period];

			
    if period < first or not source:hasData(period) then
	return;
	end
        Buff[period] =  mathex.sum(Raw, period- Period+1, period)/  mathex.sum(source.volume, period- Period+1, period) ;     
end

