-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60666

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Tick SAR MA Filter")
    indicator:description("Tick SAR MA Helper")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Selector")
    indicator.parameters:addString("Type", "Algorithm Selector", "Algorithm Selector", "First")
    indicator.parameters:addStringAlternative("Type", "First Algorithm", "First Algorithm", "First")
    indicator.parameters:addStringAlternative("Type", "Second Algorithm", "Second Algorithm", "Second")

    indicator.parameters:addGroup("MA Calculation")
    indicator.parameters:addInteger("Period1", "1. Period ", "", 7)
    indicator.parameters:addString("Method1", "MA Method", "Method", "EMA")
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA")
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA")

    indicator.parameters:addInteger("Period2", "2. Period ", "", 14)
    indicator.parameters:addString("Method2", "MA Method", "Method", "EMA")
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA")
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA")

    indicator.parameters:addGroup("SAR Calculation")
    indicator.parameters:addDouble("Step", "Step", "", 0.02, 0.001, 1)
    indicator.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Up", "Color of Up Alert", "Color of Up", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Color Down Alert", "Color of Down", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("Size", "Size", "Size", 20)
end

local Up
local Down
local Type
local first
local source = nil
local Period
local Indicator = {}
local Method
-- Streams block
local up
local down
local Size
local Flag
local Step, Max
local sar
local closeup, closedown
-- Routine
function Prepare(nameOnly)
    source = instance.source

    Type = instance.parameters.Type
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Size = instance.parameters.Size
    Step = instance.parameters.Step
    Max = instance.parameters.Max

    Period1 = instance.parameters.Period1
    Period2 = instance.parameters.Period2

    Method1 = instance.parameters.Method1
    Method2 = instance.parameters.Method2

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed")
    Indicator[1] = core.indicators:create(Method1, source, Period1)
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed")
    Indicator[2] = core.indicators:create(Method2, source, Period2)
    local profile = core.indicators:findIndicator("TICK_SAR");
    assert(profile ~= nil, "Please, download and install " .. "TICK_SAR" .. ".LUA indicator");
    sar = core.indicators:create("TICK_SAR", source, Step, Max)

    first = math.max(Indicator[1].DATA:first(), Indicator[2].DATA:first(), sar.UP:first(), sar.DN:first())

    up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, Up, source:first())
    down = instance:createTextOutput("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, Down, source:first())

    closeup = instance:createTextOutput("CloseUp", "CloseUp", "Wingdings", Size, core.H_Center, core.V_Top, Up, source:first())
    closedown = instance:createTextOutput("CloseDown", "CloseDown", "Wingdings", Size, core.H_Center, core.V_Bottom, Down, source:first())

    Flag = instance:addInternalStream(0, 0)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    Indicator[1]:update(mode)
    Indicator[2]:update(mode)
    sar:update(mode)

    if period < first then
        return
    end

    Flag[period] = 0

    up:setNoData(period)
    down:setNoData(period)

    Calculation1(period)
    Calculation2(period)
end

function Calculation1(period)
    if Type ~= "First" then
        return
    end

    if Indicator[1].DATA[period] > Indicator[2].DATA[period] and sar.DN:hasData(period) then
        Flag[period] = 1
    elseif Indicator[1].DATA[period] < Indicator[2].DATA[period] and sar.UP:hasData(period) then
        Flag[period] = -1
    else
        Flag[period] = 0
    end

    if Flag[period] == 1 and Flag[period - 1] ~= 1 then
        up:set(period, source[period], "\254")
    end

    if Flag[period] == -1 and Flag[period - 1] ~= -1 then
        down:set(period, source[period], "\254")
    end

    if Flag[period] == 0 and Flag[period - 1] ~= 0 then
        if Flag[period - 1] == -1 then
            closedown:set(period, source[period], "\253")
        end
        if Flag[period - 1] == 1 then
            closeup:set(period, source[period], "\253")
        end
    end
end

function Calculation2(period)
    if Type ~= "Second" then
        return
    end

    if (Indicator[1].DATA[period] > Indicator[2].DATA[period] and sar.DN:hasData(period)) then
        Flag[period] = 1
    elseif (Indicator[1].DATA[period] < Indicator[2].DATA[period] and sar.UP:hasData(period)) then
        Flag[period] = -1
    else
        Flag[period] = Flag[period - 1]
    end

    if Flag[period] == 1 and Flag[period - 1] ~= 1 then
        up:set(period, source[period], "\254")
    end

    if Flag[period] == -1 and Flag[period - 1] ~= -1 then
        down:set(period, source[period], "\254")
    end
end
