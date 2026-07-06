-- Id: 19617
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64556

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Min Max Cycle")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addDouble("Level1", "1.Level", "Level", 25)
    indicator.parameters:addDouble("Level2", "2.Level", "Level", 50)
    indicator.parameters:addDouble("Level3", "3.Level", "Level", 75)
    indicator.parameters:addDouble("Level4", "4.Level", "Level", 100)
    indicator.parameters:addDouble("Level5", "5.Level", "Level", 200)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("CrossColor", "Cross Color", "Line Color", core.rgb(0, 0, 0))
    indicator.parameters:addColor("color_1", "1. Level Color", "Line Color", core.rgb(128, 128, 128))
    indicator.parameters:addColor("color_2", "2. Level Color", "Line Color", core.rgb(128, 128, 128))
    indicator.parameters:addColor("color_3", "3. Level Color", "Line Color", core.rgb(128, 128, 128))
    indicator.parameters:addColor("color_4", "4. Level Color", "Line Color", core.rgb(0, 0, 255))
    indicator.parameters:addColor("color_5", "5. Level Color", "Line Color", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line width", "", 2, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100)

    indicator.parameters:addGroup("LineStyle")
    indicator.parameters:addBoolean("Show", "Show Lines", "", true)
    indicator.parameters:addColor("color1", "Min. Line Color", "Line Color", core.rgb(255, 0, 0))
    indicator.parameters:addColor("color2", "Max. Line Color", "Line Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("color3", "Center Line Color", "Line Color", core.rgb(0, 0, 255))

    indicator.parameters:addInteger("line_width", "Line width", "", 2, 1, 5)
    indicator.parameters:addInteger("line_style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE)

    indicator.parameters:addInteger("Text_Size", "Text_Size", "", 10)
    indicator.parameters:addColor("Label", "Text Color", "Text Color", core.COLOR_LABEL)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil

local transparency
local Level = {}
local Color = {}
local CrossColor

local db

local color1, color2, color3, line_width, line_style, Text_Size, Label
-- Routine
function Prepare(nameOnly)
    CrossColor = instance.parameters.CrossColor
    Show = instance.parameters.Show
    Text_Size = instance.parameters.Text_Size

    line_width = instance.parameters.line_width
    line_style = instance.parameters.line_style
    color1 = instance.parameters.color1
    color2 = instance.parameters.color2
    color3 = instance.parameters.color3
    Label = instance.parameters.Label

    source = instance.source
    first = source:first()

    for i = 1, 5, 1 do
        Level[i] = instance.parameters:getDouble("Level" .. i) / 100
        Color[i] = instance.parameters:getColor("color_" .. i)
    end

    center_y = nil
    center_x = nil

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    core.host:execute("addCommand", 1001, "Set Center", "")
    core.host:execute("addCommand", 1002, "Set High", "")
    core.host:execute("addCommand", 1003, "Set Low", "")

    require("storagedb")
    db = storagedb.get_db(name)

    instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1001 then
        local date, level = Parse(message)
        db:put("X1", tostring(date))
        db:put("center_y", tostring(level))
    elseif cookie == 1002 then
        date = Parse(message)
        db:put("X2", tostring(date))
    elseif cookie == 1003 then
        date = Parse(message)
        db:put("X3", tostring(date))
    end
end

local pattern = "([^;]*);([^;]*)"
function Parse(message)
    local level, date
    level, date = string.match(message, pattern, 0)

    if level == nil or date == nil then
        return nil, nil
    end

    return tonumber(date), tonumber(level)
end

local init = false
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    local center_y
    local center_x, maxpos, minpos

    local X1 = tonumber(db:get("X1", 0))
    local X2 = tonumber(db:get("X2", 0))
    local X3 = tonumber(db:get("X3", 0))
    center_y = tonumber(db:get("center_y", 0))

    if X1 == 0 or X2 == 0 or X3 == 0 or center_y == 0 then
        return
    end

    center_x = core.findDate(source, X1, false)
    maxpos = core.findDate(source, X2, false)
    minpos = core.findDate(source, X3, false)

    if center_x == -1 or maxpos == -1 or minpos == -1 then
        return
    end

    local min, max
    min = source.low[minpos]
    max = source.high[maxpos]

    if not init then
        for i = 1, 5, 1 do
            context:createPen(
                i,
                context:convertPenStyle(instance.parameters.style),
                instance.parameters.width,
                Color[i]
            )
        end
        transparency = context:convertTransparency(instance.parameters.transparency)
        context:createPen(6, context:convertPenStyle(instance.parameters.style), instance.parameters.width, CrossColor)

        init = true
        context:createFont(10, "Arial", Text_Size, Text_Size, 0)
        context:createPen(11, context:convertPenStyle(line_style), context:pointsToPixels(line_width), color1)
        context:createPen(12, context:convertPenStyle(line_style), context:pointsToPixels(line_width), color2)
        context:createPen(13, context:convertPenStyle(line_style), context:pointsToPixels(line_width), color3)
    end

    local xx = context:positionOfBar(center_x)
    local visible, yy = context:pointOfPrice(center_y)
    local x1, x = context:positionOfBar(minpos)
    local x2, x = context:positionOfBar(maxpos)
    local visible, y1 = context:pointOfPrice(min)
    local visible, y2 = context:pointOfPrice(max)

    local xd = math.abs(x2 - x1)
    local yd = math.abs(y2 - y1)
    local Distance = math.sqrt(xd * xd + yd * yd)

    context:drawLine(6, context:left(), yy, context:right(), yy, transparency)
    context:drawLine(6, x1, xx, context:top(), xx, context:bottom(), transparency)

    if x1 < x2 then
        for i = 1, 5, 1 do
            context:drawLine(
                i,
                context:left(),
                yy - Distance * Level[i],
                context:right(),
                yy - Distance * Level[i],
                transparency
            )
            context:drawLine(
                i,
                context:left(),
                yy + Distance * Level[i],
                context:right(),
                yy + Distance * Level[i],
                transparency
            )
            context:drawEllipse(
                i,
                -1,
                xx - Distance * Level[i],
                yy - Distance * Level[i],
                xx + Distance * Level[i],
                yy + Distance * Level[i],
                transparency
            )
        end
    else
        context:drawLine(6, context:left(), yy, context:right(), yy, transparency)
        context:drawLine(6, xx, context:top(), xx, context:bottom(), transparency)
        for i = 1, 5, 1 do
            context:drawLine(
                i,
                context:left(),
                yy - Distance * Level[i],
                context:right(),
                yy - Distance * Level[i],
                transparency
            )
            context:drawLine(
                i,
                context:left(),
                yy + Distance * Level[i],
                context:right(),
                yy + Distance * Level[i],
                transparency
            )
            context:drawEllipse(
                i,
                -1,
                xx - Distance * Level[i],
                yy - Distance * Level[i],
                xx + Distance * Level[i],
                yy + Distance * Level[i],
                transparency
            )
        end
    end

    if Show then
        context:drawLine(11, x1, y1, context:right(), y1)
        context:drawLine(12, x2, y2, context:right(), y2)
        context:drawLine(13, xx, yy, context:right(), yy)

        local Text1 = win32.formatNumber(min, false, source:getPrecision())
        local Text2 = win32.formatNumber(max, false, source:getPrecision())
        local Text3 = win32.formatNumber(center_y, false, source:getPrecision())

        width1, height1 = context:measureText(10, Text1, 0)
        width2, height2 = context:measureText(10, Text2, 0)
        width3, height3 = context:measureText(10, Text3, 0)

        context:drawText(10, Text1, Label, -1, context:right() - width1, y1 - height1, context:right(), y1, 0)
        context:drawText(10, Text2, Label, -1, context:right() - width2, y2 - height2, context:right(), y2, 0)
        context:drawText(
            10,
            Text3,
            Label,
            -1,
            context:right() - math.max(width1, width2) - width3,
            yy - height3,
            context:right() - math.max(width1, width2),
            yy,
            0
        )
    end
end
