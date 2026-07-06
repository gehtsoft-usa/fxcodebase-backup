-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41461
-- Id: 9390

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
    indicator:name("XO oscillator");
    indicator:description("XO oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Range", "Range", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Range;
local dRange;
local Hi;
local Lo;
local XO=nil;

function Prepare(nameOnly)
    source = instance.source;
    Range=instance.parameters.Range;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Range .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Hi=instance:addInternalStream(first, 0);
    Lo=instance:addInternalStream(first, 0);
    XO = instance:addStream("XO", core.Bar, name .. ".XO", "XO", instance.parameters.UPclr, first);
    XO:setPrecision(math.max(2, instance.source:getPrecision()));
    dRange=Range*source:pipSize();
end

function Update(period, mode)
   if period>first then
    if source[period]>Hi[period-1]+dRange then
     Hi[period]=source[period];
     Lo[period]=Hi[period]-dRange;
     XO[period]=1;
    elseif source[period]<Lo[period-1]-dRange then
     Lo[period]=source[period];
     Hi[period]=Lo[period]+dRange;
     XO[period]=-1;
    else
     Hi[period]=Hi[period-1];
     Lo[period]=Lo[period-1];
     XO[period]=XO[period-1];
    end
    if XO[period]>0 then
     XO:setColor(period, instance.parameters.UPclr);
    else
     XO:setColor(period, instance.parameters.DNclr);
    end
   elseif period==first then
    Hi[period]=source[period];
    Lo[period]=source[period]; 
   end 
end

