 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42662

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
function Init()
    indicator:name("Difference");
    indicator:description("Difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
 
	 indicator.parameters:addBoolean("Absolute", "Absolute", "Absolute" ,  true);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addGroup("Vertical Line Style");
	 indicator.parameters:addColor("Color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil;
 
-- Streams block
local AV = nil;
local Absolute;
local pattern = "([^;]*);([^;]*)";
local db; 
local Flag;
local Data;
local EndPeriod;
local Last;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	 
	Absolute=instance.parameters.Absolute;
    first = source:first() ;

    local name = profile:id() .. "(" .. source:name()  .. ", " .. (not Absolute and "Relative" or "Absolute")   .. ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
	Color=instance.parameters.Color;
	Width=instance.parameters.Width;
	Style=instance.parameters.Style;
	
	Flag= false;
	Data=nil;
	EndPeriod=nil;
	
	
        AV = instance:addStream("AV", core.Line, name, "Difference", instance.parameters.color, first);
    AV:setPrecision(math.max(2, instance.source:getPrecision()));
		AV:setWidth(instance.parameters.width);
        AV:setStyle(instance.parameters.style);
		AV:addLevel(0);
   
	
	    core.host:execute("addCommand", 1, "Select End Point");
		
		
		
		 
	require("storagedb");
    db = storagedb.get_db(name);	
	
	instance:ownerDrawn(true);
	
	
	 core.host:execute("setTimer", 10, 1);
end

function ReleaseInstance()
    core.host:execute("killTimer", 10);
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or Data== nil then
	return;
	end
	

	
	EndPeriod = core.findDate (source, Data, false);
		
	for i= first, source:size()-1 ,1 do	
	    if Absolute then
		 AV[i] = math.abs(source[i]-source[EndPeriod]);
		else
        AV[i] = source[i]-source[EndPeriod];
		end
    end
end

function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("Date" , tostring(Date));  	
	
	elseif cookie == 10   then
 
			Data= db:get ("Date", 0); 
			
   end
   
   
     return core.ASYNC_REDRAW ;
   
	
end	



local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 or EndPeriod == nil then
	  return;
	  end
	
        if not init then
         
            init = true;
			
			
				 
				context:createPen (1, context:convertPenStyle (Style ), context:pointsToPixels (Width ), Color )
			 
			
        end
		
  
			x, x1, x2 = context:positionOfBar (EndPeriod)
	        context:drawLine (1, x, context:top (), x, context:bottom ());
		 
 

end		
 
  
