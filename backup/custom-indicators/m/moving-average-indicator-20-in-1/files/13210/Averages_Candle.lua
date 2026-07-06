--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Averages candle indicator");
    indicator:description("Averages candle indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
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

    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Method;
local ColorMode;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local MAopen;
local MAclose;
local MAhigh;
local MAlow;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    ColorMode=instance.parameters.ColorMode;
    
	
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    

    MAclose = core.indicators:create("AVERAGES", source.close, Method, Period, false);
    MAopen = core.indicators:create("AVERAGES", source.open, Method, Period, false);
    MAhigh = core.indicators:create("AVERAGES", source.high, Method, Period, false);
    MAlow = core.indicators:create("AVERAGES", source.low, Method, Period, false);
	
	first = MAclose.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("AVERAGES", "AVERAGES", open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    MAclose:update(mode);
    MAopen:update(mode);
    MAhigh:update(mode);
    MAlow:update(mode);
    close[period]=MAclose.DATA[period];
    open[period]=MAopen.DATA[period];
    high[period]=MAhigh.DATA[period];
    low[period]=MAlow.DATA[period];
    if ColorMode then
     if open[period]>close[period] then
      open:setColor(period,instance.parameters.DNclr); 
     else
      open:setColor(period,instance.parameters.UPclr);
     end
    else
     open:setColor(period,instance.parameters.MainClr);
    end
   end 
end

