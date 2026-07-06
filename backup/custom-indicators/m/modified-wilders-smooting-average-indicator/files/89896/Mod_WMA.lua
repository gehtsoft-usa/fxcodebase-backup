-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59622
-- Id: 10171

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
    indicator:name("Modified Wilders smooting average indicator");
    indicator:description("Modified Wilders smooting average indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local k;
local Mod_WMA=nil

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Mod_WMA = instance:addStream("Mod_WMA", core.Line, name .. ".Mod_WMA", "Mod_WMA", instance.parameters.clr, first+Period);
    Mod_WMA:setWidth(instance.parameters.widthLinReg);
    Mod_WMA:setStyle(instance.parameters.styleLinReg);
    k=1/Period;
end

function Update(period, mode)
   if period>first+Period then
    Mod_WMA[period]=(mathex.avg(source, period-Period + 1, period)-Mod_WMA[period-1])*k+Mod_WMA[period-1];
   elseif period==first+Period then
    Mod_WMA[period]=mathex.avg(source, period-Period + 1, period);
   end 
end

