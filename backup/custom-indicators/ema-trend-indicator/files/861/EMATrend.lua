-- Id: 255
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=508

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("MA Trend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FastMA", "Fast Moving Average Periods", "", 21, 1, 100);
    indicator.parameters:addInteger("SlowMA", "Slow Moving Average Period", "", 34, 1, 100);
	
	indicator.parameters:addString("Method1", "Fast MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Method2", "Slow MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");

	indicator.parameters:addGroup("Style");	
	
    local yellow = core.rgb(255, 255, 128);
    local purple = core.rgb(128, 0, 255);

    indicator.parameters:addColor("FH_color", "Color of FH", "Color of FH", purple);
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("FL_color", "Color of FL", "Color of FL", yellow);
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("SH_color", "Color of SH", "Color of SH", yellow);
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("SL_color", "Color of SL", "Color of SL", purple);
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FastMA;
local SlowMA;
local Method1,Method2;
local firstFast;
local firstSlow;
local source = nil;

-- Streams block
local FH = nil;
local FL = nil;
local SH = nil;
local SL = nil;

local EFH = nil;
local EFL = nil;
local ESH = nil;
local ESL = nil;


-- Routine
function Prepare(nameOnly)
    FastMA = instance.parameters.FastMA;
    SlowMA = instance.parameters.SlowMA;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FastMA .. ", " .. FastMA.. ", " .. Method1.. ", " .. Method2  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    EFH = core.indicators:create(Method1, source.high, FastMA);	
    EFL = core.indicators:create(Method1, source.low, FastMA);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    ESH = core.indicators:create(Method2, source.high, SlowMA);
    ESL = core.indicators:create(Method2, source.low, SlowMA);

    firstFast = EFH.DATA:first();
    firstSlow = ESH.DATA:first();

    FH = instance:addStream("FH", core.Line, name .. ".FH", "FH", instance.parameters.FH_color, firstFast);
	FH:setWidth(instance.parameters.width1);
    FH:setStyle(instance.parameters.style1);
		
    FL = instance:addStream("FL", core.Line, name .. ".FL", "FL", instance.parameters.FL_color, firstFast);
	FL:setWidth(instance.parameters.width2);
    FL:setStyle(instance.parameters.style2);
		
    SH = instance:addStream("SH", core.Line, name .. ".SH", "SH", instance.parameters.SH_color, firstSlow);
	SH:setWidth(instance.parameters.width3);
    SH:setStyle(instance.parameters.style3);
		
    SL = instance:addStream("SL", core.Line, name .. ".SL", "SL", instance.parameters.SL_color, firstSlow);
	SL:setWidth(instance.parameters.width4);
    SL:setStyle(instance.parameters.style4);
end

-- Indicator calculation routine
function Update(period, mode)
    EFH:update(mode);
    EFL:update(mode);
    ESH:update(mode);
    ESL:update(mode);

    if period >= firstFast then
        FH[period] = EFH.DATA[period];
        FL[period] = EFL.DATA[period];
    end
    if period >= firstSlow then
        SH[period] = ESH.DATA[period];
        SL[period] = ESL.DATA[period];
    end
end

