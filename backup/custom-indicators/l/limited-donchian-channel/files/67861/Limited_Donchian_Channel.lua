-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41579
-- Id: 9400

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
    indicator:name("Limited Donchian channel");
    indicator:description("Limited Donchian channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addInteger("Distance", "Distance", "", 300);
    indicator.parameters:addBoolean("Fixed", "Fixed", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper line color", "Upper line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Uwidth", "Upper line width", "Upper line width", 2, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper line style", "Upper line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Mclr", "Middle line color", "Middle line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Mwidth", "Middle line width", "Middle line width", 1, 1, 5);
    indicator.parameters:addInteger("Mstyle", "Middle line style", "Middle line style", core.LINE_DASH);
    indicator.parameters:setFlag("Mstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower line color", "Lower line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Lwidth", "Lower line width", "Lower line width", 2, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower line style", "Lower line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Distance;
local Fixed;
local PDistance;
local Upper=nil;
local Middle=nil;
local Lower=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Distance=instance.parameters.Distance;
    Fixed=instance.parameters.Fixed;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Distance .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Middle = instance:addStream("Middle", core.Line, name .. ".Middle", "Middle", instance.parameters.Mclr, first);
    Middle:setWidth(instance.parameters.Mwidth);
    Middle:setStyle(instance.parameters.Mstyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
    PDistance=Distance*source:pipSize();
end

function Update(period, mode)
   if period>first then
    if source.high[period]>Upper[period-1] then
     Upper[period]=source.high[period];
     if Upper[period]-Lower[period-1]>PDistance then
      Lower[period]=Upper[period]-PDistance;
     else
      Lower[period]=Lower[period-1];
     end
    elseif source.low[period]<Lower[period-1] then
     Lower[period]=source.low[period];
     if Upper[period-1]-Lower[period]>PDistance then
      Upper[period]=Lower[period]+PDistance;
     else
      Upper[period]=Upper[period-1];
     end
    else
     Upper[period]=Upper[period-1];
     Lower[period]=Lower[period-1];
    end
    if not(Fixed) then
     local Min, Max = mathex.minmax(source, period-Period+1, period);
     if Upper[period]>Max then
      Upper[period]=Max;
     end
     if Lower[period]<Min then
      Lower[period]=Min;
     end
    end
    Middle[period]=(Upper[period]+Lower[period])/2;
   end 
end

