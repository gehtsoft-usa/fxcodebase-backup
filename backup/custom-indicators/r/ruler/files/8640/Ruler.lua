-- Id: 3269
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3598

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
    indicator:name("Bar Counter")
    indicator:description("Bar Counter")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("Time", "TimeOut in Seconds", "", 60, 1, 100000)
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 20)
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local x1, x2, y1, y2, Angle
local first
local source = nil

local DateOne, LevelOne
local DateTwo, LevelTwo
local font
local Label
local Size
local BAR
local Time

-- Routine
function Prepare(nameOnly)
    Label = instance.parameters.Label
    Time = instance.parameters.Time
    Size = instance.parameters.Size
    source = instance.source
    first = source:first()

    local s, e
    s, e = core.getcandle(source:barSize(), 0, 0, 0)
    BAR = e - s

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    core.host:execute("addCommand", 1001, "First", "")
    core.host:execute("addCommand", 1002, "Second", "")
    core.host:execute("addCommand", 1003, "Set Second as Last", "")
    core.host:execute("addCommand", 1004, "Reset", "")

    font = core.host:execute("createFont", "Ariel", Size, true, false)
    core.host:execute("setTimer", 1000, Time)

    instance:setLabelColor(core.rgb(0, 0, 0))
    instance:ownerDrawn(true)

    x1 = nil
    x2 = nil
    y2 = nil
    y1 = nil
    Angle = nil
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
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

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1001 then
        DateOne, LevelOne = Parse(message)
    elseif cookie == 1002 then
        DateTwo, LevelTwo = Parse(message)
    elseif cookie == 1004 or cookie == 1000 then
        core.host:execute("removeAll")
        LevelOne = nil
        LevelTwo = nil
        x1 = nil
        x2 = nil
        y2 = nil
        y1 = nil
    elseif cookie == 1003 then
        DateTwo = source:date(source:size() - 1)
        LevelTwo = source.close[source:size() - 1]
    end
end

function ReleaseInstance()
    core.host:execute("deleteFont", font)
    core.host:execute("killTimer", 1000)
end

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if LevelOne ~= nil and LevelTwo ~= nil then
        --	if cookie == 1001 or cookie== 1002 or cookie== 1003  then
        core.host:execute(
            "drawLine",
            1,
            DateOne,
            LevelOne,
            DateTwo,
            LevelTwo,
            instance.parameters.color,
            instance.parameters.style,
            instance.parameters.width
        )

        core.host:execute(
            "drawLabel1",
            2,
            -300,
            core.CR_RIGHT,
            Size,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Period"
        )

        local p1, p2

        if DateOne <= source:date(source:size() - 1) then
            p1 = core.findDate(source, DateOne, true)
        else
            p1 = source:size() - 1 + (DateOne - source:date(source:size() - 1)) / BAR
        end

        x, x1 = context:positionOfBar(p1)
        visible1, y1 = context:pointOfPrice(LevelOne)

        if DateTwo <= source:date(source:size() - 1) then
            p2 = core.findDate(source, DateTwo, true)
        else
            p2 = source:size() - 1 + (DateTwo - source:date(source:size() - 1)) / BAR
        end

        x, x2 = context:positionOfBar(p2)
        visible2, y2 = context:pointOfPrice(LevelTwo)

        local p
        p = math.abs(p1 - p2)

        core.host:execute(
            "drawLabel1",
            3,
            -200,
            core.CR_RIGHT,
            Size,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. 0 .. "f", p)
        )

        core.host:execute(
            "drawLabel1",
            4,
            -300,
            core.CR_RIGHT,
            Size * 2,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Difference"
        )
        core.host:execute(
            "drawLabel1",
            5,
            -100,
            core.CR_RIGHT,
            Size * 2,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "(Absolute)"
        )

        local Absolute
        Absolute = LevelTwo - LevelOne
        core.host:execute(
            "drawLabel1",
            6,
            -200,
            core.CR_RIGHT,
            Size * 2,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. source:getPrecision() .. "f", Absolute)
        )

        core.host:execute(
            "drawLabel1",
            7,
            -300,
            core.CR_RIGHT,
            Size * 3,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Difference"
        )
        core.host:execute(
            "drawLabel1",
            8,
            -100,
            core.CR_RIGHT,
            Size * 3,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "(Relativ)"
        )
        local Relativ

        Relativ = (Absolute) / (LevelOne / 100)
        core.host:execute(
            "drawLabel1",
            9,
            -200,
            core.CR_RIGHT,
            Size * 3,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. 2 .. "f", Relativ)
        )

        core.host:execute(
            "drawLabel1",
            10,
            -300,
            core.CR_RIGHT,
            Size * 4,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Difference"
        )
        core.host:execute(
            "drawLabel1",
            11,
            -100,
            core.CR_RIGHT,
            Size * 4,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "(Pips)"
        )
        local Pips

        Pips = (Absolute) / source:pipSize()
        core.host:execute(
            "drawLabel1",
            12,
            -200,
            core.CR_RIGHT,
            Size * 4,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. 2 .. "f", Pips)
        )

        core.host:execute(
            "drawLabel1",
            13,
            -300,
            core.CR_RIGHT,
            Size * 5,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Slope"
        )
        core.host:execute(
            "drawLabel1",
            14,
            -100,
            core.CR_RIGHT,
            Size * 5,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "(Pips/Period)"
        )
        local Pips

        Pips = (Absolute) / source:pipSize()
        core.host:execute(
            "drawLabel1",
            15,
            -200,
            core.CR_RIGHT,
            Size * 5,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. 2 .. "f", Pips / p)
        )

        --//////////////////

        core.host:execute(
            "drawLabel1",
            16,
            -300,
            core.CR_RIGHT,
            Size * 6,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Slope"
        )
        core.host:execute(
            "drawLabel1",
            17,
            -100,
            core.CR_RIGHT,
            Size * 6,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "(In degrees)"
        )
        if visible2 and visible1 then
            core.host:execute(
                "drawLabel1",
                18,
                -200,
                core.CR_RIGHT,
                Size * 6,
                core.CR_TOP,
                core.H_Left,
                core.V_Bottom,
                font,
                Label,
                string.format("%." .. 2 .. "f", math.atan2((y1 - y2), (x2 - x1)) * 180 / math.pi)
            )

        -- core.host:execute("drawLabel1",18, -200, core.CR_RIGHT,Size*6, core.CR_TOP, core.H_Left, core.V_Bottom,
        --            font, Label,  "    "..   string.format("%." .. 2 .. "f", (y1-y2)  ).. " / " .. string.format("%." .. 2 .. "f", ( x2-x1) )   );
        end

        core.host:execute(
            "drawLabel1",
            19,
            -300,
            core.CR_RIGHT,
            Size * 7,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "First Level"
        )

        core.host:execute(
            "drawLabel1",
            20,
            -200,
            core.CR_RIGHT,
            Size * 7,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. source:getPrecision() .. "f", LevelOne)
        )

        core.host:execute(
            "drawLabel1",
            21,
            -300,
            core.CR_RIGHT,
            Size * 8,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            "Second Level"
        )

        core.host:execute(
            "drawLabel1",
            22,
            -200,
            core.CR_RIGHT,
            Size * 8,
            core.CR_TOP,
            core.H_Left,
            core.V_Bottom,
            font,
            Label,
            string.format("%." .. source:getPrecision() .. "f", LevelTwo)
        )

    --	end
    end
end
