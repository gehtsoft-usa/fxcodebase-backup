-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1052

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
    indicator:name("Double exponential moving average");
    indicator:description("Double exponential moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TF", "Period", "Period", 50,2,2000);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DC", "Color of DEMA", "Color of DEMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

-- Streams block
local DEMA = nil;
local AVG,AVGofAVG;
local DC=nil;

-- Routine
 function Prepare(nameOnly) 
    Frame = instance.parameters.TF;
	DC = instance.parameters.DC;
    source = instance.source;
    
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	AVG = core.indicators:create("EMA", source, Frame);
	AVGofAVG = core.indicators:create("EMA", AVG.DATA, Frame);
	first = AVGofAVG.DATA:first();

   
	
    DEMA = instance:addStream("DEMA", core.Line, name, "DEMA", DC, first);
	DEMA:setWidth(instance.parameters.width);
    DEMA:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
 
	
	   AVG:update(mode);	   
	   AVGofAVG:update(mode);
	   if period < first then
	   return;
	   end
	   
	   DEMA[period] = (2*AVG.DATA[period])-AVGofAVG.DATA[period];
	 
end

