-- Id: 5788
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13034

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Color stochastic");
    indicator:description("Color stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "Number of periods for %K", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "%D slowing periods", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "Number of periods for %D", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "Smoothing type for %K", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "FS", "Fast Smoothed", "FS");

    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "Smoothing type for %D", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
    
	 indicator.parameters:addGroup("Levels");
    indicator.parameters:addDouble("OverboughtLevel", "Overbought level", "Overbought level", 80, 0, 100);
	  indicator.parameters:addDouble("CentalLevel", "Central level", "Central level", 50, 0, 100);
    indicator.parameters:addDouble("OversoldLevel", "Oversold level", "Oversold level", 20, 0, 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Kclr", "K line Color", "K line Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Kwidth", "K line width", "K line width", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "K line style", "K line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Dclr", "D line Color", "D line Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Dwidth", "D line width", "D line width", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "D line style", "D line style", core.LINE_DASH);
	indicator.parameters:addColor("OBclr", "Overbought Color", "Overbought Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("OSclr", "Oversold Color", "Oversold Color", core.rgb(255, 0, 0));
 
	
	indicator.parameters:addGroup("OB/OS Levels Style");	  
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
    
end
local first;
local source = nil;
local OverboughtLevel;
local OversoldLevel;
local Stochastic;
local BuffK=nil;
local BuffD=nil;
local CentalLevel;
function Prepare(nameOnly)
    source = instance.source;
	CentalLevel=instance.parameters.CentalLevel;
    OverboughtLevel=instance.parameters.OverboughtLevel;
    OversoldLevel=instance.parameters.OversoldLevel;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.K .. ", " .. instance.parameters.SD .. ", " .. instance.parameters.D .. ", " .. instance.parameters.MVAT_K .. ", " .. instance.parameters.MVAT_D .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Stochastic = core.indicators:create("STOCHASTIC", source, instance.parameters.K, instance.parameters.SD, instance.parameters.D, instance.parameters.MVAT_K, instance.parameters.MVAT_D);
    BuffK = instance:addStream("BuffK", core.Line, name .. ".K", "K", instance.parameters.Kclr, first);
    BuffK:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffD = instance:addStream("BuffD", core.Line, name .. ".D", "D", instance.parameters.Dclr, first);
    BuffD:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffK:setWidth(instance.parameters.Kwidth);
    BuffK:setStyle(instance.parameters.Kstyle);
    BuffD:setWidth(instance.parameters.Dwidth);
    BuffD:setStyle(instance.parameters.Dstyle);
	
	BuffK:addLevel(OverboughtLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	BuffK:addLevel(OversoldLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	BuffK:addLevel(CentalLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
end

function Update(period, mode)
   if (period>first) then
    Stochastic:update(mode);
    BuffK[period]=Stochastic.K[period];
    BuffD[period]=Stochastic.D[period];
    if BuffK[period]>=OverboughtLevel then
     BuffK:setColor(period,instance.parameters.OBclr);
    elseif BuffK[period]<=OversoldLevel then
     BuffK:setColor(period,instance.parameters.OSclr);
    else
     BuffK:setColor(period,instance.parameters.Kclr);
    end
   end 
end

