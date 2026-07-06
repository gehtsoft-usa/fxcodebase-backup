-- Id: 4524
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6302

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
    indicator:name("Entry Signal indicator");
    indicator:description("Entry Signal indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 9);
    indicator.parameters:addDouble("Level", "Level", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Line width", 3, 1, 5);
end

local first;
local source = nil;
local Period;
local Level;
local RangeStream;
local TriggerStream;
local Buff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Level=instance.parameters.Level;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Level .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RangeStream=instance:addInternalStream(first, 0);
    TriggerStream=instance:addInternalStream(first, 0);
    Buff = instance:addStream("Buff", core.Dot, name .. ".Buff", "Buff", instance.parameters.clrUP, first);
    Buff:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>first) then
    RangeStream[period]=source.high[period]-source.low[period];
    TriggerStream[period]=nil;
    if (period>first+Period) then
     local Range=mathex.lwma(RangeStream,core.rangeTo(period,Period));
     local MaxPrice=core.max(source.high,core.rangeTo(period,Period));
     local MinPrice=core.min(source.low,core.rangeTo(period,Period));
     TriggerStream[period]=TriggerStream[period-1];
     if source.close[period]<MinPrice+(MaxPrice-MinPrice)*Level/100 and TriggerStream[period-1]~=-1 then
      Buff[period]=source.low[period]-Range/2;
      Buff:setColor(period,instance.parameters.clrDN);
      TriggerStream[period]=-1;
     end
     if source.close[period]>MaxPrice-(MaxPrice-MinPrice)*Level/100 and TriggerStream[period-1]~=1 then
      Buff[period]=source.high[period]+Range/2;
      Buff:setColor(period,instance.parameters.clrUP);
      TriggerStream[period]=1;
     end
    end
   end 
end

