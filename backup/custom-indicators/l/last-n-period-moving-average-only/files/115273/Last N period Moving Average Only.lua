-- Id: 19209
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65152

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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Last N period Moving Average Only");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 
 
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period","", 14, 2, 1000); 
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
    indicator.parameters:addColor("color", "Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width","Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local first;
local source = nil;

local Period, MA,ma;

-- Routine
function Prepare(nameOnly) 
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
    source = instance.source;
	local name="";
	
 
	name = profile:id() .. "(" .. source:name() .. ", " ..Period .. ", " .. Method .. ")";
 
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma= core.indicators:create(Method, source, Period);
	first=ma.DATA:first();
	
	

    MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.color, first)
    MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);



 
end


-- Indicator calculation routine

function Update(period, mode)
     
    
	 
	    ma:update(mode);
	  
		if period < first
		or period < (source:size()-1 -Period)
		then
		return;
		end
	    
		MA[period]= ma.DATA[period];
	    MA[period-Period]= nil;
end