-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9831
-- Id: 5307

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Average Volume");
    indicator:description("Average Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Resolution", "Resolution", "", "hour");
    indicator.parameters:addStringAlternative("Resolution","A Minute", "", "min");
	 indicator.parameters:addStringAlternative("Resolution","A hour", "", "hour");
    indicator.parameters:addStringAlternative("Resolution", "A Day of the Week", "", "wday");
    indicator.parameters:addStringAlternative("Resolution", "A Day", "", "day");
    indicator.parameters:addStringAlternative("Resolution", "A Month", "", "month");	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
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
local Data = {};
local Count= {};
local FLAG;
local Resolution;
-- Routine
function Prepare(nameOnly)
    Resolution= instance.parameters.Resolution;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

	Data={}; 
	
    if (not (nameOnly)) then
        AV = instance:addStream("AV", core.Line, name, "AV", instance.parameters.color, first);
    AV:setPrecision(math.max(2, instance.source:getPrecision()));
        AV:setWidth(instance.parameters.width);
        AV:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <  first then
	return;
	end
	
	local date = core.dateToTable(source:date(period));
	FLAG= DATE(date);
	
	if period < source:size()-1 then
	
	      if  Data[FLAG] == nil then
		   
		   Data[FLAG] =   source.volume[period]  
	       Count[FLAG] = 1;    
		   
	      else
		   Data[FLAG] =   Data[FLAG] +source.volume[period]  
	       Count[FLAG] = Count[FLAG]+1;    
		  end		  
       	
    end	
	    
	if period == source:size()-1 then
	
	local i;	
	   
		for i = 1, period-1, 1  do
		
		date = core.dateToTable(source:date(i));
		FLAG= DATE(date);
		
		AV[i] = Data[FLAG] /  Count[FLAG];
		end
	
	end
        
    
end

function DATE (date)

   if Resolution ==  "min" then
   return date.min;
   elseif Resolution ==  "hour" then
   return date.hour;
   elseif Resolution ==  "wday" then
   return date.wday;
   elseif Resolution ==  "day" then
   return date.day;
   elseif Resolution ==  "month" then
   return date.month;
   end 


end

