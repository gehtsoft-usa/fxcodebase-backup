-- More information about this indicator can be found at:
-- hhttp://fxcodebase.com/code/viewtopic.php?f=17&t=41318
-- Id: 9358

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
    indicator:name("Cronex_Impulse_CD_Color oscillator");
    indicator:description("Cronex_Impulse_CD_Color oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
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
    indicator.parameters:addInteger("FastPeriod", "Fast period", "", 12);
    indicator.parameters:addInteger("SlowPeriod", "Slow period", "", 26);
    indicator.parameters:addString("SignalMethod", "Signal method", "", "MVA");
    indicator.parameters:addStringAlternative("SignalMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SignalMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SignalMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SignalMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SignalMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SignalMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SignalMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SignalMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SignalMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SignalMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SignalMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SignalMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SignalMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SignalMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SignalMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SignalMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SignalMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SignalMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SignalMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("SignalPeriod", "Signal period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACDclr", "MACD color", "MACD color", core.rgb(128, 128, 255));
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("Swidth", "Signal line width", "Signal line width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Signal line style", "Signal line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Uclr", "Upper color", "Upper color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Lclr", "Lower color", "Lower color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Method;
local FastPeriod;
local SlowPeriod;
local SignalMethod;
local SignalPeriod;
local FastMA;
local SlowMA_H, SlowMA_L;
local SignalMA;
local MACD=nil;
local Signal=nil;
local Divr=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    FastPeriod=instance.parameters.FastPeriod;
    SlowPeriod=instance.parameters.SlowPeriod;
    SignalMethod=instance.parameters.SignalMethod;
    SignalPeriod=instance.parameters.SignalPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.FastPeriod .. ", " .. instance.parameters.SlowPeriod .. ", " .. instance.parameters.SignalMethod .. ", " .. instance.parameters.SignalPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    FastMA = core.indicators:create("AVERAGES", source.weighted, Method, FastPeriod, false);
    SlowMA_H = core.indicators:create("AVERAGES", source.high, Method, SlowPeriod, false);
    SlowMA_L = core.indicators:create("AVERAGES", source.low, Method, SlowPeriod, false);
	first = math.max(FastMA.DATA:first(),SlowMA_L.DATA:first());
    MACD = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.MACDclr, first);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, first);
    Signal:setWidth(instance.parameters.Swidth);
    Signal:setStyle(instance.parameters.Sstyle);
    Divr = instance:addStream("Divr", core.Bar, name .. ".Divr", "Divr", instance.parameters.Uclr, first);
    SignalMA = core.indicators:create("AVERAGES", MACD, SignalMethod, SignalPeriod, false);
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));	
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));	
	Divr:setPrecision(math.max(2, instance.source:getPrecision()));	
end

function Update(period, mode)
   if period>first then
    FastMA:update(mode);
    SlowMA_H:update(mode);
    SlowMA_L:update(mode);
    if FastMA.DATA[period]>SlowMA_H.DATA[period] then
     MACD[period]=FastMA.DATA[period]-SlowMA_H.DATA[period];
    elseif FastMA.DATA[period]<SlowMA_L.DATA[period] then
     MACD[period]=FastMA.DATA[period]-SlowMA_L.DATA[period];
    else
     MACD[period]=0;
    end
    SignalMA:update(mode);
    Signal[period]=SignalMA.DATA[period];
    Divr[period]=MACD[period]-Signal[period];
    if Divr[period]>=Divr[period-1] then
     Divr:setColor(period, instance.parameters.Uclr);
    else
     Divr:setColor(period, instance.parameters.Lclr);
    end
   end 
end

