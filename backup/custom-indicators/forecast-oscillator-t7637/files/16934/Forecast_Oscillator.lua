-- Id: 4868
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7637

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
    indicator:name("Forecast Oscillator");
    indicator:description("Forecast Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Regress", "Regress", "", 15);
    indicator.parameters:addInteger("t3", "t3", "", 10);
    indicator.parameters:addDouble("b", "b", "", 0.7);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDlo", "Color Dot Lo", "Color Dot Lo", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clrDhi", "Color Dot Hi", "Color Dot Hi", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local Regress;
local t3;
local b;
local osc=nil;
local osct3=nil;
local DotLo=nil;
local DotHi=nil;
local b2,b3,c1,c2,c3,c4,n,w1,w2;
local e1,e2,e3,e4,e5,e6;

function Prepare(nameOnly)
    source = instance.source;
    Regress=instance.parameters.Regress;
    t3=instance.parameters.t3;
    b=instance.parameters.b;
    first = source:first()+Regress;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Regress .. ", " .. instance.parameters.t3 .. ", " .. instance.parameters.b .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    e1=instance:addInternalStream(0, 0);
    e2=instance:addInternalStream(0, 0);
    e3=instance:addInternalStream(0, 0);
    e4=instance:addInternalStream(0, 0);
    e5=instance:addInternalStream(0, 0);
    e6=instance:addInternalStream(0, 0);
    osc = instance:addStream("osc", core.Line, name .. ".osc", "osc", instance.parameters.clr1, first);
    osc:setPrecision(math.max(2, instance.source:getPrecision()));
    osct3 = instance:addStream("osct3", core.Line, name .. ".osct3", "osct3", instance.parameters.clr2, first);
    osct3:setPrecision(math.max(2, instance.source:getPrecision()));
    DotLo = instance:addStream("DotLo", core.Dot, name .. ".DotLo", "DotLo", instance.parameters.clrDlo, first);
    DotLo:setPrecision(math.max(2, instance.source:getPrecision()));
    DotHi = instance:addStream("DotHi", core.Dot, name .. ".DotHi", "DotHi", instance.parameters.clrDhi, first);
    DotHi:setPrecision(math.max(2, instance.source:getPrecision()));
    osc:setWidth(instance.parameters.widthLinReg);
    osc:setStyle(instance.parameters.styleLinReg);
    osct3:setWidth(instance.parameters.widthLinReg);
    osct3:setStyle(instance.parameters.styleLinReg);
    DotLo:setWidth(instance.parameters.DotSize);
    DotHi:setWidth(instance.parameters.DotSize);
    b2=b*b; 
    b3=b2*b; 
    c1=-b3; 
    c2=(3*(b2+b3)); 
    c3=-3*(2*b2+b+b3); 
    c4=(1+3*b+b3+3*b2); 
    n=t3; 
    n=math.max(n,1);
    n = 1 + 0.5*(n-1); 
    w1 = 2 / (n + 1); 
    w2 = 1 - w1; 
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local i;
    local sum=0;
    for i=Regress,1,-1 do
     local tmp=i-(Regress+1)/3;
     sum=sum+tmp*source[period-Regress+i];
    end
    local WT=6*sum/(Regress*(Regress+1));
    local forecastosc=(source[period]-WT)/WT*100;
    
    e1[period]=w1*forecastosc+w2*e1[period-1];
    e2[period]=w1*e1[period]+w2*e2[period-1];
    e3[period]=w1*e2[period]+w2*e3[period-1];
    e4[period]=w1*e3[period]+w2*e4[period-1];
    e5[period]=w1*e4[period]+w2*e5[period-1];
    e6[period]=w1*e5[period]+w2*e6[period-1];
    
    osc[period]=forecastosc;
    osct3[period]=c1*e6[period]+c2*e5[period]+c3*e4[period]+c4*e3[period];
    
    if osc[period-1]>osct3[period-2] and osc[period-2]<=osct3[period-3] and osct3[period-1]<0 then
     DotLo[period-1]=osct3[period]-0.05;
    end
    if osc[period-1]<osct3[period-2] and osc[period-2]>=osct3[period-3] and osct3[period-1]>0 then
     DotHi[period-1]=osct3[period]+0.05;
    end
    
end

