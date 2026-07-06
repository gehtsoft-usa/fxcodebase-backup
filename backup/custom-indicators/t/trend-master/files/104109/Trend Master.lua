-- Id: 15225
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63004

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trend Master");
    indicator:description("Trend Master");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "1. MA Period", "1. MA Period", 10);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period2", "2. MA Period", "2. MA Period", 15);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period3", "3. MA Period", "3. MA Period", 20);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period4", "4. MA Period", "4. MA Period", 25);
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
    indicator.parameters:addColor("MA1_color", "Color of MA1", "Color of MA1", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("MA2_color", "Color of MA2", "Color of MA2", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("MA3_color", "Color of MA3", "Color of MA3", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("MA4_color", "Color of MA4", "Color of MA4", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;
local Period3;
local Period4;

local Method1;
local Method2;
local Method3;
local Method4;

local first;
local source = nil;

-- Streams block
local MA1 = nil;
local MA2 = nil;
local MA3 = nil;
local MA4 = nil;

local ma1;
local ma2;
local ma3;
local ma4;

-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    Period3 = instance.parameters.Period3;
    Period4 = instance.parameters.Period4;
	Method1 = instance.parameters.Method1;
    Method2 = instance.parameters.Method2;
    Method3 = instance.parameters.Method3;
    Method4 = instance.parameters.Method4;
	
    source = instance.source;
    first = source:first();
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2) .. ", " .. tostring(Period3) .. ", " .. tostring(Period4) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
        ma1 = core.indicators:create(Method1, source.median, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
        ma2 = core.indicators:create(Method2, source.median, Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
        ma3 = core.indicators:create(Method3, source.median, Period3);
    assert(core.indicators:findIndicator(Method4) ~= nil, Method4 .. " indicator must be installed");
        ma4 = core.indicators:create(Method4, source.median, Period4);
        MA1 = instance:addStream("MA1", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1_color, ma1.DATA:first());
		MA1:setWidth(instance.parameters.width1);
        MA1:setStyle(instance.parameters.style1);
        MA2 = instance:addStream("MA2", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2_color, ma2.DATA:first());
		MA2:setWidth(instance.parameters.width2);
        MA2:setStyle(instance.parameters.style2);
        MA3 = instance:addStream("MA3", core.Line, name .. ".MA3", "MA3", instance.parameters.MA3_color, ma3.DATA:first());
		MA3:setWidth(instance.parameters.width3);
        MA3:setStyle(instance.parameters.style3);
        MA4 = instance:addStream("MA4", core.Line, name .. ".MA4", "MA4", instance.parameters.MA4_color, ma4.DATA:first());
		MA4:setWidth(instance.parameters.width4);
        MA4:setStyle(instance.parameters.style4);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
        
		ma1:update(mode);
		ma2:update(mode);
		ma3:update(mode);
		ma4:update(mode);
		
		if ma1.DATA:hasData(period) then
        MA1[period] = ma1.DATA[period];
		end
		
		if ma2.DATA:hasData(period) then
        MA2[period] = ma2.DATA[period];
		end
		
		if ma3.DATA:hasData(period) then
        MA3[period] = ma3.DATA[period];
		end
		
		if ma4.DATA:hasData(period) then
        MA4[period] = ma4.DATA[period];
		end
   
end

