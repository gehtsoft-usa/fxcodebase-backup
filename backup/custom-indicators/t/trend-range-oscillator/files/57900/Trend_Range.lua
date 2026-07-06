-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34061
-- Id: 8875
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
    indicator:name("Trend Range oscillator");
    indicator:description("Trend Range oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

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
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(128, 128, 128));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 128));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method;
local Period;
local Deviation;
local MA;
local StdDev;
local TrendRange=nil;
local Level1=nil;
local Level2=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");   
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TrendRange = instance:addStream("TrendRange", core.Bar, name .. ".TrendRange", "TrendRange", instance.parameters.clr1, source:first());
    TrendRange:setPrecision(math.max(2, instance.source:getPrecision()));
	
    MA = core.indicators:create("AVERAGES", TrendRange, Method, Period, false);
    StdDev = core.indicators:create("STDDEV", TrendRange, Period);	
	first = MA.DATA:first();
	
	
    Level1 = instance:addStream("Level1", core.Line, name .. ".Level1", "Level1", instance.parameters.clr2, first);
    Level1:setPrecision(math.max(2, instance.source:getPrecision()));
    Level2 = instance:addStream("Level2", core.Line, name .. ".Level2", "Level2", instance.parameters.clr3, first);
    Level2:setPrecision(math.max(2, instance.source:getPrecision()));
    Level1:setWidth(instance.parameters.widthLinReg);
    Level1:setStyle(instance.parameters.styleLinReg);
    Level2:setWidth(instance.parameters.widthLinReg);
    Level2:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
  
   
    local res1=(source.high[period]-source.low[period])/source:pipSize();
    TrendRange[period]=res1*source.volume[period];
    MA:update(mode);
    StdDev:update(mode);
	
	 if period<first then
   return;
   end
   
    local Max=MA.DATA[period]+StdDev.DATA[period]*Deviation;
    local Flat=Max/2;
    Level1[period]=Flat;
    Level2[period]=Max;
    if TrendRange[period]>Max then
     TrendRange:setColor(period, instance.parameters.clr3);
    elseif TrendRange[period]>Flat then
     TrendRange:setColor(period, instance.parameters.clr2);
    else
     TrendRange:setColor(period, instance.parameters.clr1);
    end
   
end

