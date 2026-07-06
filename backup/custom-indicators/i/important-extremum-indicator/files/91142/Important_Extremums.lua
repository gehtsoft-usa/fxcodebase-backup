-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59987
-- Id: 10535

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
    indicator:name("Important Extremums indicator");
    indicator:description("Important Extremums indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Period;
local UP=nil;
local DN=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UP = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Dot, name .. ".DN", "DN", instance.parameters.DNclr, first);
    UP:setWidth(instance.parameters.DotSize);
    DN:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first then
    if source.high[period-1]>=mathex.max(source.high, period-Period-1, period-2) and source.high[period-1]>source.high[period] then
     UP[period-1]=source.high[period-1];
    else
     UP[period-1]=nil;
    end

    if source.low[period-1]<=mathex.min(source.low, period-Period-1, period-2) and source.low[period-1]<source.low[period] then
     DN[period-1]=source.low[period-1];
    else
     DN[period-1]=nil;
    end
   end 
end

