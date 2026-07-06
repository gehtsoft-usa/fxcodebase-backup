-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5172

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
    indicator:name("Specific Time Range Candles indicator");
    indicator:description("Specific Time Range Candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("StartTime", "Start Time", "", "10:00");
    indicator.parameters:addString("FinishTime", "Finish Time", "", "12:00");
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP candle", "Color UP candle", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN candle", "Color DN candle", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local StartTime;
local FinishTime;
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local LastPeriod=nil;
local StartH,StartM,FinishH,FinishM;
local StartHM,FinishHM;

function Prepare(nameOnly)
    source = instance.source;
    StartTime=instance.parameters.StartTime;
    FinishTime=instance.parameters.FinishTime;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.StartTime .. ", " .. instance.parameters.FinishTime .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("STRC", "STRC", open, high, low, close);
    local Pos=string.find(StartTime,":");
    StartH=tonumber(string.sub(StartTime,1,Pos-1));
    StartM=tonumber(string.sub(StartTime,Pos+1));
    StartHM=StartH*60+StartM;
    Pos=string.find(FinishTime,":");
    FinishH=tonumber(string.sub(FinishTime,1,Pos-1));
    FinishM=tonumber(string.sub(FinishTime,Pos+1));
    FinishHM=FinishH*60+FinishM;
end

function Update(period, mode)
   local Fl=false;
   if period~=LastPeriod then
    LastPeriod=period;
    Fl=true;
   end
   if (period==source:size()-1) then
     local Count=period;
     local i;
     for i=period,first,-1 do
      local TimeTable=core.dateToTable(source:date(i));
      local CurrentHM=TimeTable.hour*60+TimeTable.min;
      if (StartHM<FinishHM and CurrentHM>=StartHM and CurrentHM<FinishHM) or (StartHM>FinishHM and (CurrentHM>=StartHM or CurrentHM<FinishHM)) then
       open[Count]=source.open[i];
       close[Count]=source.close[i];
       high[Count]=source.high[i];
       low[Count]=source.low[i];
       Count=Count-1;
      end
      if Fl==false then
       break;
      end
     end
     if Count~=period and Fl then
      for i=Count,first,-1 do
       open[i]=open[Count+1];
       close[i]=open[Count+1];
       high[i]=open[Count+1];
       low[i]=open[Count+1];
      end
     end 
   end 
end

