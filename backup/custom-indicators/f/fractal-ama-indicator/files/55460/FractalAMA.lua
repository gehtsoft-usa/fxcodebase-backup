-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32559
-- Id: 8650

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
    indicator:name("Fractal AMA indicator");
    indicator:description("Fractal AMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 16);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 5);
    indicator.parameters:addDouble("SMultiplier", "Signal multiplier", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Aclr", "AMA color", "AMA color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Awidth", "AMA width", "AMA width", 1, 1, 5);
    indicator.parameters:addInteger("Astyle", "AMA style", "AMA style", core.LINE_SOLID);
    indicator.parameters:setFlag("Astyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("Swidth", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Signal style", "Signal style", core.LINE_DASH);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Multiplier;
local SMultiplier;
local AMA=nil;
local Signal=nil;
local n2;
local log2;

function Prepare(nameOnly)
    source = instance.source;
    n2=math.floor(instance.parameters.Period/2);
    n2=math.max(n2, 1);
    Period=n2*2;
    Multiplier=instance.parameters.Multiplier;
    SMultiplier=instance.parameters.SMultiplier;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Multiplier .. ", " .. instance.parameters.SMultiplier .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    AMA = instance:addStream("AMA", core.Line, name .. ".AMA", "AMA", instance.parameters.Aclr, first);
    AMA:setWidth(instance.parameters.Awidth);
    AMA:setStyle(instance.parameters.Astyle);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, first);
    Signal:setWidth(instance.parameters.Swidth);
    Signal:setStyle(instance.parameters.Sstyle);
    n2=math.floor(Period/2);
    log2=1/math.log(2);
end

function Range(index1, index2)
 return mathex.max(source.high, index1, index2)-mathex.min(source.low, index1, index2);
end

function Update(period, mode)

   if period<first then
   return;
   end
   
    local R3=Range(period-Period+1, period)/Period;
    local R1=Range(period-n2+1, period)/n2;
    local R2=Range(period-Period+1, period-n2)/n2;
    local DE=(math.log(R1+R2)-math.log(R3))*log2;
    local Alpha=math.exp(-Multiplier*(DE-1));
    local Alphas=math.exp(-SMultiplier*(DE-1));
    Alpha=math.min(math.max(Alpha, 0.01), 1);
    AMA[period]=Alpha*source.close[period]+(1-Alpha)*AMA[period-1];
    Signal[period]=Alphas*AMA[period]+(1-Alphas)*Signal[period-1];
 
end

