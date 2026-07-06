-- Id: 7277
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22991

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("On Chart Oscillator")
    indicator:description("On Chart Oscillator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Indicator Calculation")

    indicator.parameters:addString("Position", "Overlay Position", "", "B")
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "B")
    indicator.parameters:addStringAlternative("Position", "Top", "", "T")
    indicator.parameters:addStringAlternative("Position", "Central", "", "C")

    indicator.parameters:addInteger("Period", "Period", "Period", 14)
    indicator.parameters:addString("Price", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")
    indicator.parameters:addDouble("OB_Level", "OB Level", "Level", 70)
    indicator.parameters:addDouble("OS_Level", "OS Level", "Level", 30)

    indicator.parameters:addGroup("Indicator Style")
    indicator.parameters:addColor("color", "Color of Indicator", "Color of Indicator", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Overlay Style")

    indicator.parameters:addColor("OB_color", "OB Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("OS_color", "OS Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("Zone_width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("Zone_style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("Zone_style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period
local Price

local first
local source = nil

-- Streams block
local Indicator = nil
local OB, OS, Position
local OB_Level, OS_Level
-- Routine
function Prepare(nameOnly)
    Position = instance.parameters.Position
    Top = instance.parameters.Top
    Bottom = instance.parameters.Bottom
    OB = instance.parameters.OB
    OS = instance.parameters.OS
    Price = instance.parameters.Price
    Period = instance.parameters.Period
    OB_Level = instance.parameters.OB_Level
    OS_Level = instance.parameters.OS_Level
    source = instance.source

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Indicator = core.indicators:create("RSI", source[Price], Period)
    first = Indicator.DATA:first()

    min = nil
    max = nil

    instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    Indicator:update(mode)
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
            instance.parameters.width,
            instance.parameters.color
        )
        context:createPen(
            2,
            context:convertPenStyle(instance.parameters.Zone_style),
            instance.parameters.Zone_width,
            instance.parameters.OB_color
        )
        context:createPen(
            3,
            context:convertPenStyle(instance.parameters.Zone_style),
            instance.parameters.Zone_width,
            instance.parameters.OS_color
        )

        init = true
    end

    local Delta = (context:bottom() - context:top()) / 4

    if Position == "T" then
        Top = context:top()
        Bottom = context:top() + Delta
    elseif Position == "B" then
        Top = context:bottom() - Delta
        Bottom = context:bottom()
    else
        Top = context:bottom() - (context:bottom() - context:top()) / 2 - Delta / 2
        Bottom = context:bottom() - (context:bottom() - context:top()) / 2 + Delta / 2
    end

    y1 = Bottom - (Delta / 100) * OB_Level
    y2 = Bottom - (Delta / 100) * OS_Level

    context:drawLine(2, context:left(), y1, context:right(), y1)
    context:drawLine(3, context:left(), y2, context:right(), y2)

    for period = math.max(Indicator.DATA:first(), context:firstBar()) + 1, math.min(
        source:size() - 1,
        context:lastBar()
    ), 1 do
        y1 = Bottom - (Delta / 100) * Indicator.DATA[period - 1]
        y2 = Bottom - (Delta / 100) * Indicator.DATA[period]

        x1, x = context:positionOfBar(period - 1)
        x2, x = context:positionOfBar(period)

        context:drawLine(1, x1, y1, x2, y2)
    end
end
