-- Id: 11468

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60502

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
    indicator:name("Draw the time left of last bar")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("Version", "2")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addString("Display", "Display", "", "0")
    indicator.parameters:addStringAlternative("Display", "Time", "", "0")
    indicator.parameters:addStringAlternative("Display", "Percentage", "", "1")
    indicator.parameters:addStringAlternative("Display", "Both", "", "2")
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(0, 255, 255))
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)
    indicator.parameters:addString("Corner", "Corner", "", "Right-Top")
    indicator.parameters:addStringAlternative("Corner", "Right-Top", "", "Right-Top")
    indicator.parameters:addStringAlternative("Corner", "Right-Bottom", "", "Right-Bottom")
    indicator.parameters:addStringAlternative("Corner", "Left-Bottom", "", "Left-Bottom")
    indicator.parameters:addInteger("Size", "Size", "", 100)
end

local first = 0
local source = nil
local dummy
local color
local transparency
local Corner, IntCorner, Size
local T
local TimerID

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source
    first = source:first()
    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    Corner = instance.parameters.Corner
    T = tonumber(instance.parameters.Display)

    if Corner == "Right-Top" then
        IntCorner = 0
    elseif Corner == "Right-Bottom" then
        IntCorner = 1
    elseif Corner == "Left-Top" then
        IntCorner = 2
    else
        IntCorner = 3
    end

    Size = instance.parameters.Size

    if nameOnly then
        return
    end

    dummy = instance:addStream("output", core.Line, name, "output", instance.parameters.color, 0)
    instance:ownerDrawn(true)

    color = instance.parameters.color
    transparency = instance.parameters.transparency
    if transparency == 100 then
        transparency = 255
    elseif transparency == 0 then
        transparency = 0
    else
        transparency = math.floor(255 * (transparency / 100.0) + 0.5)
    end
    TimerID = core.host:execute("setTimer", 1, 1)
    core.host:execute("addCommand", 1000, "Move here", "Move here")
end

function Update(period)
end

local init = false
local x1, y1, x2, y2
local CustomX, CustomY

function Draw(stage, context)
    if stage == 0 then
        if not init then
            context:createSolidBrush(1, color)
            context:createPen(2, context.SOLID, 1, color)
            context:createFont(3, "Arial", 5, 0, 0)
            init = true
        end

        local last = source:size() - 1
        local beginTime, endTime = core.getcandle(source:barSize(), source:date(last), -7)
        local Past = core.host:execute("convertTime", core.TZ_EST, core.TZ_LOCAL, endTime) - core.now()
        local Angle = -Past / (endTime - beginTime) * 2 * math.pi - math.pi / 2
        while Past <= 0 do
            Past = Past + endTime - beginTime
        end
        local percents = math.floor(Past / (endTime - beginTime) * 100)
        Past = math.floor(Past * 86400 + 0.5)
        local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right()

        local h, m, s, t, p, n
        t = " "
        s = math.floor(Past % 60)
        m = math.floor((Past / 60)) % 60
        h = math.floor(Past / 3600)

        if T == 0 then
            t = string.format("%i:%02i:%02i", h, m, s)
        elseif T == 1 then
            t = string.format("%i%%", percents)
        elseif T == 2 then
            t = string.format("%i:%02i:%02i %i%%", h, m, s, percents)
        end

        if IntCorner == 0 then
            x1 = right - Size
            y1 = top
            x2 = right
            y2 = top + Size
        elseif IntCorner == 1 then
            x1 = right - Size
            y1 = bottom - Size
            x2 = right
            y2 = bottom
        elseif IntCorner == 2 then
            x1 = left
            y1 = top
            x2 = left + Size
            y2 = top + Size
        elseif IntCorner == 3 then
            x1 = left
            y1 = bottom - Size
            x2 = left + Size
            y2 = bottom
        else
            x1 = CustomX
            y1 = CustomY
            x2 = x1 + Size
            if x2 > right then
                x2 = right
                x1 = right - Size
            end
            y2 = y1 + Size
            if y2 > bottom then
                y2 = bottom
                y1 = bottom - Size
            end
        end

        local x_center, y_center = (x1 + x2) / 2, (y1 + y2) / 2

        local x, y = math2d.polarToCartesian(Size / 2, Angle)
        x, y = x + x_center, y + y_center

        local width, height = context:measureText(3, t, context.CENTER)
        if y2 + height <= bottom then
            context:drawEllipse(2, -1, x1, y1, x2, y2)
            context:drawArc(2, 1, x1, y1, x2, y2, x, y, x_center, y1, transparency)
            context:drawText(3, t, color, -1, x1, y2, x2, y2 + height, context.CENTER)
        else
            context:drawEllipse(2, -1, x1, y1 - height, x2, y2 - height)
            context:drawArc(2, 1, x1, y1 - height, x2, y2 - height, x, y - height, x_center, y1 - height, transparency)
            context:drawText(3, t, color, -1, x1, y2 - height, x2, y2, context.CENTER)
        end
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1 then
        instance:updateFrom(source:size() - 1)
    elseif cookie == 1000 then
        local t, c
        t, c = core.parseCsv(message, ";")
        if c >= 4 then
            CustomX = tonumber(t[2])
            CustomY = tonumber(t[3])
            IntCorner = 4
        end
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", TimerID)
end
