-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10548

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
    indicator:name("WiOver  indicator");
    indicator:description("WiOver  indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpperClr", "Upper Color", "Upper Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("LowerClr", "Lower Color", "Lower Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local UpperBuff=nil;
local LowerBuff=nil;
local Range;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period+1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Range=instance:addInternalStream(0, 0);
    UpperBuff = instance:addStream("UpperBuff", core.Line, name .. ".Upper", "Upper", instance.parameters.UpperClr, first);
    LowerBuff = instance:addStream("LowerBuff", core.Line, name .. ".Lower", "Lower", instance.parameters.LowerClr, first);
    UpperBuff:setWidth(instance.parameters.widthLinReg);
    UpperBuff:setStyle(instance.parameters.styleLinReg);
    LowerBuff:setWidth(instance.parameters.widthLinReg);
    LowerBuff:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
    if period < source:first()+1 then
	return;
	end
	
    if source.high[period-1]>source.low[period] and source.low[period]>source.low[period-1] then
     Range[period]=source.high[period-1]-source.low[period-1]-source.low[period]/source.high[period-1];
    elseif source.low[period-1]<source.high[period] and source.high[period]<source.high[period-1] then
     Range[period]=source.high[period-1]-source.low[period-1]-source.high[period]/source.low[period-1];
    end 
	
	if period < first then
	return;
	end
	
    local abs=core.avg(Range,core.rangeTo(period,Period))*(source.high[period]-source.low[period]);
    LowerBuff[period]=source.high[period]+abs;
    UpperBuff[period]=source.low[period]-abs;

end

