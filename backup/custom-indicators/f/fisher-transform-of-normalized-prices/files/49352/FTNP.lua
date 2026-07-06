-- Id: 8277
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=28097

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
    indicator:name("Fisher Transform of Normalized Prices");
    indicator:description("Fisher Transform of Normalized Prices");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Caclulation");	

    indicator.parameters:addInteger("Len", "Period", "Period", 10);

     indicator.parameters:addGroup("Style");	

    indicator.parameters:addColor("Fisher_color", "Color of Fisher", "Color of Fisher", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Trigger_color", "Color of Trigger", "Color of Trigger", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Len;

local first;
local source = nil;

-- Streams block
local Fisher = nil;
local Trigger = nil;
local Value1;
-- Routine
function Prepare(nameOnly)
    Len = instance.parameters.Len;
    source = instance.source;
    first = source:first()+Len;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Len) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Value1 = instance:addInternalStream(0, 0);
        Fisher = instance:addStream("Fisher", core.Line, name .. ".Fisher", "Fisher", instance.parameters.Fisher_color, first);
    Fisher:setPrecision(math.max(2, instance.source:getPrecision()));
		Fisher:setWidth(instance.parameters.width1);
        Fisher:setStyle(instance.parameters.style1);
        Trigger = instance:addStream("Trigger", core.Line, name .. ".Trigger", "Trigger", instance.parameters.Trigger_color, first);
    Trigger:setPrecision(math.max(2, instance.source:getPrecision()));
		Trigger:setWidth(instance.parameters.width2);
        Trigger:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first and source:hasData(period) then
	return;
	end
	
	 
	local MinL, MaxH= mathex.minmax(source, period-Len+1, period);
	Value1[period] = 0.33*2*((source[period] - MinL)/(MaxH - MinL) - 0.5) + 0.67*Value1[period-1];
    if Value1[period] > 0.99 then Value1[period] = 0.999; end
    if Value1[period] < -0.99 then Value1[period] = -0.999; end
 
	
        Fisher[period] = 0.5*math.log((1 + Value1[period])/(1 - Value1[period])) + 0.5*Fisher[period-1];
        Trigger[period] = Fisher[period-1];
		
 
    
end

