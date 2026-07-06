-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59576
-- Id: 10065

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
    indicator:name("T3 moving average");
    indicator:description("T3 moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("b", "b", "", 0.88);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local b;
local e1, e2, e3, e4, e5, e6;
local T3_MA=nil;
local c1, c2, c3, c4, w1, w2;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    b=instance.parameters.b;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.b .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    e1 = instance:addInternalStream(first, 0);
    e2 = instance:addInternalStream(first, 0);
    e3 = instance:addInternalStream(first, 0);
    e4 = instance:addInternalStream(first, 0);
    e5 = instance:addInternalStream(first, 0);
    e6 = instance:addInternalStream(first, 0);
    T3_MA = instance:addStream("T3_MA", core.Line, name .. ".T3_MA", "T3_MA", instance.parameters.clr, first);
    T3_MA:setWidth(instance.parameters.widthLinReg);
    T3_MA:setStyle(instance.parameters.styleLinReg);
    w1=4/(Period+3);
    w2=1-w1;
    local b2=b*b;
    local b3=b2*b;
    c1=-b3;
    c2=3*(b2+b3);
    c3=-3*(2*b2+b+b3);
    c4=1+3*b+b3+3*b2;
end

function Update(period, mode)
   if period>first then
    e1[period]=w1*source[period]+w2*e1[period-1];
    e2[period]=w1*e1[period]+w2*e2[period-1];
    e3[period]=w1*e2[period]+w2*e3[period-1];
    e4[period]=w1*e3[period]+w2*e4[period-1];
    e5[period]=w1*e4[period]+w2*e5[period-1];
    e6[period]=w1*e5[period]+w2*e6[period-1];
    T3_MA[period]=c1*e6[period]+c2*e5[period]+c3*e4[period]+c4*e3[period];
   end 
end

