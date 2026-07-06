-- Id: 5253
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9561

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
    indicator:name("LR_MA oscillator");
    indicator:description("LR_MA oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
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
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2);
    indicator.parameters:addDouble("ATR_Period", "ATR period", "", 20);
    indicator.parameters:addDouble("ATR_Factor", "ATR factor", "", 1.5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrStrong", "Strong Color", "Strong Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrWeak", "Weak Color", "Weak Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Method;
local Period;
local Deviation;
local ATR_Period;
local ATR_Factor;
local Hist_Buff=nil;
local Dot_Buff=nil;
local MA;
local SumBars;
local SumSqrBars;
local StdDev;
local ATR;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Factor=instance.parameters.ATR_Factor;
    first = source:first()+2*Period;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");    
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.ATR_Factor .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA = core.indicators:create("AVERAGES", source.close, Method, Period, false);
    StdDev = core.indicators:create("STDDEV", source.close, Period);
    ATR = core.indicators:create("ATR", source, ATR_Period);
    Hist_Buff = instance:addStream("Hist_Buff", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.clrUP, first);
    Hist_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    Dot_Buff = instance:addStream("Dot_Buff", core.Dot, name .. ".Dot", "Dot", instance.parameters.clrStrong, first);
    Dot_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    Dot_Buff:setWidth(instance.parameters.DotSize);
    SumBars=Period*(Period-1)/2;
    SumSqrBars=(Period-1)*Period*(2*Period-1)/6;
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
   
    MA:update(mode);
    StdDev:update(mode);
    ATR:update(mode);
    local SumY=0;
    local Sum1=0;
    local x;
    for x=0,Period-1,1 do
     local HH=mathex.max(source.high,core.rangeTo(period-x,Period));
     local LL=mathex.min(source.low,core.rangeTo(period-x,Period));
     local dxma=source.close[period-x]-((HH+LL)/2+MA.DATA[period-x])/2;
     Sum1=Sum1+x*dxma;
     SumY=SumY+dxma;
    end
    local Sum2=SumBars*SumY;
    local Num1=Period*Sum1-Sum2;
    local Num2=SumBars*SumBars-Period*SumSqrBars;
    local Slope=0;
    if Num2~=0 then
     Slope=Num1/Num2;
    end
    local Intercept=(SumY-Slope*SumBars)/Period;
    local LinearRegValue=Intercept+Slope*(Period-1);
    if LinearRegValue<0 then
     Hist_Buff[period]=LinearRegValue;
     Hist_Buff:setColor(period,instance.parameters.clrDN)
    else
     Hist_Buff[period]=LinearRegValue;
     Hist_Buff:setColor(period,instance.parameters.clrUP)
    end
    
    local bbs=Deviation*StdDev.DATA[period]/(ATR.DATA[period]*ATR_Factor);
    Dot_Buff[period]=0;
    if bbs<1 then
     Dot_Buff:setColor(period,instance.parameters.clrWeak);
    else
     Dot_Buff:setColor(period,instance.parameters.clrStrong);
    end
  
end

