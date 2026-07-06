-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22108
-- Id: 7106

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
    indicator:name("T3 Clean indicator");
    indicator:description("T3 Clean indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addDouble("b", "b", "", 0.618);

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
local ae1, ae2, ae3, ae4, ae5, ae6;
local c1, c2, c3, c4;
local w1, w2;
local T3=nil;

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
    ae1=instance:addInternalStream(first, 0);
    ae2=instance:addInternalStream(first, 0);
    ae3=instance:addInternalStream(first, 0);
    ae4=instance:addInternalStream(first, 0);
    ae5=instance:addInternalStream(first, 0);
    ae6=instance:addInternalStream(first, 0);
    T3 = instance:addStream("T3", core.Line, name .. ".T3", "T3", instance.parameters.clr, first);
    T3:setWidth(instance.parameters.widthLinReg);
    T3:setStyle(instance.parameters.styleLinReg);
    local b2=b*b;
    local b3=b*b2;
    c1=-b3;
    c2=3*(b2+b3);
    c3=-3*(2*b2+b+b3);
    c4=1+3*b+b3+3*b2;
    w1=4/(Period+3);
    w2=1-w1;
end

function Update(period, mode)
   if (period>first) then
    ae1[period]=w1*source[period]+w2*ae1[period-1];
    ae2[period]=w1*ae1[period]+w2*ae2[period-1];
    ae3[period]=w1*ae2[period]+w2*ae3[period-1];
    ae4[period]=w1*ae3[period]+w2*ae4[period-1];
    ae5[period]=w1*ae4[period]+w2*ae5[period-1];
    ae6[period]=w1*ae5[period]+w2*ae6[period-1];
    T3[period]=c1*ae6[period]+c2*ae5[period]+c3*ae4[period]+c4*ae3[period];
   elseif period==first then
    ae1[period]=0;
    ae2[period]=0;
    ae3[period]=0;
    ae4[period]=0;
    ae5[period]=0;
    ae6[period]=0;
    T3[period]=nil;
   end 
end

