-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59985
-- Id: 10531

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
    indicator:name("Trend force oscillator");
    indicator:description("Trend force oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 7);
    indicator.parameters:addInteger("ATR_Coeff", "ATR coeff", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PUPclr", "Positive UP color", "Positive UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("PDNclr", "Positive DN color", "Positive DN color", core.rgb(255, 255, 128));
    indicator.parameters:addColor("NUPclr", "Negative UP color", "Negative UP color", core.rgb(255, 128, 0));
    indicator.parameters:addColor("NDNclr", "Negative DN color", "Negative DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local ATR_Period;
local ATR_Coeff;
local ATR;
local MinSt, MaxSt;
local MaxPeriod;
local Trend_Force=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Coeff=instance.parameters.ATR_Coeff;
	
	 MaxPeriod=math.max(Period, ATR_Period);
	 
    first = source:first()+MaxPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.ATR_Coeff .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MinSt = instance:addInternalStream(0, 0);
    MaxSt = instance:addInternalStream(0, 0);
    ATR = core.indicators:create("ATR", source, ATR_Period);
    Trend_Force = instance:addStream("Trend_Force", core.Bar, name .. ".Trend_Force", "Trend_Force", instance.parameters.PUPclr, first);
    Trend_Force:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

function Update(period, mode)
   if period>first then
    ATR:update(mode);
    local Min, Max = mathex.minmax(source, period-ATR_Period+1, period);
    MinSt[period]=Max-ATR_Coeff*ATR.DATA[period];
    MaxSt[period]=Min+ATR_Coeff*ATR.DATA[period];
    local Up=mathex.max(MinSt, period-Period+1, period);
    local Dn=mathex.min(MaxSt, period-Period+1, period);
    Trend_Force[period]=Up-Dn;
    if Trend_Force[period]>0 then
     if Trend_Force[period]>=Trend_Force[period-1] then
      Trend_Force:setColor(period, instance.parameters.PUPclr);
     else
      Trend_Force:setColor(period, instance.parameters.PDNclr);
     end 
    else
     if Trend_Force[period]>=Trend_Force[period-1] then
      Trend_Force:setColor(period, instance.parameters.NUPclr);
     else
      Trend_Force:setColor(period, instance.parameters.NDNclr);
     end 
    end
   end 
end

