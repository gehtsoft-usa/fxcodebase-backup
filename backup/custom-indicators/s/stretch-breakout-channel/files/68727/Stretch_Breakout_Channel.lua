-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42262
-- Id: 9431

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
    indicator:name("Stretch breakout channel indicator");
    indicator:description("Stretch breakout channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("St_Period", "St_Period", "", 10);
    indicator.parameters:addString("Method", "Method", "", "SMMA");
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper line color", "Upper line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Uwidth", "Upper line width", "Upper line width", 2, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper line style", "Upper line style", core.LINE_DASH);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower line color", "Lower line color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("Lwidth", "Lower line width", "Lower line width", 2, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower line style", "Lower line style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local St_Period;
local Method;
local Abs_HO_LO;
local Abs_LO;
local MA;
local Upper=nil;
local Lower=nil;

function Prepare(nameOnly)
    source = instance.source;
    St_Period=instance.parameters.St_Period;
    Method=instance.parameters.Method;
	
 
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.St_Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Abs_HO_LO = instance:addInternalStream(0, 0);
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first+St_Period);
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first+St_Period);
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
end

function Update(period, mode)
   if period>first then
    local Abs_HO=math.abs(source.high[period]-source.open[period]);
    local Abs_LO=math.abs(source.low[period]-source.open[period]);
    Abs_HO_LO[period]=math.min(Abs_HO, Abs_LO);
    if period>first+St_Period then
     local Avg=mathex.avg(Abs_HO_LO, period-St_Period+1, period);
     Upper[period]=source.open[period]+Avg;
     Lower[period]=source.open[period]-Avg;
    end
   end 
end

