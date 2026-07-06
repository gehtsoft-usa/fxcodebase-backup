-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71118

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("FM Demodulator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 30, 1, 2000);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1; 
 
local first;
local source = nil;
local a1, b1,c2,c3,c1;  
local Oscillator;  
local HL; 
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
 
	
	local Parameters= Period1 ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
	HL= instance:addInternalStream(0, 0);
    source = instance.source; 
    first=source:first()+1;
	
	a1 = math.exp(-1.414*math.pi / Period1);
	b1 = 2*a1*math.cos(1.414* math.pi / Period1);
	c2 = b1;
	c3 = -a1*a1;
	c1 = 1 - c2 - c3;
 

	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first+2 );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    
	if period < first
	then
	return;
	end
    local Deriv=math.abs(source.close[period]-source.open[period]);
 
 
    HL[period] = 10*Deriv ;
    if HL[period] > 1 then HL[period] = 1;end
    if HL[period] < -1 then HL[period] = -1;end
	
    if period < first +2
	then
	return;
	end

    Oscillator[period] = c1*(HL[period] + HL[period-1]) / 2 + c2*Oscillator[period-1] + c3*Oscillator[period-2];
--If Currentbar < 3 Then SS = Deriv;
	
	
 
				  
end


 

 