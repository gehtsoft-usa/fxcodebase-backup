-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6513

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
    indicator:name("Tirone levels indicator");
    indicator:description("Tirone levels indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Tirone1=nil;
local Tirone2=nil;
local Tirone3=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Tirone1 = instance:addStream("Tirone1", core.Line, name .. ".Tirone1", "Tirone1", instance.parameters.clr1, first);
    Tirone2 = instance:addStream("Tirone2", core.Line, name .. ".Tirone2", "Tirone2", instance.parameters.clr2, first);
    Tirone3 = instance:addStream("Tirone3", core.Line, name .. ".Tirone3", "Tirone3", instance.parameters.clr3, first);
    Tirone1:setWidth(instance.parameters.widthLinReg);
    Tirone1:setStyle(instance.parameters.styleLinReg);
    Tirone2:setWidth(instance.parameters.widthLinReg);
    Tirone2:setStyle(instance.parameters.styleLinReg);
    Tirone3:setWidth(instance.parameters.widthLinReg);
    Tirone3:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local L, H=core.minmax(source,period-Period+1, period);
    --local L=core.min(source.low,core.rangeTo(period,Period));
    local D=H-L;
    Tirone1[period]=H-D/3;
    Tirone2[period]=L+D/2;
    Tirone3[period]=L+D/3;
   
end

