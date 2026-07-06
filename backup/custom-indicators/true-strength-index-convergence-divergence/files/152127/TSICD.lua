-- Id: 12152
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60923

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("True Strength Index Convergence Divergence")
    indicator:description(
        "Is a variation of the Relative Strength Indicator which uses a doubly-smoothed exponential moving average of price momentum to eliminate choppy price changes and spot trend changes."
    )
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
    indicator:setTag("group", "Oscillators")

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger(
        "N",
        "Long Term",
        "The number of periods to average the Price Momentum.",
        7,
        2,
        1000
    )
    indicator.parameters:addInteger(
        "M",
        "Short Term",
        "The number of periods to smooth the Average Momentum.",
        14,
        2,
        1000
    )

    indicator.parameters:addString("Method1", "TSI MA Method", "Method", "EMA")
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA")
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA")

    indicator.parameters:addInteger("S", "Signal Line Period", "", 14, 2, 1000)
    indicator.parameters:addString("Method2", "Signal MA Method", "Method", "EMA")
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA")
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor(
        "color1",
        "TSI Line Color",
        "The color of the True Strength Index line.",
        core.rgb(255, 0, 0)
    )
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color2", "Signal Line Color", "The color of the Signal line.", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

    indicator.parameters:addBoolean("draw_hist", "Draw histogram", "", true);
    indicator.parameters:addColor(
        "color3",
        "Histogram Line Color",
        "The color of the Histogram line.",
        core.rgb(0, 0, 255)
    )

    indicator.parameters:addInteger("ob_level", "Overbought level", "", 50);
    indicator.parameters:addInteger("os_level", "Oversold level", "", -50);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local S
local Method2
local n
local m
local Method1
local first
local source = nil
local delta = nil
local absDelta = nil
local ema_r1 = nil
local ema_r2 = nil
local ema_s1 = nil
local ema_s2 = nil
local deltaFirst = nil
local Signal, Histogram
local MA
-- Streams block
local TSI = nil

-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1
    Method2 = instance.parameters.Method2
    S = instance.parameters.S
    n = instance.parameters.N
    m = instance.parameters.M
    source = instance.source

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. n .. ", " .. m .. ", " .. Method1 .. ", " .. S .. ", " .. Method2 .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    delta = instance:addInternalStream(source:first() + 1, 0)
    absDelta = instance:addInternalStream(source:first() + 1, 0)
    deltaFirst = delta:first()

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed")
    ema_r1 = core.indicators:create(Method1, delta, n)
    ema_r2 = core.indicators:create(Method1, absDelta, n)
    ema_s1 = core.indicators:create(Method1, ema_r1.DATA, m)
    ema_s2 = core.indicators:create(Method1, ema_r2.DATA, m)

    first = ema_s1.DATA:first()
    TSI = instance:addStream("TSI", core.Line, name, "TSI", instance.parameters.color1, first)
    TSI:setPrecision(math.max(2, instance.source:getPrecision()))
    TSI:setWidth(instance.parameters.width1)
    TSI:setStyle(instance.parameters.style1)
    TSI:addLevel(0);
    TSI:addLevel(instance.parameters.os_level);
    TSI:addLevel(instance.parameters.ob_level);

    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed")
    MA = core.indicators:create(Method2, TSI, S)

    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, MA.DATA:first())
    Signal:setPrecision(math.max(2, instance.source:getPrecision()))
    Signal:setWidth(instance.parameters.width2)
    Signal:setStyle(instance.parameters.style2)

    if instance.parameters.draw_hist then
        Histogram =
            instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, MA.DATA:first())
        Histogram:setPrecision(math.max(2, instance.source:getPrecision()))
    else
        Histogram = instance:addInternalStream(0, 0);
    end
end

-- Indicator calculation routine
function Update(period, mode)
    if period < deltaFirst then
        return
    end
    delta[period] = source[period] - source[period - 1]
    absDelta[period] = math.abs(delta[period])

    ema_r1:update(mode)
    ema_r2:update(mode)
    ema_s1:update(mode)
    ema_s2:update(mode)

    if period < first then
        return
    end
    if ema_s2.DATA[period] == 0 then
        TSI[period] = 0
    else
        TSI[period] = 100 * ema_s1.DATA[period] / ema_s2.DATA[period]
    end
    MA:update(mode)

    if period < MA.DATA:first() then
        return
    end

    Signal[period] = MA.DATA[period]

    Histogram[period] = TSI[period] - Signal[period]
end
