-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=252
-- Id: 8094

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- SMA 20/50/100/200
-- www.fxcodebase.com
-- Adapted form EMAHLCEnvelope.lua, retrieved on 22/01/10 from:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=238&sid=96034d76546872e2f1b75b51d35a8537
-- 
function Init()
    indicator:name("Multiple MA");
    indicator:description("Shows 4 MA lines  ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("1. MA Calculation");
    indicator.parameters:addInteger("MA1", "MA Period", " ", 20);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("2. MA Calculation");
    indicator.parameters:addInteger("MA2", "MA Period", " ", 50);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("3. MA Calculation");
    indicator.parameters:addInteger("MA3", "MA Period", " ", 100);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("4. MA Calculation");
    indicator.parameters:addInteger("MA4", "4. MA", " ", 200);
	indicator.parameters:addString("Method4", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of 1. MA", "Color of  1. MA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color2", "Color of 2. MA", "Color of  2. MA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color3", "Color of 3. MA", "Color of  3. MA", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color4", "Color of 4. MA", "Color of  4. MA", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);

end

-- Parameters block
local  MA1;
local  MA2;
local  MA3;
local  MA4;
local Method={};
local first;
local source = nil;

-- Streams block
local Out={};
local Indicator={};
 
-- Routine
function Prepare(nameOnly)
   MA1 = instance.parameters.MA1;
   MA2 = instance.parameters.MA2;
   MA3 = instance.parameters.MA3;
   MA4 = instance.parameters.MA4;
   Method[1] = instance.parameters.Method1;
   Method[2] = instance.parameters.Method2;
   Method[3] = instance.parameters.Method3;
   Method[4] = instance.parameters.Method4;
   source = instance.source;
   
    
   local name = profile:id() .. "(" .. source:name() .. ", ".. MA1 .. ", "..Method[1].. ", ".. MA2.. ", "..Method[2] .. ", ".. MA3.. ", "..Method[3] .. ", "..MA4.. ", "..Method[4]..")";
   instance:name(name);
   if nameOnly then
    return;
   end
    assert(core.indicators:findIndicator(Method[1]) ~= nil, Method[1] .. " indicator must be installed");
   Indicator[1] = core.indicators:create(Method[1], source ,  MA1);
    assert(core.indicators:findIndicator(Method[2]) ~= nil, Method[2] .. " indicator must be installed");
   Indicator[2] = core.indicators:create(Method[2], source , MA2);
    assert(core.indicators:findIndicator(Method[3]) ~= nil, Method[3] .. " indicator must be installed");
   Indicator[3] = core.indicators:create(Method[3], source , MA3);
    assert(core.indicators:findIndicator(Method[4]) ~= nil, Method[4] .. " indicator must be installed");
   Indicator[4] = core.indicators:create(Method[4], source , MA4);
   
   first = math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first(),Indicator[3].DATA:first(),Indicator[4].DATA:first());
   
    Out[1]= instance:addStream("MA1", core.Line, name .. ".1. MA", "1. MA", instance.parameters.color1, first);
	Out[1]:setWidth(instance.parameters.width1);
    Out[1]:setStyle(instance.parameters.style1);
    Out[2] = instance:addStream("MA2", core.Line, name .. ".2. MA", "2. MA", instance.parameters.color2, first);
	Out[2]:setWidth(instance.parameters.width2);
    Out[2]:setStyle(instance.parameters.style2);
    Out[3] = instance:addStream("MA3", core.Line, name .. ".3. MA", "3. MA", instance.parameters.color3, first);
	Out[3]:setWidth(instance.parameters.width3);
    Out[3]:setStyle(instance.parameters.style3);
    Out[4] = instance:addStream("MA4", core.Line, name .. ".4. MA", "4. MA", instance.parameters.color4, first);
	Out[4]:setWidth(instance.parameters.width4);
    Out[4]:setStyle(instance.parameters.style4);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   Indicator[1]:update(mode);
   Indicator[2]:update(mode);
   Indicator[3]:update(mode);
   Indicator[4]:update(mode);
   
   if( period < first  ) then   
   return;
   end
      Out[1][period] =  Indicator[1].DATA[period];
      Out[2][period] =  Indicator[2].DATA[period];
      Out[3][period] =  Indicator[3].DATA[period];
      Out[4][period] =  Indicator[4].DATA[period];
    
end