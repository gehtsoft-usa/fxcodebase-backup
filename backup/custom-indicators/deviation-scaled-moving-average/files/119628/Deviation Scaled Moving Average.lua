-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66208

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
    indicator:name("Deviation Scaled Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 40);
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local  Period;
local Zeros;
local first;
local source = nil;
local Filt; 
local Indicator;  
local c1,c2,c3,a1,b1;

-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ", " ..  Period   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
			
    source = instance.source;
    first=source:first()+2;
	
	
	--Smooth with a Super Smoother
	a1 = math.exp(-1.414*3.14159 / (.5*Period));
	b1 = 2*a1*math.cos(1.414*180 / (.5*Period));
	c2 = b1;
	c3 = -a1*a1;
	c1 = 1 - c2 - c3;
	 
    Zeros = instance:addInternalStream(0, 0);
	Filt= instance:addInternalStream(0, 0);
 
	Indicator = instance:addStream("Indicator" , core.Line, " Indicator"," Indicator",instance.parameters.color, first+Period +2);
	Indicator:setWidth(instance.parameters.width);
    Indicator:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period )

  
    if period < first then
	return;
	end
	
	 --Produce Nominal zero mean with zeros in the transfer response
	--at DC and Nyquist with no spectral distortion
    --Nominally whitens the spectrum because of 6 dB per octave rolloff
	
	
	Zeros[period] = source[period]  - source[period-2];
    --SuperSmoother Filter
     Filt[period] = c1*(Zeros[period] + Zeros[period-1]) / 2 + c2*Filt[period-1] + c3*Filt[period-2];
	 
	 if period < first +Period +2 then
	 return;
	 end
	 
    --Compute Standard Deviation
     local RMS = 0;
     for count = 0 , Period - 1, 1  do
     RMS = RMS + Filt[period-count]*Filt[period-count];
     end
     RMS = math.sqrt(RMS / Period);
     --Rescale Filt in terms of Standard Deviations
     local ScaledFilt = Filt[period] / RMS;
     local alpha1 = math.abs(ScaledFilt)*5 / Period;		
     Indicator[period]=alpha1*source[period] + (1 - alpha1)*Indicator[period-1];
				  
end

