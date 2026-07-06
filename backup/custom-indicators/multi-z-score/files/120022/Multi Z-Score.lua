-- Id: 21717
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66289

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
    indicator:name("Multi Z-Score");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	
	indicator.parameters:addGroup("Calculation");
	
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

    indicator.parameters:addInteger("Period", "Period", "", 10);
	indicator.parameters:addDouble("Definition", "definition", "", 100);

	

	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Z-Score Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
    indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local first;
local source = nil;
 
local Definition, Period,Method;
local Raw;
local Indicator={};
local globalz;

local Signal;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	
    Definition= instance.parameters.Definition;
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
	 
			
    source = instance.source;
	first=source:first()+Period*Definition;
	
	--a= instance:addInternalStream(0, 0);
	for i = 1 , Definition, 1  do
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    Indicator[i] = core.indicators:create(Method, source, Period*i);
	end
	
	globalz = instance:addStream("zscore" , core.Line, "zscore","zscore",instance.parameters.color1, first);
	globalz:setWidth(instance.parameters.width1);
    globalz:setStyle(instance.parameters.style1);
	
	
	Signal= instance:addStream("Signal" , core.Line, "Signal","Signal",instance.parameters.color2, first+Period);
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	
	globalz:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    
	end

-- Indicator calculation routine
function Update(period, mode)

 
   for i = 1 , Definition, 1  do
    Indicator[i]:update(mode);
	end

	
	
    if period < first  then
	return;
	end
	
	globalz[period]=0;
	

for i = 1 , Definition, 1  do

st = mathex.stdev(source, period-Period*i+1, period);

zscore = (source[period]-Indicator[i].DATA[period])/st;

globalz[period]=(globalz[period]+zscore*i)/Definition
end

 
    if period < first+Period  then
	return;
	end


Signal[period]=mathex.avg(globalz, period-Period+1, period);
				  
end


