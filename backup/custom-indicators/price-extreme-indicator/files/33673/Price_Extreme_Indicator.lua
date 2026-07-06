-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18852
-- Id: 6593

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
 indicator:name("Price extreme indicator");
 indicator:description("Price extreme indicator");
 indicator:requiredSource(core.Bar);
 indicator:type(core.Indicator);

 indicator.parameters:addGroup("Calculation");
 indicator.parameters:addInteger("Multiplier", "Multiplier", "", 5);

 indicator.parameters:addGroup("Style");
 indicator.parameters:addColor("Hclr", "High border color", "High border color", core.rgb(0, 255, 0));
 indicator.parameters:addColor("Lclr", "Low border color", "Low border color", core.rgb(255, 0, 0));
 indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
 indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
 indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Multiplier;
local HighBorder=nil;
local LowBorder=nil;
local Coeff;

function Prepare(nameOnly)
 source = instance.source;
 Multiplier=instance.parameters.Multiplier;
 first = source:first()+ Multiplier;
 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Multiplier .. ")";
 instance:name(name);
 if nameOnly then
  return;
 end
 HighBorder = instance:addStream("HighBorder", core.Line, name .. ".HighBorder", "HighBorder", instance.parameters.Hclr, first,Multiplier);
 LowBorder = instance:addStream("LowBorder", core.Line, name .. ".LowBorder", "LowBorder", instance.parameters.Lclr, first,Multiplier);
 HighBorder:setWidth(instance.parameters.widthLinReg);
 HighBorder:setStyle(instance.parameters.styleLinReg);
 LowBorder:setWidth(instance.parameters.widthLinReg);
 LowBorder:setStyle(instance.parameters.styleLinReg);
 local s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
 Coeff=(e-s)*Multiplier;
end

function DrawBorders(period)
 local BeginRange=math.ceil(source:date(period)/Coeff-1)*Coeff;
 local EndRange=math.ceil(source:date(period)/Coeff)*Coeff;
 local BeginBar=core.findDate(source, BeginRange, false);
 local EndBar=core.findDate(source, EndRange, false);
 if BeginBar~=-1 and EndBar~=-1 then
  HighBorder[period+Multiplier]=core.max(source.high, core.range(BeginBar,EndBar));
  LowBorder[period+Multiplier]=core.min(source.low, core.range(BeginBar,EndBar));
 end
 return;
end

function Update(period, mode)
 if (period<first) then
 return;
 end
 
  DrawBorders(period);
  if period==source:size()-1 then
   local i;
   for i=1, Multiplier, 1 do
    DrawBorders(period-i);
   end 
  end
 
end

