-- Id: 22427
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66715

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
    indicator:name("Balanced ATR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 14, 1, 2000);
 
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "WMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
 
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
 
local first;
local source = nil;
 
local Oscillator;  
local MA;
local Data;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1; 
 
	
	
	local Parameters= Period1 ..  ", " .. Method1 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    Data = instance:addInternalStream(0, 0);
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA = core.indicators:create(Method1, Data, Period1);    
    first=MA.DATA:first();
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
     
	
	
    if period < source:first()+1 then
	return;
	end
	
	local range=source.high[period]-source.low[period];
	local a=range/source.close[period-1];
	local b=math.abs(source.high[period]-source.close[period-1])/source.close[period-1];
	local c=math.abs(source.low[period]-source.close[period-1])/source.close[period-1];
 
    Data[period]=100*math.max(a,math.max(b,c));
     
	 
	MA:update(mode);
	
	
    if period < first then
	return;
	end
 
		
     Oscillator[period]=MA.DATA[period];
				  
end

