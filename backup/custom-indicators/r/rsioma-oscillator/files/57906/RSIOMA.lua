-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34066
-- Id: 8883

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
    indicator:name("RSIOMA oscillator");
    indicator:description("RSIOMA oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "EMA");
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
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addString("SMethod", "Smooth method", "", "EMA");
    indicator.parameters:addStringAlternative("SMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("SPeriod", "Smooth period", "", 21);
    indicator.parameters:addInteger("MomPeriod", "Momentum period", "", 1);
    indicator.parameters:addInteger("HLevel", "High level", "", 20);
    indicator.parameters:addInteger("MLevel", "Middle level", "", 0);
    indicator.parameters:addInteger("LLevel", "Low level", "", -20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(128, 0, 64));
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method;
local Period;
local SMethod;
local SPeriod;
local MomPeriod;
local HLevel;
local MLevel;
local LLevel;
local MA;
local SignalMA;
local Momentum;
local pos, neg;
local Positive, Negative;
local RSIOMA=nil;
local Signal=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    SMethod=instance.parameters.SMethod;
    SPeriod=instance.parameters.SPeriod;
    MomPeriod=instance.parameters.MomPeriod;
    HLevel=instance.parameters.HLevel;
    MLevel=instance.parameters.MLevel;
    LLevel=instance.parameters.LLevel;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.SMethod .. ", " .. instance.parameters.SPeriod .. ", " .. instance.parameters.MomPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator"); 
	
   
    pos=instance:addInternalStream(0, 0);
    neg=instance:addInternalStream(0, 0);
    Positive=instance:addInternalStream(0, 0);
    Negative=instance:addInternalStream(0, 0);
    MA = core.indicators:create("AVERAGES", source, Method, Period, false);
    Momentum = core.indicators:create("MOMENTUM", MA.DATA, MomPeriod);	
	first = Momentum.DATA:first();
    RSIOMA = instance:addStream("RSIOMA", core.Bar, name .. ".RSIOMA", "RSIOMA", instance.parameters.clr1, first+Period*2);
    RSIOMA:setPrecision(math.max(2, instance.source:getPrecision()));
	
	SignalMA = core.indicators:create("AVERAGES", RSIOMA, SMethod, SPeriod, false);
	
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, SignalMA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);    
    Signal:addLevel(HLevel);
    Signal:addLevel(MLevel);
    Signal:addLevel(LLevel);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    MA:update(mode);
    Momentum:update(mode);
	if period<first then
	return;
	end
	
    if Momentum.DATA[period]>100 then
     pos[period]=Momentum.DATA[period]-100;
     neg[period]=0;
    else
     pos[period]=0;
     neg[period]=100-Momentum.DATA[period];
    end
	
    if period<first+Period then
	return;
	end
	
     Positive[period]=mathex.sum(pos, period-Period+1, period);
     Negative[period]=mathex.sum(neg, period-Period+1, period);
	 
	 
	if period<first+2*Period then
	return;
	end
	 
     local p=mathex.avg(Positive, period-Period+1, period);
     local n=mathex.avg(Negative, period-Period+1, period);
     local res;
     RSIOMA[period]=RSIOMA[period-1];
     if n~=0 then
      res=1+p/n;
      if res~=0 then
       RSIOMA[period]=50-100/res;
      end
     end
     if RSIOMA[period]>0 then
      if RSIOMA[period]>=HLevel then
       RSIOMA:setColor(period, instance.parameters.clr1);
      else
       RSIOMA:setColor(period, instance.parameters.clr2);
      end
     else
      if RSIOMA[period]<=LLevel then
       RSIOMA:setColor(period, instance.parameters.clr3);
      else
       RSIOMA:setColor(period, instance.parameters.clr4);
      end
     end
	 
	 
     SignalMA:update(mode);
	 if period < SignalMA.DATA:first() then
	 return;
	 end
	 
     Signal[period]=SignalMA.DATA[period];
 
 
end

