-- Id: 9406
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41584

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("VHP channel");
    indicator:description("VHP channel");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fast_Period", "Fast_Period", "", 21);
    indicator.parameters:addInteger("Slow_Period", "Slow_Period", "", 144);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HPclr", "HP color", "HP color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("HPwidth", "HP width", "HP width", 1, 1, 5);
    indicator.parameters:addInteger("HPstyle", "HP style", "HP style", core.LINE_SOLID);
    indicator.parameters:setFlag("HPstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HPSclr", "HP slow color", "HP slow color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("HPSwidth", "HP slow width", "HP slow width", 1, 1, 5);
    indicator.parameters:addInteger("HPSstyle", "HP slow style", "HP slow style", core.LINE_DASH);
    indicator.parameters:setFlag("HPSstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Uclr", "Upper edge color", "Upper edge color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Uwidth", "Upper edge width", "Upper edge width", 2, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper edge style", "Upper edge style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower edge color", "Lower edge color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Lwidth", "Lower edge width", "Lower edge width", 2, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower edge style", "Lower edge style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Fast_Period;
local Slow_Period;
local HP=nil;
local HPS=nil;
local Upper=nil;
local Lower=nil;
local Lambda_F, Lambda_S;

function Prepare(nameOnly)
    source = instance.source;
    Fast_Period=instance.parameters.Fast_Period;
    Slow_Period=instance.parameters.Slow_Period;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Fast_Period .. ", " .. instance.parameters.Slow_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    HP = instance:addStream("HP", core.Line, name .. ".HP", "HP", instance.parameters.HPclr, first);
    HP:setWidth(instance.parameters.HPwidth);
    HP:setStyle(instance.parameters.HPstyle);
    HPS = instance:addStream("HPS", core.Line, name .. ".HP slow", "HP slow", instance.parameters.HPSclr, first);
    HPS:setWidth(instance.parameters.HPSwidth);
    HPS:setStyle(instance.parameters.HPSstyle);
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
    Lambda_F = 0.0625/math.pow(math.sin(math.pi/Fast_Period), 4);
    Lambda_S = 0.0625/math.pow(math.sin(math.pi/Slow_Period), 4);
end

function CalcHP(Count, Lambda, src, Buff)
 local a={};
 local b={};
 local c={};
 local i;
 
 a[0]=1+Lambda;
 b[0]=-2*Lambda;
 c[0]=Lambda;
 for i=1, Count-3, 1 do
  a[i]=6*Lambda+1;
  b[i]=-4*Lambda;
  c[i]=Lambda;
 end
 a[1]=5*Lambda+1;
 a[Count-1]=1+Lambda;
 a[Count-2]=5*Lambda+1;
 b[Count-2]=-2*Lambda;
 b[Count-1]=0;
 c[Count-2]=0;
 c[Count-1]=0;
 local H1, H2, H3, H4, H5, HH1, HH2, HH3, HH5, HB, HC, Z = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
 local srcLast=src:size()-1;
 
 for i=0, Count-1, 1 do
  Z=a[i]-H4*H1-HH5*HH2;
  HB=b[i];
  HH1=H1;
  H1=(HB-H4*H2)/Z;
  b[i]=H1;
  HC=c[i];
  HH2=H2;
  H2=HC/Z;
  c[i]=H2;
  a[i]=(src[srcLast-i]-HH3*HH5-H3*H4)/Z;
  HH3=H3;
  H3=a[i];
  H4=HB-H5*HH1;
  HH5=H5;
  H5=HC;
 end
 
 H2=0;
 H1=a[Count-1];
 Buff[srcLast-Count+1]=H1;
 for i=Count-2, 0, -1 do
  Buff[srcLast-i]=a[i]-b[i]*H1-c[i]*H2;
  H2=H1;
  H1=Buff[srcLast-i];
 end
 
end

function Update(period, mode)
   if period==source:size()-1 then
    CalcHP(Slow_Period, Lambda_F, source, HP);
    CalcHP(Slow_Period, Lambda_S, source, HPS);
    
    local disp=0;
    local i;
    for i=0, Slow_Period-1, 1 do
     disp=disp+(HP[period-i]-HPS[period-i])*(HP[period-i]-HPS[period-i]);
    end
    disp=disp/(Slow_Period-1);
    local dev=2*math.sqrt(disp);
    for i=0, Slow_Period-1, 1 do
     Upper[period-i]=HPS[period-i]+dev;
     Lower[period-i]=HPS[period-i]-dev;
    end
   end 
end

