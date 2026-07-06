-- Id: 5618
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Volatility Quality trigger");
    indicator:description("Volatility Quality trigger");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
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

function Prepare()
    source = instance.source;
    Length=instance.parameters.Length;
    Method=instance.parameters.Method;
    Smoothing=instance.parameters.Smoothing;
    Filter=instance.parameters.Filter;
    MainPrice=instance.parameters.MainPrice;
    first = source:first()+2;
    Dir = instance:addInternalStream(first, 0);
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "AVERAGES" .. " indicator must be installed");
    MA_H = core.indicators:create("AVERAGES", source.high, Method, Length, false);
    MA_L = core.indicators:create("AVERAGES", source.low, Method, Length, false);
    MA_O = core.indicators:create("AVERAGES", source.open, Method, Length, false);
    if MainPrice=="close" then
     MA_C = core.indicators:create("AVERAGES", source.close, Method, Length, false);
    else
     MA_C = core.indicators:create("AVERAGES", source.median, Method, Length, false);
    end 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Smoothing .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.MainPrice .. ")";
    instance:name(name);
    VQ = instance:addStream("VQ", core.Bar, name .. ".VQ", "VQ", instance.parameters.UPclr, first);
    VQ:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first+Smoothing) then
    MA_H:update(mode);
    MA_L:update(mode);
    MA_O:update(mode);
    MA_C:update(mode);
    local Max=math.max(MA_H.DATA[period]-MA_L.DATA[period],MA_H.DATA[period]-MA_C.DATA[period-Smoothing],MA_C.DATA[period-Smoothing]-MA_L.DATA[period]);
    local VQ_=0.25*math.abs((MA_C.DATA[period]-MA_C.DATA[period-Smoothing])/Max+(MA_C.DATA[period]-MA_O.DATA[period])/(MA_H.DATA[period]-MA_L.DATA[period]))*(2*MA_C.DATA[period]-MA_C.DATA[period-Smoothing]-MA_O.DATA[period]);
    Dir[period]=Dir[period-1];
    if math.abs(VQ_)>=Filter*source:pipSize() then
     if VQ_>0 then
      Dir[period]=1;
     else
      Dir[period]=-1;
     end
    end 
    if Dir[period]>0 and Dir[period-1]<=0 then 
     VQ[period]=1;
     VQ:setColor(period,instance.parameters.UPclr);
    elseif Dir[period]<0 and Dir[period-1]>=0 then
     VQ[period]=-1;
     VQ:setColor(period,instance.parameters.DNclr);
    else
     VQ[period]=0; 
    end
   elseif period<=first+Smoothing then
    Dir[period]=0;
    VQ[period]=0; 
   end 
end

