-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41448
-- Id: 9371

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
    indicator:name("IINWMARROWS indicator");
    indicator:description("IINWMARROWS indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fast_MA_Period", "Fast MA period", "", 13);
    indicator.parameters:addString("Fast_MA_Method", "Fast MA method", "", "EMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Fast_MA_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Slow_MA_Period", "Slow MA period", "", 13);
    indicator.parameters:addString("Slow_MA_Method", "Slow MA method", "", "EMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Slow_MA_Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local Fast_MA_Period;
local Fast_MA_Method;
local Slow_MA_Period;
local Slow_MA_Method;
local Fast_MA, Slow_MA;
local UP=nil;
local DN=nil;

function Prepare(nameOnly)
    source = instance.source;
    Fast_MA_Period=instance.parameters.Fast_MA_Period;
    Fast_MA_Method=instance.parameters.Fast_MA_Method;
    Slow_MA_Period=instance.parameters.Slow_MA_Period;
    Slow_MA_Method=instance.parameters.Slow_MA_Method;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Fast_MA_Period .. ", " .. instance.parameters.Fast_MA_Method .. ", " .. instance.parameters.Slow_MA_Period .. ", " .. instance.parameters.Slow_MA_Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    Fast_MA = core.indicators:create("AVERAGES", source.close, Fast_MA_Method, Fast_MA_Period, false);
    Slow_MA = core.indicators:create("AVERAGES", source.open, Slow_MA_Method, Slow_MA_Period, false);
	
	 first = math.max(Fast_MA.DATA:first(),Slow_MA.DATA:first())
    UP=instance:createTextOutput ("UP", "UP", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.UPclr, 0);
    DN=instance:createTextOutput ("DN", "DN", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.DNclr, 0);
end

function Update(period, mode)
   if period>first then
    Fast_MA:update(mode);
    Slow_MA:update(mode);
    if Fast_MA.DATA[period-1]>Slow_MA.DATA[period-1] and Fast_MA.DATA[period-2]<Slow_MA.DATA[period-2] and Fast_MA.DATA[period]>Slow_MA.DATA[period] then
     UP:set(period, source.low[period], "\225");
    else
     UP:setNoData(period);
    end

    if Fast_MA.DATA[period-1]<Slow_MA.DATA[period-1] and Fast_MA.DATA[period-2]>Slow_MA.DATA[period-2] and Fast_MA.DATA[period]<Slow_MA.DATA[period] then
     DN:set(period, source.high[period], "\226");
    else
     DN:setNoData(period);
    end
   end 
end

