-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41467
-- Id: 9397

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
    indicator:name("Ichimoku average indicator");
    indicator:description("Ichimoku average indicator");
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
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("Tenkan_Period", "Tenkan period", "", 8);
    indicator.parameters:addInteger("Kijun_Period", "Kijun period", "", 24);
    indicator.parameters:addInteger("Senkou_Period", "Senkou period", "", 48);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tclr", "Tenkan Sen color", "Tenkan Sen color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Twidth", "Tenkan Sen width", "Tenkan Sen width", 1, 1, 5);
    indicator.parameters:addInteger("Tstyle", "Tenkan Sen style", "Tenkan Sen style", core.LINE_SOLID);
    indicator.parameters:setFlag("Tstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Kclr", "Kijun Sen color", "Kijun Sen color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Kwidth", "Kijun Sen width", "Kijun Sen width", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "Kijun Sen style", "Kijun Sen style", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Cclr", "Chinkou Span color", "Chinkou Span color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Cwidth", "Chinkou Span width", "Chinkou Span width", 1, 1, 5);
    indicator.parameters:addInteger("Cstyle", "Chinkou Span style", "Chinkou Span style", core.LINE_SOLID);
    indicator.parameters:setFlag("Cstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SAclr", "Senkou Span A color", "Senkou Span A color", core.rgb(255, 255, 128));
    indicator.parameters:addInteger("SAwidth", "Senkou Span A width", "Senkou Span A width", 1, 1, 5);
    indicator.parameters:addInteger("SAstyle", "Senkou Span A style", "Senkou Span A style", core.LINE_DASH);
    indicator.parameters:setFlag("SAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SBclr", "Senkou Span B color", "Senkou Span B color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("SBwidth", "Senkou Span B width", "Senkou Span B width", 1, 1, 5);
    indicator.parameters:addInteger("SBstyle", "Senkou Span B style", "Senkou Span B style", core.LINE_DASH);
    indicator.parameters:setFlag("SBstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local C_First;
local source = nil;
local Method;
local Price;
local Tenkan_Period;
local Kijun_Period;
local Senkou_Period;
local T_MA, K_MA, S_MA;
local Tenkan=nil;
local Kijun=nil;
local Chinkou=nil;
local SenkouA=nil;
local SenkouB=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Price=instance.parameters.Price;
    Tenkan_Period=instance.parameters.Tenkan_Period;
    Kijun_Period=instance.parameters.Kijun_Period;
    Senkou_Period=instance.parameters.Senkou_Period;
    
    local src;
    if Price=="close" then
     src=source.close;
    elseif Price=="open" then
     src=source.open;
    elseif Price=="high" then
     src=source.high;
    elseif Price=="low" then
     src=source.low;
    elseif Price=="median" then
     src=source.median;
    elseif Price=="typical" then
     src=source.typical;
    else
     src=source.weighted;
    end 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Price .. ", " .. instance.parameters.Tenkan_Period .. ", " .. instance.parameters.Kijun_Period .. ", " .. instance.parameters.Senkou_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
	
    T_MA = core.indicators:create("AVERAGES", src, Method, Tenkan_Period);
    K_MA = core.indicators:create("AVERAGES", src, Method, Kijun_Period);
    S_MA = core.indicators:create("AVERAGES", src, Method, Senkou_Period);
	
	first = math.max( T_MA.DATA:first(),K_MA.DATA:first(),S_MA.DATA:first());
    Tenkan = instance:addStream("Tenkan", core.Line, name .. ".Tenkan Sen", "Tenkan Sen", instance.parameters.Tclr, first+Tenkan_Period-1);
    Tenkan:setWidth(instance.parameters.Twidth);
    Tenkan:setStyle(instance.parameters.Tstyle);
    Kijun = instance:addStream("Kijun", core.Line, name .. ".Kijun Sen", "Kijun Sen", instance.parameters.Kclr, first+Kijun_Period-1);
    Kijun:setWidth(instance.parameters.Kwidth);
    Kijun:setStyle(instance.parameters.Kstyle);
    Chinkou = instance:addStream("Chinkou", core.Line, name .. ".Chinkou Span", "Chinkou Span", instance.parameters.Cclr, first, -Kijun_Period);
    Chinkou:setWidth(instance.parameters.Cwidth);
    Chinkou:setStyle(instance.parameters.Cstyle);
    SenkouA = instance:addStream("SenkouA", core.Line, name .. ".Senkou Span A", "Senkou Span A", instance.parameters.SAclr, math.max(Tenkan:first(), Kijun:first()), Kijun_Period);
    SenkouA:setWidth(instance.parameters.SAwidth);
    SenkouA:setStyle(instance.parameters.SAstyle);
    SenkouB = instance:addStream("SenkouB", core.Line, name .. ".Senkou Span B", "Senkou Span B", instance.parameters.SBclr, first+Senkou_Period-1, Kijun_Period);
    SenkouB:setWidth(instance.parameters.SBwidth);
    SenkouB:setStyle(instance.parameters.SBstyle);
    instance:createChannelGroup("SA-SB", "SA-SB", SenkouA, SenkouB, instance.parameters.SAclr, 100 - instance.parameters.Transparency);
    C_First=Chinkou:first()+Kijun_Period;
end

function Update(period, mode)
   if period>first then
    T_MA:update(mode);
    K_MA:update(mode);
    S_MA:update(mode);
    Tenkan[period]=T_MA.DATA[period];
    Kijun[period]=K_MA.DATA[period];
    SenkouA[period+Kijun_Period]=(Tenkan[period]+Kijun[period])/2;
    SenkouB[period+Kijun_Period]=S_MA.DATA[period];
    if period>C_First then
     Chinkou[period-Kijun_Period]=source.close[period];
    end 
    if SenkouA[period]>SenkouB[period] then
     SenkouA:setColor(period, instance.parameters.SAclr);
     SenkouB:setColor(period, instance.parameters.SAclr);
    else
     SenkouA:setColor(period, instance.parameters.SBclr);
     SenkouB:setColor(period, instance.parameters.SBclr);
    end
   end 
end

