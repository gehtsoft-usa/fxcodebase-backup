-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=39716
-- Id: 9883

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
    indicator:name("Period Range");
    indicator:description("Average Period Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 
 
     indicator.parameters:addInteger("Period", "Period", "Period", 14, 1, 2000);
    indicator.parameters:addBoolean("Last" , "Use Last Period", "", true);	
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(  255, 0, 0));
	indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(  0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
 
local first;
local source;
local Last;
-- Streams block
local Top, Bottom,Central;
 
 
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Last = instance.parameters.Last;
    source = instance.source;	  
    first = source:first()+Period+1;

    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Top = instance:addStream("TOP", core.Line, name, "Top", instance.parameters.Top_color, first);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
		Bottom = instance:addStream("BOTTOM", core.Line, name, "Bottom", instance.parameters.Bottom_color, first);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setWidth(instance.parameters.width);
        Bottom:setStyle(instance.parameters.style);
		
		Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.Central_color, first);
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		Central:setWidth(instance.parameters.width);
        Central:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	local Shift;  
	  
  if Last then
  Shift = 0;
  else
  Shift=-1;
  end
  
 min, max= mathex.minmax(source, period-Period+1+Shift, period+Shift );		
 
 Top[period]=0;
 Bottom[period]=100;
 if  max == min then
 Central[period]= math.huge;
 else
 Central[period]= ((source.close[period]-min) /((max-min)/100) );
 end
     
end
 