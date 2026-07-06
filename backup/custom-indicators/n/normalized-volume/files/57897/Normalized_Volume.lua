-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34058
-- Id: 8870

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
    indicator:name("Normalized volume");
    indicator:description("Normalized volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Period", "Period", "", "Hour");
    indicator.parameters:addStringAlternative("Period", "Minute", "", "Minute");
    indicator.parameters:addStringAlternative("Period", "Hour", "", "Hour");
    indicator.parameters:addStringAlternative("Period", "Day", "", "Day");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local Coeff;
local NV=nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    NV = instance:addStream("NV", core.Bar, name .. ".NV", "NV", instance.parameters.clr, first);
    NV:setPrecision(math.max(2, instance.source:getPrecision()));
    if instance.parameters.Period=="Minute" then
     Coeff=1440;
    elseif instance.parameters.Period=="Hour" then
     Coeff=24;
    else
     Coeff=1;
    end
end

function Update(period, mode)
   if period>first then
    local T;
    if period==source:size()-1 then
     T=core.now()-source:date(period-1);
    else
     T=source:date(period)-source:date(period-1);
    end
    if T>0 then
     NV[period]=source.volume[period]/(T*Coeff);
    end 
   end 
end

