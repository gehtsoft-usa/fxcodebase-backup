-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65706

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

function Init()
    indicator:name("MA Crossover shown in price Chart");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 10, 2, 2000);
  
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 20, 2, 2000);
  
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1 , Period1;
local Method2 ,  Period2; 
local first;
local source = nil;
 
local Line;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)  

   
    Period1= instance.parameters.Period1; 
    
	
	Period2= instance.parameters.Period2; 
	
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ",  " ..Period1   .. ",  " ..Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
   
			
    source = instance.source;
     
    
    first=math.max(Period1,Period2);
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period)

	
	
    if period < first then
	return;
	end
	
	
	-- Price =(Period2*SUM(Period1-1)-Period1*SUM(Period2-1))/(Period1-Period2)
	
    local Sum1=mathex.sum(source, period-Period1+1, period);	
    local Sum2=mathex.sum(source, period-Period2+1, period);	
    Line[period]=source[period]+(Period2*Sum1-Period1*Sum2)/(Period1-Period2);
				  
end

