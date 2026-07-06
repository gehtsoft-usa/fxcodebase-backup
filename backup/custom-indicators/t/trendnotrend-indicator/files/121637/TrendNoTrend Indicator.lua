-- Id: 22480
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66841 

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

function Init()
    indicator:name("TrendNoTrend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Regression Period", "", 50, 1, 2000);  
	indicator.parameters:addDouble("Level", "Level", "", 1.96, 0, 2000);  
	 

	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period,Level ;
 
local first;
local source = nil;
 
local Oscillator;  
 
-- Routine
 function Prepare(nameOnly)    
 
    Period = instance.parameters.Period ; 
	Level= instance.parameters.Level;
	
	
	local Parameters=   Period .. ", "  .. Level;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=Period;
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode) 
	
    if period < first then
	return;
	end
	
	 
	 
	 local SD=mathex.stdev(source, period-Period+1, period)
     local Value=(mathex.lregSlope (source, period-Period+1, period)-0)*((Period-2)^(1/2))/( StandardError(SD,Period) /SD);
	 
	  if Value < Level then
	 Oscillator[period]=0;
	 else
	  Oscillator[period]=1;
	  end
				  
end



function StandardError(SD,N) 
return SD/  (N^(1/2));
end
 
