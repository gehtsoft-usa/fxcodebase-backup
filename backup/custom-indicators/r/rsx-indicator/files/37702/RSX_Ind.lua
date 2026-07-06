-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21623
-- Id: 7094

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
    indicator:name("RSX indicator");
    indicator:description("RSX indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local RSX=nil;
local a, a1, a2, b, b1, b2, c, c1, c2, d, e1, e2, f, f1, f2, g, g1, g2, h;
local k1, k2;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    a1 = instance:addInternalStream(first, 0);
    a2 = instance:addInternalStream(first, 0);
    b1 = instance:addInternalStream(first, 0);
    b2 = instance:addInternalStream(first, 0);
    c1 = instance:addInternalStream(first, 0);
    c2 = instance:addInternalStream(first, 0);
    e1 = instance:addInternalStream(first, 0);
    e2 = instance:addInternalStream(first, 0);
    f1 = instance:addInternalStream(first, 0);
    f2 = instance:addInternalStream(first, 0);
    g1 = instance:addInternalStream(first, 0);
    g2 = instance:addInternalStream(first, 0);
    RSX = instance:addStream("RSX", core.Line, name .. ".RSX", "RSX", instance.parameters.clr, first);
    RSX:setPrecision(math.max(2, instance.source:getPrecision()));
    RSX:setWidth(instance.parameters.widthLinReg);
    RSX:setStyle(instance.parameters.styleLinReg);
    RSX:addLevel(30);
    RSX:addLevel(50);
    RSX:addLevel(70);
    k2=3/(Period+2);
    k1=1-k2;
end

function Update(period, mode)
   if period>first then
    local a=100*(source[period]-source[period-1]);
    a1[period]=k1*a1[period-1]+k2*a;
    a2[period]=k1*a2[period-1]+k2*a1[period];
    b=1.5*a1[period]-0.5*a2[period];
    
    b1[period]=k1*b1[period-1]+k2*b;
    b2[period]=k1*b2[period-1]+k2*b1[period];
    c=1.5*b1[period]-0.5*b2[period];
    
    c1[period]=k1*c1[period-1]+k2*c;
    c2[period]=k1*c2[period-1]+k2*c1[period];
    d=1.5*c1[period]-0.5*c2[period];
    
    e1[period]=k1*e1[period-1]+k2*math.abs(a);
    e2[period]=k1*e2[period-1]+k2*e1[period];
    f=1.5*e1[period]-0.5*e2[period];
    
    f1[period]=k1*f1[period-1]+k2*f;
    f2[period]=k1*f2[period-1]+k2*f1[period];
    g=1.5*f1[period]-0.5*f2[period];
    
    g1[period]=k1*g1[period-1]+k2*g;
    g2[period]=k1*g2[period-1]+k2*g1[period];
    h=1.5*g1[period]-0.5*g2[period];
    
    if h~=0 then
     RSX[period]=(d/h+1)*50;
    end 
   elseif period==first then 
    a1[period]=0;
    a2[period]=0;
    b1[period]=0;
    b2[period]=0;
    c1[period]=0;
    c2[period]=0;
    e1[period]=0;
    e2[period]=0;
    f1[period]=0;
    f2[period]=0;
    g1[period]=0;
    g2[period]=0;
   end 
end

