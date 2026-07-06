-- Id: 10522
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59981

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Historical Volatility Ratio oscillator");
    indicator:description("Historical Volatility Ratio oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period 1", "", 6);
    indicator.parameters:addInteger("Period2", "Period 2", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period1;
local Period2;
local St;
local HVR=nil;
local MaxPeriod;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    St = instance:addInternalStream(first, 0);
    HVR = instance:addStream("HVR", core.Line, name .. ".HVR", "HVR", instance.parameters.clr, first);
    HVR:setPrecision(math.max(2, instance.source:getPrecision()));
    HVR:setWidth(instance.parameters.widthLinReg);
    HVR:setStyle(instance.parameters.styleLinReg);
    MaxPeriod=math.max(Period1, Period2);
end

function Update(period, mode)
   if period>first+MaxPeriod then
    St[period]=math.log(source[period]/source[period-1]);
    local StdDev1=mathex.stdev(St, period-Period1+1, period);
    local StdDev2=mathex.stdev(St, period-Period2+1, period);
    if StdDev2~=0 then
     HVR[period]=StdDev1/StdDev2;
    else
     HVR[period]=nil;
    end    
   end 
end

