-- Id: 20604
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65755

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
    indicator:name("Advance decline ratio");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 9, 2, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local Period; 
local first;
local source = nil;
local AD;  
local Up,Down;

-- Routine
 function Prepare(nameOnly)   
   
    Period= instance.parameters.Period;
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    source = instance.source;     
    first=source:first()+Period;
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	 
 
	AD = instance:addStream("AD" , core.Line, "AD","AD",instance.parameters.color, first);
    AD:setPrecision(math.max(2, instance.source:getPrecision()));
	AD:setWidth(instance.parameters.width);
    AD:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    if source.close[period]>source.open[period] then
	Up[period]=1;
	Down[period]=0;
	else
	Up[period]=0;
	Down[period]=1;
	end
		
    if period < first then
	return;
	end
	
	
	local upBars=mathex.sum(Up, period-Period+1, period)
	local downBars=mathex.sum(Down, period-Period+1, period)
	
	
	 if downBars==0 then
	  AD[period]=upBars;
     else	 
     AD[period]=upBars/downBars;
	 end
				  
end

