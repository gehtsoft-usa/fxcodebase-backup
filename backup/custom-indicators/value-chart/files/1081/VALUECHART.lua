-- Id: 347
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=612

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
    indicator:name("Value Chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "ATR periods", "", 5);
	 indicator.parameters:addBoolean("Show", "Show Lines", "" , true);
	 
	 indicator.parameters:addInteger("L1", "1.Level", "", 8);
	 indicator.parameters:addInteger("L2", "2.Level", "", 4);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local median = nil;
local MVA = nil;
local ATR = nil;
local first;
local source = nil;

local L1, L2;

-- Streams block
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local Show;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
	Show= instance.parameters.Show;
    source = instance.source;
	L1= instance.parameters.L1;
	L2= instance.parameters.L2;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    median = instance:addInternalStream(source:first(), 0);
    MVA = core.indicators:create("MVA", median, N);
    ATR = core.indicators:create("ATR", source, N);
    first = ATR.DATA:first();

    open = instance:addStream("open", core.Line, name .. ".open", "open", 0, first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name .. ".high", "high", 0, first);
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name .. ".low", "low", 0, first);
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name .. ".close", "close", 0, first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
	if Show then
    open:addLevel(-L1);
    open:addLevel(-L2);
    open:addLevel(L1);
    open:addLevel(L2);
	end
    instance:createCandleGroup("VC", "VC", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= source:first() then
        median[period] = (source.high[period] + source.low[period] + source.close[period]) / 3;       
    end
    ATR:update(mode);
    MVA:update(mode);
    if period >= first then
        local mva = MVA.DATA[period];
        local atr = ATR.DATA[period] / N;

        high[period] = (source.high[period] - mva) / atr;
        low[period] = (source.low[period] - mva) / atr;
        close[period] = (source.close[period] - mva) / atr;
        open[period] = (source.open[period] - mva) / atr;
    end    
end

