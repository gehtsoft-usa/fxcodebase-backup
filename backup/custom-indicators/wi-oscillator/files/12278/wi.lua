-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4966
-- Id: 4226

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
    indicator:name("Wi indicator");
    indicator:description("Wi indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
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
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP_P", "Color Up +", "Color Up +", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN_P", "Color Dn +", "Color Dn +", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrEQ_P", "Color Eq +", "Color Eq +", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrUP_M", "Color Up -", "Color Up -", core.rgb(128, 255, 128));
    indicator.parameters:addColor("clrDN_M", "Color Dn -", "Color Dn -", core.rgb(255, 128, 64));
    indicator.parameters:addColor("clrEQ_M", "Color Eq -", "Color Eq -", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local Period;
local Method;
local APrice;
local MA;
local Buff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    APrice = instance:addInternalStream(0, 0);
    MA = core.indicators:create("AVERAGES", APrice, Method, Period, false);
	first = MA.DATA:first();
    Buff = instance:addStream("Buff", core.Bar, name .. ".Buff", "Buff", instance.parameters.clrUP_P, first);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   
   
    APrice[period]=2*source.close[period]-source.high[period]-source.low[period];
	if (period<first) then
	return;
	end
	
    MA:update(mode);
    Buff[period]=MA.DATA[period];
    if Buff[period]>0 then
     if Buff[period]>Buff[period-1] then
      Buff:setColor(period,instance.parameters.clrUP_P);
     elseif Buff[period]<Buff[period-1] then
      Buff:setColor(period,instance.parameters.clrDN_P);
     else
      Buff:setColor(period,instance.parameters.clrEQ_P);
     end
    else
     if Buff[period]>Buff[period-1] then
      Buff:setColor(period,instance.parameters.clrUP_M);
     elseif Buff[period]<Buff[period-1] then
      Buff:setColor(period,instance.parameters.clrDN_M);
     else
      Buff:setColor(period,instance.parameters.clrEQ_M);
     end
    end
 
    
end

