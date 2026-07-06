-- Id: 15041

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62860

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ZigZag Vertical Line")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "The minimum number of periods used to draw one ZigZag line.", 12)
    indicator.parameters:addInteger(
        "Deviation",
        "Deviation",
        "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.",
        5
    )
    indicator.parameters:addInteger(
        "Backstep",
        "Backstep",
        "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.",
        3
    )
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clrHigh", "Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("clrLow", "Low Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
    indicator.parameters:addInteger("transparency", "Line Transparency", "", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period
local source = nil
local ZigZag
local Depth, Deviation, Backstep
local first
-- Streams block
local transparency
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    source = instance.source
    ZigZag =
        core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep, core.rgb(0, 255, 0), core.rgb(255, 0, 0))
    first = ZigZag.DATA:first()
    local name = profile:id() .. "(" .. source:name() .. "," .. Depth .. "," .. Deviation .. "," .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    transparency = instance.parameters.transparency

    instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period)
    if period < source:size() - 1 then
        return
    end

    ZigZag:update(core.UpdateAll)
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createPen(
            1,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.clrHigh
        )
        context:createSolidBrush(2, instance.parameters.clrHigh)
        context:createPen(
            3,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.clrLow
        )
        context:createSolidBrush(4, instance.parameters.clrLow)
        init = true
    end

    local Last = math.min(context:lastBar(), (ZigZag.DATA:size() - 1)) - 1
    local First = math.max(context:firstBar(), first) + 1

    for i = First, Last, 1 do
        x1, x = context:positionOfBar(i - 1)

        if
            ZigZag.DATA:colorI(i) == core.rgb(0, 255, 0) and ZigZag.DATA:colorI(i - 1) ~= core.rgb(0, 255, 0) or
                ZigZag.DATA:colorI(i) == core.rgb(0, 255, 0) and ZigZag.DATA[i + 1] == nil
         then
            context:drawRectangle(
                1,
                2,
                x1,
                context:top(),
                x1 + 1,
                context:bottom(),
                context:convertTransparency(transparency)
            )
        end
        if
            ZigZag.DATA:colorI(i) == core.rgb(255, 0, 0) and ZigZag.DATA:colorI(i - 1) ~= core.rgb(255, 0, 0) or
                ZigZag.DATA:colorI(i) == core.rgb(255, 0, 0) and ZigZag.DATA[i + 1] == nil
         then
            context:drawRectangle(
                3,
                4,
                x1,
                context:top(),
                x1 + 1,
                context:bottom(),
                context:convertTransparency(transparency)
            )
        end
    end
end
