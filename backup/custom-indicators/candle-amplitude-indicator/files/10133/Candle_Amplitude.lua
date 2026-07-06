-- Id: 3762
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4049

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
    indicator:name("Candle amplitude indicator");
    indicator:description("Candle amplitude indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "HL");
    indicator.parameters:addStringAlternative("Method", "High-Low", "", "HL");
    indicator.parameters:addStringAlternative("Method", "Close-Open", "", "CO");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMain", "Color main", "Color main", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrSig", "Color signal", "Color signal", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Method;
local Amplitude;
local BuffMain=nil;
local BuffSignal=nil;
local UpdateFunction;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Amplitude = instance:addInternalStream(first, 0);
    BuffMain = instance:addStream("BuffMain", core.Line, name .. ".Main", "Main", instance.parameters.clrMain, first);
    BuffMain:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffSignal = instance:addStream("BuffSignal", core.Line, name .. ".Signal", "Signal", instance.parameters.clrSig, first);
    BuffSignal:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffMain:setWidth(instance.parameters.widthLinReg);
    BuffMain:setStyle(instance.parameters.styleLinReg);
    BuffSignal:setWidth(instance.parameters.widthLinReg);
    BuffSignal:setStyle(instance.parameters.styleLinReg);
    UpdateFunction=_G["Update" .. Method];
    BuffSignal:addLevel(0);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
    UpdateFunction(period, mode);
    BuffMain[period]=Amplitude[period];
    BuffSignal[period]=mathex.avg(Amplitude,math.max(first,period-Period+1),period);
   
end

function UpdateHL(period, mode)
 Amplitude[period]=source.high[period]-source.low[period];
end

function UpdateCO(period, mode)
 Amplitude[period]=source.close[period]-source.open[period];
end

