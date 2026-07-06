-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70321

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
    indicator:name("Vertical Lines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation");
	
	
	indicator.parameters:addBoolean("EndPoint", "End Point Set By Cursor", "Last candle will be used if not used", false);
	
	indicator.parameters:addInteger("Period", "Shift from End Point","" , 0);
 
 
	 indicator.parameters:addGroup( " Line Shift");
	 
 
   for i=1, 10, 1 do
   AddShift(i, i) 
   end 
	 
   
   indicator.parameters:addGroup( " Line Style");
   for i=1, 10, 1 do
   AddStyle(i) 
   end
 
end

function AddShift(id, line_shift)

indicator.parameters:addInteger("Shift"..id, id..". Line Shift", "",line_shift );

end 
function AddStyle(id) 
	indicator.parameters:addGroup(id.." Line");
	
	indicator.parameters:addBoolean("Use"..id, "Use this line", "", false);
   indicator.parameters:addColor("Label"..id, "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size"..id, "Font Size", "", 10);
   
    indicator.parameters:addColor("Color"..id, "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..id, core.FLAG_LINE_STYLE);
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 local Period, EndPoint;
local first;
local source = nil;

local Use={};
local Label={};
local Size={};
local Color={}; 
local Width={}; 
local Style={}; 
local Shift={};
 local pattern = "([^;]*);([^;]*)";
local EndPeriod;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

    EndPoint=instance.parameters.EndPoint;
    Period=instance.parameters.Period;
	 

    if   (nameOnly) then
        return;
    end
    
	
	for i=1, 10, 1 do 
	
		 Use[i]=instance.parameters:getBoolean("Use" .. i);
		 Label[i]=instance.parameters:getColor("Label" .. i);
		 Size[i]=instance.parameters:getInteger("Size" .. i);
		 Color[i]=instance.parameters:getColor("Color" .. i);
		 Width[i]=instance.parameters:getInteger("Width" .. i);
		 Style[i]=instance.parameters:getInteger("Style" .. i);
		 Shift[i]=instance.parameters:getInteger("Shift" .. i);
	end
	
	 
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


function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("Date" , tostring(Date));  	
	elseif cookie == 10 and  EndPoint then

	   local Data;
   
			Data= db:get ("Date", 0);
			
			if Data ==0 then
			return;
			end
			
			
			EndPeriod = core.findDate (source, Data, false);

		   
   end
   
	
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
         
            init = true;
			
			
				for i= 1, 10, 1 do
				context:createPen (i, context:convertPenStyle (Style[i]), context:pointsToPixels (Width[i]), Color[i])
				  context:createFont (10+i, "Arial", context:pointsToPixels (Size[i]), context:pointsToPixels (Size[i]), 0);
				end
			
        end
		
	 
    local Start;
	if EndPoint then
	
	         if   (  EndPeriod== nil ) then
			 return;
			 end
 
 
	    Start=EndPeriod+Period;
	else
		Start=source:size()-1+Period;
	end
	
    for i= 1, 10, 1 do
	
			if Use[i] then
			x, x1, x2 = context:positionOfBar (Start+Shift[i])
			context:drawLine (i, x, context:top (), x, context:bottom ());
			
			width, height = context:measureText (10+i,i.."." , 0);
			context:drawText (10+i, tostring(i.."."), Label[i], -1, x, context:bottom ()-height, x+width , context:bottom (), 0)
			end
	end
	
 

end		
 
  