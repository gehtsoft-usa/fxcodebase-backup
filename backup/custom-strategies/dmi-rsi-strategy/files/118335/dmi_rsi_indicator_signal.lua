-- Id: 20766
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65858

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("DMI+RSI")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("lene", "lene", "", 12)
    indicator.parameters:addInteger("lensig", "lensig", "", 12)
    indicator.parameters:addInteger("len", "Length", "", 12)
 
end

local source
local upe = nil
local downe = nil
local trur = nil
local plus = nil
local smma1 = nil
local smma1_source = nil
local smma2 = nil
local smma2_source = nil
local up = nil
local up_source = nil
local down = nil
local down_source = nil
local minus = nil
local sum = nil
local lene
local lensig
local len
local src
local rsi
local limitlong
local limitshort
local signal
local tr
local test
local Color;
function Prepare(nameOnly)
    source = instance.source
    instance:name(profile:id())
    if nameOnly then
        return
    end
	
	Color = instance.parameters.Color;
	
    len = instance.parameters.len
    lene = instance.parameters.lene
    lensig = instance.parameters.lensig
    upe = instance:addInternalStream(0, 0)
    downe = instance:addInternalStream(0, 0)
    tr = instance:addInternalStream(0, 0)
    trur = core.indicators:create("SMMA", tr, lenadx)
    plus = instance:addInternalStream(0, 0)
    smma1_source = instance:addInternalStream(0, 0)
    smma1 = core.indicators:create("SMMA", smma1_source, lene)
    minus = instance:addInternalStream(0, 0)
    smma2_source = instance:addInternalStream(0, 0)
    smma2 = core.indicators:create("SMMA", smma2_source, lene)
    up_source = instance:addInternalStream(0, 0)
    up = core.indicators:create("SMMA", up_source, len)
    down_source = instance:addInternalStream(0, 0)
    down = core.indicators:create("SMMA", down_source, len)
    sum = instance:addInternalStream(0, 0)
    src = instance:addInternalStream(0, 0)
    rsi = instance:addInternalStream(0, 0)
    limitlong = instance:addInternalStream(0, 0)
    limitshort = instance:addInternalStream(0, 0)

    signal = instance:addStream("Signal", core.Line, "Signal", "Signal",  core.rgb(0, 0, 0), 1)
    test = instance:addStream("test", core.Line, "test", "test", core.rgb(0, 0, 0), 1)
	
	signal:setPrecision(math.max(2, instance.source:getPrecision()));
	test:setPrecision(math.max(2, instance.source:getPrecision()));
end

function getTrueRange(period)
    local hl = math.abs(source.high[period] - source.low[period]);
    local hc = math.abs(source.high[period] - source.close[period - 1]);
    local lc = math.abs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

function Update(period, mode)
    if period < 1 then
        return
    end
    tr[period] = getTrueRange(period);
    upe[period] = source.high[period] - source.high[period - 1]
    downe[period] = -(source.low[period] - source.low[period - 1])
    trur:update(core.UpdateLast)
    if upe[period] > downe[period] and upe[period] > 0 then
        smma1_source[period] = upe[period]
    else
        smma1_source[period] = smma1_source[period - 1]
    end
    smma1:update(core.UpdateLast)
    plus[period] = 100 * smma1.DATA[period] / trur.DATA[period]
    if downe[period] > upe[period] and downe[period] > 0 then
        smma2_source[period] = downe[period]
    else
        smma2_source[period] = smma2_source[period - 1]
    end
    smma2:update(core.UpdateLast)
    minus[period] = 100 * smma2.DATA[period] / trur.DATA[period]
    sum[period] = plus[period] + minus[period]
    src[period] =
        ((source.open[period] + source.close[period] + source.low[period] + source.high[period]) / 4) -
        ((source.open[period - 1] + source.close[period - 1] + source.low[period - 1] + source.high[period - 1]) / 4)
    up_source[period] = math.max(src[period], 0)
    up:update(core.UpdateLast)
    down_source[period] = -math.min(src[period], 0)
    down:update(core.UpdateLast)
    if down[period] == 0 then
        rsi[period] = 100
    elseif up[period] == 0 then
        rsi[period] = 0
    else
        rsi[period] = 100 - (100 / (1 + up.DATA[period] / down.DATA[period]))
    end
    if core.crossesOver(plus, minus, period) and rsi[period] < 30 then
        limitlong[period] = source.close[period]
        test[period] = source.close[period]
    else
        limitlong[period] = limitlong[period - 1]
    end
    if core.crossesUnder(minus, plus, period) and rsi[period] > 70 then
        limitshort[period] = source.close[period]
    else
        limitshort[period] = limitshort[period - 1]
    end
    if core.crossesOver(plus, minus, period) and limitlong[period] > limitlong[period - 1] then
        signal[period] = 1
    end
    if core.crossesUnder(minus, plus, period) and limitshort[period] < limitshort[period - 1] then
        signal[period] = -1
    end
end
