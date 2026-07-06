-- More information about this indicator can be found at:
-- http://fxcodebase.com/ 

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Lagrange Interpolation forecasting Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period3", "1. Period", "", 14, 2, 2000);
    indicator.parameters:addInteger("Period1", "2. Period", "", 14, 2, 2000);
	
    indicator.parameters:addInteger("Period2", "3. Period", "", 1, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Average;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	
	
	local Parameters= Period3..", "..Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period3+Period1*2;
	
	 Average= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first, Period2);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()+Period3 
	then
	return;
	end
	Average[period]=mathex.avg(source, period-Period3+1, period)
	
    if period < first then
	return;
	end
	
	local x, x1, x2, x3, y1, y2, y3=period+Period2, period-Period1*2+1, period-Period1*1+1, period, Average[period-Period1*2+1], Average[period-Period1*1+1], Average[period];
	
	 local y=LagrangeInterpolation(x, x1, x2, x3, y1, y2, y3);
		
     Oscillator[period+Period2]= y-Average[period];
				  
end


function LagrangeInterpolation(x, x1, x2, x3, y1, y2, y3)
local A=(y1*(x-x2)*(x-x3))/((x1-x2)*(x1-x3));
local B=(y2*(x-x1)*(x-x3))/((x2-x1)*(x2-x3));
local C=(y3*(x-x1)*(x-x2))/((x3-x1)*(x3-x2));
return A+B+C;
end
