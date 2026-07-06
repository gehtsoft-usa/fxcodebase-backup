-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=47357
-- Id: 9498

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
    indicator:name("Ulcer Index");
    indicator:description("Ulcer Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	 indicator.parameters:addBoolean("Inverse", "Inverse pair", "", false);	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UI_color", "Color of UI", "Color of UI", core.rgb(255, 0, 0));
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
local Source;
local Inverse;
-- Streams block
local UI = nil;
local PercentDrawdown;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Inverse = instance.parameters.Inverse;
    source = instance.source;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Source = instance:addInternalStream(0, 0);
        PercentDrawdown  = instance:addInternalStream(0, 0);
	 
        UI = instance:addStream("UI", core.Line, name, "UI", instance.parameters.UI_color, first+Period);
    UI:setPrecision(math.max(2, instance.source:getPrecision()));
		UI:setWidth(instance.parameters.width);
        UI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


	
	 local Max;
	 if Inverse then	
	 Source[period]= 1/source[period];
	 else
	 Source[period]= source[period];	 
     end	 
	 
	 
	if period < first   then
	return;
	end
	
	 Max= mathex.max(Source, period-Period+1, period);	
	  PercentDrawdown[period] =(((Source[period] - Max )/Max )* 100)^2;
	  
	if period < first +Period  then
	return;
	end
	  
	 local MA= mathex.avg(PercentDrawdown, period-Period+1, period);
	
        UI[period] = math.sqrt(MA);
    
end

