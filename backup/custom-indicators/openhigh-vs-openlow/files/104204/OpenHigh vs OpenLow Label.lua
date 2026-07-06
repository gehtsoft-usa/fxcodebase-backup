
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63018

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("OpenHigh vs OpenLow ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show Label", "Show Label", false);
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 8);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Show;
local font;
local Label;
local Size;

-- Routine
function Prepare(nameOnly)
 
    Label=instance.parameters.Label;
	Show=instance.parameters.Show;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
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
 
	if stage~= 2 then
	return;
	end
	
        if not init then
           context:createFont (1, "Tahoma", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
			
	
   
  
   local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1); 
       
			    for i= first, last, 1 do	 
				 X0, X1, X2 = context:positionOfBar (i); 
				 
				  OH = (source.high[i]-source.open[i])/source:pipSize();
                  OL = (source.open[i]-source.low[i])/source:pipSize();
				  OH= win32.formatNumber(OH, false, 1);
				  OL= win32.formatNumber(OL, false, 1);
		
				     if Show then
				 	 Text1=  "HO:" ..  OH;	 
					 else
					 Text1=OH;
					 end
					 
                     width1, height1 = context:measureText (1, Text1, 0);
					 visible, y1 = context:pointOfPrice (source.high[i]);
                     context:drawText (1,  Text1, Label, -1,  X0-width1/2 ,  y1-height1 ,X0+width1/2,y1, 0 );
					 
					 if Show then
					 Text2=  "OL:" ..  OL;	
                     else
					 Text2=OL;
					 end					  
                     width2, height2 = context:measureText (1, Text2, 0);
					 visible, y2 = context:pointOfPrice (source.low[i]);
                     context:drawText (1,  Text2, Label, -1,  X0-width2/2 ,  y2 ,X0+width2/2,y2+height2, 0 );
				end
  
end		
 
