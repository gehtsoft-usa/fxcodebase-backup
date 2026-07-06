-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66476
-- Id: 

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

function Init()
    indicator:name("WinMidas")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("days", "Days", 100, 10, 5000);
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil
local Date, Level
local Line = {}
local s1, s2
-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Date = 0
    s1 = instance:addInternalStream(0, 0)
    s2 = instance:addInternalStream(0, 0)

    core.host:execute("addCommand", 100, "Start From Selected Period", "")

    source = instance.source
    first = instance.parameters.days;
    Line = instance:addStream("Line", core.Line, " Line", " Line", instance.parameters.color, first)
    Line:setWidth(instance.parameters.width)
    Line:setStyle(instance.parameters.style)
end

local pattern = "([^;]*);([^;]*)"

function Parse(message)
    local level, date
    level, date = string.match(message, pattern, 0)

    if level == nil or date == nil then
        return 0, 0
    end

    return tonumber(date), tonumber(level)
end

-- Indicator calculation routine
function Update(period)
    if period < first then
        s1[period] = 0;
        s2[period] = 1;
        Line[period] = nil
        return
    end
    s1[period] = s1[period - 1] + source.median[period] * source.volume[period]
    s2[period] = s2[period - 1] + source.volume[period];

    if Date <= 0 then
        return
    end

    Period = core.findDate(source, Date, false)

    if period < Period then
        Line[period] = nil
        return
    end

    Line[period] = s1[period] / s2[period];
end

function AsyncOperationFinished(cookie, success, message)
    local D, L

    D, L = Parse(message)

    if cookie == 100 then
        Date = D
    end

    instance:updateFrom(0)
    return core.ASYNC_REDRAW
end

--[[
days := Input("Days",10,5000,100);
Cum(If(Cum(1)<days,0,MP()*V))/Cum(If(Cum(1)=1,1,If(Cum(1)<days,0,V)))
]]
