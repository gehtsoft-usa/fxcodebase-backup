-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41464
-- Id: 9396

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
    indicator:name("Z cloud indicator");
    indicator:description("Z cloud indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("ki", "ki", "", 2);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local ki;
local Pbuff=nil;
local Mbuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    ki=instance.parameters.ki;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ki .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first);
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, first);
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if period>first then
    if (source[period]>Pbuff[period-1] and source[period]>source[period-1]) or (source[period]<Pbuff[period-1] and source[period]<source[period-1]) then
     Pbuff[period]=Pbuff[period-1]+(source[period]-Pbuff[period-1])/ki;
    else
     Pbuff[period]=Pbuff[period-1];
    end 
    
    if (source[period]>Mbuff[period-1] and source[period]<source[period-1]) or (source[period]<Mbuff[period-1] and source[period]>source[period-1]) then
     Mbuff[period]=Mbuff[period-1]+(source[period]-Mbuff[period-1])/ki;
    else
     Mbuff[period]=Mbuff[period-1];
    end 
    
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
    
   end 
end

