-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60521
-- Id: 11496

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
    indicator:name("Master_Candle")
    indicator:description("Master_Candle")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Min Engulf Candles", "Min Engulf Candles", 4, 1, 1000)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Top", "Top Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period
local first
local source = nil
local Top, Bottom
local id
local style, width
-- Routine
function Prepare(nameOnly)
    Top = instance.parameters.Top
    style = instance.parameters.style
    width = instance.parameters.width
    Bottom = instance.parameters.Bottom
    Period = instance.parameters.Period
    source = instance.source
    first = source:first() + Period

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")"
    instance:name(name)

    instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    id = 0
    core.host:execute("removeLine", 10000)
    core.host:execute("removeLine", 20000)
end

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    id = 0
    core.host:execute("removeLine", 10000)
    core.host:execute("removeLine", 20000)

    local Last = math.min(context:lastBar(), source:size() - 1)
    local First = math.max(source:first(), context:firstBar())

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

    local period

    for period = First, Last, 1 do
        isMasterCandle(period - Period)
    end
end

function Line(period)
    local Index = period + Period
    core.host:execute(
        "drawLine",
        ID(),
        source:date(period),
        source.high[period],
        source:date(Index),
        source.high[period],
        Top,
        style,
        width,
        string.format("%." .. source:getPrecision() .. "f", source.high[period])
    )
    core.host:execute(
        "drawLine",
        ID(),
        source:date(period),
        source.low[period],
        source:date(Index),
        source.low[period],
        Bottom,
        style,
        width,
        string.format("%." .. source:getPrecision() .. "f", source.low[period])
    )
end

function ID()
    id = id + 1

    return id
end
function isMasterCandle(period)
    local CandleTop = source.high[period]
    local CandleBottom = source.low[period]
    local i
    local Flag = true

    for i = period, period + Period, 1 do
        if math.max(source.close[i], source.open[i]) > CandleTop or math.min(source.close[i], source.open[i]) < CandleBottom then
            Flag = false
        end
    end

    if Flag then
        if period == source:size() - 1 - Period then
            local Index = period + Period
            core.host:execute(
                "drawLine",
                10000,
                source:date(period),
                source.high[period],
                source:date(Index),
                source.high[period],
                Top,
                style,
                width,
                string.format("%." .. source:getPrecision() .. "f", source.high[period])
            )
            core.host:execute(
                "drawLine",
                20000,
                source:date(period),
                source.low[period],
                source:date(Index),
                source.low[period],
                Bottom,
                style,
                width,
                string.format("%." .. source:getPrecision() .. "f", source.low[period])
            )
        else
            Line(period)
        end
    end
end
