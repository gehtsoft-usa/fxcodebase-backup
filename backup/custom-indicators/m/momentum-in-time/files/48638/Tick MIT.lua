-- Id: 19992
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27768


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Moment In Time");
    indicator:description("Momemt In Time");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Selector");
	indicator.parameters:addInteger("hour", "Hour", "", 0, 0, 24);
	indicator.parameters:addInteger("minute", "Minute", "", 0, 0, 60);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MIT_color", "Color of MIT", "Color of MIT", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Size, LabeL;
local first;
local source = nil;
local Start;
-- Streams block
local MIT = nil;
local hour, minute;
local  dayoffset,weekoffset;
local ChartSize, DSize;
function Prepare(nameOnly)
  
    source = instance.source;
    first = source:first();
	Size= instance.parameters.Size;
	Label= instance.parameters.Label;
	hour= instance.parameters.hour;
	minute= instance.parameters.minute;
	dayoffset = core.host:execute("getTradingDayOffset");
	weekoffset = core.host:execute("getTradingWeekOffset");

	
	local s1, e1
	
	 s1, e1 = core.getcandle(source:barSize(),  0,  0, 0);
	 ChartSize = e1-s1;
	
	 s1, e1 = core.getcandle("D1", 0, 0, 0);
	 DSize = e1-s1;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(hour).. ", " .. tostring(minute) .. ")";
    instance:name(name);


    if (not (nameOnly)) then
	    if DSize > ChartSize then
        MIT = instance:addStream("MIT", core.Line, name, "MIT", instance.parameters.MIT_color, first);
    	Start = instance:createTextOutput ("Start", "Start", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Label, first);
		else
		MIT = instance:addStream("MIT", core.Bar, name, "MIT", instance.parameters.MIT_color, first);
		end
		MIT:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	local date = source:date(period) ;
    local t = core.dateToTable(date);


	local s, e;
	s, e = core.getcandle("D1", date,dayoffset,weekoffset); 
	
	local second = 1 / 86400;
	
	s= s + minute*60*second + 60*60*hour*second;
	

    
	
	local index, Flag;
	
	if source:barSize() == "m1" then
	Flag= true;
	else
	Flag=false;
	end
	
     index= core.findDate(source, s, Flag);


   
	
    if DSize > ChartSize then
    MIT[period] = source[period]- source[index]; 
	
	 if period == index then
	 Start:set(period , 0, "\108");	
	 end
	 
	else
	MIT[period] = source[period]- source[period-1];
    end	
    
end

