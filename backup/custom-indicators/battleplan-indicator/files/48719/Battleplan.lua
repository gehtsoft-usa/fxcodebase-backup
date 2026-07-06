-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27802
-- Id: 8147

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
    indicator:name("Battleplan indicator");
    indicator:description("Battleplan indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("StartTime", "Start time", "", "6/29/2012 10:00");
    indicator.parameters:addDouble("Inf", "Inf", "", 18000);
    indicator.parameters:addDouble("Sup", "Sup", "", 21000);
    indicator.parameters:addInteger("CycleLength", "Cycle length", "", 60);
    indicator.parameters:addDouble("Trend", "Trend", "", 0);
    indicator.parameters:addInteger("Ncycle", "N cycle", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local StartTime;
local Inf, Sup;
local CycleLength;
local Trend;
local Ncycle;
local Battleplan = nil;
local StartPeriod = nil;
local b;

function StrToTime(Str)
 local Y,M,D,Hour,Min;
 local Pos;
 local Str_=Str;
 Pos=string.find(Str_,"/");
 M=(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,"/");
 D=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_," ");
 Y=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,":");
 Hour=tonumber(string.sub(Str_,1,Pos-1));
 Min=tonumber(string.sub(Str_,Pos+1));
 return core.datetime(Y,M,D,Hour,Min,0);
end

function Prepare(nameOnly)
    source = instance.source;
    StartTime=StrToTime(instance.parameters.StartTime);
    Inf=instance.parameters.Inf;
    Sup=instance.parameters.Sup;
    CycleLength=instance.parameters.CycleLength;
    Trend=instance.parameters.Trend;
    Ncycle=instance.parameters.Ncycle;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.StartTime .. ", " .. instance.parameters.Inf .. ", " .. instance.parameters.Sup .. ", " .. instance.parameters.CycleLength .. ", " .. instance.parameters.Trend .. ", " .. instance.parameters.Ncycle .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    b = instance:addInternalStream(first, 0);
    Battleplan = instance:addStream("Battleplan", core.Line, name .. ".Battleplan", "Battleplan", instance.parameters.clr, first);
    Battleplan:setPrecision(math.max(2, instance.source:getPrecision()));
    Battleplan:setWidth(instance.parameters.widthLinReg);
    Battleplan:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first and source:date(period)>=StartTime then
    if StartPeriod == nil then
     StartPeriod = period;
    else
     local x = (360/CycleLength)*(period-StartPeriod+1);
     local Cycle = math.sin((x-90)*math.pi/180)+math.sin((Ncycle*x-90)*math.pi/180)+math.sin((2*Ncycle*x-90)*math.pi/180)+math.sin((4*Ncycle*x-90)*math.pi/180);
     local c = 0.01029*Trend;
     b[period] = b[period-1]+c;
     Battleplan[period] = (Cycle+b[period]+10)*((Sup-Inf)/15)+Inf;
    end
   else
    StartPeriod = nil;
    b[period] = 0;
   end 
end

