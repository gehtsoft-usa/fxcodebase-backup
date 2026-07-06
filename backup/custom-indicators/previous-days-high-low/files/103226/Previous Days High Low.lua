-- Id: 15038

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62859

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
    indicator.parameters:addColor("clrHigh", "High Line Color", "", core.rgb(0, 255, 0))
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
-- Streams block
local transparency
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period
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
            instance.parameters.clrHigh
        )
        context:createPen(
            22,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.clrLow
        )
        init = true
    end

    local Firstx = source:size() - 1 - Period + 1
    local Lastx = source:size() - 1
    x2, x = context:positionOfBar(Lastx)

    for i = Firstx, Lastx, 1 do
        x1, x = context:positionOfBar(i)
        visible, y1 = context:pointOfPrice(source.high[i])
        visible, y2 = context:pointOfPrice(source.low[i])
        -- context:drawLine (11, x1, y1, x2, y1+1, context:convertTransparency (transparency));
        --context:drawLine (22, x1, y2, x2, y2-1, context:convertTransparency (transparency));
        context:drawRectangle(11, 11, x1, y1, x2, y1 + 1, context:convertTransparency(transparency))
        context:drawRectangle(22, 22, x1, y2, x2, y2 - 1, context:convertTransparency(transparency))
    end
end
