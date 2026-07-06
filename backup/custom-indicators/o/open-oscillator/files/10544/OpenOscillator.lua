-- Id: 3892
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4202

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
    indicator:name("Open oscillator");
    indicator:description("Open oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addInteger("SignalPeriod", "SignalPeriod", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LowClr", "Low Color", "Low Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("HighClr", "High Color", "High Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LowSignalClr", "Low Signal Color", "Low Signal Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("HighSignalClr", "High Signal Color", "High Signal Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Lines width", "Lines width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Lines style", "Lines style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("widthSigReg", "Signal width", "Signal width", 3, 1, 5);
    indicator.parameters:addInteger("styleSigReg", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSigReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local SignalPeriod;
local LowBuff=nil;
local HighBuff=nil;
local LowMABuff=nil;
local HighMABuff=nil;
local EMA_Low;
local EMA_High;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    SignalPeriod=instance.parameters.SignalPeriod;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LowBuff = instance:addStream("LowBuff", core.Line, name .. ".Low", "Low", instance.parameters.LowClr, first);
    LowBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    HighBuff = instance:addStream("HighBuff", core.Line, name .. ".High", "High", instance.parameters.HighClr, first);
    HighBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    EMA_Low=core.indicators:create("EMA", LowBuff, SignalPeriod);
    EMA_High=core.indicators:create("EMA", HighBuff, SignalPeriod);
    LowMABuff = instance:addStream("LowMABuff", core.Line, name .. ".SignalLow", "SignalLow", instance.parameters.LowSignalClr, first);
    LowMABuff:setPrecision(math.max(2, instance.source:getPrecision()));
    HighMABuff = instance:addStream("HighMABuff", core.Line, name .. ".SignalHigh", "SignalHigh", instance.parameters.HighSignalClr, first);
    HighMABuff:setPrecision(math.max(2, instance.source:getPrecision()));
    LowBuff:setWidth(instance.parameters.widthLinReg);
    LowBuff:setStyle(instance.parameters.styleLinReg);
    HighBuff:setWidth(instance.parameters.widthLinReg);
    HighBuff:setStyle(instance.parameters.styleLinReg);
    LowMABuff:setWidth(instance.parameters.widthSigReg);
    LowMABuff:setStyle(instance.parameters.styleSigReg);
    HighMABuff:setWidth(instance.parameters.widthSigReg);
    HighMABuff:setStyle(instance.parameters.styleSigReg);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local MinPr,MinPos=mathex.min(source.low,period-Period+1, period);
    local MaxPr,MaxPos=mathex.max(source.high,period-Period+1, period);
    LowBuff[period]=source.open[MinPos]-source.open[period];
    HighBuff[period]=source.open[period]-source.open[MaxPos];
    EMA_Low:update(mode);
    EMA_High:update(mode);
    LowMABuff[period]=EMA_Low.DATA[period];
    HighMABuff[period]=EMA_High.DATA[period];
    
end

