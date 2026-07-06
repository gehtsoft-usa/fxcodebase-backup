-- Id: 9109
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36273

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
    indicator:name("Waddah_Attar_Hidden_Levels indicator");
    indicator:description("Waddah_Attar_Hidden_Levels indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width1", "Width 1", "Width 1", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style 1", "Style 1", core.LINE_DASH);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Width 2", "Width 2", 2, 1, 5);
    indicator.parameters:addInteger("style2", "Style 2", "Style 2", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width3", "Width 3", "Width 3", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Style 3", "Style 3", core.LINE_DASH);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width4", "Width 4", "Width 4", 2, 1, 5);
    indicator.parameters:addInteger("style4", "Style 4", "Style 4", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr5", "Color 5", "Color 5", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width5", "Width 5", "Width 5", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Style 5", "Style 5", core.LINE_DASH);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Dsource;
local Buff1=nil;
local Buff2=nil;
local Buff3=nil;
local Buff4=nil;
local Buff5=nil;
local loading;
local DayOffset, WeekOffset;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Dsource = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 0, 100, 101);
    loading=false;
    DayOffset = core.host:execute("getTradingDayOffset");
    WeekOffset = core.host:execute("getTradingWeekOffset");    
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr1, first);
    Buff1:setWidth(instance.parameters.width1);
    Buff1:setStyle(instance.parameters.style1);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr2, first);
    Buff2:setWidth(instance.parameters.width2);
    Buff2:setStyle(instance.parameters.style2);
    Buff3 = instance:addStream("Buff3", core.Line, name .. ".Buff3", "Buff3", instance.parameters.clr3, first);
    Buff3:setWidth(instance.parameters.width3);
    Buff3:setStyle(instance.parameters.style3);
    Buff4 = instance:addStream("Buff4", core.Line, name .. ".Buff4", "Buff4", instance.parameters.clr4, first);
    Buff4:setWidth(instance.parameters.width4);
    Buff4:setStyle(instance.parameters.style4);
    Buff5 = instance:addStream("Buff5", core.Line, name .. ".Buff5", "Buff5", instance.parameters.clr5, first);
    Buff5:setWidth(instance.parameters.width5);
    Buff5:setStyle(instance.parameters.style5);
end

function AsyncOperationFinished(cookie, success, error)
 if cookie == 101 then
  loading = true;
 elseif cookie == 100 then
  assert(success, error);
  loading = false;
  instance:updateFrom(0);
 end 
end

function Update(period, mode)
   if period>first and not(loading) then
    local day1=core.getcandle("D1", source:date(period), DayOffset, WeekOffset);
    local index1=core.findDate(Dsource, day1, false);
    local day2=core.getcandle("D1", source:date(period-1), DayOffset, WeekOffset);
    local index2=core.findDate(Dsource, day2, false);
    local c1, c2;
    if index1>=0 then
     if index1~=index2 then
      if Dsource.close[index1]>=Dsource.open[index1] then
       c1=(Dsource.high[index1]-Dsource.close[index1])/2+Dsource.close[index1];
       c2=(Dsource.open[index1]-Dsource.low[index1])/2+Dsource.low[index1];
      else
       c1=(Dsource.high[index1]-Dsource.open[index1])/2+Dsource.open[index1];
       c2=(Dsource.close[index1]-Dsource.low[index1])/2+Dsource.low[index1];
      end
      Buff1[period]=c1+(c1-c2)*0.618;
      Buff2[period]=c1;
      Buff3[period]=(c1+c2)/2;
      Buff4[period]=c2;
      Buff5[period]=c2-(c1-c2)*0.618;
      Buff1[period-1]=nil;
      Buff2[period-1]=nil;
      Buff3[period-1]=nil;
      Buff4[period-1]=nil;
      Buff5[period-1]=nil;
     else
      Buff1[period]=Buff1[period-1];
      Buff2[period]=Buff2[period-1];
      Buff3[period]=Buff3[period-1];
      Buff4[period]=Buff4[period-1];
      Buff5[period]=Buff5[period-1];
     end
    end
   end 
end

