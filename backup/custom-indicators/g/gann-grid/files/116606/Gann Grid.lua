-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65474

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters

function Init()

    indicator:name("Gann Grid");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation")
	indicator.parameters:addDouble("Interval", "Interval in pips" ,"", 100);
 
	
	indicator.parameters:addGroup("Style");	  
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(128,128, 128));
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
local Interval;
 
-- Routine

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	
	
    source = instance.source;
    first = source:first();	
	
    Interval= instance.parameters.Interval;
 
 
	 
    instance:ownerDrawn(true);    
	
 
	 
end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)    

 
 
end

 


local init = false;

 function Draw(stage, context)
 
 
 
 
 
	
    if stage ~= 2 then
        return ;
    end

 

     
    if not init then 
		  context:createPen(1, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), instance.parameters.color); 
		 
		  init = true;
    end
		
	    
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
	 
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
	mid_y= top+(bottom-top)/2;
	mid_x= left+(right-left)/2;
    
     top_point = context:priceOfPoint (top);
     visible, Step =  context:pointOfPrice (top_point -Interval*source:pipSize());
   
   
      a, c=  math2d.lineEquation (0, 0, Step, Step);
 
	 
      for X=left, right, Step  do
	  x1, y1, x2, y2 = math2d.lineRectangleIntersection (context:left() , context:top(), context:right(), context:bottom(), X,bottom,X + Step, bottom-Step);	  
	  context:drawLine (1,x1, y1, x2, y2);

	  end
	 
 
 
   
	 for X=left, right, Step  do
     x1, y1, x2, y2 = math2d.lineRectangleIntersection (context:left() , context:top(), context:right(), context:bottom(),  X,top,X + Step, top+Step);
	 context:drawLine (1,x1, y1, x2, y2);
     end
end
 
 