-- Id: 5427
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10495

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
    indicator:name("SinTrend indicator");
    indicator:description("SinTrend indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local SinTrend=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SinTrend = instance:addStream("SinTrend", core.Bar, name .. ".SinTrend", "SinTrend", instance.parameters.UPclr, first);
    SinTrend:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    SinTrend[period]=math.sin((source[period]-source[period-Period])/Period);
    if SinTrend[period]>0 then
     SinTrend:setColor(period,instance.parameters.UPclr);
    else
     SinTrend:setColor(period,instance.parameters.DNclr);
    end
   end 
end

