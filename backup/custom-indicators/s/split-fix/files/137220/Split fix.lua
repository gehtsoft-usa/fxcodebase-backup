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
    indicator:name("Split fix");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("FixData", "Fix The Data", "", true);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 5);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down color", "", core.COLOR_DOWNCANDLE );
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 local pattern = "([^;]*);([^;]*)";
local Up,Down ;
local first;
local source = nil;
local GlobalData;
local FixData,Multiplier; 
local open, high, low, close;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 


    Up = instance.parameters.Up;
    Down= instance.parameters.Down; 
   
    FixData = instance.parameters.FixData;
    Multiplier= instance.parameters.Multiplier;
	
    GlobalData=nil;

	source = instance.source; 
	first=source:first();
	
	require("storagedb");
    db = storagedb.get_db(name);	

    	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	
	core.host:execute("addCommand", 1, "Select End Point");
	core.host:execute("setTimer", 10, 1);
	
end

function ReleaseInstance()
    core.host:execute("killTimer", 10);
end
 
 

-- Indicator calculation routine
function Update(period)
	 
	
	if period < first then
	return;
	end
	
	if period == first and FixData then
		GlobalData= tonumber(db:get ("Date", 0));
    end
	
	
    local Ratio=1;
	
   
   
   if FixData then
	
	if GlobalData ~=nil  then 
			EndPeriod = core.findDate (source, GlobalData, false);
		
		     if period <= EndPeriod then
			 Ratio=Multiplier;
			 end
			  
		
		end
	end
	
	open[period] = source.open[period]/Ratio;
	close[period] = source.close[period]/Ratio;
	high[period] = source.high[period]/Ratio;
	low[period] = source.low[period]/Ratio;
	
	
	if close[period]> open[period] then
	open:setColor(period, Up);
    else
	open:setColor(period, Down);
	end

		 
		 
   
		
 end


function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("Date" , tostring(Date));  
    end
   
   if cookie == 10   then
 
   
			GlobalData= tonumber(db:get ("Date", 0));
			
	instance:updateFrom(0);	        
    return core.ASYNC_REDRAW ;
			
			
   end
		   
 
	
end	
