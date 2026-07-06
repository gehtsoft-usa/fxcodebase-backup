-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27869
-- Id: 8187

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Heiken Ashi Real");
    indicator:description("Heiken Ashi Real");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Open_color", "Color of Open", "Color of Open", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Close_color", "Color of Close", "Color of Close", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;

-- Streams block 
local Open, Close;
-- Routine
function Prepare(nameOnly)
     
    source = instance.source;
    first = source:first()+1;
	 

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Open = instance:addStream("Open", core.Line, name .. ".Open", "Open", instance.parameters.Open_color, first);
		Open:setWidth(instance.parameters.width1);
        Open:setStyle(instance.parameters.style1);
        Close = instance:addStream("Close", core.Line, name .. ".Close", "Close", instance.parameters.Close_color, first);
		Close:setWidth(instance.parameters.width2);
        Close:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	
	  local haOpen=(Open[period-1]+Close[period-1])/2;
      local haClose=(source.open[period]+source.high[period]+source.low[period]+source.close[period])/4;
  
	
        Open[period] = haOpen;
        Close[period] = haClose;
   
end

