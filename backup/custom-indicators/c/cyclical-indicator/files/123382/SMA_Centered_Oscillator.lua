-- Id: 23656
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("SMA centered oscillator");
    indicator:description("SMA centered oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("HalfLength1", "Half length 1", "", 25);
    indicator.parameters:addInteger("HalfLength2", "Half length 2", "", 13);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local HalfLength1;
local HalfLength2;
local MaxHalfLength;
local work3, work4, work5, work6, work7, work8;
local Buffer1=nil;
local Buffer2=nil;

function Prepare()
    source = instance.source;
    HalfLength1=instance.parameters.HalfLength1;
    HalfLength2=instance.parameters.HalfLength2;
    first = source:first()+2;
    work3=instance:addInternalStream(first, 0);
    work4=instance:addInternalStream(first, 0);
    work5=instance:addInternalStream(first, 0);
    work6=instance:addInternalStream(first, 0);
    work7=instance:addInternalStream(first, 0);
    work8=instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.HalfLength1 .. ", " .. instance.parameters.HalfLength2 .. ")";
    instance:name(name);
    Buffer1 = instance:addStream("Buffer1", core.Line, name .. ".Buffer1", "Buffer1", instance.parameters.clr, first);
    Buffer1:setPrecision(math.max(2, instance.source:getPrecision()));
    Buffer2 = instance:addStream("Buffer2", core.Line, name .. ".Buffer2", "Buffer2", instance.parameters.clr, first);
    Buffer2:setPrecision(math.max(2, instance.source:getPrecision()));
    MaxHalfLength = math.max(HalfLength1, HalfLength2);
end

function Update(period, mode)
   if period>first+MaxHalfLength then
    local work1 = mathex.avg(source, period-HalfLength1, period);
    local work2 = mathex.avg(source, period-HalfLength2, period);
    work3[period] = 100*(work1-work2);
    work4[period] = mathex.avg(work3, period-HalfLength2, period);
    work5[period] = 100*(work4[period]-work4[period-1]);
    work6[period] = mathex.avg(work5, period-HalfLength2, period);
    work7[period] = 100*(work6[period]-work6[period-1]);
    work8[period] = mathex.avg(work7, period-HalfLength2, period);
    Buffer1[period] = work8[period];
    Buffer2[period] = work8[period]-work8[period-1];
   end 
end

