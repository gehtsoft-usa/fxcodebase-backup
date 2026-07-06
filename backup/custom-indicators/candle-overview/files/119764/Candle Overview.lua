-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66234

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
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
    indicator:name("Candle Overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
  
	
    indicator.parameters:addGroup("Calculation");	
 
   
	indicator.parameters:addString("X", "X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
	
		indicator.parameters:addString("Y", "X Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
   
 
	
	indicator.parameters:addGroup("Label Style"); 
	indicator.parameters:addInteger("Size", "Label Size", "", 12, 1 , 100);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
	
 
	
	
	
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
	
	
	 indicator.parameters:addGroup("Debugging Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
 
local X;
local Y ; 
local Label, Size;
 
local ShiftY; 
local ToTime; 
local Labels={"Open : ", "High : ","Low : ","Close : ", "Date : ", "Time : "};
LabelText={};
 

local Index, Date;

 local db; 
local pattern = "([^;]*);([^;]*)";

	
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	
     Index= nil;
	 Date= nil;
	
	 
	X=instance.parameters.X;  
	Y=instance.parameters.Y; 
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;    
	 for i= 1, 6 ,1 do
	LabelText[i]={};	
	LabelText[i][1]=Labels[i];
	LabelText[i][2]=nil;
	end
	
	
	
	source = instance.source;
    first = source:first();
	
	 
	  
	ToTime= instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
	 
	
	require("storagedb");
    db = storagedb.get_db(name);	
	
    core.host:execute("addCommand", 1, "Select Candle");	
	core.host:execute("addCommand", 2, "Reset Candle Selection");	
    core.host:execute ("setTimer", 10, 1);
	
	 instance:ownerDrawn(true);
end


  

function AsyncOperationFinished(cookie, success, message)
    
  
	
	if cookie == 1  then 	 
    local  level, date = string.match(message, pattern, 0);	
	db:put("Date", tostring(date));  
	end
	
	if cookie == 2 then 	
	db:put("Date", 0);  
	end
	
	if  cookie== 10 then
	
			Date= tonumber(db:get("Date", 0)); 
			Index= core.findDate (source, Date, false);
			
			if Index<= 0 or Date== 0 then
			Index=source:size()-1;
			Date=source:date(Index);
			end	
			
			
			
			
			LabelText[1][2]= win32.formatNumber(source.open[Index], false, source:getPrecision());
			LabelText[2][2]=win32.formatNumber(source.high[Index], false, source:getPrecision());
			LabelText[3][2]=win32.formatNumber(source.low[Index], false, source:getPrecision());
			LabelText[4][2]=win32.formatNumber(source.close[Index], false, source:getPrecision());
		 
				
			
			Table = core.dateToTable ( core.host:execute ("convertTime", core.TZ_TS, ToTime, source:date(Index))) ;
		    
		 
			LabelText[5][2]=  Table.month.." / ".. Table.day ;
			LabelText[6][2]=  Table.hour  .." / ".. Table.min; 
	 
    end
  
 
end
	
	
 
 
function Draw(stage, context)
   
 

   if stage ~= 2 then
        return ;
    end

    -- initialize GDI objects
    if not init then
	   
	    context:createPen (11, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.color) ;
	 
	 
		 context:createFont (13, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
					 

        init= true; 
	end
	
	
	
	if not (Date~= 0  and Date ~= nil) then
	return;
	end
	
	x, x1, x2 = context:positionOfDate (Date)
	context:drawLine (11, x, context:bottom() , x, context:top());	
 
	
	
	
	for i= 1, 6, 1 do
	
	      if LabelText[i][2]~= nil then
		  
		  
							 
							  
							  width, height = context:measureText (13, LabelText[i][1].. LabelText[i][2] , 0);
							  context:drawText (13,  LabelText[i][1].. LabelText[i][2]  , Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
						 
						 
		  
		  end
	end
 
	
	 
 
end
 

function Update(period,mode)


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
 