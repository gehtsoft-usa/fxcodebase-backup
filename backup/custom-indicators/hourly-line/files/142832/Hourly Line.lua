-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71347

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Hourly Line");
    indicator:description("Hourly Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
	indicator.parameters:addGroup("Caclulation");   
    indicator.parameters:addString("TF", "Time Frame", "", "H1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Color of Line", core.rgb(255, 0, 0));
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
local width, style,color;
local s1, e1, s2, e2;
local dayoffset;
local weekoffset;
local TF;
-- Routine
function Prepare(nameOnly) 
	width= instance.parameters.width;
	style= instance.parameters.style;
	color= instance.parameters.color;
	TF= instance.parameters.TF;
    source = instance.source;
    first = source:first();
	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle("H1", 0, 0, 0);
   

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end
	
	 instance:ownerDrawn(true); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 0 then
	return;
	end
	
	
   if(e1 - s1) > (e2 - s2) then
   return;
   end
   
   
    s, e = core.getcandle (TF, source:date(source:size()-1), dayoffset, weekoffset)
    x1, x, x = context:positionOfDate (s);
    x2, x, x = context:positionOfDate (e);	
	
	
        if not init then
            context:createPen (1, context:convertPenStyle (style), context:pixelsToPoints (width), color);
            init = true;
        end
 
 
        context:drawLine (1, x1, context:top(), x1, context:bottom());
        context:drawLine (1, x2, context:top(), x2, context:bottom());
end