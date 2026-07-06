
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63487

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
    indicator:name("Bid Ask Median");
    indicator:description("Bid Ask Median."); 
    indicator:requiredSource(core.Tick);
	indicator:type(core.Indicator);
	 

     indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
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
local clr, style, width;
local bid, ask;
local Out;
-- Routine
function Prepare(nameOnly)
    clr = instance.parameters.clr;
	style = instance.parameters.style;
	width = instance.parameters.width;
    source = instance.source;
    first = source:first();
	
	
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 if source:isBid() then
     bid = source;
     ask = core.host:execute("getAskPrice");
    else
     ask = source;
     bid = core.host:execute("getBidPrice");
    end
	 
	Out = instance:addStream("BAM", core.Line, name, "BAM", instance.parameters.color, source:first());
   Out:setWidth(instance.parameters.width );
   Out:setStyle(instance.parameters.style );
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
	
 if period <  source:first() then
 return;
 end
	 
	Out[period]= ask [period] +(bid[period] -ask [period])/2;
	 
end

