-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60375
-- Id: 11258

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
    indicator:name("bbhisto oscillator");
    indicator:description("bbhisto oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP dots color", "UP dots color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr", "DN dots color", "DN dots color", core.rgb(255, 0, 128));
    indicator.parameters:addInteger("DotSize", "Dots size", "", 3);
end

local first;
local source = nil;
local Period;
local bb=nil;
local Dots=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    bb = instance:addStream("bb", core.Bar, name .. ".bb", "bb", instance.parameters.clr, first);
    bb:setPrecision(math.max(2, instance.source:getPrecision()));
    Dots = instance:addStream("Dots", core.Dot, name .. ".Dots", "Dots", instance.parameters.UPclr, first);
    Dots:setPrecision(math.max(2, instance.source:getPrecision()));
    Dots:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first then
    local d=mathex.stdev(source, period-Period+1, period);
    d=math.max(d, 0.0001);
    local ma=mathex.avg(source, period-Period+1, period);
    bb[period]=(source[period]+2*d-ma)/(3*d)-0.6667;
    if bb[period]>0 then
     Dots[period]=1;
     Dots:setColor(period, instance.parameters.UPclr);
    elseif bb[period]<0 then
     Dots[period]=-1;
     Dots:setColor(period, instance.parameters.DNclr);
    else
     Dots[period]=nil;
    end
   end 
end

