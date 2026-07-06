-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3697
-- Id: 3393

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
    indicator:name("Fast MA indicator");
    indicator:description("Fast MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 40);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local Period;
local Buff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff = instance:addStream("Buff", core.Line, name .. ".Buff", "Buff", instance.parameters.clr, first);
    Buff:setWidth(instance.parameters.width);
    Buff:setStyle(instance.parameters.style);
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
   
    local i;
    local Sum=0;
    local SumW=0;
    local SumP=0;
    local SumP2=0;
    for i=0,Period-1,1 do
     Sum=Sum+source[period-i];
     SumW=SumW+source[period-i]*i;
     SumP=SumP+i;
     SumP2=SumP2+i*i;
    end
    local var3=SumP2*Period-SumP*SumP;
    local var2=(SumW*Period-SumP*Sum)/var3;
    local var1=(Sum-SumP*var2)/Period;
    Buff[period]=var1;
 
end

