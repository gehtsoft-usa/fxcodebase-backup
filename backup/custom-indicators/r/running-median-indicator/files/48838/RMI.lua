-- Id: 8182
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27852

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
    indicator:name("Running Median Indicator");
    indicator:description("Running Median Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period must be ODD -or +1 will be added", 13);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RMI_color", "Color of RMI", "Color of RMI", core.rgb(255, 0, 0));
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
local raw;
local before ;
local after ;
-- Streams block
local RMI = nil;
local Last;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	if math.mod(Period,2)==0 then
	Period=Period+1;
	end
    source = instance.source;
    first = source:first() ;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        RMI = instance:addStream("RMI", core.Line, name, "RMI", instance.parameters.RMI_color, first);
		RMI:setWidth(instance.parameters.width);
        RMI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)



   -- table.insert(before,  #before+1,source.median[period]);
	

    if period <= first  then
	  before={} ;
      after={} ;
       return;
    end
	

	
	
	
	if period <= first+Period  then
	table.insert(before,  source.median[period]);
	return;
	end
	
	
	
	if Last~=  source:serial(period)then
	Last=source:serial(period);
	table.remove(before, 1);
    before[Period]= source.median[period];
	else
	before[Period]= source.median[period];
	end
	
	
	 Copy ( before, after);
    table.sort(after);
	 
	
	 RMI[period]= after[Period/2+0.5];

end

function Copy (from, to)

local i;

	for i = 1, #from, 1 do
	
	to[i]= from[i];

	end

end

