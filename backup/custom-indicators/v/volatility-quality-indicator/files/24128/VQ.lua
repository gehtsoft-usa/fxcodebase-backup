-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12170
-- Id: 5613

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
    indicator:name("Volatility Quality indicator");
    indicator:description("Volatility Quality indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "", 5);
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
    indicator.parameters:addInteger("Smoothing", "Smoothing", "", 1);
    indicator.parameters:addInteger("Filter", "Filter", "", 5);
    indicator.parameters:addString("MainPrice", "Main price", "", "close");
    indicator.parameters:addStringAlternative("MainPrice", "close", "", "close");
    indicator.parameters:addStringAlternative("MainPrice", "median", "", "median");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Length;
local Method;
local Smoothing;
local Filter;
local MainPrice;
local Dir;
local MA_H, MA_L, MA_O, MA_C;
local VQ=nil;

function Prepare(nameOnly)
    source = instance.source;
    Length=instance.parameters.Length;
    Method=instance.parameters.Method;
    Smoothing=instance.parameters.Smoothing;
    Filter=instance.parameters.Filter;
    MainPrice=instance.parameters.MainPrice;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Smoothing .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.MainPrice .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Dir = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
	
    MA_H = core.indicators:create("AVERAGES", source.high, Method, Length, false);
    MA_L = core.indicators:create("AVERAGES", source.low, Method, Length, false);
    MA_O = core.indicators:create("AVERAGES", source.open, Method, Length, false);
    if MainPrice=="close" then
     MA_C = core.indicators:create("AVERAGES", source.close, Method, Length, false);
    else
     MA_C = core.indicators:create("AVERAGES", source.median, Method, Length, false);
    end 
	
	first = MA_C.DATA:first()+Smoothing;
	 
    VQ = instance:addStream("VQ", core.Dot, name .. ".VQ", "VQ", instance.parameters.UPclr, first);
    VQ:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    MA_H:update(mode);
    MA_L:update(mode);
    MA_O:update(mode);
    MA_C:update(mode);
    local Max=math.max(MA_H.DATA[period]-MA_L.DATA[period],MA_H.DATA[period]-MA_C.DATA[period-Smoothing],MA_C.DATA[period-Smoothing]-MA_L.DATA[period]);
    local VQ_=0.25*math.abs((MA_C.DATA[period]-MA_C.DATA[period-Smoothing])/Max+(MA_C.DATA[period]-MA_O.DATA[period])/(MA_H.DATA[period]-MA_L.DATA[period]))*(2*MA_C.DATA[period]-MA_C.DATA[period-Smoothing]-MA_O.DATA[period]);
    if math.abs(VQ_)<Filter*source:pipSize() then
     Dir[period]=Dir[period-1];
    else 
     if VQ_>0 then
      Dir[period]=1;
     else
      Dir[period]=-1;
     end
    end 
    if Dir[period]>0 then 
     VQ[period]=MA_C.DATA[period];
     VQ:setColor(period,instance.parameters.UPclr);
    elseif Dir[period]<0 then
     VQ[period]=MA_C.DATA[period];
     VQ:setColor(period,instance.parameters.DNclr);
    end
   
end

