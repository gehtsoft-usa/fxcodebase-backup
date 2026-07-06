-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6512

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
    indicator:name("DXMA indicator");
    indicator:description("DXMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local DXMA=nil;
local DMI;
local C=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    DMI = core.indicators:create("DMI", source, Period);
    C = instance:addInternalStream(first, 0);
    DXMA = instance:addStream("DXMA", core.Line, name .. ".DXMA", "DXMA", instance.parameters.clr, first+Period);
    DXMA:setWidth(instance.parameters.widthLinReg);
    DXMA:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    DMI:update(mode);
    local ydi=DMI.DIP[period]-DMI.DIM[period]+50;
	
    local l,h=core.minmax(source,period-Period+1, period);
   -- local l=core.min(source.low,core.rangeTo(period,Period));
    C[period]=(h-l)*ydi*0.01+l;
    if period>first+Period then
     DXMA[period]=core.avg(C,core.rangeTo(period,Period));
    end 
 
end

