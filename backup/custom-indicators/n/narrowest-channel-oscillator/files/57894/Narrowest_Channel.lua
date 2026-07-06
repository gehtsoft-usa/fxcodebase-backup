-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34055
-- Id: 8866

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
    indicator:name("Narrowest channel oscillator");
    indicator:description("Narrowest channel oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Range", "Range", "", 3);
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Rclr", "Range color", "Range color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Rwidth", "Range line width", "Range line width", 1, 1, 5);
    indicator.parameters:addInteger("Rstyle", "Range line style", "Range line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Rstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MRclr", "Min range color", "Min range color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MRwidth", "Min range line width", "Min range line width", 1, 1, 5);
    indicator.parameters:addInteger("MRstyle", "Min range line style", "Min range line style", core.LINE_DASH);
    indicator.parameters:setFlag("MRstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Swidth", "Signal dot size", "Signal dot size", 3, 1, 5);
end

local first;
local source = nil;
local PRange;
local Period;
local Range=nil;
local MinRange=nil;
local Signal=nil;

function Prepare(nameOnly)
    source = instance.source;
    PRange=instance.parameters.Range;
    Period=instance.parameters.Period;
    first = source:first()+PRange;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Range .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Range = instance:addStream("Range", core.Line, name .. ".Range", "Range", instance.parameters.Rclr, first);
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
    Range:setWidth(instance.parameters.Rwidth);
    Range:setStyle(instance.parameters.Rstyle);
    MinRange = instance:addStream("MinRange", core.Line, name .. ".MinRange", "MinRange", instance.parameters.MRclr, first+Period);
    MinRange:setPrecision(math.max(2, instance.source:getPrecision()));
    MinRange:setWidth(instance.parameters.MRwidth);
    MinRange:setStyle(instance.parameters.MRstyle);
    Signal = instance:addStream("Signal", core.Dot, name .. ".Signal", "Signal", instance.parameters.Sclr, first+Period);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.Swidth);
end

function Update(period, mode)
   if period<first then
   return;
   end
    local Min, Max = mathex.minmax(source, period-PRange+1, period);
    Range[period]=Max-Min;
    if period<first+Period then
	return;
	end
	
     MinRange[period]=mathex.min(Range, period-Period, period-1);
     if Range[period]<MinRange[period] and Range[period-1]>=MinRange[period-1] then
      Signal[period]=MinRange[period];
     else
      Signal[period]=nil;
     end 
end

