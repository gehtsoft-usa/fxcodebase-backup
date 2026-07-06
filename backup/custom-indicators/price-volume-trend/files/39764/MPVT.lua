-- Id: 10021
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23071

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
    indicator:name("Modified Volume Price Trend");
    indicator:description("Volume Price Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addDouble("Scale", "Scale", "", 1);


    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MVPT_color", "Color of MVPT", "Color of MVPT", core.rgb(255, 0, 0));
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
local Scale;
-- Streams block 
local AvgFour;
local MVPT;

local Raw;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;	
	Scale=instance.parameters.Scale;	

    local name = profile:id() .. "(" .. source:name()  .. ", " .. Scale .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		AvgFour= instance:addInternalStream(0, 0);
		Raw= instance:addInternalStream(0, 0);
		first = source:first();
        MVPT = instance:addStream("MVPT", core.Line, name, "MVPT", instance.parameters.MVPT_color, first);
		MVPT:setWidth(instance.parameters.width);
        MVPT:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
 

    AvgFour[period]=(source.open[period]+source.close[period]+source.high[period]+source.low[period])/4; 
	Raw[period] =   Raw[period-1]+ Scale*Calculation (period)  ; 
	
   
	if period < source:size()-1 then
	return;
	end   
	
	  local min1, max1;
		local min2, max2;
		min1=mathex.min(source.low, first, source:size()-1);
		max1=mathex.max(source.high,first, source:size()-1);
		min2,max2=mathex.minmax(Raw,first, source:size()-1);

	local i; 
	for i = first, source:size()-1, 1 do
     MVPT[i] = ((Raw[i] - min2)/ (max2-min2))*(max1-min1) +min1
	end
end

 

function Calculation (period)

 local rV=source.volume[period]/50000;
 return (rV*((AvgFour[period]-AvgFour[period-1])/ AvgFour[period-1]));
 
end