-- Id: 12205
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60973

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
    indicator:name("Axis Label");
    indicator:description("Axis Label");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
   
    indicator.parameters:addGroup("Style");
	indicator.parameters:addString("Label", "Label Text", "Label Text","");
    indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Background", "Background Color", "Background Color", core.rgb(128, 128, 128));
	indicator.parameters:addBoolean("Show", "Show Line", "", false);
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
local Size;
-- Streams block
local Color;
local Background;
local Show;
local Label;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	  
    first = source:first();
	Label= instance.parameters.Label;
	Show= instance.parameters.Show;
	Color= instance.parameters.Color;
	Background= instance.parameters.Background;
	Size= instance.parameters.Size;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	 
	instance:ownerDrawn(true);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then           
			context:createFont (1, "Arial", Size, Size, 0);
			context:createPen (2, context:convertPenStyle (instance.parameters.style), instance.parameters.width, Color);
			context:createPen (3, context:convertPenStyle (instance.parameters.style), instance.parameters.width, Background);
			context:createSolidBrush (4, Background)
            init = true;
        end
		
	local  x1, y1, x2, y2;
	
	local text=Label .. string.format("%." ..  source:getPrecision() .. "f", source[source:size()-1]);	
	local width, height =context:measureText (1, text, context.RIGHT)
	x1= context:right ()-width;
	x2= context:right () ;
	local visible, y =context:pointOfPrice (source[source:size()-1]);
	
	    context:drawRectangle (3, 4, x1, y, x2, y+height,128);
		context:drawText (1, text, Color, -1, x1, y, x2, y+height, context.RIGHT);
   
    if Show then
	context:drawLine (2, context:left (), y, context:right (), y)
	end
	 
end		

