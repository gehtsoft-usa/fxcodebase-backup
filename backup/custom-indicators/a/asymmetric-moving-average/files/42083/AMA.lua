-- Id: 7689
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24459

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
    indicator:name("Asymmetric moving average");
    indicator:description("Asymmetric moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);

	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("CMA_color", "Color of CMA", "Color of CMA", core.rgb(255, 0, 0));
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
local Raw;
local first;
local source = nil;

-- Streams block
local CMA = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;	 
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Raw=instance:addInternalStream(first, Period/2); 
        CMA = instance:addStream("CMA", core.Line, name, "CMA", instance.parameters.CMA_color, first);
		CMA:setWidth(instance.parameters.width);
        CMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

     Raw[period]= source[period];
	 
	 
    if period < first or not source:hasData(period) or period <  (first+Period/2) then
	return;
	end
   
	
	local Count=0;
	
	for  i = period+1, (period+Period/2), 1 do
	 Raw[i] =source[period]; 
	end
	
	
	
	CMA[period] = mathex.avg(Raw, (period-Period/2+1), (period+Period/2)) ;
    
end

