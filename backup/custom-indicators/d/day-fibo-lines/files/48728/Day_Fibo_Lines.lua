-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27807
-- Id: 8150

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
    indicator:name("Day of week lables indicator");
    indicator:description("Day of week lables indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "00:00");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HL_LineClr", "High/Low lines color", "High/Low lines color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("HL_Width", "High/Low lines width", "High/Low lines width", 3, 1, 5);
    indicator.parameters:addInteger("HL_Style", "High/Low lines style", "High/Low lines style", core.LINE_SOLID);
    indicator.parameters:setFlag("HL_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_LineClr", "Central line color", "Central line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Central_Width", "Central line width", "Central line width", 2, 1, 5);
    indicator.parameters:addInteger("Central_Style", "Central line style", "Central line style", core.LINE_DASHDOT);
    indicator.parameters:setFlag("Central_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Fibo_LineClr", "Fibo lines color", "Fibo lines color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Fibo_Width", "Fibo lines width", "Fibo lines width", 1, 1, 5);
    indicator.parameters:addInteger("Fibo_Style", "Fibo lines style", "Fibo lines style", core.LINE_DOT);
    indicator.parameters:setFlag("Fibo_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("LableClr", "Lable Color", "Lable Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("FontSize", "Label font size", "Label font size", 10);
end

local first;
local source = nil;
local BeginT;
local font;
local H, L = nil, nil;
local F1, F2, F3, F4, F5 = nil, nil, nil, nil, nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local BeginTime=instance.parameters.BeginTime;
    local Pos=string.find(BeginTime,":");
    local BeginH=tonumber(string.sub(BeginTime,1,Pos-1));
    local BeginM=tonumber(string.sub(BeginTime,Pos+1));
    BeginT=60*BeginH+BeginM;
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
    H = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.HL_LineClr, first);
    H:setWidth(instance.parameters.HL_Width);
    H:setStyle(instance.parameters.HL_Style);
    L = instance:addStream("L", core.Line, name .. ".L", "L", instance.parameters.HL_LineClr, first);
    L:setWidth(instance.parameters.HL_Width);
    L:setStyle(instance.parameters.HL_Style);
    F1 = instance:addStream("F1", core.Line, name .. ".F1", "F1", instance.parameters.Fibo_LineClr, first);
    F1:setWidth(instance.parameters.Fibo_Width);
    F1:setStyle(instance.parameters.Fibo_Style);
    F2 = instance:addStream("F2", core.Line, name .. ".F2", "F2", instance.parameters.Fibo_LineClr, first);
    F2:setWidth(instance.parameters.Fibo_Width);
    F2:setStyle(instance.parameters.Fibo_Style);
    F3 = instance:addStream("F3", core.Line, name .. ".F3", "F3", instance.parameters.Central_LineClr, first);
    F3:setWidth(instance.parameters.Central_Width);
    F3:setStyle(instance.parameters.Central_Style);
    F4 = instance:addStream("F4", core.Line, name .. ".F4", "F4", instance.parameters.Fibo_LineClr, first);
    F4:setWidth(instance.parameters.Fibo_Width);
    F4:setStyle(instance.parameters.Fibo_Style);
    F5 = instance:addStream("F5", core.Line, name .. ".F5", "F5", instance.parameters.Fibo_LineClr, first);
    F5:setWidth(instance.parameters.Fibo_Width);
    F5:setStyle(instance.parameters.Fibo_Style);
end

function DayNumber(period)
 local D=source:date(period);
 local T=core.dateToTable(D);
 local wday=T.wday;
 local CandleTime=60*T.hour+T.min;
 if CandleTime<BeginT then
  wday=wday-1;
  if wday<1 then
   wday=7;
  end
 end
 return wday;
end

function Update(period, mode)
   if period>first then
    local DN=DayNumber(period);
    local DN2=DayNumber(period-1);
    if DN2~=DN then
     H[period] = source.high[period];
     L[period] = source.low[period];
    else
     H[period] = math.max(H[period-1], source.high[period]);
     L[period] = math.min(L[period-1], source.low[period]);
    end
    F1[period] = 0.236*(H[period]-L[period])+L[period];
    F2[period] = 0.382*(H[period]-L[period])+L[period];
    F3[period] = 0.5*(H[period]-L[period])+L[period];
    F4[period] = 0.618*(H[period]-L[period])+L[period];
    F5[period] = 0.764*(H[period]-L[period])+L[period];
   elseif period==first then
    H[period] = source.high[period];
    L[period] = source.low[period];
   end 
end

