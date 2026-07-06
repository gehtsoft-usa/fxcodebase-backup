-- Id: 4591
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6491

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
    indicator:name("candle");
    indicator:description("just a candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
end

local source = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first = 0;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low" .. ".low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    volume = instance:addStream("volume", core.Line, name .. ".volume", "volume", core.rgb(0, 0, 0), first)
    volume:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup(name, "bar", open, high, low, close, volume);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= first then
        open[period] = source.open[period];
        high[period] = source.high[period];
        low[period] = source.low[period];
        close[period] = source.close[period];
        volume[period] = source.volume[period];
    end
end



