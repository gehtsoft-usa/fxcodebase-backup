-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36262
-- Id: 9092

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
    indicator:name("Vo oscillator");
    indicator:description("Vo oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addString("Smooth_Method", "Smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Smooth_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Smooth_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Smooth_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Smooth_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Smooth_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Smooth_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Smooth_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Smooth_Period", "Smooth period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Smooth_Method;
local Smooth_Period;
local Range;
local MA;
local Vo=nil;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Smooth_Method=instance.parameters.Smooth_Method;
    Smooth_Period=instance.parameters.Smooth_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smooth_Method .. ", " .. instance.parameters.Smooth_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    Range=instance:addInternalStream(source:first(), 0);
    MA=core.indicators:create("AVERAGES", Range, Smooth_Method, Smooth_Period, false);
	
	 first = MA.DATA:first();
    Vo = instance:addStream("Vo", core.Line, name .. ".Vo", "Vo", instance.parameters.clr, first);
    Vo:setPrecision(math.max(2, instance.source:getPrecision()));
    Vo:setWidth(instance.parameters.widthLinReg);
    Vo:setStyle(instance.parameters.styleLinReg);
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period<Period  then
   return;
   end
    local MinL, MaxH = mathex.minmax(source, period-Period+1, period);
    Range[period]=(MaxH-MinL)/pipSize;
	
	if period<first  then
   return;
   end
    MA:update(mode);
    Vo[period]=MA.DATA[period];
 
end

