-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41316
-- Id: 9357

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
    indicator:name("BBflat_sw oscillator");
    indicator:description("BBflat_sw oscillator");
    indicator:requiredSource(core.Tick);
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
    indicator.parameters:addInteger("Period", "Period", "", 100);
    indicator.parameters:addInteger("BB_Period", "Bands period", "", 100);
    indicator.parameters:addDouble("BB_Deviation", "Bands deviation", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MAclr", "MA color", "MA color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("MAwidth", "MA line width", "MA line width", 3, 1, 5);
    indicator.parameters:addInteger("MAstyle", "MA line style", "MA line style", core.LINE_DASH);
    indicator.parameters:setFlag("MAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("BBclr", "Bands color", "Bands color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("BBwidth", "Band line width", "Band line width", 1, 1, 5);
    indicator.parameters:addInteger("BBstyle", "Band line style", "Band line style", core.LINE_SOLID);
    indicator.parameters:setFlag("BBstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method;
local Period;
local BB_Period;
local BB_Deviation;
local MA_Ind;
local BB_Ind;
local MA=nil;
local UpperBand=nil;
local LowerBand=nil;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    BB_Period=instance.parameters.BB_Period;
    BB_Deviation=instance.parameters.BB_Deviation;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.BB_Period .. ", " .. instance.parameters.BB_Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
  
    MA_Ind = core.indicators:create("AVERAGES", source, Method, Period, false);
    BB_Ind = core.indicators:create("BB", source, BB_Period, BB_Deviation);
	
	  first = math.max(MA_Ind.DATA:first(),BB_Ind.DATA:first());
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first);
    MA:setWidth(instance.parameters.MAwidth);
    MA:setStyle(instance.parameters.MAstyle);
    UpperBand = instance:addStream("UpperBand", core.Line, name .. ".UpperBand", "UpperBand", instance.parameters.BBclr, first);
    LowerBand = instance:addStream("LowerBand", core.Line, name .. ".LowerBand", "LowerBand", instance.parameters.BBclr, first);
    UpperBand:setWidth(instance.parameters.BBwidth);
    UpperBand:setStyle(instance.parameters.BBstyle);
    LowerBand:setWidth(instance.parameters.BBwidth);
    LowerBand:setStyle(instance.parameters.BBstyle);
    pipSize=source:pipSize();
	
	MA:setPrecision(math.max(2, instance.source:getPrecision()));	
	UpperBand:setPrecision(math.max(2, instance.source:getPrecision()));	
	LowerBand:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    MA_Ind:update(mode);
    BB_Ind:update(mode);
    MA[period]=(source[period]-MA_Ind.DATA[period])/pipSize;
    local BB_Range=(BB_Ind.TL[period]-BB_Ind.AL[period])/pipSize;
    UpperBand[period]=BB_Range;
    LowerBand[period]=-BB_Range;
   end 
end

