-- Id: 3210
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3499

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
    indicator:name("Wildhog");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Frame", "Period", "", 8);
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("color", "Color of S1", "Color of S1", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Oversold Overbought Levels");
	 indicator.parameters:addInteger("OB", "Overbought Level", "", 60);
	  indicator.parameters:addInteger("OS", "Oversold Level", "", 40);
	  
	  indicator.parameters:addGroup("Oversold Overbought Levels Style");
	 indicator.parameters:addColor("os_color", "Color of S1", "Color of S1", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("os_width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("os_style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("os_style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local OB,OS;
local os_width,os_style, os_color;

local first;
local source = nil;

-- Streams block
local Wildhog = nil;

-- Routine
function Prepare(nameOnly)
    OB=instance.parameters.OB;
	OS=instance.parameters.OS;
	os_width=instance.parameters.os_width;
	os_style=instance.parameters.os_style;
    os_color=instance.parameters.os_color;
    Frame = instance.parameters.Frame;
    source = instance.source;
    first = source:first()+Frame;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Wildhog = instance:addStream("Wildhog", core.Line, name, "Wildhog", instance.parameters.color, first);
    Wildhog:setPrecision(math.max(2, instance.source:getPrecision()));
	Wildhog:setWidth(instance.parameters.width);
    Wildhog:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then	
	
		local min, max;
		
        min,max	= mathex.minmax(source, period-Frame, period); 	

        Wildhog[period] = ((((source.close[period]-min)/(max-min))*100)/3 )+ ( Wildhog[period-1] / 3)*2;
	    
		if period== source:size()-1 then
    	core.host:execute ("drawLine", 1,  source:date(first), OB, source:date(period), OB, os_color, os_style, os_width);	
        core.host:execute ("drawLine", 2, source:date(first), OS, source:date(period), OS, os_color, os_style, os_width);	
	    end
	
    end
end

