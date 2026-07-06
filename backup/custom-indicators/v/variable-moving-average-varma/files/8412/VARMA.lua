-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3521

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

function Init()
    indicator:name("Variable Moving Average ");
    indicator:description("VARMA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Frame", "Period", "", 9, 2, 2000);
	indicator.parameters:addInteger("Smoothing", "Smoothing", "", 2, 1, 200);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of VMA Line", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Smoothing;
local CMO;

local first;
local source = nil;

-- Streams block
local VMA = nil;
local SC;

-- Routine
function Prepare(nameOnly)
    Smoothing = instance.parameters.Smoothing;
    Frame = instance.parameters.Frame;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", ".. Smoothing.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   	
	CMO = core.indicators:create("CMO", source, Frame);
	 first = CMO.DATA:first()+1;

	 SC =2/(Smoothing+1);
	  
    VMA = instance:addStream("VMA", core.Line, name, "VMA", instance.parameters.color, first);
	VMA:setWidth(instance.parameters.width);
    VMA:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	
	    CMO:update(mode);
			
			
		local AbsCMO = math.abs(CMO.DATA[period])/ 100;
		
		if period >first +Smoothing+2 then
	
		VMA[period] = (SC*AbsCMO*source[period])+(1-(SC*AbsCMO))*VMA[period-1]; 
		else
		VMA[period]= source[period];
		end
		
		
    end
end

