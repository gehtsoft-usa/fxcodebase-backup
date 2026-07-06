-- Id: 14397

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62389

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume Trend");
    indicator:description("Volume Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	  indicator.parameters:addColor("Volume_Color", "Volume Color", "Color of Volume", core.rgb(0, 0, 255));
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
local Volume = nil;
local Regression=nil;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Regression = instance:addStream("Regression", core.Line, name, "Regression", instance.parameters.color, first);
    Regression:setPrecision(math.max(2, instance.source:getPrecision()));
		Regression:setWidth(instance.parameters.width);
        Regression:setStyle(instance.parameters.style);
		Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.Volume_Color, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    Volume[period]= source.volume[period];
    local i;
	local a, b,x;
	
	if period < Period then
	return;
	end
	
	if period==source:size()-1 then
	    a, b, dev, raff =mathex.regChannel  (source.volume, period-Period+1, period);	 
		for i=source:size()-1-Period+1, period, 1 do	 
		x = (i - (source:size()-1-Period+1 ) + 1);
		Regression[i]= a * x + b;
		end
	end
	
	if period > Period then
	Regression[period-Period]=nil;
	end
end

