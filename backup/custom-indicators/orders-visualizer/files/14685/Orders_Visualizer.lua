-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6395
-- Id: 4558

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Orders visualizer indicator");
    indicator:description("Orders visualizer indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("OrderType", "Order type", "", "BUY");
    indicator.parameters:addStringAlternative("OrderType", "BUY", "", "BUY");
    indicator.parameters:addStringAlternative("OrderType", "SELL", "", "SELL");
    indicator.parameters:addString("StartPrice", "Start price", "", "open");
    indicator.parameters:addStringAlternative("StartPrice", "open", "", "open");
    indicator.parameters:addStringAlternative("StartPrice", "close", "", "close");
    indicator.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    indicator.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LimitClr", "Limit Color", "Limit Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("StopClr", "Stop Color", "Stop Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("UnknownClr", "Unknown Color", "Unknown Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local OrderType;
local StartPrice;
local Limit;
local Stop;
local Result=nil;

function Prepare(nameOnly)
    source = instance.source;
    OrderType=instance.parameters.OrderType;
    StartPrice=instance.parameters.StartPrice;
    Limit=instance.parameters.Limit;
    Stop=instance.parameters.Stop;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OrderType .. ", " .. instance.parameters.StartPrice .. ", " .. instance.parameters.Limit .. ", " .. instance.parameters.Stop .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Result = instance:addStream("Result", core.Dot, name .. ".Result", "Result", instance.parameters.UnknownClr, first);
    Result:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>=first) then
    local i;
    local FirstPrice;
    if StartPrice=="open" then
     i=period;
     FirstPrice=source.open[period];
    else
     i=period+1;
     FirstPrice=source.close[period];
    end
    local LimitCross=false;
    local StopCross=false;
    while (i<=source:size()-1 and LimitCross==false and StopCross==false) do
     if OrderType=="BUY" then
      if source.high[i]-FirstPrice>=Limit*source:pipSize() then
       LimitCross=true;
      end
      if FirstPrice-source.low[i]>=Stop*source:pipSize() then
       StopCross=true;
      end
     else
      if source.high[i]-FirstPrice>=Stop*source:pipSize() then
       StopCross=true;
      end
      if FirstPrice-source.low[i]>=Limit*source:pipSize() then
       LimitCross=true;
      end
     end 
     i=i+1;
    end
    if LimitCross and StopCross then
     Result[period]=FirstPrice;
     Result:setColor(period,instance.parameters.UnknownClr);
    elseif LimitCross then
     Result[period]=FirstPrice;
     Result:setColor(period,instance.parameters.LimitClr);
    elseif StopCross then
     Result[period]=FirstPrice;
     Result:setColor(period,instance.parameters.StopClr);
    end
   end 
end

