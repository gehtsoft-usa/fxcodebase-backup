-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34060
-- Id: 8874

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
    indicator:name("SmPriceBend oscillator");
    indicator:description("SmPriceBend oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "Method 1", "", "MVA");
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
    indicator.parameters:addInteger("Period1", "Period 1", "", 21);
    indicator.parameters:addString("Method2", "Method 2", "", "MVA");
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
    indicator.parameters:addInteger("Period2", "Period 2", "", 6);
    indicator.parameters:addInteger("MomPeriod", "Momentum period", "", 2);
    indicator.parameters:addDouble("HLevel", "High level", "", 300);
    indicator.parameters:addDouble("MLevel", "Middle level", "", 0);
    indicator.parameters:addDouble("LLevel", "Low level", "", -300);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Pclr", "Positive color", "Positive color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Pclr2", "Positive color 2", "Positive color 2", core.rgb(0, 255, 255));
    indicator.parameters:addColor("Nclr", "Negative color", "Negative color", core.rgb(128, 0, 128));
    indicator.parameters:addColor("Nclr2", "Negative color 2", "Negative color 2", core.rgb(255, 0, 255));
end

local first;
local source = nil;
local Method1;
local Period1;
local Method2;
local Period2;
local MomPeriod;
local HLevel;
local MLevel;
local LLevel;
local MA1;
local MA2;
local Momentum;
local MomNorm;
local SmPriceBend=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method1=instance.parameters.Method1;
    Period1=instance.parameters.Period1;
    Method2=instance.parameters.Method2;
    Period2=instance.parameters.Period2;
    MomPeriod=instance.parameters.MomPeriod;
    HLevel=instance.parameters.HLevel;
    MLevel=instance.parameters.MLevel;
    LLevel=instance.parameters.LLevel;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.MomPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator");   
	
    MA1 = core.indicators:create("AVERAGES", source, Method1, Period1, false);
    Momentum = core.indicators:create("MOMENTUM", MA1.DATA, MomPeriod);
	
	first = Momentum.DATA:first();
    MomNorm=instance:addInternalStream(first, 0);
    MA2 = core.indicators:create("AVERAGES", MomNorm, Method2, Period2, false);
    SmPriceBend = instance:addStream("SmPriceBend", core.Bar, name .. ".SmPriceBend", "SmPriceBend", instance.parameters.Pclr, MA2.DATA:first());
    SmPriceBend:setPrecision(math.max(2, instance.source:getPrecision()));
    SmPriceBend:addLevel(HLevel);
    SmPriceBend:addLevel(MLevel);
    SmPriceBend:addLevel(LLevel);
end

function Update(period, mode)
  
   
    MA1:update(mode);
    Momentum:update(mode);
	
   if period<first then
   return;
   end
	
    MomNorm[period]=(Momentum.DATA[period]-100)/source:pipSize();
    MA2:update(mode);
	
	 if period<MA2.DATA:first() then
   return;
   end
	
    SmPriceBend[period]=MA2.DATA[period];
    if SmPriceBend[period]>MLevel then
     if SmPriceBend[period]>HLevel then
      SmPriceBend:setColor(period, instance.parameters.Pclr2);
     else
      SmPriceBend:setColor(period, instance.parameters.Pclr);
     end
    else
     if SmPriceBend[period]<LLevel then
      SmPriceBend:setColor(period, instance.parameters.Nclr2);
     else
      SmPriceBend:setColor(period, instance.parameters.Nclr);
     end
    end
  end 

