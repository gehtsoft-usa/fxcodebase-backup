-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10151
-- Id: 5326

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Normalized HL indicator");
    indicator:description("Normalized HL indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addBoolean("Normalize", "Normalize", "", true);
    indicator.parameters:addInteger("SignalPeriod", "Signal period", "", 35);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Signal_clr", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 3, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_DASH);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Normalize;
local NormHL=nil;
local Signal=nil;
local EMA;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Normalize=instance.parameters.Normalize;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    NormHL = instance:addStream("NormHL", core.Bar, name .. ".NormHL", "NormHL", instance.parameters.clr, first);
    NormHL:setPrecision(math.max(2, instance.source:getPrecision()));
    EMA=core.indicators:create("EMA", NormHL, SignalPeriod);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_clr, EMA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<first+Period) then
   return;
   end
   
    --local max,maxpos=mathex.max(source.high,core.rangeTo(period,Period));
    --local min,minpos=mathex.min(source.high,core.rangeTo(period,Period));
	
	local min, max, minpos, maxpos=mathex.minmax(source,period-Period+1, period);

    local TimeRange=1;
    if Normalize then
     local s, e = core.getcandle(source:barSize(), source:date(first), 0, 0);
     TimeRange=e-s;
    end 
    NormHL[period]=(max-min)/(math.abs(maxpos-minpos)*TimeRange);
    EMA:update(mode);
	if period < EMA.DATA:first() then
	return;
	end
	
    Signal[period]=EMA.DATA[period];
    
end

