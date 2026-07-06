-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59063
-- Id: 9692

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
    indicator:name("Lyapunov HP oscillator");
    indicator:description("Lyapunov HP oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
  --  indicator.parameters:addInteger("MA_Period", "MA period", "", 4);
    indicator.parameters:addInteger("Filter", "Filter", "", 7);
    indicator.parameters:addInteger("L_Period", "Lyapunov period", "", 525);
  --  indicator.parameters:addInteger("L_Time", "Lyapunov time", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA_Period;
local Filter;
local L_Period;
local L_Time;
local Lyapunov_HP=nil;
local Lambda;
local hpf, a, b, c;

function Prepare(nameOnly)
    source = instance.source;
    Filter=instance.parameters.Filter;
    L_Period=instance.parameters.L_Period;
    first = source:first()+L_Period;
    local name = profile:id() .. "(" .. source:name()  .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.L_Period  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    hpf = instance:addInternalStream(first, 0);
    a = instance:addInternalStream(first, 0);
    b = instance:addInternalStream(first, 0);
    c = instance:addInternalStream(first, 0);
    Lyapunov_HP = instance:addStream("Lyapunov_HP", core.Line, name .. ".Lyapunov_HP", "Lyapunov_HP", instance.parameters.clr, first);
    Lyapunov_HP:setPrecision(math.max(2, instance.source:getPrecision()));
    Lyapunov_HP:setWidth(instance.parameters.widthLinReg);
    Lyapunov_HP:setStyle(instance.parameters.styleLinReg);
    Lambda = 0.0625/math.pow(math.sin(math.pi/Filter),4);
end

function Update(period, mode)
   if period>first and period==source:size()-1 then
    a[period]=1+Lambda;
    b[period]=-2*Lambda;
    c[period]=Lambda;
    local i;
    for i=first, period-1, 1 do
     a[i]=6*Lambda+1;
     b[i]=-4*Lambda;
     c[i]=Lambda;
    end
    a[period-1]=5*Lambda+1;
    a[first]=1+Lambda;
    a[first+1]=5*Lambda+1;
    b[first+1]=-2*Lambda;
    b[first]=0;
    c[first+1]=0;
    c[first]=0;
    
    local H1, H2, H3, H4, H5, HH1, HH2, HH3, HH4, HH5, HB, HC, Z = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    
    for i=period, first, -1 do
     Z=a[i]-H4*H1-HH5*HH2;
     HB=b[i];
     HH1=H1;
     H1=(HB-H4*H2)/Z;
     b[i]=H1;
     HC=c[i];
     HH2=H2;
     H2=HC/Z;
     c[i]=H2;
     a[i]=(source[i]-HH3*HH5-H3*H4)/Z;
     HH3=H3;
     H3=a[i];
     H4=HB-H5*HH1;
     HH5=H5;
     H5=HC;
    end
    
    H2=0;
    H1=a[first+1];
    hpf[first+1]=H1;

    for i=first+2, period, 1 do
     hpf[i]=a[i]-b[i]*H1-c[i]*H2;
     H2=H1;
     H1=hpf[i];
    end
    
    for i=period, first+1, -1 do
     Lyapunov_HP[i]=math.log(math.abs(hpf[i]/hpf[i-1]))*100000;
    end
    
   end 
end

