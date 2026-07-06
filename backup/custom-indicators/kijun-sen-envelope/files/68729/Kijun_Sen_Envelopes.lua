-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42264
-- Id: 9435

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
    indicator:name("Kijun Sen envelopes indicator");
    indicator:description("Kijun Sen envelopes indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Kijun_Sen_Period", "Kijun Sen period", "", 26);
    indicator.parameters:addInteger("Deviation", "Envelope deviation", "", 200);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("KSclr", "Kijun Sen color", "Kijun Sen color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("KSwidth", "Kijun Sen width", "Kijun Sen width", 3, 1, 5);
    indicator.parameters:addInteger("KSstyle", "Kijun Sen style", "Kijun Sen style", core.LINE_SOLID);
    indicator.parameters:setFlag("KSstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Uclr", "Upper envelope color", "Upper envelope color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Uwidth", "Upper envelope width", "Upper envelope width", 1, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper envelope style", "Upper envelope style", core.LINE_DASH);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower envelope color", "Lower envelope color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Lwidth", "Lower envelope width", "Lower envelope width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower envelope style", "Lower envelope style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Kijun_Sen_Period;
local Deviation;
local Kijun_Sen=nil;
local Upper=nil;
local Lower=nil;
local DeviationPip;

function Prepare(nameOnly)
    source = instance.source;
    Kijun_Sen_Period=instance.parameters.Kijun_Sen_Period;
    Deviation=instance.parameters.Deviation;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Kijun_Sen_Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Kijun_Sen = instance:addStream("Kijun_Sen", core.Line, name .. ".Kijun_Sen", "Kijun_Sen", instance.parameters.KSclr, first+Kijun_Sen_Period-1);
    Kijun_Sen:setWidth(instance.parameters.KSwidth);
    Kijun_Sen:setStyle(instance.parameters.KSstyle);
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first+Kijun_Sen_Period-1);
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first+Kijun_Sen_Period-1);
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
    DeviationPip=Deviation*source:pipSize();
end

function Update(period, mode)
   if period>first+Kijun_Sen_Period then
    local Min, Max = mathex.minmax(source, period-Kijun_Sen_Period+1, period);
    Kijun_Sen[period]=(Max+Min)/2;
    Upper[period]=Kijun_Sen[period]+DeviationPip;
    Lower[period]=Kijun_Sen[period]-DeviationPip;
   end 
end

