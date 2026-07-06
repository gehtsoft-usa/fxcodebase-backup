-- Id: 6238
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15511

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
    indicator:name("Symphonie Extreme indicator");
    indicator:description("Symphonie Extreme indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SSP", "SSP", "", 7);
    indicator.parameters:addDouble("Kmax", "Kmax", "", 50.6);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnClr", "Dn Color", "Dn Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local SSP, Kmax;
local St;
local Symp_Emotion=nil;

function Prepare(nameOnly)
    source = instance.source;
    SSP=instance.parameters.SSP;
    Kmax=instance.parameters.Kmax;
    first = source:first()+SSP;
    local name = profile:id() .. "(" .. source:name() .. ", " .. SSP .. ", " .. Kmax .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    St=instance:addInternalStream(first, 0);
    Symp_Emotion = instance:addStream("Symp_Emotion", core.Bar, name .. ".Symp_Emotion", "Symp_Emotion", instance.parameters.UpClr, first);
    Symp_Emotion:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    local Max=mathex.max(source.high, core.rangeTo(period, SSP));
    local Min=mathex.min(source.low, core.rangeTo(period, SSP));
    St[period]=Max-(Max-Min)*Kmax/100;
    Symp_Emotion[period]=St[period];
    if St[period]>=St[period-SSP] then
     Symp_Emotion:setColor(period, instance.parameters.UpClr);
    else
     Symp_Emotion:setColor(period, instance.parameters.DnClr);
    end
   end 
end

