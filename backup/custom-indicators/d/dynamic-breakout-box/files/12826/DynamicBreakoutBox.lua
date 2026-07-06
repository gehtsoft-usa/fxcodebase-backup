
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5269

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Dynamic Breakout Box indicator");
    indicator:description("Dynamic Breakout Box indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BoxLength", "BoxLength", "", 4);
    indicator.parameters:addInteger("BoxRange", "BoxRange", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BoxClr", "Box Color", "Box Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("BoxTransparency", "Box Transparency", "", 30);
    indicator.parameters:addColor("BoxHighClr", "Box High Color", "Box High Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("BoxLowClr", "Box Low Color", "Box Low Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("HighLineClr", "High Line Color", "High Line Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("LowLineClr", "Low Line Color", "Low Line Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local BoxLength;
local BoxRange;
local BuffBoxHigh=nil;
local BuffBoxLow=nil;
local BuffLineHigh=nil;
local BuffLineLow=nil;
local PrevPStream;
local BoxRangePips;
local CloudBoxHigh;
local CloudBoxLow;

function Prepare(nameOnly)
    source = instance.source;
    BoxLength=instance.parameters.BoxLength;
    BoxRange=instance.parameters.BoxRange;
    first = source:first()+ BoxLength;
    PrevPStream=instance:addInternalStream(0, 0);
    CloudBoxHigh=instance:addInternalStream(0, 0);
    CloudBoxLow=instance:addInternalStream(0, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BoxLength .. ", " .. instance.parameters.BoxRange .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    BuffBoxHigh = instance:addStream("BuffBoxHigh", core.Line, name .. ".BoxHigh", "BoxHigh", instance.parameters.BoxHighClr, first);
    BuffBoxLow = instance:addStream("BuffBoxLow", core.Line, name .. ".BoxLow", "BoxLow", instance.parameters.BoxLowClr, first);
    BuffLineHigh = instance:addStream("BuffLineHigh", core.Line, name .. ".LineHigh", "LineHigh", instance.parameters.HighLineClr, first);
    BuffLineLow = instance:addStream("BuffLineLow", core.Line, name .. ".LineLow", "LineLow", instance.parameters.LowLineClr, first);
    instance:createChannelGroup("Box","Box" , CloudBoxHigh, CloudBoxLow, instance.parameters.BoxClr, 100-instance.parameters.BoxTransparency);
    BoxRangePips=BoxRange*source:pipSize();
end

function Update(period, mode)
   if (period>first) then
    BuffLineHigh[period]=BuffLineHigh[period-1];
    BuffLineLow[period]=BuffLineLow[period-1];
    local _period=GetPeriodForMinRange(period,BoxLength,999,BoxRangePips,PrevPStream[period-1]);
    PrevPStream[period]=_period;
    local upper=core.max(source.high,core.rangeTo(period,_period));
    local lower=core.min(source.low,core.rangeTo(period,_period));
    
    if _period>first then
     if PrevPStream[period-1]<=BoxLength then
      if PrevPStream[period-BoxLength]<=BoxLength then
       if source.high[period-_period+1]==upper then
        upper=lower+BoxRangePips;
       end
       if source.low[period-_period+1]==lower then
        lower=upper-BoxRangePips;
       end
       local j;
       for j=period-BoxLength,period,1 do
        BuffBoxHigh[j]=upper;
        BuffBoxLow[j]=lower;
        CloudBoxHigh[j]=upper;
        CloudBoxLow[j]=lower;
       end
       BuffLineHigh[period-1]=nil;
       BuffLineLow[period-1]=nil;
       BuffLineHigh[period]=upper;
       BuffLineLow[period]=lower;
      end
     else
      if source.low[period]>=BuffBoxLow[period-1] and source.high[period]<=BuffBoxHigh[period-1] then
       BuffBoxHigh[period]=BuffBoxHigh[period-1];
       BuffBoxLow[period]=BuffBoxLow[period-1];
      else
       BuffBoxHigh[period]=nil;
       BuffBoxLow[period]=nil; 
      end
     end
    end

   elseif (period>=first) then
    PrevPStream[period]=BoxLength;
    BuffBoxHigh[period]=nil;
    BuffBoxLow[period]=nil;
    BuffLineHigh[period]=nil;
    BuffLineLow[period]=nil;
   end 
end

function GetRange(Period, Shift)
 return core.max(source.high,core.range(math.max(Shift-Period+1,first),Shift))-core.min(source.low,core.range(math.max(Shift-Period+1,first),Shift));
end

function GetPeriodForMinRange(Shift,MinP,MaxP,MinRange,PrevP)
 local P=PrevP;
 if GetRange(P,Shift)>=MinRange then
  while (P>=MinP) do
   if GetRange(P,Shift)<MinRange then
    return (P+1);
   end
   P=P-1;
  end
  return (P);
 end
 for P=PrevP+1,MaxP-1,1 do
  if Shift-P==first then
   return (Shift-first+1);
  end
  if GetRange(P,Shift)>=MinRange then
   return (P);
  end
 end
 return (Shift-first+1);
end

