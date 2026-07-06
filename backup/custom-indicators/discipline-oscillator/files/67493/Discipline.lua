-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41273
-- Id: 9315

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Discipline oscillator");
    indicator:description("Discipline oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addString("Price", "Price", "", "0");
    indicator.parameters:addStringAlternative("Price", "close", "", "0");
    indicator.parameters:addStringAlternative("Price", "open", "", "1");
    indicator.parameters:addStringAlternative("Price", "high", "", "2");
    indicator.parameters:addStringAlternative("Price", "low", "", "3");
    indicator.parameters:addStringAlternative("Price", "median", "", "4");
    indicator.parameters:addStringAlternative("Price", "typical", "", "5");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "6");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PUclr", "Positive UP color", "Positive UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("PDclr", "Positive DN color", "Positive DN color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("NUclr", "Negative UP color", "Negative UP color", core.rgb(128, 0, 64));
    indicator.parameters:addColor("NDclr", "Negative DN color", "Negative DN color", core.rgb(255, 128, 255));
end

local first;
local source = nil;
local Period;
local Price;
local TickSource;
local Value;
local D=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Price=tonumber(instance.parameters.Price);
    first = source:first()+ Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Value = instance:addInternalStream(first, 0);
    D = instance:addStream("D", core.Bar, name .. ".D", "D", instance.parameters.PUclr, first);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
   if Price==0 then
    TickSource = source.close;
   elseif Price==1 then
    TickSource = source.open;
   elseif Price==2 then
    TickSource = source.high;
   elseif Price==3 then
    TickSource = source.low;
   elseif Price==4 then
    TickSource = source.median;
   elseif Price==5 then
    TickSource = source.typical;
   else
     TickSource = source.wieghted;
   end
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local Min, Max = mathex.minmax(source, period-Period+1, period);
    local Range=Max-Min;
    if Range~=0 then
     Value[period]=((TickSource[period]-Min)/Range-0.5+Value[period-1])*2/3;
    else
     Value[period]=0.999;
    end
    Value[period]=math.min(math.max(Value[period], -0.999), 0.999);
    D[period]=(math.log(1+Value[period])/(1-Value[period])+D[period-1])/2;
    if D[period]>0 then
     if D[period]>=D[period-1] then
      D:setColor(period, instance.parameters.PUclr);
     else
      D:setColor(period, instance.parameters.PDclr);
     end
    else
     if D[period]>=D[period-1] then
      D:setColor(period, instance.parameters.NUclr);
     else
      D:setColor(period, instance.parameters.NDclr);
     end
    end
  
end

