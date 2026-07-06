-- Id: 14955
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62723

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Vertical Line");
    indicator:description("Vertical Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addString("Periods", "Periods", "Periods", "1,5,7,12");
	
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
local Periods;

local first;
local source = nil;
local width, style,color;
local ArrPeriods={};
local CountPeriods;
-- Routine
function Prepare(nameOnly)
    Periods = instance.parameters.Periods;
	width= instance.parameters.width;
	style= instance.parameters.style;
	color= instance.parameters.color;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Periods .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end

    ArrPeriods, CountPeriods=core.parseCsv(Periods);
	
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
	
	
    if not init then
        context:createPen (1, context:convertPenStyle (style), context:pixelsToPoints (width), color);
        init = true;
    end

    local left, top, right, bottom=context:left(), context:top(), context:right(), context:bottom();
 
    context:setClipRectangle(left, top, right, bottom);

    local i;
    local x, x1, x2;
    for i=0, CountPeriods-1, 1 do
        x, x1, x2 = context:positionOfBar (source:size()-1-ArrPeriods[i]);
        context:drawLine (1, x, top, x, bottom);
    end

    context:resetClipRectangle();
end