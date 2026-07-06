-- Id: 22505
-- More information about this indicator can be found at:
-- http://fxcodebase.com 

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
    indicator:name("Maximum Profit");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 50, 2, 2000);
	indicator.parameters:addBoolean("Shift" , "Shift", "",true);	
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Confirmed Bar Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color2", "Unconfirmed Bar Color", "", core.rgb(0, 255, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period; 
local source = nil;
local Oscillator;  
local Shift;
local shift;

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period= instance.parameters.Period;
	Shift= instance.parameters.Shift;
	local Parameters=  Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", ".. Parameters  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

     if Shift then
	 shift=Period;
	 else
	 shift=0;
	 end
			
    source = instance.source;
  
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color1, source:first(),shift  );
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
 
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	
	
    if period < source:first() then
	return;
	end
	
	if period < (source:size()-1 -Period) then
	local Max=0;
     for i=0, Period, 1 do
		 if period+i <= source:size()-1 then
		 Max=math.max(Max,(source.high[period+i]-source.low[period]));
		 end
	 end	
	 
	 Oscillator[period+shift]=Max/source:pipSize(); 
	 Oscillator:setColor(period+shift, instance.parameters.color1);
	else
		 New(period);
	
	end
				  
end

function New(period)


   local Max=0;
	 
	 for i=period, source:size()-1, 1 do
	 Max=math.max(Max,(source.high[i]-source.low[period]));
	 end
	 
     Oscillator[period+shift]=Max/source:pipSize();
	 Oscillator:setColor(period+shift, instance.parameters.color2);

end