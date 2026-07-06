-- Id: 14203
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=848

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
    indicator:name("Schaff Trend Cycle Oscillator with smoothing method selector");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("C", "Schaff cycle periods", "", 10, 2, 10000);
    indicator.parameters:addInteger("S", "Short periods", "", 23, 2, 10000);
    indicator.parameters:addInteger("L", "Long periods", "", 50, 2, 10000); 
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");

 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrSCHTC", "Color of the line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local firstmcd = 0;
local firstst = 0;
local first = 0;
local Method = nil;
local S = 0;
local L = 0;
local C = 0;
local source = nil;
local out = nil;
local mas, mal, mast;
local st, mcd

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    S = instance.parameters.S;
    L = instance.parameters.L;
    C = instance.parameters.C;
    Method = instance.parameters.Method;

    assert(S < L, "Short Period Length must be less than Long Period Length");
    assert(C < L, "Cycle Periods must be less than Long Period Length");
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

    local name = profile:id() .. "(" .. source:name() .. "," .. C .. "," .. S .. "," .. L .. "," .. Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    mas = core.indicators:create("AVERAGES", source, Method, S);
    mal = core.indicators:create("AVERAGES", source, Method,L);

    firstmcd = mal.DATA:first();
    mcd = instance:addInternalStream(firstmcd, 0);
    firstst = firstmcd + C;
    st = instance:addInternalStream(firstst, 0);

    mast = core.indicators:create("AVERAGES", st,  Method,C / 2);
    first = mast.DATA:first();
    out = instance:addStream("SCHTC", core.Line, name, "SCHTC", instance.parameters.clrSCHTC,  first)
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
	
	out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
end

-- calculate the value
function Update(period, mode)
    if (period >= firstmcd) then
        mas:update(mode);
        mal:update(mode);
        mcd[period] = mas.DATA[period] - mal.DATA[period];
    end
    if (period >= firstst) then
 
        local min, max = mathex.minmax(mcd, period-C+1, period);
        
        st[period] = (mcd[period] - min) / (max - min) * 100;
    end
    if (period > first) then
        mast:update(mode);
        out[period] = mast.DATA[period];
    end
end

