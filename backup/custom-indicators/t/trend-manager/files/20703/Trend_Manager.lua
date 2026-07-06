-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9709

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
    indicator:name("TrendManager indicator");
    indicator:description("TrendManager indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("DVLimit", "DV limit", "", 10);
    indicator.parameters:addInteger("FastPeriod", "Period of fast MA", "", 23);
    indicator.parameters:addString("FastPrice", "Price of fast MA", "", "close");
    indicator.parameters:addStringAlternative("FastPrice", "close", "", "close");
    indicator.parameters:addStringAlternative("FastPrice", "open", "", "open");
    indicator.parameters:addStringAlternative("FastPrice", "high", "", "high");
    indicator.parameters:addStringAlternative("FastPrice", "low", "", "low");
    indicator.parameters:addStringAlternative("FastPrice", "median", "", "median");
    indicator.parameters:addStringAlternative("FastPrice", "typical", "", "typical");
    indicator.parameters:addStringAlternative("FastPrice", "weighted", "", "weighted");
    indicator.parameters:addString("FastMethod", "Method of fast MA", "", "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("FastMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("FastMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("FastMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("FastMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("FastMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("FastMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("FastMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("FastMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("FastMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("FastMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("FastMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("FastMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("FastMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("FastMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("FastMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("FastMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("FastMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("FastMethod", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("SlowPeriod", "Period of slow MA", "", 84);
    indicator.parameters:addString("SlowPrice", "Price of slow MA", "", "close");
    indicator.parameters:addStringAlternative("SlowPrice", "close", "", "close");
    indicator.parameters:addStringAlternative("SlowPrice", "open", "", "open");
    indicator.parameters:addStringAlternative("SlowPrice", "high", "", "high");
    indicator.parameters:addStringAlternative("SlowPrice", "low", "", "low");
    indicator.parameters:addStringAlternative("SlowPrice", "median", "", "median");
    indicator.parameters:addStringAlternative("SlowPrice", "typical", "", "typical");
    indicator.parameters:addStringAlternative("SlowPrice", "weighted", "", "weighted");
    indicator.parameters:addString("SlowMethod", "Method of slow MA", "", "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SlowMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SlowMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SlowMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SlowMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SlowMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SlowMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SlowMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SlowMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SlowMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SlowMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SlowMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SlowMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SlowMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SlowMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SlowMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SlowMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SlowMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SlowMethod", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local DVLimit;
local FastPeriod;
local FastPrice;
local FastMethod;
local SlowPeriod;
local SlowPrice;
local SlowMethod;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local SlowMA;
local FastMA;
local DVLimitPips;

function TickPrice(PriceType)
 if PriceType=="close" then
  return source.close;
 elseif PriceType=="open" then
  return source.open;
 elseif PriceType=="high" then
  return source.high;
 elseif PriceType=="low" then
  return source.low;
 elseif PriceType=="median" then
  return source.median;
 elseif PriceType=="typical" then
  return source.typical;
 else
  return source.weighted;
 end 
end

function Prepare(nameOnly)
    source = instance.source;
    DVLimit=instance.parameters.DVLimit;
    FastPeriod=instance.parameters.FastPeriod;
    FastPrice=instance.parameters.FastPrice;
    FastMethod=instance.parameters.FastMethod;
    SlowPeriod=instance.parameters.SlowPeriod;
    SlowPrice=instance.parameters.SlowPrice;
    SlowMethod=instance.parameters.SlowMethod;
   
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.DVLimit .. ", " .. instance.parameters.FastPeriod .. ", " .. instance.parameters.FastPrice .. ", " .. instance.parameters.FastMethod .. ", " .. instance.parameters.SlowPeriod .. ", " .. instance.parameters.SlowPrice .. ", " .. instance.parameters.SlowMethod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    FastMA = core.indicators:create("AVERAGES", TickPrice(FastPrice), FastMethod, FastPeriod, false);
    SlowMA = core.indicators:create("AVERAGES", TickPrice(SlowPrice), SlowMethod, SlowPeriod, false);
	
	first = math.max(FastMA.DATA:first(), SlowMA.DATA:first());
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("TrendManager", "TrendManager", open, high, low, close);
    DVLimitPips=DVLimit*source:pipSize();
end

function Update(period, mode)
   if (period>first) then
    FastMA:update(mode);
    SlowMA:update(mode);
    local D=FastMA.DATA[period]-SlowMA.DATA[period];
    if D>=DVLimitPips then
     open[period]=source.high[period];
     close[period]=source.high[period]+D-DVLimitPips;
     high[period]=source.high[period]+D-DVLimitPips;
     low[period]=source.high[period];
     open:setColor(period,instance.parameters.UPclr);
    elseif D<=-DVLimitPips then
     open[period]=source.low[period];
     close[period]=source.low[period]+D-DVLimitPips;
     high[period]=source.low[period];
     low[period]=source.low[period]+D-DVLimitPips;
     open:setColor(period,instance.parameters.DNclr);
    end
   end 
end

