-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6397
-- Id: 4563

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
    indicator:name("Historical Volatility indicator");
    indicator:description("Historical Volatility indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 21, 2, 1000);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "High-Low", "", "High-Low");
    indicator.parameters:addDouble("decline", "decline", "", 0.94, 0, 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Method;
local decline;
local horizon;
local HV=nil;
local Coeff;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    decline=instance.parameters.decline;
    horizon=instance.parameters.horizon;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.decline .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    HV = instance:addStream("HV", core.Line, name .. ".HV", "HV", instance.parameters.clr, first);
    HV:setPrecision(math.max(2, instance.source:getPrecision()));
    Coeff=4*math.log(2);
end

function Update(period, mode)
   if (period>first) then
    local i;
    local hlhv=0;
    local tshv=0;
    for i=period,period-Period+1,-1 do
     hlhv=hlhv+math.pow(math.log(source.high[i]/source.low[i]),2)/Coeff;
     tshv=tshv+math.log(source.close[i]/source.close[i-1]);
    end
    hlhv=math.sqrt(hlhv/Period);
    tshv=tshv/Period;
    local shv=0;
    for i=period,period-Period+1,-1 do
     shv=shv+math.pow((tshv-math.log(source.close[i]/source.close[i-1])),2);
    end
    shv=math.sqrt(shv/(Period-1));
    ehv=math.sqrt((1-decline)*shv);
    if Method=="MVA" then
     HV[period]=shv;
    elseif Method=="EMA" then
     HV[period]=ehv;
    else
     HV[period]=hlhv;
    end
   end 
end

