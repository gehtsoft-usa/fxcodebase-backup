-- Id: 16026

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63467

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Intraday trading fibonacci zone analysis")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("LineColor", "Line color", "Color", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line width", "Color", 2)
    indicator.parameters:addColor("resistance", "Resistance Color", "Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("support", "Support Color", "Color", core.rgb(255, 0, 0))
    indicator.parameters:addDouble("transparency", "Transparency", "Transparency", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first
local source
local Source, loading
local transparency
local resistance, support
-- Routine
function Prepare(nameOnly)
    source = instance.source
    resistance = instance.parameters.resistance
    support = instance.parameters.support

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    instance:ownerDrawn(true)

    Source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 2, 100, 101)
    loading = true
end

-- Indicator calculation routine
function Update(period, mode)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loading = true
    end
end

local init = false

function Draw(stage, context)
    if stage ~= 0 or loading then
        return
    end

    if not init then
        context:createSolidBrush(1, resistance)
        context:createSolidBrush(2, support)
        context:createPen(3, context.SOLID, instance.parameters.width, instance.parameters.LineColor)
        transparency = context:convertTransparency(instance.parameters.transparency)
        init = true
    end

    local Daily_High = Source.high[Source.high:size() - 1 - 1]
    local Daily_Low = Source.low[Source.high:size() - 1 - 1]
    local Daily_Close = Source.close[Source.high:size() - 1 - 1]

    local Day_Range = (Daily_High - Daily_Low)
    local fibo_range_A = (0.618 * Day_Range)
    local fibo_range_B = (1.382 * Day_Range)

    local CentralLine = (Daily_High + Daily_Low + Daily_Close) / 3

    local line_C = (Day_Range / 2)

    local zone_E = CentralLine + Day_Range
    local zone_E1 = CentralLine + fibo_range_B

    local zone_D = CentralLine + line_C
    local zone_D1 = CentralLine + fibo_range_A

    local zone_B = CentralLine - line_C
    local zone_B1 = CentralLine - fibo_range_A

    local zone_A = CentralLine - Day_Range
    local zone_A1 = CentralLine - fibo_range_B

    s, e =
        core.getcandle(
        "D1",
        core.now(),
        core.host:execute("getTradingDayOffset"),
        core.host:execute("getTradingWeekOffset")
    )

    x1 = core.findDate(source, s, false)
    x2 = core.findDate(source, e, false)

    if x1 == 1 or x2 == 1 then
        return
    end

    x1, x = context:positionOfBar(x1)
    x2, x = context:positionOfBar(x2)

    visible, y0 = context:pointOfPrice(CentralLine)

    visible, A1 = context:pointOfPrice(zone_A)
    visible, A2 = context:pointOfPrice(zone_A1)

    visible, B1 = context:pointOfPrice(zone_B)
    visible, B2 = context:pointOfPrice(zone_B1)

    visible, D1 = context:pointOfPrice(zone_D)
    visible, D2 = context:pointOfPrice(zone_D1)

    visible, E1 = context:pointOfPrice(zone_E)
    visible, E2 = context:pointOfPrice(zone_E1)

    context:drawLine(3, x1, y0, x2, y0)
    context:drawRectangle(-1, 2, x1, A1, x2, A2, transparency)
    context:drawRectangle(-1, 2, x1, B1, x2, B2, transparency)
    context:drawRectangle(-1, 1, x1, E1, x2, E2, transparency)
    context:drawRectangle(-1, 1, x1, D1, x2, D2, transparency)
end
