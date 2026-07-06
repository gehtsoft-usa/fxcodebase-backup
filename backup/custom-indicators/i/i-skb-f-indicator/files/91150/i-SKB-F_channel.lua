-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59993
-- Id: 10545

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
    indicator:name("i-SKB-F_channel indicator");
    indicator:description("i-SKB-F_channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Offset", "Offset", "", -3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper channel color", "Upper channel color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Uwidth", "Upper channel width", "Upper channel width", 2, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper channel style", "Upper channel style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower channel color", "Lower channel color", core.rgb(22, 255, 0));
    indicator.parameters:addInteger("Lwidth", "Lower channel width", "Lower channel width", 2, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower channel style", "Lower channel style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Offset;
local U_Channel=nil;
local L_Channel=nil;

function Prepare(nameOnly)
    source = instance.source;
    Offset=instance.parameters.Offset*source:pipSize();
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Offset .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    U_Channel = instance:addStream("U_Channel", core.Line, name .. ".U_Channel", "U_Channel", instance.parameters.Uclr, first);
    U_Channel:setWidth(instance.parameters.Uwidth);
    U_Channel:setStyle(instance.parameters.Ustyle);
    L_Channel = instance:addStream("L_Channel", core.Line, name .. ".L_Channel", "L_Channel", instance.parameters.Lclr, first);
    L_Channel:setWidth(instance.parameters.Lwidth);
    L_Channel:setStyle(instance.parameters.Lstyle);
end

function IsFractal(index)
 if source.high[index]>source.high[index-1] and source.high[index]>source.high[index-2] and source.high[index]>source.high[index+1] and source.high[index]>source.high[index+2] then
  return source.high[index];
 elseif source.low[index]<source.low[index-1] and source.low[index]<source.low[index-2] and source.low[index]<source.low[index+1] and source.low[index]<source.low[index+2] then 
  return source.low[index];
 else
  return nil;
 end
end

function EquationDirect(x1, y1, x2, y2, x)
 return (y2-y1)*(x-x1)/(x2-x1)+y1;
end

function Update(period, mode)
   if period==source:size()-1 then
    local x1, x2, x3;
    local y1, y2, y3 = nil, nil, nil;
    local i=period-2;
    local Fr;
    while i>first+2 and y1==nil do 
     Fr=IsFractal(i);
     if Fr~=nil then
      y1=y2;
      y2=y3;
      y3=Fr;
      x1=x2;
      x2=x3;
      x3=i;
     end
     i=i-1;
    end
    local y4=EquationDirect(x3, y3, x1, y1, x2);
    local u1, u2, d1, d2;
    if y2>y1 then
     u2=y3+y2-y4;
     u1=EquationDirect(x3, u2, x2, y2, period);
     d2=y3;
     d1=EquationDirect(x3, y3, x1, y1, period);
    else
     u2=y3;
     u1=EquationDirect(x3, y3, x1, y1, period);
     d2=y3+y2-y4;
     d1=EquationDirect(x3, d2, x2, y2, period);
    end
    u2=u2+Offset;
    u1=u1+Offset;
    d2=d2-Offset;
    d1=d1-Offset;
    core.drawLine(U_Channel, core.range(x3, period), u2, x3, u1, period);
    core.drawLine(L_Channel, core.range(x3, period), d2, x3, d1, period);
   end 
end

