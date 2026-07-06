-- Id: 6242
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

--                                 Symphonie Sentiment Indicator v3.0 


function Init()
    indicator:name("Symphonie Sentiment indicator");
    indicator:description("Symphonie Sentiment indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnClr", "Dn Color", "Dn Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local St;
local Symp_Sentiment=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    St=instance:addInternalStream(0, 0);
    Symp_Sentiment = instance:addStream("Symp_Sentiment", core.Bar, name .. ".Symp_Sentiment", "Symp_Sentiment", instance.parameters.UpClr, first);
    Symp_Sentiment:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    local Max=mathex.max(source.high, core.rangeTo(period, Period));
    local Min=mathex.min(source.low, core.rangeTo(period, Period));
    local St_Temp=0.66*((source.median[period]-Min)/(Max-Min)-0.5)+0.67*St[period-1];
    St_Temp=math.max(St_Temp,-1);
    St_Temp=math.min(St_Temp,1);
    St[period]=St_Temp;
    Symp_Sentiment[period]=(math.log((1+St[period])/(1-St[period]))+Symp_Sentiment[period-1])/2;
    if Symp_Sentiment[period]>=0 then
     Symp_Sentiment:setColor(period,instance.parameters.UpClr);
    else
     Symp_Sentiment:setColor(period,instance.parameters.DnClr);
    end
   end 
end

