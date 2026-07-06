---- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60593

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
    indicator:name("Elsig’s Shifting Mean");
    indicator:description("Elsig’s Shifting Mean");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
   indicator.parameters:addString("Method", "Coloring Method", "Method" , "Trend Continuation");
    indicator.parameters:addStringAlternative("Method", "Trend Continuation", "Trend Continuation" , "Trend Continuation");
    indicator.parameters:addStringAlternative("Method", "Current Trend Conditions", "Current Trend Conditions" , "Current Trend Conditions");
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	  indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Up, Down,Neutral;
local Method;
local first;
local source = nil;

-- Streams block
local MEAN = nil;
local  First=0
local Color;
local Flag=0;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
    source = instance.source;
    first = source:first();
	
    Flag=0;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Method)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    Trend = instance:addInternalStream(0, 0);
        MEAN = instance:addStream("MEAN", core.Line, name, "MEAN", Neutral, first);
		MEAN:setWidth(instance.parameters.width);
        MEAN:setStyle(instance.parameters.style);
    end
end

local Last=0;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if  period < Period	
	then
	return;
	end
	
  
   Flag= math.floor(period/Period);	   	  
   First= first+ (Flag)*Period;
	   
	 if Last~= Flag then
	 Last= Flag;
	 else
     return;	
     end

	 
	
 
	
	   
		
   local min, max= mathex.minmax(source,  First-Period , math.min(First-1, period));
    for period = First-Period  , 	 math.min(First-1, period) , 1 do
	      
           MEAN[period] = (min+ max)/2;			   
		   
			if MEAN[period]> MEAN[period-1] then
			Trend[period]=1;
			elseif MEAN[period]< MEAN[period-1] then
			Trend[period]=-1; 
			else
			
			  if  Method ==  "Trend Continuation" then
			  Trend[period]=Trend[period-1];
			  else
			   Trend[period]=0;
			  end
			end
			
			
			
			
			if Trend[period]== 1 then
			MEAN:setColor(period, Up);
			elseif Trend[period]== -1 then
			MEAN:setColor(period, Down); 
			else
			MEAN:setColor(period, Neutral); 
			end
	 
	 end
end

