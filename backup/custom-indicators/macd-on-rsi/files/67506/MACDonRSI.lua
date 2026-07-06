-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41286
-- Id: 9323

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
    indicator:name("MACDonRSI oscillator");
    indicator:description("MACDonRSI oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "MA period", "", 13);
    indicator.parameters:addString("MA_Method", "MA method", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 14);
    indicator.parameters:addInteger("Fast_MACD_Period", "Fast MACD period", "", 12);
    indicator.parameters:addInteger("Slow_MACD_Period", "Slow MACD period", "", 26);
    indicator.parameters:addInteger("Signal_MACD_Period", "Signal MACD period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PUclr", "Positive UP color", "Positive UP color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("PDclr", "Positive DN color", "Positive DN color", core.rgb(128, 128, 255));
    indicator.parameters:addColor("NUclr", "Negative UP color", "Negative UP color", core.rgb(255, 128, 0));
    indicator.parameters:addColor("NDclr", "Negative DN color", "Negative DN color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("RSIclr", "RSI color", "RSI color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("RSIwidth", "RSI width", "RSI width", 1, 1, 5);
    indicator.parameters:addInteger("RSIstyle", "RSI style", "RSI style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Swidth", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA_Period;
local MA_Method;
local RSI_Period;
local Fast_MACD_Period;
local Slow_MACD_Period;
local Signal_MACD_Period;
local MA;
local RSI;
local MACD;
local RSIbuff=nil;
local Signalbuff=nil;
local Histbuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    RSI_Period=instance.parameters.RSI_Period;
    Fast_MACD_Period=instance.parameters.Fast_MACD_Period;
    Slow_MACD_Period=instance.parameters.Slow_MACD_Period;
    Signal_MACD_Period=instance.parameters.Signal_MACD_Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.Fast_MACD_Period .. ", " .. instance.parameters.Slow_MACD_Period .. ", " .. instance.parameters.Signal_MACD_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
   
    MA = core.indicators:create("AVERAGES", source, MA_Method, MA_Period, false);
    RSI = core.indicators:create("RSI", MA.DATA, RSI_Period);
    MACD = core.indicators:create("MACD", RSI.DATA, Fast_MACD_Period, Slow_MACD_Period, Signal_MACD_Perios);
	
	 first =  MACD.SIGNAL:first();
    RSIbuff = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
    RSIbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    RSIbuff:setWidth(instance.parameters.RSIwidth);
    RSIbuff:setStyle(instance.parameters.RSIstyle);
    Signalbuff = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, first);
    Signalbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Signalbuff:setWidth(instance.parameters.Swidth);
    Signalbuff:setStyle(instance.parameters.Sstyle);
    Histbuff = instance:addStream("Hist", core.Bar, name .. ".Hist", "Hist", instance.parameters.PUclr, first);
    Histbuff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
  
   
    MA:update(mode);
    RSI:update(mode);
    MACD:update(mode);
	
	 if period<first then
   return;
   end
   
   
    RSIbuff[period]=RSI.DATA[period];
    Histbuff[period]=MACD.MACD[period]*8;
    Signalbuff[period]=MACD.SIGNAL[period]*8;
    if Histbuff[period]>0 then
     if Histbuff[period]>Histbuff[period-1] then
      Histbuff:setColor(period, instance.parameters.PUclr);
     else
      Histbuff:setColor(period, instance.parameters.PDclr);
     end
    else
     if Histbuff[period]>Histbuff[period-1] then
      Histbuff:setColor(period, instance.parameters.NUclr);
     else
      Histbuff:setColor(period, instance.parameters.NDclr);
     end
    end
  
end

