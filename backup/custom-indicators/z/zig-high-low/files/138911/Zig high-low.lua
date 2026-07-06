-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70583

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
    indicator:name("Zig high-low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	indicator.parameters:addBoolean("Confirmed", "Confirmed", "", false);
	indicator.parameters:addInteger("CutOffNumber", "CutOff Number", "",2);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
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
local Label;
local Size;
local ShiftY;
local ZigZag;
local Confirmed;
local LD,HD=nil,nil;
local LastHigh;
local LastLow;
local Last;
local CutOffNumber;
local NH,NL;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


	CutOffNumber=instance.parameters.CutOffNumber;
    Confirmed=instance.parameters.Confirmed;
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
 
    instance:ownerDrawn(true);
	
	
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);	
	first=ZigZag.DATA:first() ;
	
   LastHigh=0;
   LastLow=0;
   Last=nil;
   LD,HD=nil,nil
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 


function Update(period)   


    if period < source:size()-1  
	then
	return;
	end
	
	
	if Last~=source:serial(period) then
	Last=source:serial(period);	
	
	ZigZag:update(core.UpdateAll);
	end



    LD,HD= FindLast(period);
  
end


function FindLast(period)

 ReturnLow=0;
 ReturnHigh=0;
		
  LastHigh=0;
  LastLow=0;
  
  NH=0;
  NL=0;
  
		for i = period-1, first, -1 do 
		
		    if ZigZag.DATA:hasData(i)  then


 
							
								if ReturnHigh==0
								and  ((ZigZag.DATA[i] > ZigZag.DATA[i+1] and ZigZag.DATA[i+1]~=0 )or not Confirmed)
								and  ZigZag.DATA[i] > ZigZag.DATA[i-1]
								then
								
								     if LastHigh~= 0 then
									 
									   
                                   
										    if ZigZag.DATA[LastHigh]< ZigZag.DATA[i] then
											LastHigh=i;
											NH=NH+1;
											elseif ZigZag.DATA[LastLow]> ZigZag.DATA[i]  then
											ReturnHigh= LastHigh;	
											end
																					
											if NH == CutOffNumber then
											ReturnHigh= LastHigh;	
											end
									 

									 else									 
								     LastHigh=i;
									 NH=NH+1;
                                     end 									 
								end
							
							
 	
							
							
					 
						    	if ReturnLow==0 
								and  ((ZigZag.DATA[i] < ZigZag.DATA[i+1] and ZigZag.DATA[i+1]~=0 ) or not Confirmed)
								and   ZigZag.DATA[i] < ZigZag.DATA[i-1]
								then
								  
								  
								     if LastLow~= 0 then
									 
							
												
											 
														if ZigZag.DATA[LastLow]> ZigZag.DATA[i]  then
														LastLow=i;
														NL=NL+1;
														elseif ZigZag.DATA[LastLow]< ZigZag.DATA[i]  then
														ReturnLow= LastLow;	
														end
														
														
														
														if  NL == CutOffNumber then
														ReturnLow= LastLow;	
														end
										 

									  else									 
									  LastLow=i;
								      NL=NL+1;
									  end 			
								  
								end
							
						 
							
							
				 
					

            end			
			
			if ReturnLow~=0 and ReturnHigh~=0 then
			break;
			end

		end


   return ReturnLow,ReturnHigh;

end



 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2
	  or LD==nil
	  or HD==nil
	  or LD==0
	  or HD==0
	  then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		   context:createPen (2, context.DOT, 1, Label)
            init = true;
        end
	
	
	-- LD,HD
			
	local Text1=  "High : " ..   win32.formatNumber(source.high[HD], false, source:getPrecision());
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   visible, y = context:pointOfPrice (source.high[HD]);
   	context:drawLine (2,  context:left(), y,  context:right(), y);
   
   	local Text1=  "Low : " ..   win32.formatNumber(source.low[LD], false, source:getPrecision());
	 
   local i=2;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   
     visible, y = context:pointOfPrice (source.low[LD]);
   	context:drawLine (2,  context:left(), y,  context:right(), y);
   

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
 