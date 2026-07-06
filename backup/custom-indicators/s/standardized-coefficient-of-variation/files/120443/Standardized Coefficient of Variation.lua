-- Id: 21932
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66478

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
    indicator:name("Standardized Coefficient of Variation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 
   indicator.parameters:addGroup("Claculation"); 	
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "",3);
	indicator.parameters:addInteger("Period", "Period", "",3);
	indicator.parameters:addInteger("Smoothing_Period", "Smoothing Period", "",3);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local first;
local source = nil;
 local Period, Smoothing_Period, ATR_Period; 
local Line ;
local ATR, Raw; 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	Period=instance.parameters.Period;
    Smoothing_Period=instance.parameters.Smoothing_Period;
	ATR_Period=instance.parameters.ATR_Period;
	
	
	
	source = instance.source;
	ATR = core.indicators:create("ATR", source, ATR_Period);
    first=ATR.DATA:first()+Period; 
	
	Raw = instance:addInternalStream(first, 0);
	
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first+Smoothing_Period);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
	
	
	Line:setPrecision(math.max(2, instance.source:getPrecision()));
end

 

-- Indicator calculation routine
function Update(period, mode)

    
	ATR:update(mode);
	
    if period < first  then 
	return;
	end
	
	
	
	local min,max=mathex.minmax(ATR.DATA, period-Period+1, period); 
	
	Raw[period]=(max-ATR.DATA[period])/(max-min);	
	
	
	if period < first +Smoothing_Period then 
	return;
	end
	
	Line[period]= mathex.avg(Raw, period-Smoothing_Period+1, period);
	

		 			
end
 