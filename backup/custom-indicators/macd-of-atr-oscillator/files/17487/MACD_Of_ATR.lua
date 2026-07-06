-- Id: 4927
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7885

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MACD of ATR oscillator");
    indicator:description("MACD of ATR oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortPeriod", "Short ATR period", "", 7);
    indicator.parameters:addInteger("LongPeriod", "Long ATR period", "", 49);
    indicator.parameters:addInteger("SignalPeriod", "Signal MACD period", "", 10);
    indicator.parameters:addString("Method", "Signal method", "", "EMA");
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
    indicator.parameters:addColor("MACD_Clr", "MACD Color", "MACD Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD", "MACD width", "MACD width", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", "MACD style", "MACD style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_Clr", "Signal Color", "Signal Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSignal", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("styleSignal", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSignal", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Histogram_Clr", "Histogram Color", "Histogram Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local ShortPeriod;
local LongPeriod;
local SignalPeriod;
local Method;
local Short_ATR;
local Long_ATR;
local MACD=nil;
local Signal=nil;
local Histogram=nil;
local MA;

function Prepare(nameOnly)
    source = instance.source;
    ShortPeriod=instance.parameters.ShortPeriod;
    LongPeriod=instance.parameters.LongPeriod;
    SignalPeriod=instance.parameters.SignalPeriod;
    Method=instance.parameters.Method;
  
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ShortPeriod .. ", " .. instance.parameters.LongPeriod .. ", " .. instance.parameters.SignalPeriod .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Short_ATR = core.indicators:create("ATR", source, ShortPeriod);
    Long_ATR = core.indicators:create("ATR", source, LongPeriod);
	
	first = math.max(Short_ATR.DATA:first(), Long_ATR.DATA:first());
	
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_Clr, first);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_Clr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.widthSignal);
    Signal:setStyle(instance.parameters.styleSignal);
    Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Histogram_Clr, first);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
    MA = core.indicators:create("AVERAGES", MACD, Method, SignalPeriod, false);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    Short_ATR:update(mode);
    Long_ATR:update(mode);
    MACD[period]=Short_ATR.DATA[period]-Long_ATR.DATA[period];
    MA:update(mode);
    Signal[period]=MA.DATA[period];
    Histogram[period]=MACD[period]-Signal[period];
   
end

