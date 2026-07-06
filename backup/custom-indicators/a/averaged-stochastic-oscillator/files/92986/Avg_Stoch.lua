-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60387
-- Id: 11267

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
    indicator:name("Averaged stochastic oscillator");
    indicator:description("Averaged stochastic oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K_Period", "Number of periods for %K", "", 5);
    indicator.parameters:addInteger("Slowing", "%D slowing periods", "", 3);
    indicator.parameters:addInteger("D_Period", "Number of periods for %D", "", 3);
    indicator.parameters:addString("K_Smooth", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("K_Smooth", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("K_Smooth", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("K_Smooth", "Fast Smoothed", "", "FS");
    indicator.parameters:addString("D_Smooth", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("D_Smooth", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("D_Smooth", "EMA", "", "EMA");
    indicator.parameters:addInteger("Avg_Period", "Avg. period", "", 4);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Kclr", "%K line color", "%K line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Kwidth", "%K line width", "%K line width", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "%K line style", "%K line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Dclr", "%D line color", "%D line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Dwidth", "%D line width", "%D line width", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "%D line style", "%D line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local K_Period;
local Slowing;
local D_Period;
local K_Smooth;
local D_Smooth;
local Avg_Period;
local Stoch;
local K=nil;
local D=nil;

function Prepare(nameOnly)
    source = instance.source;
    K_Period=instance.parameters.K_Period;
    Slowing=instance.parameters.Slowing;
    D_Period=instance.parameters.D_Period;
    K_Smooth=instance.parameters.K_Smooth;
    D_Smooth=instance.parameters.D_Smooth;
    Avg_Period=instance.parameters.Avg_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.K_Period .. ", " .. instance.parameters.Slowing .. ", " .. instance.parameters.D_Period .. ", " .. instance.parameters.K_Smooth .. ", " .. instance.parameters.D_Smooth .. ", " .. instance.parameters.Avg_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Stoch = core.indicators:create("STOCHASTIC", source, K_Period, Slowing, D_Period, K_Smooth, D_Smooth);
    first = math.max(Stoch.K:first(), Stoch.D:first())+2;
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.Kclr, first);
    K:setWidth(instance.parameters.Kwidth);
    K:setStyle(instance.parameters.Kstyle);
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.Dclr, first);
    D:setWidth(instance.parameters.Dwidth);
    D:setStyle(instance.parameters.Dstyle);
	
	K:setPrecision(math.max(2, instance.source:getPrecision())); 
	D:setPrecision(math.max(2, instance.source:getPrecision())); 
end

function Update(period, mode)
   if period>first+Avg_Period then
    Stoch:update(mode);
    K[period]=mathex.avg(Stoch.K, period-Avg_Period+1, period);
    D[period]=mathex.avg(Stoch.D, period-Avg_Period+1, period);
   end 
end

