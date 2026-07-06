-- Id: 21929
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66477

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
    indicator:name("STDs of Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 
   indicator.parameters:addGroup("Claculation"); 	
    indicator.parameters:addInteger("Period", "Period", "",20);
	
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
 local Period; 
local Line ;
 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	Period=instance.parameters.Period; 
	 
			
    source = instance.source;
    first=source:first() +Period; 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
end

 

-- Indicator calculation routine
function Update(period)

  
    if period < first then 
	return;
	end
	  
	 --(V-mov(V,20,S))/std(V,20)
		 
		Line[period]=( source.volume[period]-mathex.avg(source.volume, period-Period+1, period))/ mathex.stdev(source.volume, period-Period+1, period);
	 
		 			
end
 