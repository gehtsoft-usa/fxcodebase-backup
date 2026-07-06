-- Id: 18533
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64839

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
    indicator:name("Wick Length Labels indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


    indicator.parameters:addGroup("Caclulation");
    indicator.parameters:addInteger("Min", "Filter Wick Length", "", 20);
   indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 5);
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
 
local font;
local Label;
local Size;
local Min;
-- Routine
function Prepare(nameOnly)
    Min=instance.parameters.Min;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
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
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
	
	local First=math.max(first,context:firstBar () );
	local Last=math.min(source:size()-1,context:lastBar () );
	
	
	for i= First, Last, 1 do
	
	Top= (source.high[i]-math.max(source.close[i],source.open[i]))/source:pipSize();
	Bottom= (math.min(source.close[i],source.open[i])-source.low[i])/source:pipSize();
	
	x, x1, x2 = context:positionOfBar (i);
	
	if Top >= Min then
	
	visible, y = context:pointOfPrice (source.high[i]);
	Text= win32.formatNumber(Top, false, 0);
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  x- width/2,  y-height ,x+width/2,y, 0 );	
	end
	
	if Bottom >= Min then
	visible, y = context:pointOfPrice (source.low[i]);
	Text= win32.formatNumber(Bottom, false, 0);
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  x-width/2 ,  y ,x+width/2,y+height, 0 );	
	
	
	end
	
	end
	
  

   

end		
 
 