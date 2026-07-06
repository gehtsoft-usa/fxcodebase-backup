-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31125
-- Id: 8356

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
    indicator:name("XMA_Range_Bands indicator");
    indicator:description("XMA_Range_Bands indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "Method1", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period1", "Period1", "", 100);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addString("Method2", "Method2", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period2", "Period2", "", 20);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("XMAclr", "XMA color", "XMA color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Upperclr", "Upper color", "Upper color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Lowerclr", "Lower color", "Lower color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("XMAwidth", "XMA width", "XMA width", 2, 1, 5);
    indicator.parameters:addInteger("XMAstyle", "XMA style", "XMA style", core.LINE_SOLID);
    indicator.parameters:setFlag("XMAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Bandwidth", "Band width", "Band width", 1, 1, 5);
    indicator.parameters:addInteger("Bandstyle", "Band style", "Band style", core.LINE_DASH);
    indicator.parameters:setFlag("Bandstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method1;
local Period1;
local Price;
local Method2;
local Period2;
local Deviation;
local Range;
local MA1;
local MA2;
local XMA=nil;
local Upper=nil;
local Lower=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method1=instance.parameters.Method1;
    Period1=instance.parameters.Period1;
    Price=instance.parameters.Price;
    Method2=instance.parameters.Method2;
    Period2=instance.parameters.Period2;
    Deviation=instance.parameters.Deviation;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Price .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    Range = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
    if Price=="open" then
     MA1 = core.indicators:create("AVERAGES", source.open, Method1, Period1, false);
    elseif Price=="high" then
     MA1 = core.indicators:create("AVERAGES", source.high, Method1, Period1, false);
    elseif Price=="low" then
     MA1 = core.indicators:create("AVERAGES", source.low, Method1, Period1, false);
    elseif Price=="close" then
     MA1 = core.indicators:create("AVERAGES", source.close, Method1, Period1, false);
    elseif Price=="median" then
     MA1 = core.indicators:create("AVERAGES", source.median, Method1, Period1, false);
    elseif Price=="typical" then
     MA1 = core.indicators:create("AVERAGES", source.typical, Method1, Period1, false);
    else
     MA1 = core.indicators:create("AVERAGES", source.weighted, Method1, Period1, false);
    end 
	
	
    MA2 = core.indicators:create("AVERAGES", Range, Method2, Period2, false);
	
	first = MA2.DATA:first()+2;
    XMA = instance:addStream("XMA", core.Line, name .. ".XMA", "XMA", instance.parameters.XMAclr, MA1.DATA:first());
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Upperclr, first);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lowerclr, first);
    XMA:setWidth(instance.parameters.XMAwidth);
    XMA:setStyle(instance.parameters.XMAstyle);
    Upper:setWidth(instance.parameters.Bandwidth);
    Upper:setStyle(instance.parameters.Bandstyle);
    Lower:setWidth(instance.parameters.Bandwidth);
    Lower:setStyle(instance.parameters.Bandstyle);
end

function Update(period, mode)
   
    Range[period]=source.high[period]-source.low[period];
		
    MA1:update(mode);
	
	if (period<MA1.DATA:first()) then
	return;
	end
	XMA[period]=MA1.DATA[period];
	  

    MA2:update(mode);
	
	if (period<first) then
	return;
	end
  
    Upper[period]=MA1.DATA[period]+MA2.DATA[period];
    Lower[period]=MA1.DATA[period]-MA2.DATA[period];
    
end

