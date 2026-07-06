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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=70510

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Horizontal Line");
    indicator:description("Horizontal Line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Method", "Method", "Method" , "Shift");
    indicator.parameters:addStringAlternative("Method", "Shift", "Shift" , "Shift");
    indicator.parameters:addStringAlternative("Method", "Date", "Date" , "Date");
	
    indicator.parameters:addInteger("Period", "Shift Period", "Period", 10);
	
	indicator.parameters:addDate ("Date", "Date", "Date", 0);
	indicator.parameters:setFlag ("Date",core.FLAG_DATETIME);
	
 
	
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("label", "Label Color", "Label Color", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("size", "Font Size", "Font Size", 10);
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("extend", "Extend Line", "", true);
	indicator.parameters:addBoolean("Show", "Show Label", "", true);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local Hour;
local first;
local source = nil;
local Date;
-- Streams block
local Line = nil;
local color;
local extend;
local label;
local size;
local Show;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	Date = instance.parameters.Date;
	Hour = instance.parameters.Hour;
	color= instance.parameters.color;
	extend= instance.parameters.extend;
	label= instance.parameters.label;
	size= instance.parameters.size;
	Show= instance.parameters.Show;
    source = instance.source;
    first = source:first();
	 
    local name;
	if Method== "Shift" then
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ", " .. tostring(Period) .. ")";
	else
	
	local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4,Date));
	local dateDescr =  string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min); 
 
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ", " .. tostring(dateDescr) .. ")";
	end
	
	
	if   (nameOnly) then
        return;
    end
	
    instance:name(name);
    instance:ownerDrawn(true);

    
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
            context:createPen (1, context:convertPenStyle (instance.parameters.style), instance.parameters.width, color)
			context:createPen (2, context.DASH, instance.parameters.width, color);
            context:createFont (3, "Arial", context:pointsToPixels (size), context:pointsToPixels (size), 0); 

            init = true;
    end

		
 
	local Last= source:size()-1 ;  
	local last; 
	
    if Method == "Shift" then	
	last= source:size()-1-Period;	
		if last < first then
		 last =  first;
		end	    
    visible, y = context:pointOfPrice (source[last]); 
	x1, x, x  = context:positionOfBar (last);
	x2, x, x  = context:positionOfBar (source:size()-1);
	context:drawLine (1, x1, y, x2, y); 
	Value = string.format("%." .. source:getPrecision() .. "f", source[last]);
	core.host:execute("setStatus", Value); 
	
		 if Show then
		 width, height = context:measureText (3, Value, 0); 
		context:drawText (3, Value, label, -1, x +width/4, y-height, x +width+width/4, y, 0);
		end
		if extend then
		context:drawLine (2, x2, y, context:right (), y); 
		context:drawLine (2, context:left (), y, x1 ,y); 
		end
	else
	
	last =  core.findDate (source, Date, false);
	
	if last < first then
	 last =  first;
	end	   
	
	if last >  Last then
	 last =   Last;
	end	    
	visible, y = context:pointOfPrice (source[last]); 
	x1, x, x  = context:positionOfBar (last);
	x2, x, x  = context:positionOfBar (source:size()-1);
	context:drawLine (1, x1, y, x2, y); 
	Value = string.format("%." .. source:getPrecision() .. "f", source[last]);
	core.host:execute("setStatus", Value); 
	    if Show then
		width, height = context:measureText (3, Value, 0); 
		context:drawText (3, Value, label, -1, x +width/4, y-height, x +width+width/4, y, 0);
		end
		if extend then
		context:drawLine (2, x2, y, context:right (), y); 
		context:drawLine (2, context:left (), y, x1 ,y); 
		end
    end
end

