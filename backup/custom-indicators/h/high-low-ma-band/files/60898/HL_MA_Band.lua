-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36271
-- Id: 9105

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
    indicator:name("HL_MA_Band indicator");
    indicator:description("HL_MA_Band indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

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
local Method;
local MA_H, MA_L;
local Hbuff=nil;
local Lbuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    MA_H = core.indicators:create("AVERAGES", source.high, Method, Period, false);
    MA_L = core.indicators:create("AVERAGES", source.low, Method, Period, false);
	
	first = MA_H.DATA:first() ;
    Hbuff = instance:addStream("Hbuff", core.Line, name .. ".Hbuff", "Hbuff", instance.parameters.UPclr, first);
    Lbuff = instance:addStream("Lbuff", core.Line, name .. ".Lbuff", "Lbuff", instance.parameters.UPclr, first);
    instance:createChannelGroup("TC","TC" , Hbuff, Lbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if period<first then
   return;
   end
    MA_H:update(mode);
    MA_L:update(mode);
    Hbuff[period]=MA_H.DATA[period];
    Lbuff[period]=MA_L.DATA[period];
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

