-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60365
-- Id: 11238

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
    indicator:name("T3_iAnchMom oscillator");
    indicator:description("T3_iAnchMom oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMA_Period", "EMA period", "", 3);
    indicator.parameters:addInteger("Mom_Period", "Momentum period", "", 8);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Output", "Output method", "", "Dots");
    indicator.parameters:addStringAlternative("Output", "Line", "", "Line");
    indicator.parameters:addStringAlternative("Output", "Dots", "", "Dots");
    indicator.parameters:addColor("clr1", "Positive Up color", "Positive Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Positive Dn color", "Positive Dn color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Negative Up color", "Negative Up color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr4", "Negative Dn color", "Negative Dn color", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width (Dot size)", "Line width (Dot size)", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local EMA_Period;
local Mom_Period;
local w1, w2, w3, w4, c1, c2, c3, c4;
local e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12;
local Mom=nil;

function Prepare(nameOnly)
    source = instance.source;
    EMA_Period=instance.parameters.EMA_Period;
    Mom_Period=instance.parameters.Mom_Period;
    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.EMA_Period .. ", " .. instance.parameters.Mom_Period .. ")";
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
    e7 = instance:addInternalStream(first, 0);
    e8 = instance:addInternalStream(first, 0);
    e9 = instance:addInternalStream(first, 0);
    e10 = instance:addInternalStream(first, 0);
    e11 = instance:addInternalStream(first, 0);
    e12 = instance:addInternalStream(first, 0);
    if instance.parameters.Output=="Line" then
     Mom = instance:addStream("Mom", core.Line, name .. ".Mom", "Mom", instance.parameters.clr1, first);
     Mom:setStyle(instance.parameters.styleLinReg);
    else
     Mom = instance:addStream("Mom", core.Dot, name .. ".Mom", "Mom", instance.parameters.clr1, first);
    end
    Mom:setPrecision(math.max(2, instance.source:getPrecision()));
    Mom:setWidth(instance.parameters.widthLinReg);
     
    local b=0.7;
    local b2=b*b;
    local b3=b2*b;
    c1=-b3;
    c2=3*(b2+b3);
    c3=-3*(2*b2+b+b3);
    c4=1+3*b+b3+3*b2;
    local n=EMA_Period;
    local n1=2*Mom_Period+1;

    if (n<1) then
     n=1;
    end 
    n=1+0.5*(n-1);
    w1=2/(n+1);
    w2=1-w1;
    if (n1<1) then
     n1=1;
    end 
    n1=1+0.5*(n1-1);
    w3=2/(n1+1);
    w4=1-w3;
end

function Update(period, mode)
   if period>first then
    e1[period]=w1*source[period]+w2*e1[period-1];
    e2[period]=w1*e1[period]+w2*e2[period-1];
    e3[period]=w1*e2[period]+w2*e3[period-1];
    e4[period]=w1*e3[period]+w2*e4[period-1];
    e5[period]=w1*e4[period]+w2*e5[period-1];
    e6[period]=w1*e5[period]+w2*e6[period-1];
    local a=c1*e6[period]+c2*e5[period]+c3*e4[period]+c4*e3[period];
    e7[period]=w3*source[period]+w4*e7[period-1];
    e8[period]=w3*e7[period]+w4*e8[period-1];
    e9[period]=w3*e8[period]+w4*e9[period-1];
    e10[period]=w3*e9[period]+w4*e10[period-1];
    e11[period]=w3*e10[period]+w4*e11[period-1];
    e12[period]=w3*e11[period]+w4*e12[period-1];
    local c=c1*e12[period]+c2*e11[period]+c3*e10[period]+c4*e9[period];
    if c~=0 then
     Mom[period]=100*(a/c-1);
    end
    if Mom[period]>0 then
     if Mom[period]>Mom[period-1] then
      Mom:setColor(period, instance.parameters.clr1);
     else
      Mom:setColor(period, instance.parameters.clr2);
     end
    else
     if Mom[period]>Mom[period-1] then
      Mom:setColor(period, instance.parameters.clr3);
     else
      Mom:setColor(period, instance.parameters.clr4);
     end
    end 
   elseif period==first then
    e1[period]=0; 
    e2[period]=0; 
    e3[period]=0; 
    e4[period]=0; 
    e5[period]=0; 
    e6[period]=0; 
    e7[period]=0; 
    e8[period]=0; 
    e9[period]=0; 
    e10[period]=0; 
    e11[period]=0; 
    e12[period]=0; 
   end 
end

