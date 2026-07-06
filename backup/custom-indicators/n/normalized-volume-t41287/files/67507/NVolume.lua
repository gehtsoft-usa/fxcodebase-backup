-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41287
-- Id: 9324

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("NVolume oscillator");
    indicator:description("NVolume oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 24);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Nclr", "Negative color", "Negative color", core.rgb(0, 128, 192));
    indicator.parameters:addColor("Pclr1", "Positive color 1", "Positive color 1", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Pclr2", "Positive color 2", "Positive color 2", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Pclr3", "Positive color 3", "Positive color 3", core.rgb(255, 128, 64));
    indicator.parameters:addColor("Pclr4", "Positive color 4", "Positive color 4", core.rgb(255, 255, 0));
end

local first;
local source = nil;
local Period;
local MVA;
local NVolume=nil;

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
    NVolume = instance:addStream("NVolume", core.Bar, name .. ".NVolume", "NVolume", instance.parameters.Nclr, first);
    NVolume:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   NVolume:setColor(period, instance.parameters.Pclr4);
   return;
   end
   
    MVA:update(mode);
    NVolume[period]=source.volume[period]/MVA.DATA[period]*100-100;
    if NVolume[period]<0 then
     NVolume:setColor(period, instance.parameters.Nclr);
    elseif NVolume[period]<38.2 then
     NVolume:setColor(period, instance.parameters.Pclr1);
    elseif NVolume[period]<61.8 then
     NVolume:setColor(period, instance.parameters.Pclr2);
    elseif NVolume[period]<100 then
     NVolume:setColor(period, instance.parameters.Pclr3);
    else
     NVolume:setColor(period, instance.parameters.Pclr4);
    end
 
end

