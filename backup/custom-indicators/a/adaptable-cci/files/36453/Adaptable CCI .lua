-- Id: 6946
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20800

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

-- The indicator corresponds to the Commodity Channel Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 8 "Sycle Analisis" (page 209-210)

-- Indicator profile initialization routine
function Init()
    indicator:name("Adaptable CCI ");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N1", "Average Period", "", 14, 2, 1000);
	indicator.parameters:addInteger("N2", "Deviation Period", "", 14, 2, 1000);
	indicator.parameters:addDouble("Correction", "Correction Factor", "", 0.015);
	
	
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI","Line Color","" , core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI", "Line Width", "" , 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style","" , core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");  
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", "Oversold Level","", -100, -1000, 1000);
	indicator.parameters:addColor("level_overboughtsold_color", "Overbought/Oversold Line Color", "" , core.rgb(255, 255, 0));
    indicator.parameters:addInteger("level_overboughtsold_width", "Overbought/Oversold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Overbought/Oversold Line Style", "", core.LINE_SOLID);    
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N1, N2;

local first;
local source = nil;
local tp = nil;

-- Streams block
local CCI = nil;
local Method;
local Indicator;
local Correction;
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
	Correction = instance.parameters.Correction;
    N1 = instance.parameters.N1;
	N2 = instance.parameters.N2;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N1 .. ", " .. N2 .. ", " .. Method.. ", " ..  Correction.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	Indicator = core.indicators:create(Method, source, N1);
	first =N1+N2;
	
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.clrCCI, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2);

    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(0);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
end

-- Indicator calculation routine
function Update(period, mode)


     Indicator:update(mode);
	 
    if period < first then
	return;
	end
	
   

        local mean = Indicator.DATA[period];
        local meandev = mathex.meandev(source, period-N2+1, period);

        if (meandev == 0) then
            CCI[period] = 0;
        else
            CCI[period] = (source[period] - mean) / (meandev * Correction);
        end
 end







