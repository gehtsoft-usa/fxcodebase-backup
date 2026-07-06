-- Id: 19354

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61337

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
    indicator:name("Distance from the moving average");
    indicator:description("Distance from the moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	
	
    indicator.parameters:addInteger("Duration1", "1. MA Duration ", "MA Duration ", 60);
	indicator.parameters:addInteger("Duration2", "2. MA Duration ", "MA Duration", 120);
	
	indicator.parameters:addString("Type", "MA Duration Type", "", "seconds");
    indicator.parameters:addStringAlternative("Type", "Seconds", "", "seconds");
    indicator.parameters:addStringAlternative("Type", "Ticks", "", "ticks");
 
	
	indicator.parameters:addBoolean("Smoothing", "Uses Smoothing", "", true);
	
	
 
 
	
	indicator.parameters:addString("Mode", "Mode", "Mode", "Value");
	indicator.parameters:addStringAlternative("Mode", "Value", "Value" , "Value");
    indicator.parameters:addStringAlternative("Mode", "Pip", "Pip" , "Pip");
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of Distance", "Color of Distance", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "Color of Smoothed", "Color of Smoothed", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
 
local Period2;
 
local Smoothing;
 
local source = nil;
 
local Mode;

local Duration1, Duration2, Type;
local MA;

-- Streams block
local Distance = nil;

local Second;

-- Routine
function Prepare(nameOnly)
 
   
    Duration1= instance.parameters.Duration1;
	Duration2= instance.parameters.Duration2;
	Type= instance.parameters.Type;
	
	Mode= instance.parameters.Mode;
	
	Smoothing= instance.parameters.Smoothing;
	
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Duration1) .. ", " .. tostring(Duration2).. ", " .. tostring(Typ) .. ", " .. tostring(Mode) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local date1= core.datetime (2014, 1, 1, 1, 1, 0);
	local date2= core.datetime (2014, 1, 1, 1, 2, 0);
	Second= ((date2 - date1)/60);
 

   

   
        Distance = instance:addStream("Distance", core.Line, name, "Distance", instance.parameters.color1, source:first());
    Distance:setPrecision(math.max(2, instance.source:getPrecision()));
		Distance:setWidth(instance.parameters.width1);
        Distance:setStyle(instance.parameters.style1);
		
		if Smoothing then 
		MA = instance:addStream("Smoothed", core.Line, name, "Smoothed", instance.parameters.color2, source:first());
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
		MA:setWidth(instance.parameters.width2);
        MA:setStyle(instance.parameters.style2);
		end
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

 
    if period < source:first() or not source:hasData(period) then
	return;
	end
	
	
	if Type == "seconds" then
	P1= core.findDate (source, source:date(period)- Second * Duration1, false);
	else
	P1= period-Duration1+1;
	end
	
	if P1==-1
	or P1< source:first()+1 	
    then
    return;
    end 
	 
		
        local MA1= mathex.avg(source,P1, period);
		
		
	    if Mode== "Pip" then
		Distance[period] = (source[period]-  MA1)/source:pipSize();
		else
        Distance[period] = source[period]-  MA1;
		end
		
		
		
	if not Smoothing then
    return;
    end	
	
	
	
    if Type == "seconds" then
	P2= core.findDate (source, source:date(period)- Second * Duration2, false);
	else
	P2= period-Duration2+1;
	end
	
	if P2==-1
	or P2< source:first()+1 	
    then
    return;
    end 
	  
	   local MA2= mathex.avg(Distance,P2, period);
	   MA[period] =  MA2;
    
end

