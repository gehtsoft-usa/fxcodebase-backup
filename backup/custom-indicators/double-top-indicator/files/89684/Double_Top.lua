-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59574
-- Id: 10061

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
    indicator:name("Double top indicator");
    indicator:description("Double top indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MinHeight", "Min. height of peak (in pips)", "", 10);
    indicator.parameters:addInteger("MaxDist", "Max. distance between peaks (in bars)", "", 20);
    indicator.parameters:addInteger("MinBars", "Min. number of bars after the peak (in bars)", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tclr1", "Top color", "Top color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Tclr2", "Double top color", "Double top color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bclr1", "Bottom color", "Bottom color", core.rgb(128, 0, 0));
    indicator.parameters:addColor("Bclr2", "Double bottom color", "Double bottom color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local MinHeight;
local MaxDist;
local MinBars;
local MinHeightPip;
local Top=nil;
local DoubleTop=nil;
local Bottom=nil;
local DoubleBottom=nil;

function Prepare(nameOnly)
    source = instance.source;
    MinHeight=instance.parameters.MinHeight;
    MaxDist=instance.parameters.MaxDist;
    MinBars=instance.parameters.MinBars;
    MinHeightPip=MinHeight*source:pipSize();
    first = source:first()+MinBars;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MinHeight .. ", " .. instance.parameters.MaxDist .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Top = instance:addStream("Top", core.Dot, name .. ".Top", "Top", instance.parameters.Tclr1, first);
    DoubleTop = instance:addStream("DoubleTop", core.Dot, name .. ".DoubleTop", "DoubleTop", instance.parameters.Tclr2, first);
    Bottom = instance:addStream("Bottom", core.Dot, name .. ".Bottom", "Bottom", instance.parameters.Bclr1, first);
    DoubleBottom = instance:addStream("DoubleBottom", core.Dot, name .. ".DoubleBottom", "DoubleBottom", instance.parameters.Bclr2, first);
    Top:setWidth(instance.parameters.DotSize);
    DoubleTop:setWidth(instance.parameters.DotSize);
    Bottom:setWidth(instance.parameters.DotSize);
    DoubleBottom:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first then
    if IsTop(period-MinBars) then
     Top[period-MinBars]=source.high[period-MinBars];
    else
     Top[period-MinBars]=nil; 
    end
    if IsBottom(period-MinBars) then
     Bottom[period-MinBars]=source.low[period-MinBars];
    else
     Bottom[period-MinBars]=nil; 
    end
    local Res;
    if Top[period-MinBars]==source.high[period-MinBars] then
     Res=FindPrevTop(period-MinBars);
     if Res~=nil then
      DoubleTop[period-MinBars]=source.high[period-MinBars];
     end
    end
    if Bottom[period-MinBars]==source.low[period-MinBars] then
     Res=FindPrevBottom(period-MinBars);
     if Res~=nil then
      DoubleBottom[period-MinBars]=source.low[period-MinBars];
     end
    end
   end 
end

function FindPrevTop(index)
 local i=index-1;
 while i>first and i>=index-MaxDist do
  if Top[i]==source.high[i] then
   return i;
  end
  i=i-1;
 end
 return nil;
end

function FindPrevBottom(index)
 local i=index-1;
 while i>first and i>=index-MaxDist do
  if Bottom[i]==source.low[i] then
   return i;
  end
  i=i-1;
 end
 return nil;
end

function IsTop(index)
 local i;
 local Fl=true;
 for i=1,MinBars,1 do
  if source.high[index+i]>=source.high[index] then
   Fl=false;
  end
 end
 if Fl then
  i=index-1;
  while i>first do
   if source.high[i]>=source.high[index] then
    return false;
   end
   if source.high[index]-source.low[i]>=MinHeightPip then
    return true;
   end
   i=i-1;
  end
 end
 return false;
end

function IsBottom(index)
 local i;
 local Fl=true;
 for i=1,MinBars,1 do
  if source.low[index+i]<=source.low[index] then
   Fl=false;
  end
 end
 if Fl then
  i=index-1;
  while i>first do
   if source.low[i]<=source.low[index] then
    return false;
   end
   if source.high[i]-source.low[index]>=MinHeightPip then
    return true;
   end
   i=i-1;
  end
 end
 return false;
end
