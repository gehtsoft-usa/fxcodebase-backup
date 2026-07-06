-- Id: 3094
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3372&sid=6eb856b7a0e3a5289eb215e2282f8b31

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
    indicator:name("Stochastic expansion indicator");
    indicator:description("Stochastic expansion indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("KPeriod", "Period K", "", 13);
    indicator.parameters:addInteger("Slowing", "Slowing", "", 6);
    indicator.parameters:addInteger("NoiseFilter", "NoiseFilter", "", 6);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color UP", "Color UP", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrSig", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local KPeriod;
local Slowing;
local NoiseFilter;
local BuffK=nil;
local SigBuff=nil;
local LowBuff;
local HighBuff;
local KB;

function Prepare(nameOnly)
    source = instance.source;
    KPeriod=instance.parameters.KPeriod;
    Slowing=instance.parameters.Slowing;
    NoiseFilter=instance.parameters.NoiseFilter;
    first = source:first()+math.max(KPeriod,Slowing)
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.KPeriod .. ", " .. instance.parameters.Slowing .. ", " .. instance.parameters.NoiseFilter .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LowBuff = instance:addInternalStream(first, 0);
    HighBuff = instance:addInternalStream(first, 0);
    KB = instance:addInternalStream(first, 0);
    BuffK = instance:addStream("BuffK", core.Line, name .. ".K", "K", instance.parameters.clr1, first+Slowing);
    BuffK:setPrecision(math.max(2, instance.source:getPrecision()));
    SigBuff = instance:addStream("SigBuff", core.Line, name .. ".Signal", "Signal", instance.parameters.clrSig, first+Slowing+NoiseFilter);
    SigBuff:setPrecision(math.max(2, instance.source:getPrecision()));
	
	BuffK:setWidth(instance.parameters.width1);
	BuffK:setStyle(instance.parameters.style1);
	SigBuff:setWidth(instance.parameters.width2);
	SigBuff:setStyle(instance.parameters.style2);
end

function Update(period, mode)


   if period< first then
   return;
   end
   
    LowBuff[period]=source.close[period]-mathex.min(source.low,period-KPeriod+1, period);
    HighBuff[period]=mathex.max(source.high,period-KPeriod+1, period)-source.close[period];
	
   if period< first +Slowing then
   return;
   end
   
    local SumLow=mathex.sum(LowBuff, period-Slowing+1, period);
    local SumHigh=mathex.sum(HighBuff, period-Slowing+1, period);
    local KB1;
    local KB2;
    if SumHigh==0 then
     KB1=0;
    else
     KB1=SumLow/SumHigh;
    end
    if SumLow==0 then
     KB2=0;
    else
     KB2=-SumHigh/SumLow;
    end
    KB[period]=KB1+KB2;
	
	if period< first +Slowing +NoiseFilter then
	return;
	end
    local Avg=mathex.avg(KB,  period-NoiseFilter+1,period);
    SigBuff[period]=Avg;
    BuffK[period]=KB[period];
  
end

