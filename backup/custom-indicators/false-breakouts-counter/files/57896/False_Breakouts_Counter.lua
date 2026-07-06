-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34057
-- Id: 8867

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
    indicator:name("False Breakouts Counter");
    indicator:description("False Breakouts Counter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP counter color", "UP counter color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("UPwidth", "UP counter line width", "UP counter line width", 1, 1, 5);
    indicator.parameters:addInteger("UPstyle", "UP counter line style", "UP counter line style", core.LINE_SOLID);
    indicator.parameters:setFlag("UPstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("DNclr", "DN counter color", "DN counter color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DNwidth", "DN counter line width", "DN counter line width", 1, 1, 5);
    indicator.parameters:addInteger("DNstyle", "DN counter line style", "DN counter line style", core.LINE_SOLID);
    indicator.parameters:setFlag("DNstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Sum counter color", "Sum counter color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Swidth", "Sum counter line width", "Sum counter line width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Sum counter line style", "Sum counter line style", core.LINE_DASH);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local UpStream, DnStream;
local UpCounter=nil;
local DnCounter=nil;
local SumCounter=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UpStream=instance:addInternalStream(source:first(), 0);
    DnStream=instance:addInternalStream(source:first(), 0);
    UpCounter = instance:addStream("UpCounter", core.Line, name .. ".UpCounter", "UpCounter", instance.parameters.UPclr, first);
    UpCounter:setPrecision(math.max(2, instance.source:getPrecision()));
    UpCounter:setWidth(instance.parameters.UPwidth);
    UpCounter:setStyle(instance.parameters.UPstyle);
    DnCounter = instance:addStream("DnCounter", core.Line, name .. ".DnCounter", "DnCounter", instance.parameters.DNclr, first);
    DnCounter:setPrecision(math.max(2, instance.source:getPrecision()));
    DnCounter:setWidth(instance.parameters.DNwidth);
    DnCounter:setStyle(instance.parameters.DNstyle);
    SumCounter = instance:addStream("SumCounter", core.Line, name .. ".SumCounter", "SumCounter", instance.parameters.Sclr, first);
    SumCounter:setPrecision(math.max(2, instance.source:getPrecision()));
    SumCounter:setWidth(instance.parameters.Swidth);
    SumCounter:setStyle(instance.parameters.Sstyle);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    if source.high[period]>source.high[period-1] and source.close[period]<=source.high[period-1] then
     UpStream[period]=1;
    else
     UpStream[period]=0; 
    end
    if source.low[period]<source.low[period-1] and source.close[period]>=source.low[period-1] then
     DnStream[period]=1;
    else
     DnStream[period]=0;
    end
    if period>first+Period then
     UpCounter[period]=mathex.sum(UpStream, period-Period+1, period);
     DnCounter[period]=mathex.sum(DnStream, period-Period+1, period);
     SumCounter[period]=UpCounter[period]+DnCounter[period];
    end
   
end

