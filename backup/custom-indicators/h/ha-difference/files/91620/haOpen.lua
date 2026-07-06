-- Id: 10722
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60133

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
    indicator:name("haOpen");
    indicator:description("haOpen");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("open_color", "Color of open", "Color of open", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("close_color", "Color of close", "Color of close", core.rgb(255, 0, 0));
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
local open = nil;
local close = nil;

-- Routine
function Prepare(nameOnly)  
    source = instance.source;
	 

    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

 
        open = instance:addStream("open", core.Line, name .. ".open", "open", instance.parameters.open_color, first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
		open:setWidth(instance.parameters.width1);
        open:setStyle(instance.parameters.style1);
        close = instance:addStream("close", core.Line, name .. ".close", "close", instance.parameters.close_color, first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
		close:setWidth(instance.parameters.width2);
        close:setStyle(instance.parameters.style2);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )

    
    if period < first  then
	return;
	end
        open[period] = ( open[period-1] + close[period-1] ) / 2;
        close[period] =  ( source.open[period] + source.high[period] + source.low[period] + source.close[period] ) / 4 ;
     
end

