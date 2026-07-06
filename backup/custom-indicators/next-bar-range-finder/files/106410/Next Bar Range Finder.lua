-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63509

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Next Bar Range Finder");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Top", "Top Color", "", core.rgb(0, 255, 0));  
    indicator.parameters:addColor("Bottom", "Bottom Color", "", core.rgb(255, 0, 0));
	
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
 
local Top,Bottom, low, high; 

-- Routine
function Prepare(nameOnly)
  
	 
    Top=instance.parameters.Top;
	Bottom=instance.parameters.Bottom;   
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	low = instance:addStream("low", core.Line, name .. ".low", "low", Bottom, first+1, 1);
    high = instance:addStream("high", core.Line, name .. ".high", "high", Top, first+1,1);
	
	low:setWidth(instance.parameters.width);
    low:setStyle(instance.parameters.style);
	
	high:setWidth(instance.parameters.width);
    high:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  low[period+1]= ((source.high[period]+source.low[period]+source.close[period])/3)*2-source.high[period];
  high[period+1]= ((source.high[period]+source.low[period]+source.close[period])/3)*2-source.low[period]; 

end
  