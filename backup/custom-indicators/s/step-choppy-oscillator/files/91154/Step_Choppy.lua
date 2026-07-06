-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 10553

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
    indicator:name("Step choppy oscillator");
    indicator:description("Step choppy oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("Kv", "Kv", "", 1);
    indicator.parameters:addInteger("StepSize", "Step size", "", 0);
    indicator.parameters:addString("Mode", "MA mode", "", "MVA");
    indicator.parameters:addStringAlternative("Mode", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Mode", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Mode", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Mode", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Mode", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Mode", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Mode", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Mode", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Mode", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Mode", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Mode", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Mode", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Mode", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Mode", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Mode", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Mode", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Mode", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Mode", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Mode", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Mode", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Mode", "JSmooth", "", "JSmooth");
    indicator.parameters:addString("UsePrice", "Use price", "", "0");
    indicator.parameters:addStringAlternative("UsePrice", "Close", "", "0");
    indicator.parameters:addStringAlternative("UsePrice", "High/Low", "", "1");
    indicator.parameters:addDouble("StepSizeFast", "Step size fast", "", 5);
    indicator.parameters:addDouble("StepSizeSlow", "Step size slow", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr1", "Strong Up trend color", "Strong Up trend color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("UPclr2", "Retrace Up trend color", "Retrace Up trend color", core.rgb(128, 128, 255));
    indicator.parameters:addColor("UPclr3", "Choppy Up trend color", "Choppy Up trend color", core.rgb(128, 255, 255));
    indicator.parameters:addColor("UPclr4", "Be ready to change Up trend color", "Be ready to change Up trend color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr1", "Strong Dn trend color", "Strong Dn trend color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("DNclr2", "Retrace Dn trend color", "Retrace Dn trend color", core.rgb(255, 128, 128));
    indicator.parameters:addColor("DNclr3", "Choppy Dn trend color", "Choppy Dn trend color", core.rgb(255, 128, 64));
    indicator.parameters:addColor("DNclr4", "Be ready to change Dn trend color", "Be ready to change Dn trend color", core.rgb(255, 255, 0));
end

local first;
local source = nil;
local Period;
local Kv;
local StepSize;
local Mode;
local UsePrice;
local StepSizeFast;
local StepSizeSlow;
local StepMA, StepRSIFast, StepRSISlow;
local Step_Choppy=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Kv=instance.parameters.Kv;
    StepSize=instance.parameters.StepSize;
    Mode=instance.parameters.Mode;
    UsePrice=instance.parameters.UsePrice;
    StepSizeFast=instance.parameters.StepSizeFast;
    StepSizeSlow=instance.parameters.StepSizeSlow;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Kv .. ", " .. instance.parameters.StepSize .. ", " .. instance.parameters.Mode .. ", " .. instance.parameters.UsePrice .. ", " .. instance.parameters.StepSizeFast .. ", " .. instance.parameters.StepSizeSlow .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("STEP_MA") ~= nil, "Please, download and install STEP_MA.LUA indicator");
	assert(core.indicators:findIndicator("STEP_RSI2") ~= nil, "Please, download and install STEP_RSI2.LUA indicator");
	
    StepMA = core.indicators:create("STEP_MA", source, Period, Kv, StepSize, Mode, 0, "0", false, false);
    StepRSIFast = core.indicators:create("STEP_RSI2", source.close, Period, StepSizeFast, 1, Mode);
    StepRSISlow = core.indicators:create("STEP_RSI2", source.close, Period, StepSizeSlow, 1, Mode);
    Step_Choppy = instance:addStream("Step_Choppy", core.Bar, name .. ".Step_Choppy", "Step_Choppy", instance.parameters.UPclr1, first);
    Step_Choppy:setPrecision(math.max(2, instance.source:getPrecision()));
	Step_Choppy:addLevel(0);
end

function Update(period, mode)
   if period>first then
    StepMA:update(mode);
    StepRSIFast:update(mode);
    StepRSISlow:update(mode);
    Step_Choppy[period]=1;
    local Trend=StepMA.trend[period];
    local RSI=StepRSIFast.RSI[period];
    local FastRSI=StepRSIFast.StepMA[period];
    local SlowRSI=StepRSISlow.StepMA[period];

    if FastRSI>SlowRSI and RSI>FastRSI and Trend>0 then
     Step_Choppy:setColor(period, instance.parameters.UPclr1);
    elseif FastRSI>SlowRSI and RSI<FastRSI and Trend>0 then
     Step_Choppy:setColor(period, instance.parameters.UPclr2);
    elseif FastRSI<SlowRSI and RSI>FastRSI and Trend>0 then
     Step_Choppy:setColor(period, instance.parameters.UPclr3);
    elseif FastRSI<SlowRSI and RSI<FastRSI and Trend>0 then
     Step_Choppy:setColor(period, instance.parameters.UPclr4);
    elseif FastRSI<SlowRSI and RSI<FastRSI and Trend<0 then
     Step_Choppy:setColor(period, instance.parameters.DNclr1);
    elseif FastRSI<SlowRSI and RSI>FastRSI and Trend<0 then
     Step_Choppy:setColor(period, instance.parameters.DNclr2);
    elseif FastRSI>SlowRSI and RSI<FastRSI and Trend<0 then
     Step_Choppy:setColor(period, instance.parameters.DNclr3);
    elseif FastRSI>SlowRSI and RSI>FastRSI and Trend<0 then
     Step_Choppy:setColor(period, instance.parameters.DNclr4);
    else
     Step_Choppy[period]=0;
    end
    
   end 
end

