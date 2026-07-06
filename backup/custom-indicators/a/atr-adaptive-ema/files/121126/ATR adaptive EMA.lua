-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66643

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
    indicator:name("ATR adaptive EMA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 2, 2000);
 
	indicator.parameters:addString("Price", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted"); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Price; 
local ATR;
local first;
local source = nil;
 
local Oscillator;  
local ATR;
local Line
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Period= instance.parameters.Period;
    Price = instance.parameters.Price;
	
			
    source = instance.source;
    
  
    ATR = core.indicators:create("ATR", source , Period);    
    first=ATR.DATA:first()+Period;
	
	 
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ATR:update(mode);
	
	
    if period < first then
	return;
	end
	
	local min,max=mathex.minmax(ATR.DATA, period-Period+1, period);
	local coeff = 1-(ATR.DATA[period]-min)/(max-min);
	local alpha = 2.0 / (1+Period*(coeff+1.0)/2.0);
	
     Line[period]=Line[period-1]+alpha*(source[Price][period] - Line[period-1]);
				  
end
 

