-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64543
-- Id: 17861

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
    indicator:name("Normalized Volume");
    indicator:description("Normalized Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Negative", "Negative color", "Negative color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Positive", "Positive color", "Positive color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Neutral", "Neutral color", "Neutral color", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local Period;
local MVA;
local Normalized=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MVA = core.indicators:create("MVA", source.volume, Period);	
	first = MVA.DATA:first();
    Normalized = instance:addStream("Normalized", core.Bar, name .. ".Normalized", "Normalized", instance.parameters.Neutral, first);
    Normalized:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   Normalized:setColor(period, instance.parameters.Neutral);
   return;
   end
   
    MVA:update(mode);
    Normalized[period]=source.volume[period]/MVA.DATA[period]*100;
	
	
    if Normalized[period]>100 then
     Normalized:setColor(period, instance.parameters.Positive);
    elseif Normalized[period]<100 then
     Normalized:setColor(period, instance.parameters.Negative);
   else
     Normalized:setColor(period, instance.parameters.Neutral);
    end
 
end

