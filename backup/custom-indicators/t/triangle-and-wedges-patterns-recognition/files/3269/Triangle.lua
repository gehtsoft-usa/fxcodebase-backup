-- Id: 1132
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1643

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Triangle")
    indicator:description("Triangle")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addString("k1", "Triangle", "Triangle  Y/N", "Yes")
    indicator.parameters:addStringAlternative("k1", "Yes", "Triangle Yes", "Yes")
    indicator.parameters:addStringAlternative("k1", "No", "Triangle No", "No")

    indicator.parameters:addString("k2", "Expanding Triangle", "Expanding Triangle  Y/N", "No")
    indicator.parameters:addStringAlternative("k2", "Yes", "Expanding Triangle Yes", "Yes")
    indicator.parameters:addStringAlternative("k2", "No", "Expanding Triangle No", "No")

    indicator.parameters:addString("k5", "Wedges", "Up Wedges  Y/N", "No")
    indicator.parameters:addStringAlternative("k5", "Yes", "Wedges  Yes", "Yes")
    indicator.parameters:addStringAlternative("k5", "No", "Wedges  No", "No")

    indicator.parameters:addString("k6", "Down Wedges", "Wedges  Y/N", "No")
    indicator.parameters:addStringAlternative("k6", "Yes", "Wedges  Yes", "Yes")
    indicator.parameters:addStringAlternative("k6", "No", "Wedges  No", "No")

    indicator.parameters:addInteger("x", "Max. Base / Side Ratio", "Max. Base / Side Ratio", 5)
    indicator.parameters:addInteger("y", "Max. Side / Side Ratio", "Max. Side / Side Ratio", 5)

    indicator.parameters:addInteger("frame", "Frame Size", "Frame Size", 50)
    indicator.parameters:addColor("top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0))
    indicator.parameters:addColor("bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
    indicator.parameters:addBoolean("strategy_output", "Strategy output", "", false);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first = nil
local source = nil
local candlesize = nil

local k1 = nil
local k2 = nil
--local k3=nil;
--local k4=nil;
local k5 = nil
local k6 = nil
local base1 = 0
local base2 = 0

-- Streams block
local dummy = nil

--Variable
local upy = nil
local downy = nil
local style, width
local output_up;
local output_down;
-- Routine
function Prepare(nameOnly)
    style = instance.parameters.style
    frame = instance.parameters.frame
    width = instance.parameters.width
    k1 = instance.parameters.k1
    k2 = instance.parameters.k2
    k3 = instance.parameters.k3
    k4 = instance.parameters.k4
    k5 = instance.parameters.k5
    k6 = instance.parameters.k6
    base1 = instance.parameters.x
    base2 = instance.parameters.y

    source = instance.source
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    local s, e
    s, e = core.getcandle(source:barSize(), core.now(), 0)
    -- remember size of the candle to calculate the date for the lines which ends after the end of the chart
    candlesize = e - s

    upy = instance:addInternalStream(0, 0)
    downy = instance:addInternalStream(0, 0)

    -- add an extent to make the output streams longer than the source to be able draw into the future
    dummy = instance:addStream("D", core.Dot, name, "D", instance.parameters.top_color, first, 300)
    if instance.parameters.strategy_output then
        output_up = instance:addStream("OUTPUT_UP", core.Dot, "OUTPUT_UP", "OUTPUT_UP", 0, 0)
        output_down = instance:addStream("OUTPUT_DOWN", core.Dot, "OUTPUT_DOWN", "OUTPUT_DOWN", 0, 0)
    end
end

local last_period = -1

-- update
function Update(period)
    -- detect restart
    if last_period > period then
        core.host:execute("removeAll")
    end
    last_period = period

    if period >= 6 then
        fractal(period)
    end
    if period >= frame then
        Draw(period, frame)
    end
end

--distance between two points
function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end

-- calculate fractals
function fractal(p)
    upy[p] = 0
    downy[p] = 0

    curr = source.high[p - 2]

    if
        (curr >= source.high[p - 4] and curr >= source.high[p - 3] and curr >= source.high[p - 1] and
            curr >= source.high[p])
     then
        upy[p - 2] = source.high[p - 2]
    end

    curr = source.low[p - 2]
    if (curr <= source.low[p - 4] and curr <= source.low[p - 3] and curr <= source.low[p - 1] and curr <= source.low[p]) then
        downy[p - 2] = source.low[p - 2]
    end

    upy[p - 1] = 0
    downy[p - 1] = 0
    upy[p] = 0
    downy[p] = 0
end

-- get line equation coefficients
function getline(x1, y1, x2, y2)
    local a, b

    a = ((y2 - y1) / (x2 - x1))
    b = (y1 - a * x1)
    return a, b
end

-- get line intersection point
function intersect(a1, b1, a2, b2)
    local x, y

    -- collinear
    if a1 == a2 then
        return nil, nil
    end

    x = (b2 - b1) / (a1 - a2)
    y = a1 * x + b1
    return x, y
end

local line_id = 0

-- draws line based on two fractals and the point of the intersection
function drawline(x1, y1, x2, y2, ix, iy, color, is_top)
    -- line's coordinates
    local lx1, lx2, ly1, ly2

    -- case 1
    -- intesection is before x1
    if ix < x1 then
        -- intesection is between x1 and x2
        lx1 = ix
        ly1 = iy
        lx2 = x2
        ly2 = y2
    elseif ix >= x1 and ix <= x2 then
        -- intesection is after x2
        lx1 = x1
        ly1 = y1
        lx2 = x2
        ly2 = y2
    else
        lx1 = x1
        ly1 = y1
        lx2 = ix
        ly2 = iy
    end

    -- if line is out of the chart area - adjust it to the chart borders
    if lx1 < 0 or lx2 >= dummy:size() then
        local a, b
        a, b = getline(lx1, ly1, lx2, ly2)
        if lx1 < 0 then
            lx1 = 0
        end
        if lx2 >= dummy:size() then
            lx2 = dummy:size() - 1
        end
        ly1 = a * lx1 + b
        ly2 = a * lx2 + b
    end

    -- get dates instead of number of the periods
    local date1, date2
    date1 = source:date(lx1)
    if lx2 >= source:size() then
        date2 = source:date(source:size() - 1) + candlesize * (lx2 - source:size() + 1)
    else
        date2 = source:date(lx2)
    end
    core.host:execute("drawLine", line_id, date1, ly1, date2, ly2, color, style, width)
    if instance.parameters.strategy_output then
        if is_top then
            core.drawLine(output_up, core.range(lx1, lx2), ly1, lx1, ly2, lx2);
        else
            core.drawLine(output_down, core.range(lx1, lx2), ly1, lx1, ly2, lx2);
        end
    end
    line_id = line_id + 1
end

-- find last two up and down fractals
function Draw(period, frame)
    local i, f
    -- x (period) and y (price) coordinates of two last fractals
    local hx1, hy1, hx2, hy2
    local lx1, ly1, lx2, ly2

    hy1 = nil
    hy2 = nil
    ly1 = nil
    ly2 = nil
    f = 0

    for i = period, period - frame + 1, -1 do
        if upy[i] ~= 0 then
            if hy1 == nil then
                hy1 = upy[i]
                hx1 = i
                f = f + 1
            elseif hy2 == nil then
                hy2 = upy[i]
                hx2 = i
                f = f + 1
            end
        end
        if downy[i] ~= 0 then
            if ly1 == nil then
                ly1 = downy[i]
                lx1 = i
                f = f + 1
            elseif ly2 == nil then
                ly2 = downy[i]
                lx2 = i
                f = f + 1
            end
        end
        -- all four points are found
        if f == 4 then
            break
        end
    end

    -- if all four points has been found
    if f == 4 then
        -- intersection point
        local ix, iy = nil
        -- a and b coefficients of the y = a * x + b line quation
        -- x2 always < x1
        local a1, b1, a2, b2
        a1, b1 = getline(hx2, hy2, hx1, hy1)
        a2, b2 = getline(lx2, ly2, lx1, ly1)

        ix, iy = intersect(a1, b1, a2, b2)
        if ix == nil then
            -- collinear
            return
        else
            local ls = Distance(lx2, ly2, ix, iy)
            local bs = Distance(hx2, hy2, lx2, ly2)
            local hs = Distance(hx2, hy2, ix, iy)

            if ls / bs > base1 or hs / bs > base1 then
                return
            end

            if bs > ls or bs > hs then
                return
            end

            if ls / hs > base2 or hs / ls > base2 then
                return
            end

            --Triangle
            if ix > hx1 and ix > lx1 and iy <= hy1 and iy >= ly1 and k1 == "No" then
                return
            end

            --Expanding Triangle
            if ix < hx1 and ix < lx1 and iy <= hy1 and iy >= ly1 and k2 == "No" then
                return
            end

            --Up Wedges
            if iy > hy1 and iy > ly1 and ix > hx1 and ix > lx1 and k5 == "No" then
                return
            end

            -- Down Wedges
            if iy < hy1 and iy < ly1 and ix > hx1 and ix > lx1 and k6 == "No" then
                return
            end

            -- Expanding Down Wedges
            if iy < hy1 and iy < ly1 and ix < hx1 and ix < lx1 then
                return
            end

            -- Expanding Up Wedges
            if iy > hy1 and iy > ly1 and ix < hx1 and ix < lx1 then
                return
            end

            drawline(hx2, hy2, hx1, hy1, ix, iy, instance.parameters.top_color, true)
            drawline(lx2, ly2, lx1, ly1, ix, iy, instance.parameters.bottom_color, false)
        end
    end
end
