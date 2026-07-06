-- Id: 23556
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67239

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
    indicator:name("Average Cross Distance");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 50, 2, 2000);
    indicator.parameters:addInteger("Average_Period", "Period", "", 50, 2, 2000);
 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period;
local Average_Period; 
local first;
local source = nil;
 
local Oscillator;  
local MA;
local Data;
-- Routine
 function Prepare(nameOnly)   
 
  
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
 
	Average_Period = instance.parameters.Average_Period;
	
	
	local Parameters= Period  ..  ", " .. Method   ..  ", " ..Average_Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source, Period);
    first=MA.DATA:first();
    
    
	
	Data = instance:addInternalStream(0, 0); 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    MA:update(mode);
   	
    if period < first then
	return;
	end
	
		
     Data[period]=0;
	 
	 if core.crosses (source, MA.DATA, period) then
	 Data[period]= Find(period);
	 end
	 
	 Oscillator[period]= Average(period);			  
end

function Find(period)

    Data[period]=1;
    for i= period -1, first, -1 do
	
	 if core.crosses (source, MA.DATA, i) then
	 Data[i]=1;
	 break;
	 end
	
	end

end


function Average(period)

    local Last=period;
	local Sum=0;
	local Count=0;
    for i= period -1, first, -1 do
	
		 if Data[i] ==1  then
		 
		  Sum= Sum+(Last-i);
		  Count=Count+1;
		  Last=i;
		  
		  if Count==Average_Period then
		  break;
		  end
		  
		  
		 end
	
	end

	
	return Sum/Count;
end
