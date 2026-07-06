-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3479

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
    indicator:name("LRMA indicator");
    indicator:description("LRMA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 34);
    indicator.parameters:addInteger("Signal", "Signal", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LRMAclr", "Color of LRMA", "Color of LRMA", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SIGNALclr", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Signal;
local SMA;
local LWMA;
local LRMA=nil;
local SigBuff=nil;
local SignalMA;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Signal=instance.parameters.Signal;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Signal .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SMA = core.indicators:create("MVA", source, Period);
    LWMA = core.indicators:create("LWMA", source, Period);
    LRMA = instance:addStream("LRMA", core.Line, name .. ".LRMA", "LRMA", instance.parameters.LRMAclr, first+Period);
    SigBuff = instance:addStream("SigBuff", core.Line, name .. ".Signal", "Signal", instance.parameters.SIGNALclr, first+Period+Signal);
    SignalMA = core.indicators:create("MVA", LRMA, Signal);
    LRMA:setWidth(instance.parameters.widthLinReg);
    LRMA:setStyle(instance.parameters.styleLinReg);
    SigBuff:setWidth(instance.parameters.widthLinReg);
    SigBuff:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period<first+Period  then
   return;
   end
   
    SMA:update(mode);
    LWMA:update(mode);
    LRMA[period]=3*LWMA.DATA[period]-2*SMA.DATA[period];
	
   if period<first+Period +Signal then
   return;
   end
    SignalMA:update(mode);	
    SigBuff[period]=SignalMA.DATA[period];
 
end

