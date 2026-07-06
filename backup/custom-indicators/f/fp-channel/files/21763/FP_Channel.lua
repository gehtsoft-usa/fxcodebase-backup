-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10503

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
    indicator:name("FP channel indicator");
    indicator:description("FP channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 100, 3, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TopClr", "Top Color", "Top Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MiddleClr", "Middle Color", "Middle Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("BottomClr", "Bottom Color", "Bottom Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local TopBuff=nil;
local MiddleBuff=nil;
local BottomBuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TopBuff = instance:addStream("TopBuff", core.Line, name .. ".Top", "Top", instance.parameters.TopClr, first);
    MiddleBuff = instance:addStream("MiddleBuff", core.Line, name .. ".Middle", "Middle", instance.parameters.MiddleClr, first);
    BottomBuff = instance:addStream("BottomBuff", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BottomClr, first);
    TopBuff:setWidth(instance.parameters.widthLinReg);
    TopBuff:setStyle(instance.parameters.styleLinReg);
    MiddleBuff:setWidth(instance.parameters.widthLinReg);
    MiddleBuff:setStyle(instance.parameters.styleLinReg);
    BottomBuff:setWidth(instance.parameters.widthLinReg);
    BottomBuff:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    local min,max=mathex.minmax(source,period-Period+1, period);
   -- local min=mathex.min(source.low,core.rangeTo(period,Period));
    local pivot=(source.close[period-1]+source.close[period-2]+source.close[period-3])/3;
    local sum=max+min+pivot;
    MiddleBuff[period]=sum/3;
    TopBuff[period]=(sum-min)/2;
    BottomBuff[period]=(sum-max)/2;
   end 
end

