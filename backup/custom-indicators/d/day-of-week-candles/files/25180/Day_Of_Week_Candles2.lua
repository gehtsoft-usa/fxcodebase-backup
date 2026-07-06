--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Day of week candles indicator");
    indicator:description("Day of week candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "03:00");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MoClr", "Monday Color", "Monday Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TuClr", "Tuesday Color", "Tuesday Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("WeClr", "Wednesday Color", "Wednesday Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("ThClr", "Thursday Color", "Thursday Color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("FrClr", "Friday Color", "Friday Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SaClr", "Saturday Color", "Saturday Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("SuClr", "Sunday Color", "Sunday Color", core.rgb(128, 255, 55));
end

local first;
local source = nil;
local BeginT;

function Prepare()
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("CCI color candle", "", open, high, low, close);
    local BeginTime=instance.parameters.BeginTime;
    local Pos=string.find(BeginTime,":");
    local BeginH=tonumber(string.sub(BeginTime,1,Pos-1));
    local BeginM=tonumber(string.sub(BeginTime,Pos+1));
    BeginT=60*BeginH+BeginM;
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    
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
    if wday==1 then
     open:setColor(period,instance.parameters.SuClr)
    elseif wday==2 then
     open:setColor(period,instance.parameters.MoClr)
    elseif wday==3 then
     open:setColor(period,instance.parameters.TuClr)
    elseif wday==4 then
     open:setColor(period,instance.parameters.WeClr)
    elseif wday==5 then
     open:setColor(period,instance.parameters.ThClr)
    elseif wday==6 then
     open:setColor(period,instance.parameters.FrClr)
    else
     open:setColor(period,instance.parameters.SaClr)
    end
 
end

