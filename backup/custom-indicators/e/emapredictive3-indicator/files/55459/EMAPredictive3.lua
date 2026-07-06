-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32558
-- Id: 8649

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
    indicator:name("EMAPredictive3 indicator");
    indicator:description("EMAPredictive3 indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("ShortPeriod", "Short period", "", 8);
    indicator.parameters:addDouble("LongPeriod", "Long period", "", 25);
    indicator.parameters:addDouble("ExtraTimeForward", "Extra time forward", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ShortPeriod;
local LongPeriod;
local ExtraTimeForward;
local EMAPredictive3=nil;
local p1, p3, t1, t3, t;
local MA1, MA3;

function Prepare(nameOnly)
    source = instance.source;
    ShortPeriod=instance.parameters.ShortPeriod;
    LongPeriod=instance.parameters.LongPeriod;
    ExtraTimeForward=instance.parameters.ExtraTimeForward;
    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ShortPeriod .. ", " .. instance.parameters.LongPeriod .. ", " .. instance.parameters.ExtraTimeForward .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA1=instance:addInternalStream(first, 0);
    MA3=instance:addInternalStream(first, 0);
    EMAPredictive3 = instance:addStream("EMAPredictive3", core.Line, name .. ".EMAPredictive3", "EMAPredictive3", instance.parameters.clr, first);
    EMAPredictive3:setWidth(instance.parameters.widthLinReg);
    EMAPredictive3:setStyle(instance.parameters.styleLinReg);
    p1=2/(LongPeriod+1);
    p3=2/(ShortPeriod+1);
    t1=(LongPeriod-1)/2;
    t3=(ShortPeriod-1)/2;
    t=ShortPeriod+ExtraTimeForward;
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    MA1[period]=p1*source[period]+(1-p1)*MA1[period-1];
    MA3[period]=p3*source[period]+(1-p3)*MA3[period-1];
    local slope1=(MA3[period]-MA1[period])/(t1-t3);
    EMAPredictive3[period]=MA3[period]+slope1*t;
 
end

