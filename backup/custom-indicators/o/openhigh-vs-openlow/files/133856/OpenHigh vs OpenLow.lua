-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63018

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("OpenHigh vs OpenLow  ");
    indicator:description("OpenHigh vs OpenLow  ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 
	indicator.parameters:addGroup("Style");	
	
 
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);
    indicator.parameters:addColor("Color", "Label Color", "Color", core.COLOR_LABEL );
	indicator.parameters:addBoolean("Both", "Show Both", "", true);
 
	
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Top, Bottom;
local Size;
local Color;
local Both;
 
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	Both=instance.parameters.Both;
	 
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    Top = instance:addInternalStream(0, 0);
	Bottom = instance:addInternalStream(0, 0);
	
	instance:ownerDrawn(true);
end



local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	
	      if not init then
		   
			
			 
		  
            init = true;
        end
	
	
	 context:createFont(1, "Arial", Size, Size, context.NORMAL);
				  
	
	 
    local first = math.max(source:first(), context:firstBar ());
    local last = math.min (context:lastBar (), source:size()-1);
	local Number;	
    
 
	
       
			    for i= first, last, 1 do	 
			    x0, x1, x2 = context:positionOfBar (i);
				
				
				if source.close[i] > source.open[i] or Both then
				visible, y =context:pointOfPrice (source.high[i]);
				Number=tostring(Top[i]);
				width, height = context:measureText (1,  Number , 0)	
				 context:drawText(1,  Number , Color, -1, x0-width/2, y -height  ,x0+width/2, y, 0);
				end
				
				if source.close[i] < source.open[i]  or Both then
				Number=tostring(Bottom[i]);
				visible, y =context:pointOfPrice (source.low[i]);
				width, height = context:measureText (1,  Number , 0)	
				 context:drawText(1,  Number , Color, -1, x0-width/2, y    ,x0+width/2, y +height, 0);
				 
				
				end
				
				
				
				
				
				end

end


function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     
    if period <=first or not source:hasData(period) then
	return;
	end
    
	local Num;
 
	
       
		Num =(source.high[period]-source.open[period])/source:pipSize(); 
        Top[period]= round(Num, 1)      	
		 
		Num=(source.open[period]-source.low[period])/source:pipSize(); 
        Bottom[period] =round(Num, 1)      
		 
		
		 
end

