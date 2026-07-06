-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59586
-- Id: 10084

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
    indicator:name("Neo parabolic indicator");
    indicator:description("Neo parabolic indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper channel color", "Upper channel color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Uwidth", "Upper channel width", "Upper channel width", 1, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper channel style", "Upper channel style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower channel color", "Lower channel color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Lwidth", "Lower channel width", "Lower channel width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower channel style", "Lower channel style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Upper=nil;
local Lower=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
end

function Update(period, mode)
   if period>first then
    local Min, Max = 0, 0;
    local i;
    local Lowest, Highest;
    for i=1, Period, 1 do
     Lowest, Highest = mathex.minmax(source, period-i+1, period); 
     Min=Min+Lowest;
     Max=Max+Highest;
    end
    Upper[period]=Max/Period;
    Lower[period]=Min/Period;
   end 
end

