-- Id: 25162
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68528

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
    indicator:name("Median Mean Ratio");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Smoothing", "Price Smoothing", "", 1, 1, 2000);
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	indicator.parameters:addInteger("Average_Period", "Average Period", "", 14, 1, 2000);
    indicator.parameters:addBoolean("Inverse", "Inverse", "", false);

	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period,Inverse; 
local first;
local source = nil;
local Source;
local Average_Period; 
local Oscillator,Signal, Histogram;  
local Smoothing;

-- Routine
 function Prepare(nameOnly)    
	
	Period= instance.parameters.Period;
	Inverse= instance.parameters.Inverse;
	Average_Period= instance.parameters.Average_Period;
	Smoothing= instance.parameters.Smoothing;
	
	local Parameters=Smoothing ..  ", " .. Period ..  ", " ..Average_Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period+Smoothing;
	
	Source= instance:addInternalStream(0, 0); 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color1, first);
	Oscillator:setWidth(instance.parameters.width1);
    Oscillator:setStyle(instance.parameters.style1);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.color2, first+Average_Period);
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
	
	Histogram = instance:addStream("Histogram" , core.Bar, " Histogram"," Histogram",instance.parameters.color3, first+Average_Period);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    if period < source:first()+Smoothing then
	return;
	end 
   
	Source[period]=mathex.avg(source, period-Smoothing+1, period);
	
    if period < first then
	return;
	end 
		
     if not Inverse then
	 Oscillator[period]= (mathex.avg (Source, period-Period+1, period)/mathex.median_s (Source, period-Period+1, period))-1;
     else	 
     Oscillator[period]=(mathex.median_s (Source, period-Period+1, period)/mathex.avg (Source, period-Period+1, period)) ;
	 end
	 
	 
	if period < first +Average_Period then
	return;
	end  
	
	
	Signal[period]=mathex.avg(Oscillator, period-Average_Period+1, period);
	
	Histogram[period]=  (Oscillator[period]-Signal[period]);
				  
end

