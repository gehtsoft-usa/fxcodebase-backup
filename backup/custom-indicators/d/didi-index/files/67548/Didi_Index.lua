-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41319
-- Id: 9361

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Didi index oscillator");
    indicator:description("Didi index oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CurtaPeriod", "Curta period", "", 3);
    indicator.parameters:addInteger("MediaPeriod", "Media period", "", 8);
    indicator.parameters:addInteger("LongaPeriod", "Longa period", "", 20);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Cclr", "Curta color", "Curta color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Cwidth", "Curta width", "Curta width", 1, 1, 5);
    indicator.parameters:addInteger("Cstyle", "Curta style", "Curta style", core.LINE_SOLID);
    indicator.parameters:setFlag("Cstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Mclr", "Media color", "Media color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Mwidth", "Media width", "Media width", 1, 1, 5);
    indicator.parameters:addInteger("Mstyle", "Media style", "Media style", core.LINE_SOLID);
    indicator.parameters:setFlag("Mstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Longa color", "Longa color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Lwidth", "Longa width", "Longa width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Longa style", "Longa style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local CurtaPeriod;
local MediaPeriod;
local LongaPeriod;
local Method;
local C_MA, M_MA, L_MA;
local Curta=nil;
local Media=nil;
local Longa=nil;

function Prepare(nameOnly)
    source = instance.source;
    CurtaPeriod=instance.parameters.CurtaPeriod;
    MediaPeriod=instance.parameters.MediaPeriod;
    LongaPeriod=instance.parameters.LongaPeriod;
    Method=instance.parameters.Method;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CurtaPeriod .. ", " .. instance.parameters.MediaPeriod .. ", " .. instance.parameters.LongaPeriod .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
    C_MA = core.indicators:create("AVERAGES", source, Method, CurtaPeriod, false);
    M_MA = core.indicators:create("AVERAGES", source, Method, MediaPeriod, false);
    L_MA = core.indicators:create("AVERAGES", source, Method, LongaPeriod, false);
	
	 first = math.max(C_MA.DATA:first(),L_MA.DATA:first(),M_MA.DATA:first())
    Curta = instance:addStream("Curta", core.Line, name .. ".Curta", "Curta", instance.parameters.Cclr, first);
    Curta:setWidth(instance.parameters.Cwidth);
    Curta:setStyle(instance.parameters.Cstyle);
    Media = instance:addStream("Media", core.Line, name .. ".Media", "Media", instance.parameters.Mclr, first);
    Media:setWidth(instance.parameters.Mwidth);
    Media:setStyle(instance.parameters.Mstyle);
    Longa = instance:addStream("Longa", core.Line, name .. ".Longa", "Longa", instance.parameters.Lclr, first);
    Longa:setWidth(instance.parameters.Lwidth);
    Longa:setStyle(instance.parameters.Lstyle);
	
	Curta:setPrecision(math.max(2, instance.source:getPrecision()));
	Media:setPrecision(math.max(2, instance.source:getPrecision()));
	Longa:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    C_MA:update(mode);
    M_MA:update(mode);
    L_MA:update(mode);
    local Med=M_MA.DATA[period];
    if Med>0 then
     Curta[period]=C_MA.DATA[period]/Med;
     Media[period]=1;
     Longa[period]=L_MA.DATA[period]/Med;
    end
   end 
end

