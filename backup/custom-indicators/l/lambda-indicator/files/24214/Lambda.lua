-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12225
-- Id: 5625

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
    indicator:name("Lambda indicator");
    indicator:description("Lambda indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Lambda", "Lambda", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BigClr", "Big Color", "Big Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SmallClr", "Small Color", "Small Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Lambda;
local BigBuff=nil;
local SmallBuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Lambda=instance.parameters.Lambda;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Lambda .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BigBuff = instance:addStream("BigBuff", core.Line, name .. ".Big", "Big", instance.parameters.BigClr, first);
    BigBuff:setWidth(instance.parameters.width1);
    BigBuff:setStyle(instance.parameters.style1);

    SmallBuff = instance:addStream("SmallBuff", core.Line, name .. ".Small", "Small", instance.parameters.SmallClr, first);
    SmallBuff:setWidth(instance.parameters.width2);
    SmallBuff:setStyle(instance.parameters.style2);

end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local d=source.open[period]-source.open[period-1];
    if math.abs(d)>Lambda*source:pipSize() then
     BigBuff[period]=BigBuff[period-1]+d;
     SmallBuff[period]=SmallBuff[period-1];
    else
     SmallBuff[period]=SmallBuff[period-1]+d;
     BigBuff[period]=BigBuff[period-1];
    end
  
end

