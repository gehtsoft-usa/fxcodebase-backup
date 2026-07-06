-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36266
-- Id: 9096

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
    indicator:name("Waddah_Attar_Def_RSI oscillator");
    indicator:description("Waddah_Attar_Def_RSI oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period1", "RSI period 1", "", 14);
    indicator.parameters:addInteger("RSI_Period2", "RSI period 2", "", 28);
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
    indicator.parameters:addInteger("Smooth_Period", "Smooth period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 255));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(0, 128, 0));
end

local first;
local source = nil;
local RSI_Period1;
local RSI_Period2;
local Smooth_Method;
local Smooth_Period;
local RSI1, RSI2;
local St_RSI;
local MA;
local Def_RSI=nil;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period1=instance.parameters.RSI_Period1;
    RSI_Period2=instance.parameters.RSI_Period2;
    Smooth_Method=instance.parameters.Smooth_Method;
    Smooth_Period=instance.parameters.Smooth_Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period1 .. ", " .. instance.parameters.RSI_Period2 .. ", " .. instance.parameters.Smooth_Method .. ", " .. instance.parameters.Smooth_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
	 RSI1 = core.indicators:create("RSI", source.weighted, RSI_Period1);
    RSI2 = core.indicators:create("RSI", source.weighted, RSI_Period2);
	
	
    St_RSI = instance:addInternalStream(math.max( RSI1.DATA:first(),RSI2.DATA:first()), 0);
   
    MA = core.indicators:create("AVERAGES", St_RSI, Smooth_Method, Smooth_Period, false);
	
	first = MA.DATA:first();
    Def_RSI = instance:addStream("Def_RSI", core.Bar, name .. ".Def_RSI", "Def_RSI", instance.parameters.clr1, first);
    Def_RSI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
  
    RSI1:update(mode);
    RSI2:update(mode);
	
	if period < math.max( RSI1.DATA:first(),RSI2.DATA:first()) then
	return;
	end
	
	
    St_RSI[period]=RSI1.DATA[period]-RSI2.DATA[period];
    MA:update(mode);
	
	 if period<first then
	 return;
	 end
	 
	 
    Def_RSI[period]=MA.DATA[period];
    if Def_RSI[period]>=0 then
     if Def_RSI[period]>Def_RSI[period-1] then
      Def_RSI:setColor(period, instance.parameters.clr4);
     else
      Def_RSI:setColor(period, instance.parameters.clr3);
     end
    else
     if Def_RSI[period]<Def_RSI[period-1] then
      Def_RSI:setColor(period, instance.parameters.clr1);
     else
      Def_RSI:setColor(period, instance.parameters.clr2);
     end
    end
  
end

