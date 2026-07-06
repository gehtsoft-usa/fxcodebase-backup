-- More information about this indicator can be found at:
-- http://fxcodebase.com 

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
    indicator:name(" High Low Range Average Readout");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	
	indicator.parameters:addBoolean("Shift", "Shift by one period", "", false);
		indicator.parameters:addBoolean("Combine", "Combine", "", false);

	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("High", "High Label Color", "", core.rgb(0, 255, 0)); 
   indicator.parameters:addColor("Low", "Low Label Color", "", core.rgb(255, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
--local Label;
local Size;
local ShiftY;
local Period, Shift,Combine;
local high, low,High, Low;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	
	Period=instance.parameters.Period;
	Shift=instance.parameters.Shift;
	Combine=instance.parameters.Combine;
	
	ShiftY=instance.parameters.ShiftY;
   -- Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first()+Period;
 
    instance:ownerDrawn(true);
	
	high= instance:addInternalStream(0, 0);
	 low= instance:addInternalStream(0, 0);
	 
	 High= instance:addInternalStream(0, 0);
	 Low= instance:addInternalStream(0, 0);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   
  
  
  
	high[period]= source.high[period]-source.open[period];
	low[period]= source.open[period]-source.low[period];
	
	
	if period <  first
	then
	return;
	end
	
	 High[period]= mathex.avg(high,period-Period+1, period);
	 Low[period]= mathex.avg(low,period-Period+1, period);
	
  
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
	
	
	period=source:size()-1;
	
	if Shift then
	period = period-1;
	end
			
 
 
 
    if Combine then
	
	       	local Value1= "Combine: " .. win32.formatNumber((High[period]-Low[period])/source:pipSize(), false, source:getPrecision());
 
	   
	   if (High[period]-Low[period])> 0 then
	   width, height = context:measureText (1, Value1, 0);
	   context:drawText (1,  Value1, instance.parameters.High, -1,  iX(context,width,0,1) ,  iY(context,height,1,0) ,iX(context,width,0,2),iY(context,height,1,1), 0 );	
	   else
	    width, height = context:measureText (1, Value1, 0);
	   context:drawText (1,  Value1, instance.parameters.Low, -1,  iX(context,width,0,1) ,  iY(context,height,1,0) ,iX(context,width,0,2),iY(context,height,1,1), 0 );	
	   end
	   
	
	
	else
	
	
	
	local Value1= "High: " .. win32.formatNumber(High[period]/source:pipSize(), false, source:getPrecision());
	local Value2= "Low: " .. win32.formatNumber(Low[period]/source:pipSize(), false, source:getPrecision()); 
	
   
   if High[period]> Low[period] then   
   l_i=2;
   h_i=1;
   else
   l_i=1;
   h_i=2;
   end
   
   width, height = context:measureText (1, Value1, 0);
   context:drawText (1,  Value1, instance.parameters.High, -1,  iX(context,width,0,1) ,  iY(context,height,h_i,0) ,iX(context,width,0,2),iY(context,height,h_i,1), 0 );	
   
  
   width, height = context:measureText (1, Value2, 0);
   context:drawText (1,  Value2, instance.parameters.Low, -1,  iX(context,width,0,1) ,  iY(context,height,l_i,0) ,iX(context,width,0,2),iY(context,height,l_i,1), 0 );	
 
 
   end
end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
 