-- Id: 2330
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1052

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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Triple Moving Average");
    indicator:description("Triple Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Caculation"); 
    indicator.parameters:addInteger("Frame", "Period", "Period", 50,2,2000);	
	indicator.parameters:addString("Method", "MA Method", "", "EMA");
	 indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");   
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "", "TMA"); 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "TEMA Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "TEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
    indicator.parameters:addColor("TC", "Color of TEMA", "Color of TEMA", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Frame;
local Method;

local first;
local source = nil;

-- Streams block
local TEMA = nil;
local EMA1, EMA2, EMA3;
local TC = nil;

-- Routine
 function Prepare(nameOnly) 
    Method = instance.parameters.Method;
    Frame = instance.parameters.Frame;
    TC = instance.parameters.TC;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Frame ..", ".. Method ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	

    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    EMA1 = core.indicators:create(Method, source, Frame);
    EMA2 = core.indicators:create(Method, EMA1.DATA, Frame);
    EMA3 = core.indicators:create(Method, EMA2.DATA, Frame);
    first = EMA3.DATA:first();

   
	
    TEMA = instance:addStream("TEMA", core.Line, name, "TEMA", TC, first);
	TEMA:setWidth(instance.parameters.width);
    TEMA:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period,mode)
    EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
	
     if period < first  then
	 return;
	 end
	 
        TEMA[period] = 3 * EMA1.DATA[period] - 3 * EMA2.DATA[period] + EMA3.DATA[period];
    
end

