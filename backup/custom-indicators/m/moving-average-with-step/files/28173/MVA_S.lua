-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14876
-- Id: 6079

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
    indicator:name("MVA_S indicator");
    indicator:description("MVA_S indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addInteger("Step", "Step", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Step;
local MVA_S=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Step=instance.parameters.Step;
    first = source:first()+Period*Step;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Step .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MVA_S = instance:addStream("MVA_S", core.Line, name .. ".MVA_S", "MVA_S", instance.parameters.clr, first);
    MVA_S:setWidth(instance.parameters.widthLinReg);
    MVA_S:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    local i;
    local Sum=0;
    for i=0,Period-1,1 do
     Sum=Sum+source[period-i*Step];
    end
    MVA_S[period]=Sum/Period;
   end 
end

