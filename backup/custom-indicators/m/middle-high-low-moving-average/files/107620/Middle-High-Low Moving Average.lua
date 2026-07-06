-- Id: 16505

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63763

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


--[[TASC Aug 2016
Article: MHL MA
By: Vitali Apirine
]]
function Init()
    indicator:name("Middle-High-Low Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MHLLength", "MHL Length", "MHL Length", 10);
    indicator.parameters:addInteger("MovAvgLength", "MovAvg Length", "MovAvg Length", 50);
	
	
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
    indicator.parameters:addColor("color1", "MHL Color", "Color", core.rgb(0,255,0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("color2", "Close Color", "Color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local source;
local first;
local MHLLength,MovAvgLength;
local MHL;
local Method;
local HL, hl;
local C,c;
function Prepare(nameOnly) 
    source = instance.source;
    
   
   Method=instance.parameters.Method;
   MHLLength=instance.parameters.MHLLength;
   MovAvgLength=instance.parameters.MovAvgLength;
   MHL = instance:addInternalStream(0, 0);
 
  
    local name = profile:id() .. " ( " .. MHLLength .. ", " .. MovAvgLength .. ", " .. Method.. " )";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	hl = core.indicators:create(Method, MHL, MovAvgLength);
	c = core.indicators:create(Method, source.close, MovAvgLength);
	first= math.max(hl.DATA:first(), c.DATA:first());
	HL = instance:addStream("HL", core.Line, name, "HL", instance.parameters.color1, first);
	HL:setWidth(instance.parameters.width1);
    HL:setStyle(instance.parameters.style1);
	
	C = instance:addStream("C", core.Line, name, "C", instance.parameters.color2, first);
	C:setWidth(instance.parameters.width2);
    C:setStyle(instance.parameters.style2);
end

function Update(period, mode)


if period < MHLLength then
return;
end 


min,max=mathex.minmax(source, period-MHLLength+1, period);
MHL[period] = ( max+ min ) / 2 ;

hl:update(mode);
c:update(mode);

if period < first then
return;
end 

HL[period]= hl.DATA[period];
C[period]= c.DATA[period];
 
 
end
 