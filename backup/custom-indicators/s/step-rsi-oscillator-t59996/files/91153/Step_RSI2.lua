-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59996
-- Id: 10552

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
    indicator:name("Step RSI 2 oscillator");
    indicator:description("Step RSI 2 oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 14);
    indicator.parameters:addDouble("StepSize", "Step size", "", 5);
    indicator.parameters:addInteger("MA_Period", "MA period", "", 1);
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSIclr", "RSI color", "RSI color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("RSIwidth", "RSI width", "RSI width", 1, 1, 5);
    indicator.parameters:addInteger("RSIstyle", "RSI style", "RSI style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("StepMAclr", "Step MA color", "Step MA color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("StepMAwidth", "Step MA width", "Step MA width", 1, 1, 5);
    indicator.parameters:addInteger("StepMAstyle", "Step MA style", "Step MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("StepMAstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSI_Period;
local StepSize;
local MA_Period;
local Method;
local RSI=nil;
local StepMA=nil;
local MA;
local P, N;
local smin, smax, trend;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    StepSize=instance.parameters.StepSize;
    MA_Period=instance.parameters.MA_Period;
    Method=instance.parameters.Method;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.StepSize .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
  
    MA = core.indicators:create("AVERAGES", source, Method, MA_Period, false);
	
	 first = MA.DATA:first();
    P=instance:addInternalStream(0, 0);
    N=instance:addInternalStream(0, 0);
    smin=instance:addInternalStream(0, 0);
    smax=instance:addInternalStream(0, 0);
    trend=instance:addInternalStream(0, 0);
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.RSIwidth);
    RSI:setStyle(instance.parameters.RSIstyle);
    StepMA = instance:addStream("StepMA", core.Line, name .. ".StepMA", "StepMA", instance.parameters.StepMAclr, first);
    StepMA:setPrecision(math.max(2, instance.source:getPrecision()));
    StepMA:setWidth(instance.parameters.StepMAwidth);
    StepMA:setStyle(instance.parameters.StepMAstyle);
end

function StepMACalc(index)
 smax[index]=RSI[index]+2*StepSize;
 smin[index]=RSI[index]-2*StepSize;
 trend[index]=trend[index-1];
 if trend[index-1]<=0 and RSI[index]>smax[index-1] then
  trend[index]=1;
 elseif trend[index-1]>=0 and RSI[index]<smin[index-1] then
  trend[index]=-1; 
 end
 if trend[index]>0 then
  smin[index]=math.max(smin[index], smin[index-1]);
  return smin[index]+StepSize;
 else
  smax[index]=math.min(smax[index], smax[index-1]);
  return smax[index]-StepSize;
 end
 return 0;
end

function Update(period, mode)
   if period>first then
    MA:update(mode);
    local Diff=MA.DATA[period]-MA.DATA[period-1];
    P[period]=math.max(Diff, 0);
    N[period]=math.max(-Diff, 0);
    if period>first+RSI_Period then
     local Pavg=mathex.avg(P, period-RSI_Period+1, period);
     local Navg=mathex.avg(N, period-RSI_Period+1, period);
     if Navg~=0 then
      RSI[period]=100-100/(1+Pavg/Navg);
     else
      RSI[period]=100;
     end 
     StepMA[period]=StepMACalc(period);
    end 
   end 
end

