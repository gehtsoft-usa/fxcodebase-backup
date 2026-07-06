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
	
	
	indicator.parameters:addBoolean("EndPoint", "End Point Set By Cursor", "", false);
	
	indicator.parameters:addInteger("Period", "Number of Periods","" , 24);
	indicator.parameters:addDouble("Ratio", "Risk/Reward ","" , 1);
	indicator.parameters:addDouble("Position", "Position % ","" , 25);
	

	
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
    indicator.parameters:addColor("Line_Color", "Line Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 local Period, Position, Ratio;
local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local high, low;
local EntryLong, EntryShort, StopLong, StopShort, LimitLong, LimitShort;
local EndPoint;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

    EndPoint=instance.parameters.EndPoint;
    Period=instance.parameters.Period;
	Position=instance.parameters.Position/100;
	Ratio=instance.parameters.Ratio;

    if   (nameOnly) then
        return;
    end
	
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);
	EntryLong = instance:addInternalStream(0, 0);
	EntryShort = instance:addInternalStream(0, 0);
	
	StopLong = instance:addInternalStream(0, 0);
	StopShort = instance:addInternalStream(0, 0);
	
	LimitLong = instance:addInternalStream(0, 0);
	LimitShort = instance:addInternalStream(0, 0);

    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Line_Color=instance.parameters.Line_Color;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
 
    instance:ownerDrawn(true);
	
	
	require("storagedb");
    db = storagedb.get_db(name);	
	

	    core.host:execute("addCommand", 1, "Select End Point");
		
		
		 core.host:execute("setTimer", 10, 1);
end

function ReleaseInstance()
    core.host:execute("killTimer", 10);
end

local pattern = "([^;]*);([^;]*)";
local EndPeriod;
function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("Date" , tostring(Date));  	
	end
	
	
	
	  if cookie == 10 and  EndPoint then

	   local Data;
   
			Data= db:get ("Date", 0);
			
			if Data ==0 then
			return;
			end
			
			
			EndPeriod = core.findDate (source, Data, false);

		   if EndPeriod < source:first() then
		   return;
		   end   
   end
   
	
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
	
	
	if EndPoint then
	period =EndPeriod;
	context:createPen(10, context.SOLID, 1,  Line_Color);
	
	 if period~= nil and period > 1 then
	 
	 x= context:positionOfBar(period);
	context:drawLine(10, x, context:top (), x, context:bottom ());
	end
	
    else	
	period=source:size()-1;
	end
	
	if period== nil then
	return;
	end
	
	
	if period <  source:first()+Period then
	return;
	end
	
			
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
 