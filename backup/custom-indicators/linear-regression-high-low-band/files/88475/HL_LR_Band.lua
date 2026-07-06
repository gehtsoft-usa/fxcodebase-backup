-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59058
-- Id: 9688

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
    indicator:name("HL_LR_Band indicator");
    indicator:description("HL_LR_Band indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Cclr", "Constriction color", "Constriction color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("Eclr", "Expansion color", "Expansion color", core.rgb(255, 255, 128));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Period;
local LR_H, LR_L;
local Hbuff=nil;
local Lbuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("LINEAR REGRESSION LINE") ~= nil, "Please, download and install LINEAR REGRESSION LINE.LUA indicator");   
	
    LR_H = core.indicators:create("LINEAR REGRESSION LINE", source.high, Period);
    LR_L = core.indicators:create("LINEAR REGRESSION LINE", source.low, Period);
	
	first = LR_L.DATA:first();
    Hbuff = instance:addStream("Hbuff", core.Line, name .. ".Hbuff", "Hbuff", instance.parameters.UPclr, first);
    Lbuff = instance:addStream("Lbuff", core.Line, name .. ".Lbuff", "Lbuff", instance.parameters.UPclr, first);
    instance:createChannelGroup("TC","TC" , Hbuff, Lbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if period>first then
    LR_H:update(mode);
    LR_L:update(mode);
    Hbuff[period]=LR_H.DATA[period];
    Lbuff[period]=LR_L.DATA[period];
    if Hbuff[period]>Hbuff[period-1] then
     if Lbuff[period]>Lbuff[period-1] then
      Hbuff:setColor(period, instance.parameters.UPclr);
      Lbuff:setColor(period, instance.parameters.UPclr);
     else
      Hbuff:setColor(period, instance.parameters.Eclr);
      Lbuff:setColor(period, instance.parameters.Eclr);
     end
    else
     if Lbuff[period]>Lbuff[period-1] then
      Hbuff:setColor(period, instance.parameters.Cclr);
      Lbuff:setColor(period, instance.parameters.Cclr);
     else
      Hbuff:setColor(period, instance.parameters.DNclr);
      Lbuff:setColor(period, instance.parameters.DNclr);
     end
    end
   end 
end

