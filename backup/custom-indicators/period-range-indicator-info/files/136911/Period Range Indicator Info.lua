-- More information about this indicator can be found at:
-- http://fxcodebase.com/ 

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
    indicator:name("Period Range Indicator Info");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

	indicator.parameters:addGroup("Calculation");
	
	
	indicator.parameters:addInteger("Period", "Number of Periods","" , 24);
	indicator.parameters:addDouble("Ratio", "Risk/Reward ","" , 1);
	indicator.parameters:addDouble("Position", "Position % ","" , 25);
	
 
	indicator.parameters:addBoolean("SignalMode", "Signal Mode", "Use by Strategies only", false);

	
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
   indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("color1", "Entry Long Line Color", "", core.rgb(0,255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Entry Short Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Stop Long Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color4", "Stop Short Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color5", "Limit Long Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color6", "Limit Short Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Period, Position, Ratio;
local first;
 
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local high, low;
local EntryLong, EntryShort, StopLong, StopShort, LimitLong, LimitShort;
local SignalMode ;
local source;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

    SignalMode=instance.parameters.SignalMode;
	
    Period=instance.parameters.Period;
	Position=instance.parameters.Position/100;
	Ratio=instance.parameters.Ratio;

    if   (nameOnly) then
        return;
    end
	
	source=instance.source;
	
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);
	
	
	if not SignalMode then
	
	
	EntryLong = instance:addInternalStream(0, 0);
	EntryShort = instance:addInternalStream(0, 0);
	
	StopLong = instance:addInternalStream(0, 0);
	StopShort = instance:addInternalStream(0, 0);
	
	LimitLong = instance:addInternalStream(0, 0);
	LimitShort = instance:addInternalStream(0, 0);
	
	else
	
	EntryLong = instance:addStream("EntryLong" , core.Line, " EntryLong"," EntryLong",instance.parameters.color1 , source:first());
    EntryLong:setWidth(instance.parameters.width1);
    EntryLong:setStyle(instance.parameters.style1);
	
	
	EntryShort = instance:addStream("EntryShort" , core.Line, " EntryShort"," EntryShort",instance.parameters.color2 , source:first());
    EntryShort:setStyle(core.LINE_NONE );
	EntryShort:setWidth(instance.parameters.width2);
    EntryShort:setStyle(instance.parameters.style2);
	
	StopLong = instance:addStream("StopLong" , core.Line, " StopLong"," StopLong",instance.parameters.color3 , source:first());
    StopLong:setStyle(core.LINE_NONE );
	StopLong:setWidth(instance.parameters.width3);
    StopLong:setStyle(instance.parameters.style3);
	
	StopShort = instance:addStream("StopShort" , core.Line, " StopShort"," StopShort",instance.parameters.color4 , source:first());
    StopShort:setStyle(core.LINE_NONE );
	StopShort:setWidth(instance.parameters.width4);
    StopShort:setStyle(instance.parameters.style4);
	
	LimitLong = instance:addStream("LimitLong" , core.Line, " LimitLong"," LimitLong",instance.parameters.color5 , source:first());
    LimitLong:setStyle(core.LINE_NONE );
	LimitLong:setWidth(instance.parameters.width5);
    LimitLong:setStyle(instance.parameters.style5);
		
	LimitShort = instance:addStream("LimitShort" , core.Line, " LimitShort"," LimitShort",instance.parameters.color6 , source:first());
    LimitShort:setStyle(core.LINE_NONE );
	LimitShort:setWidth(instance.parameters.width6);
    LimitShort:setStyle(instance.parameters.style6);
	
	end
	

    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
 
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

   if period < source:first() +Period then
   return;
   end
   
  local min,max=  mathex.minmax(source, period-Period+1, period);
  
  high[period]=max;
  low[period]=min;
  
 
 
EntryLong[period]=source.close[period-1]+((high[period-1]-low[period-1])*Position);
EntryShort[period]=source.close[period-1]-((high[period-1]-low[period-1])*Position);
StopLong[period]=EntryLong[period]-((high[period-1]-low[period-1])*Position); 
StopShort[period]= EntryShort[period]+((high[period-1]-low[period-1])*Position); 
LimitLong[period]=EntryLong[period]+(((high[period-1]-low[period-1])*Position)*Ratio) 
LimitShort[period]= EntryShort[period]-(((high[period-1]-low[period-1])*Position)*Ratio); 
 
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
			
	local Text1=  "Prior Period Range";
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   
   local Text1=  "Periods : ".. Period;
	 
   local i=2;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   
   local Text1=  "Range High : ".. high[period-1];
	 
   local i=3;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   
    local Text1=  "Range Low : ".. low[period-1];
   
   local i=4;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   
     local Text1=  "Range Close : ".. source.close[period-1];
   
   local i=5;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	

  
   local Text1=  "Long" 
   
   local i=6;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	



   local Text1= "Entry : " ..  EntryLong[period]; 
   
   local i=7;	 
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
 
 local Text1= "Stop : " ..  StopLong[period]; 
   
   local i=8;	 
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	

  local Text1= "Limit : " ..  LimitLong[period]; 
   
   local i=9;	 
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	


local Text1=  "Short" 
   
   local i=10;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	



   local Text1= "Entry : " ..  EntryShort[period]; 
   
   local i=11;	 
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
 
 local Text1= "Stop : " ..  StopShort[period]; 
   
   local i=12;	 
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	

  local Text1= "Limit : " ..  LimitShort[period]; 
   
   local i=13;	 
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	

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
 