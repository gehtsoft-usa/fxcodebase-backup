-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12832
-- Id: 5725

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
    indicator:name("ColorXWPR oscillator");
    indicator:description("ColorXWPR oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("DPeriod", "DPeriod", "", 15);
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
    indicator.parameters:addInteger("SPeriod", "SPeriod", "", 7);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("WPR_Clr", "WPR Color", "WPR Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SignalUP_Clr", "Signal UP Color", "Signal UP Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SignalDN_Clr", "Signal DN Color", "Signal DN Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local DPeriod;
local Method;
local SPeriod;
local Price;
local Tsource;
local MA;
local WPR=nil;
local XWPR=nil;

function Prepare(nameOnly)
    source = instance.source;
    DPeriod=instance.parameters.DPeriod;
    Method=instance.parameters.Method;
    SPeriod=instance.parameters.SPeriod;
    Price=instance.parameters.Price;
 
    if Price=="close" then
     Tsource=source.close;
    elseif Price=="open" then
     Tsource=source.open;
    elseif Price=="high" then
     Tsource=source.high;
    elseif Price=="low" then
     Tsource=source.low;
    elseif Price=="median" then
     Tsource=source.median;
    elseif Price=="typical" then
     Tsource=source.typical;
    else
     Tsource=source.weighted;
    end 
	   first = source:first()+DPeriod;
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.DPeriod .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.SPeriod .. ", " .. instance.parameters.Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    WPR = instance:addStream("WPR", core.Line, name .. ".WPR", "WPR", instance.parameters.WPR_Clr, first);
    MA = core.indicators:create("AVERAGES", WPR, Method, SPeriod, false);
    XWPR = instance:addStream("XWPR", core.Line, name .. ".XWPR", "XWPR", instance.parameters.SignalUP_Clr,  MA.DATA:first());
    WPR:setWidth(instance.parameters.widthLinReg);
    WPR:setStyle(instance.parameters.styleLinReg);
    XWPR:setWidth(instance.parameters.widthLinReg);
    XWPR:setStyle(instance.parameters.styleLinReg);
	
	WPR:setPrecision(math.max(2, instance.source:getPrecision()));
	XWPR:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
   
    local LL,HH=mathex.minmax(source ,period-DPeriod+1, period);
  --  local LL=core.min(source.low,core.rangeTo(period,DPeriod));
    if HH~=LL then
     WPR[period]=-(HH-Tsource[period])*100/(HH-LL);
    else
     WPR[period]=WPR[period-1];
    end
	
	if period < MA.DATA:first() then
	return;
	end
	
    MA:update(mode);		
    XWPR[period]=MA.DATA[period];
    if XWPR[period]>XWPR[period-1] then
     XWPR:setColor(period,instance.parameters.SignalUP_Clr);
    else
     XWPR:setColor(period,instance.parameters.SignalDN_Clr);
    end
   
end

