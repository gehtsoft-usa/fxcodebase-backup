-- Id: 3312
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3623

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Time trading range indicator");
    indicator:description("Time trading range indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time", "", "01:00");
    indicator.parameters:addString("EndTime", "End time", "", "05:30");
    indicator.parameters:addString("BoxEndTime", "Box end time", "", "10:00");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP1", "Color UP 1", "Color UP 1", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clrUP2", "Color UP 2", "Color UP 2", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN1", "Color DN 1", "Color DN 1", core.rgb(128, 0, 0));
    indicator.parameters:addColor("clrDN2", "Color DN 2", "Color DN 2", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local BeginTime;
local EndTime;
local BoxEndTime;
local BeginTime_H, BeginTime_M;
local EndTime_H, EndTime_M;
local BoxEndTime_H, BoxEndTime_M;
local BM_Begin;
local BM_End;
local BM_BoxEnd;
local i;

function Prepare(nameOnly)
    source = instance.source;
    BeginTime=instance.parameters.BeginTime;
    EndTime=instance.parameters.EndTime;
    BoxEndTime=instance.parameters.BoxEndTime;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. BeginTime .. ", " .. EndTime .. ", " .. BoxEndTime .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    hUP1=instance:addInternalStream(first, 0);
    lUP1=instance:addInternalStream(first, 0);
    hUP2=instance:addInternalStream(first, 0);
    lUP2=instance:addInternalStream(first, 0);
    hDN1=instance:addInternalStream(first, 0);
    lDN1=instance:addInternalStream(first, 0);
    hDN2=instance:addInternalStream(first, 0);
    lDN2=instance:addInternalStream(first, 0);
    BM_Begin=instance:addInternalStream(first, 0);
    BM_End=instance:addInternalStream(first, 0);
    BM_BoxEnd=instance:addInternalStream(first, 0);
    instance:createChannelGroup("UpGroup1","Up1" , hUP1, lUP1, instance.parameters.clrUP1, 100-instance.parameters.Transparency);
    instance:createChannelGroup("UpGroup2","Up2" , hUP2, lUP2, instance.parameters.clrUP2, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGroup1","Dn1" , hDN1, lDN1, instance.parameters.clrDN1, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGroup2","Dn2" , hDN2, lDN2, instance.parameters.clrDN2, 100-instance.parameters.Transparency);
    local Pos=string.find(BeginTime,":");
    BeginTime_H=tonumber(string.sub(BeginTime,1,Pos-1));
    BeginTime_M=tonumber(string.sub(BeginTime,Pos+1));
    Pos=string.find(EndTime,":");
    EndTime_H=tonumber(string.sub(EndTime,1,Pos-1));
    EndTime_M=tonumber(string.sub(EndTime,Pos+1));
    Pos=string.find(BoxEndTime,":");
    BoxEndTime_H=tonumber(string.sub(BoxEndTime,1,Pos-1));
    BoxEndTime_M=tonumber(string.sub(BoxEndTime,Pos+1));
end

function Update(period, mode)
   if period==first then
    BM_Begin[period]=0;
    BM_End[period]=0;
    BM_BoxEnd[period]=0;
   end
   if (period>first) then
    local Table1=core.dateToTable(source:date(period));
    local Table2=core.dateToTable(source:date(period-1));
    local T1_H=Table1.hour;
    local T1_M=Table1.min;
    if T1_H==0 and T1_M==0 then
     T1_H=24;
    end
    
    if Table2.hour*60+Table2.min<=BeginTime_H*60+BeginTime_M and T1_H*60+T1_M>BeginTime_H*60+BeginTime_M then
     BM_Begin[period]=BM_Begin[period-1]+1;
     hUP1:setBookmark(BM_Begin[period],period-1);
    else
     BM_Begin[period]=BM_Begin[period-1];
    end

    if Table2.hour*60+Table2.min<=EndTime_H*60+EndTime_M and T1_H*60+T1_M>EndTime_H*60+EndTime_M then
     BM_End[period]=BM_End[period-1]-1;
     hUP1:setBookmark(BM_End[period],period-1);
    else
     BM_End[period]=BM_End[period-1];
    end
    
    if Table2.hour*60+Table2.min<=BoxEndTime_H*60+BoxEndTime_M and T1_H*60+T1_M>BoxEndTime_H*60+BoxEndTime_M then
     BM_BoxEnd[period]=BM_BoxEnd[period-1]+1;
     hUP2:setBookmark(BM_BoxEnd[period],period-1);
    else
     BM_BoxEnd[period]=BM_BoxEnd[period-1];
    end
    
    if BM_Begin[period]~=0 then
     local BeginPeriod=hUP1:getBookmark(BM_Begin[period]);
     local EndPeriod;
     if BM_End[period]~=0 then
      EndPeriod=hUP1:getBookmark(BM_End[period]);
     else
      EndPeriod=period;
     end 
     if EndPeriod<=BeginPeriod then
      EndPeriod=period;
     end
     local Min=core.min(source.low,core.range(BeginPeriod,EndPeriod));
     local Max=core.max(source.high,core.range(BeginPeriod,EndPeriod));
     local Open=source.open[BeginPeriod];
     local Close=source.close[EndPeriod];
     if BeginPeriod<EndPeriod and period>=BeginPeriod and period<=EndPeriod+1 then
      if Close>Open then
       core.drawLine(hUP1, core.range(BeginPeriod,EndPeriod), Max, BeginPeriod, Max, EndPeriod);
       core.drawLine(lUP1, core.range(BeginPeriod,EndPeriod), Min, BeginPeriod, Min, EndPeriod);
       for i=BeginPeriod, EndPeriod, 1 do
        hDN1[i]=nil;
        lDN1[i]=nil;
       end
      else
       core.drawLine(hDN1, core.range(BeginPeriod,EndPeriod), Max, BeginPeriod, Max, EndPeriod);
       core.drawLine(lDN1, core.range(BeginPeriod,EndPeriod), Min, BeginPeriod, Min, EndPeriod);
       for i=BeginPeriod, EndPeriod, 1 do
        hUP1[i]=nil;
        lUP1[i]=nil;
       end
      end 
     end 
      
     local BoxEndPeriod;
     if BM_BoxEnd[period]~=0 then
      BoxEndPeriod=hUP2:getBookmark(BM_BoxEnd[period]);
     else
      BoxEndPeriod=period;
     end 
     if BoxEndPeriod<=EndPeriod then
      BoxEndPeriod=period;
     end
     if BoxEndPeriod>EndPeriod and period>=EndPeriod and period<=BoxEndPeriod+1 then
      if Close>Open then
       core.drawLine(hUP2, core.range(EndPeriod,BoxEndPeriod), Max, EndPeriod, Max, BoxEndPeriod);
       core.drawLine(lUP2, core.range(EndPeriod,BoxEndPeriod), Min, EndPeriod, Min, BoxEndPeriod);
       for i=EndPeriod, period, 1 do
        hDN2[i]=nil;
        lDN2[i]=nil;
       end
      else
       core.drawLine(hDN2, core.range(EndPeriod,BoxEndPeriod), Max, EndPeriod, Max, BoxEndPeriod);
       core.drawLine(lDN2, core.range(EndPeriod,BoxEndPeriod), Min, EndPeriod, Min, BoxEndPeriod);
       for i=EndPeriod, period, 1 do
        hUP2[i]=nil;
        lUP2[i]=nil;
       end
      end 
     end
    end 
    
   end 
end

