-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23386
-- Id: 7394

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
    indicator:name("Simple ZigZag indicator");
    indicator:description("Simple ZigZag indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "", "Pips");
    indicator.parameters:addStringAlternative("Method", "Percent", "", "Percent");
    indicator.parameters:addDouble("Step", "Step (pips or percent)", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "Dn Color", "Dn Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Step, StepPoint;
local Method;
local Direction;
local MinBar, MaxBar;
local MaxPrice, MinPrice;

function Prepare(nameOnly)
    source = instance.source;
    Step=instance.parameters.Step;
    Method=instance.parameters.Method;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Step .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Direction=instance:addInternalStream(first, 0);
    MinBar=instance:addInternalStream(first, 0);
    MaxBar=instance:addInternalStream(first, 0);
    MinPrice=instance:addInternalStream(first, 0);
    MaxPrice=instance:addInternalStream(first, 0);
    StepPoint=Step*source:pipSize();
end

function Draw(price1, period1, price2, period2)
 if price2>=price1 then
  core.host:execute("drawLine", 2*period1, source:date(period1), price1, source:date(period2), price2, instance.parameters.UPclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
 else
  core.host:execute("drawLine", 2*period1+1, source:date(period1), price1, source:date(period2), price2, instance.parameters.DNclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
 end 
 return;
end

function CalculateUp(period, price)
 local LastBar=MaxBar[period];
 if MaxPrice[LastBar]==nil or MaxPrice[LastBar]==0 then
  MaxPrice[LastBar]=source.high[LastBar];
 end
 if price>MaxPrice[LastBar] then
  MaxPrice[LastBar]=nil;
  MaxPrice[period]=price;
  MaxBar[period]=period;
  LastBar=period;
  if MinBar[period]~=nil then
   Draw(MinPrice[MinBar[period]],MinBar[period],price,period);
  end 
 end
 if (price+StepPoint<MaxPrice[LastBar] and Method=="Pips") or (price*(1+Step/100)<MaxPrice[LastBar] and Method=="Percent") then
  Direction[period]=-1;
  MinPrice[period]=price;
  MinBar[period]=period;
  if MaxBar[period]~=nil then
   Draw(MaxPrice[MaxBar[period]],MaxBar[period],price,period);
  end 
 end
 return;
end

function CalculateDn(period, price)
 local LastBar=MinBar[period];
 if MinPrice[LastBar]==nil or MinPrice[LastBar]==0 then
  MinPrice[LastBar]=source.low[LastBar];
 end
 if price<MinPrice[LastBar] then
  MinPrice[LastBar]=nil;
  MinPrice[period]=price;
  MinBar[period]=period;
  LastBar=period;
  if MaxBar[period]~=nil then
   Draw(MaxPrice[MaxBar[period]],MaxBar[period],price,period);
  end 
 end
 if (price-StepPoint>MinPrice[LastBar] and Method=="Pips") or (price*(1-Step/100)>MinPrice[LastBar] and Method=="Percent") then
  Direction[period]=1;
  MaxPrice[period]=price;
  MaxBar[period]=period;
  if MinBar[period]~=nil then
   Draw(MinPrice[MinBar[period]],MinBar[period],price,period);
  end 
 end
 return;
end

function Calculate(period, price)
 if Direction[period]==1 then
  CalculateUp(period, price);
 else
  CalculateDn(period, price);
 end
 return;
end

function Update(period, mode)
   if period>first and period<=source:size()-1 then
    MinBar[period]=MinBar[period-1];
    MaxBar[period]=MaxBar[period-1];
    Direction[period]=Direction[period-1];
    MinPrice[period]=nil;
    MaxPrice[period]=nil;
    if source.close[period]<source.open[period] then
     Calculate(period, source.high[period]);
     Calculate(period, source.low[period]);
    else
     Calculate(period, source.low[period]);
     Calculate(period, source.high[period]);
    end
   elseif period==first then  
    Direction[period]=1;
    MinBar[period]=period;
    MaxBar[period]=period;
    if source.close[period]>source.open[period] then
     MinPrice[period]=source.high[period];
     MaxPrice[period]=source.high[period];
    else
     MinPrice[period]=source.low[period];
     MaxPrice[period]=source.low[period];
    end 
   end 
end

