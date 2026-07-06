-- Id: 5454
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10552

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("UpDownBars indicator");
    indicator:description("UpDownBars indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local UpDownBars=nil;
local up;
local down;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then 
        return;
    end
    up=instance:addInternalStream(0, 0);
    down=instance:addInternalStream(0, 0);
    UpDownBars = instance:addStream("UpDownBars", core.Bar, name .. ".UpDownBars", "UpDownBars", instance.parameters.UPclr, first);
    UpDownBars:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if  period<source:first() then
   return;
   end
   
     local Range=source.close[period]-source.open[period];
     if Range>0 then
      up[period]=math.sqrt(Range);
      down[period]=0;
     else
      up[period]=0;
      down[period]=math.sqrt(-Range);
     end
     if  period<= first then
     return;
     end
      UpDownBars[period]=mathex.lwma(up,period-Period+1, period)-mathex.lwma(down,period-Period+1, period);
      if UpDownBars[period]>0 then
       UpDownBars:setColor(period,instance.parameters.UPclr);
      else
       UpDownBars:setColor(period,instance.parameters.DNclr);
      end
     
    
end

