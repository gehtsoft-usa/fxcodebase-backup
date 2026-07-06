-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12840
-- Id: 5742

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Trading day average indicator");
    indicator:description("Indicator shows the average price of the trading day (for High and Low)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the trading day", "", "03:00");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Hclr", "High Color", "High Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Lclr", "Low Color", "Low Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("CloudClr", "Cloud color", "Cloud color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
end

local first;
local source = nil;
local BeginTime;
local BeginT;
local HighSum, LowSum;
local Count;
local HighAvg=nil;
local LowAvg=nil;

function Prepare(nameOnly)
    source = instance.source;
    BeginTime=instance.parameters.BeginTime;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BeginTime .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    HighSum = instance:addInternalStream(first, 0);
    LowSum = instance:addInternalStream(first, 0);
    Count = instance:addInternalStream(first, 0);
    HighAvg = instance:addStream("HighAvg", core.Line, name .. ".HighAvg", "HighAvg", instance.parameters.Hclr, first);
    LowAvg = instance:addStream("LowAvg", core.Line, name .. ".LowAvg", "LowAvg", instance.parameters.Lclr, first);
    instance:createChannelGroup("TDA","TDA" , HighAvg, LowAvg, instance.parameters.CloudClr, 100-instance.parameters.Transparency);
    HighAvg:setWidth(instance.parameters.widthLinReg);
    HighAvg:setStyle(instance.parameters.styleLinReg);
    LowAvg:setWidth(instance.parameters.widthLinReg);
    LowAvg:setStyle(instance.parameters.styleLinReg);
    local Pos=string.find(BeginTime,":");
    local BeginH=tonumber(string.sub(BeginTime,1,Pos-1));
    local BeginM=tonumber(string.sub(BeginTime,Pos+1));
    BeginT=60*BeginH+BeginM;
end

function Update(period, mode)
   if (period>first) then
    local D=source:date(period);
    local T=core.dateToTable(D);
    local CandleTime=60*T.hour+T.min;
    local D2=source:date(period-1);
    local T2=core.dateToTable(D2);
    local CandleTime2=60*T2.hour+T2.min;
    if CandleTime2<BeginT and CandleTime>=BeginT then
     HighSum[period]=source.high[period];
     LowSum[period]=source.low[period];
     Count[period]=1;
    else
     HighSum[period]=HighSum[period-1]+source.high[period];
     LowSum[period]=LowSum[period-1]+source.low[period];
     Count[period]=Count[period-1]+1;
    end
    HighAvg[period]=HighSum[period]/Count[period];
    LowAvg[period]=LowSum[period]/Count[period];
   elseif period==first then
    HighSum[period]=source.high[period];
    LowSum[period]=source.low[period];
    Count[period]=1;
   end 
end

