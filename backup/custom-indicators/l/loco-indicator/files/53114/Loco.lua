-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31123
-- Id: 8351

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
    indicator:name("Loco indicator");
    indicator:description("Loco indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Coeff", "Coeff", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local Coeff;
local Loco=nil;

function Prepare(nameOnly)
    source = instance.source;
    Coeff=instance.parameters.Coeff/1000;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Coeff .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Loco = instance:addStream("Loco", core.Dot, name .. ".Loco", "Loco", instance.parameters.UPclr, first);
    Loco:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first then
    if source[period]==Loco[period-1] then
     Loco[period]=Loco[period-1];
    elseif source[period-1]>Loco[period-1] and source[period]>Loco[period-1] then
     Loco[period]=math.max(Loco[period-1], source[period]*(1-Coeff));
    elseif source[period]>Loco[period-1] then
     Loco[period]=source[period]*(1-Coeff);
    else
     Loco[period]=source[period]*(1+Coeff);
    end
    if Loco[period]>=source[period] then
     Loco:setColor(period, instance.parameters.UPclr);
    else
     Loco:setColor(period, instance.parameters.DNclr);
    end
   end 
end

