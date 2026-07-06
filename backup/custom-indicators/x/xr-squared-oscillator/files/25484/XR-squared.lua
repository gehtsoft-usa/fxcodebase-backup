-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13035
-- Id: 5791

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("XR-squared oscillator");
    indicator:description("XR-squared oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "Period of MA", "", 3);
    indicator.parameters:addString("MA_Method", "Method of MA", "", "MVA");
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
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addInteger("Signal_Period", "Signal Period", "", 21);
    indicator.parameters:addString("Signal_Method", "Signal Method", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Sclr", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA_Period;
local MA_Method;
local Period;
local Signal_Period;
local Signal_Method;
local MA;
local Signal_MA;
local XR=nil;
local Signal=nil;
local SumX;
local SumX2;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    Period=instance.parameters.Period;
    Signal_Period=instance.parameters.Signal_Period;
    Signal_Method=instance.parameters.Signal_Method;
    
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Signal_Method .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    MA = core.indicators:create("AVERAGES", source, MA_Method, MA_Period, false);
    XR = instance:addStream("XR", core.Line, name .. ".XR", "XR", instance.parameters.clr,   MA.DATA:first());
    XR:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal_MA = core.indicators:create("AVERAGES", XR, Signal_Method, Signal_Period, false);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, Signal_MA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    SumX=(Period+1)*Period/2;
    SumX2=Period*(Period+1)*(2*Period+1)/6;
    XR:setWidth(instance.parameters.widthLinReg);
    XR:setStyle(instance.parameters.styleLinReg);
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<MA.DATA:first())then
   return;
   end
   
   
    MA:update(mode);
    local SumY=0;
    local SumY2=0;
    local SumXY=0;
    local i;
    for i=1,Period,1 do
     SumY=SumY+MA.DATA[period-i+1];
     SumY2=SumY2+MA.DATA[period-i+1]*MA.DATA[period-i+1];
     SumXY=SumXY+MA.DATA[period-i+1]*i;
    end
    local Q1=SumXY-SumX*SumY/Period;
    local Q2=SumX2-SumX*SumX/Period;
    local Q3=SumY2-SumY*SumY/Period;
    XR[period]=100*Q1*Q1/(Q2*Q3);
	
	if (period<Signal_MA.DATA:first())then
   return;
   end
   
    Signal_MA:update(mode);
    Signal[period]=Signal_MA.DATA[period];
  
end

