-- Id: 15603
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63217

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
    indicator:name("Median Average Adaptive Filter");
    indicator:description("Median Average Adaptive Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Threshold", "Threshold", "Threshold", 0.002);
	indicator.parameters:addInteger("Length", "Length", "Length", 39);
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Filter_color", "Color of Filter", "Color of Filter", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Threshold;
local Length;
local first;
local source = nil;
local Smooth;
-- Streams block
local Filter = nil;
local Value2;
-- Routine
function Prepare(nameOnly)
    Threshold = instance.parameters.Threshold;
	Length = instance.parameters.Length;
    source = instance.source;
    first = source:first()+3;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Threshold) .. ", " .. tostring(Length) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Smooth= instance:addInternalStream(first, 0);
		Value2=  instance:addInternalStream(first, 0);
        Filter = instance:addStream("Filter", core.Line, name, "Filter", instance.parameters.Filter_color, first + Length);
		Filter:setWidth(instance.parameters.width);
        Filter:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period<  first or not  source:hasData(period) then
	return;
	end
	
	Smooth[period]=(source[period] + 2*source[period-1] + 2*source[period-2] + source[period-3])/6;
	
	
	if period < first + Length then
	return;
	end
	
	local Value3 = 0.2;
	local iLength=Length;
	local Value1;
	while ( Value3 > Threshold and iLength >0   ) do
	local alpha = 2 / (iLength + 1);
	
	Value1 = mathex.median_s (Smooth, period-iLength, period);  
    Value2[period] = alpha*Smooth[period] + (1 - alpha)*Value2[period-1];	
	
	if Value1 ~= 0 then 
	Value3 = math.abs(Value1 - Value2[period]) / Value1;
	end
	
    iLength = iLength - 2;
	end
	
	
	if iLength < 3 then
	iLength = 3;
	end
	
     local alpha = 2 / (iLength + 1);	
     Filter[period] =  alpha*Smooth[period] + (1 - alpha)*Filter[period-1];
    
end


