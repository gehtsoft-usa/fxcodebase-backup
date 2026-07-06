-- Id: 23107
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67047

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

function Init()
    indicator:name("Price MA Cross Stop");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addInteger("Period1", "1. MA Period", "", 50, 2, 1000);
 
	
 
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addDouble("Percentage", "Percentage", "", 200, 0, 1000);
	
 
 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil; 
local Method, Short, Period1 , MA1,MA2; 
local Percentage;
local Trend;
 function Prepare(nameOnly)   
 
 
    Method= instance.parameters.Method;
	Period1= instance.parameters.Period1; 
	Percentage= instance.parameters.Percentage;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period1.. ", " ..  Method  .. ", " ..  Percentage.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
    Trend = instance:addInternalStream(0, 0);
   
	source = instance.source;
	
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1=core.indicators:create(Method,  source , Period1);  
	first= MA1.DATA:first() ;

    	
	Line = instance:addStream("Line", core.Line, name, "", core.rgb(0, 0, 0), first);
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
		
end

-- Indicator calculation routine
function Update(period, mode)
	 
	MA1:update(mode);
	 
	
	if period < first then 
	return;
	end
	
   
	
	Line[period]=Line[period-1];
	Trend[period]=Trend[period-1];
 
    if  (source[period]> MA1.DATA[period] 
	and source[period-1]<= MA1.DATA[period-1]  )
	then
	Line[period]= source[period];
	Trend[period]=1;
	end
	
	if  (source[period]< MA1.DATA[period] 
	and source[period-1]>= MA1.DATA[period-1]  )
	then
	Line[period]= source[period];
	Trend[period]=-1;
	end	 
	
	
	if Line[period]~= Line[period-1] then    
	Line:setBreak (period, true); 
	end
	
	if Trend[period]==1 then
	Line:setColor(period, Up);
	elseif Trend[period]==-1 then
	Line:setColor(period, Down);
	else
	Line:setColor(period, Neutral);
	end
		
 end


