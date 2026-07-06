-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12839
-- Id: 5738

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("MACD with gaussian filter");
    indicator:description("MACD with gaussian filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastPeriod", "FastPeriod", "", 12);
    indicator.parameters:addInteger("SlowPeriod", "SlowPeriod", "", 26);
    indicator.parameters:addInteger("SignalPeriod", "SignalPeriod", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_Clr", "MACD Color", "MACD Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Signal_Clr", "Signal Color", "Signal Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Hist_Clr", "Histogram Color", "Histogram Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local FastPeriod;
local SlowPeriod;
local SignalPeriod;
local FastMA;
local SlowMA;
local MACD=nil;
local Signal=nil;
local Histogram=nil;
local pFast={};
local pSlow={};
local pSig={};

function InitParams(Period)
 local p={};
 p.Period=Period;
 local w=2*math.pi/Period;
 local beta=(1-math.cos(w))/(math.pow(2,1/3)-1);
 local Alpha=-beta+math.sqrt(beta*(beta+2));
 p.p1=math.pow(Alpha,4);
 p.p2=4*(1-Alpha);
 p.p3=6*math.pow(1-Alpha,2);
 p.p4=4*math.pow(1-Alpha,3);
 p.p5=math.pow(1-Alpha,4);
 return p;
end

function Gauss(st,s,period,p)
 return p.p1*s[period-1]+p.p2*st[period-1]-p.p3*st[period-2]+p.p4*st[period-3]-p.p5*st[period-4];
end

function Prepare(nameOnly)
    source = instance.source;
    FastPeriod=instance.parameters.FastPeriod;
    SlowPeriod=instance.parameters.SlowPeriod;
    SignalPeriod=instance.parameters.SignalPeriod;
    first = source:first()+5;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastPeriod .. ", " .. instance.parameters.SlowPeriod .. ", " .. instance.parameters.SignalPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    FastMA=instance:addInternalStream(first, 0);
    SlowMA=instance:addInternalStream(first, 0);
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_Clr, first);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_Clr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Hist_Clr, first);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
    pFast=InitParams(FastPeriod);
    pSlow=InitParams(SlowPeriod);
    pSig=InitParams(SignalPeriod);
end

function Update(period, mode)
   if (period>first) then
    FastMA[period]=Gauss(FastMA,source,period,pFast);
    SlowMA[period]=Gauss(SlowMA,source,period,pSlow);
    MACD[period]=FastMA[period]-SlowMA[period];
    Signal[period]=Gauss(Signal,MACD,period,pSig);
    Histogram[period]=MACD[period]-Signal[period];
   end 
end

