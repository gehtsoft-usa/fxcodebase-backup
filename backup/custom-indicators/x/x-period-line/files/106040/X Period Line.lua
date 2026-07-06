-- Id: 15967

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63433

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
    indicator:name("Previous Days High Low")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
    indicator.parameters:addInteger("transparency", "Line Transparency", "", 50)

    indicator.parameters:addBoolean("Show", "Show Label", "", true)
    indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL)
    indicator.parameters:addInteger("Size", "Font Size", "", 10)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period
local source = nil
-- Streams block
local transparency
local Label
local Show
local Size
-- Routine
function Prepare(nameOnly)
    Label = instance.parameters.Label
    Period = instance.parameters.Period
    Size = instance.parameters.Size
    Show = instance.parameters.Show
    source = instance.source

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    transparency = instance.parameters.transparency

    instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period)
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createPen(
            11,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.clr
        )
        context:createFont(1, "Arial", Size, Size, 0)
        init = true
    end

    local Firstx = math.max(source:first(), context:firstBar())
    local Lastx = math.min(source:size() - 1, context:lastBar())

    for i = Firstx, Lastx, 1 do
        x1, x = context:positionOfBar(i - Period)
        x2, x = context:positionOfBar(i)
        visible, y = context:pointOfPrice(source.close[i])

        context:drawRectangle(11, 11, x1, y, x2, y + 1, context:convertTransparency(transparency))
        if Show then
            text = win32.formatNumber(source.close[i], false, source:getPrecision())
            width, height = context:measureText(1, text, 0)
            context:drawText(1, text, Label, -1, x2, y - height, x2 + width, y, 0)
        end
    end
end
