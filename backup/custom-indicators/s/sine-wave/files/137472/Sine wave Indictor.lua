 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70412

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("Sine wave");
    indicator:description("Sine wave");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
     indicator.parameters:addInteger("Extension", "Extension", "Extension", 100);
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addGroup("Vertical Line Style");
	 indicator.parameters:addColor("Start", "Start Line Color", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("End", "End Line Color", "", core.rgb(255, 0, 0));
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
local StartDate, EndDate;
local StartLevel, EndLevel;
 local StartPeriod, EndPeriod;
local pattern = "([^;]*);([^;]*)";
local db; 
local Extension;
local Line;
-- Routine

 

function Prepare(nameOnly)
    
    source = instance.source;
	 
 
    first = source:first() ;

    local name = profile:id() .. "(" .. source:name()  ..  ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
	Start=instance.parameters.Start;
	End=instance.parameters.End;
	
	Width=instance.parameters.Width;
	Style=instance.parameters.Style;
	
	Extension=instance.parameters.Extension;
	
	EndDate=nil;
	StartData=nil;
	
	StartPeriod, EndPeriod=nil,nil;
	
	
        Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first,Extension);
       Line:setPrecision(math.max(2, instance.source:getPrecision()));
		Line:setWidth(instance.parameters.width);
        Line:setStyle(instance.parameters.style);
		Line:addLevel(0);
   
	
	    core.host:execute("addCommand", 1, "Start Point");
 		core.host:execute("addCommand", 2, "End Point");
		
		
		 
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
    if period < source:size()-1 then
	return;
	end
	

    if StartDate~= nil then
	StartPeriod = core.findDate (source, StartDate, false);
	end
	if EndDate~= nil then
	EndPeriod = core.findDate (source, EndDate, false);
	end
		
		
    if EndDate== nil or StartPeriod== nil or period < StartPeriod then 
	return;
	end
	
	local Period=(EndPeriod-StartPeriod)/2;
	local Delta=(EndLevel-StartLevel)/2;
	for i= StartPeriod-1, source:size()-1+Extension ,1 do	
	 
        Line[i] =StartLevel+ (Delta/Period)*(i-StartPeriod) +Delta* math.sin(math.pi * ((i-StartPeriod)/Period) ) ;
		
    end
end

function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("StartDate" , tostring(Date));  	
	db:put("StartLevel" , tostring(Level));  	
	end
	
	
	if cookie== 2 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("EndDate" , tostring(Date));  	
	db:put("EndLevel" , tostring(Level));  	
	end
	
	if cookie == 10   then
 
			StartDate= db:get ("StartDate", 0); 
			StartLevel= db:get ("StartLevel", 0); 
			
			
			EndDate= db:get ("EndDate", 0); 
			EndLevel= db:get ("EndLevel", 0);
			instance:updateFrom(0);
	 
   end
   
   
     return core.ASYNC_REDRAW ;
   
	
end	



local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2  then
	  return;
	  end
	
        if not init then
         
            init = true;
			
			
				 
				context:createPen (1, context:convertPenStyle (Style ), context:pointsToPixels (Width ), Start )
			    context:createPen (2, context:convertPenStyle (Style ), context:pointsToPixels (Width ), End )
			
        end
		
            if StartPeriod~= nil then
			x, x1, x2 = context:positionOfBar (StartPeriod)
	        context:drawLine (1, x, context:top (), x, context:bottom ());
		    end
			
			 if EndPeriod~= nil then
			x, x1, x2 = context:positionOfBar (EndPeriod)
	        context:drawLine (2, x, context:top (), x, context:bottom ());
		    end

end		
 
  
