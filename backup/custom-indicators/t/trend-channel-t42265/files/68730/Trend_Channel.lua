-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42265
-- Id: 9436

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
    indicator:name("Trend channel indicator");
    indicator:description("Trend channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addInteger("Limit", "Limit", "", 300);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper color", "Upper color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Uwidth", "Upper line width", "Upper line width", 1, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper line style", "Upper line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower color", "Lower color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("Lwidth", "Lower line width", "Lower line width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower line style", "Lower line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UDclr", "Upper dot color", "Upper dot color", core.rgb(0, 128, 0));
    indicator.parameters:addInteger("UDwidth", "Upper dot size", "Upper dot size", 5, 1, 5);
    indicator.parameters:addColor("LDclr", "Lower dot color", "Lower dot color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("LDwidth", "Lower dot size", "Lower dot size", 5, 1, 5);
end

local first;
local source = nil;
local Period;
local Limit;
local Period2;
local Upper=nil;
local Lower=nil;
local Udot=nil;
local Ldot=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Limit=instance.parameters.Limit;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Limit .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
    Udot = instance:addStream("Udot", core.Dot, name .. ".Udot", "Udot", instance.parameters.UDclr, first);
    Udot:setWidth(instance.parameters.UDwidth);
    Ldot = instance:addStream("Ldot", core.Dot, name .. ".Ldot", "Ldot", instance.parameters.LDclr, first);
    Ldot:setWidth(instance.parameters.LDwidth);
    Period2=math.floor((Period-1)/2);
end

function Update(period, mode)
   if period>first+Limit and period==source:size()-1 then
    local u1, u2 = nil, nil;
    local l1, l2 = nil, nil;
    local i=period;
    while i>=period-Limit and (u2==nil or l2==nil) do
     if source.low[i-Period2]==mathex.min(source.low, i-Period, i) then
      if l1==nil then
       l1=i-Period2;
      elseif l2==nil then
       l2=i-Period2;
      end
     end
     if source.high[i-Period2]==mathex.max(source.high, i-Period, i) then
      if u1==nil then
       u1=i-Period2;
      elseif u2==nil then
       u2=i-Period2;
      end
     end
     i=i-1;
    end
    if u2~=nil and l2~=nil then
     local H_last = source.high[u2]+(source.high[u1]-source.high[u2])*(period-u2)/(u1-u2);
     local L_last = source.low[l2]+(source.low[l1]-source.low[l2])*(period-l2)/(l1-l2);
     core.drawLine(Upper, core.range(u2, period), source.high[u2], u2, H_last, period);
     core.drawLine(Lower, core.range(l2, period), source.low[l2], l2, L_last, period);
     core.drawLine(Udot, core.range(first, period), 0, first, 0, period);
     core.drawLine(Ldot, core.range(first, period), 0, first, 0, period);
     if Udot[u1]~=source.high[u1] or Udot[u2]~=source.high[u2] or Ldot[l1]~=source.low[l1] or Ldot[l2]~=source.low[l2] then
      Udot[u1]=source.high[u1];
      Udot[u2]=source.high[u2];
      Ldot[l1]=source.low[l1];
      Ldot[l2]=source.low[l2];
     end 
    end
   end 
end

