-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10143
-- Id: 5320

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
    indicator:name("Break lag ATR indicator");
    indicator:description("Break lag ATR indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ATRclr", "ATR Color", "ATR Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("AboveClr", "Above Color", "Above Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("BelowClr", "Below Color", "Below Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local TRBuffer;
local ATRBuffer=nil;
local SubCOBuffer=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TRBuffer = instance:addInternalStream(source:first(), 0);
    ATRBuffer = instance:addStream("ATRBuffer", core.Line, name .. ".ATR", "ATR", instance.parameters.ATRclr, first);
    ATRBuffer:setPrecision(math.max(2, instance.source:getPrecision()));
    SubCOBuffer = instance:addStream("SubCOBuffer", core.Bar, name .. ".CO", "CO", instance.parameters.AboveClr, first);
    SubCOBuffer:setPrecision(math.max(2, instance.source:getPrecision()));
    ATRBuffer:setWidth(instance.parameters.widthLinReg);
    ATRBuffer:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)


   TRBuffer[period]=math.max(source.high[period],source.close[period-1])-math.min(source.low[period],source.close[period-1]);
  -- TRBuffer[period]=math.max(source.high[period],source.close[period-1])-math.min(source.low[period],source.close[period-1]);
   
   if (period>first) then    
    ATRBuffer[period]=ATRBuffer[period-1]+(TRBuffer[period]-TRBuffer[period-Period])/Period;
    SubCOBuffer[period]=math.abs(source.close[period-1]-source.open[period-1]);
    if SubCOBuffer[period]>ATRBuffer[period-1] then
     SubCOBuffer:setColor(period,instance.parameters.AboveClr);
    else
     SubCOBuffer:setColor(period,instance.parameters.BelowClr);
    end
   elseif period==first then    
    ATRBuffer[period]=mathex.avg(TRBuffer,core.rangeTo(period,Period));
   end 
end

