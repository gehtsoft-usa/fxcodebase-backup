-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9511
-- Id: 20817

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Day Start Line")
    indicator:description("The indicator draws a vertical line at the specified time")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Parameters")
    indicator.parameters:addInteger("hour", "Hour (EST)", "Hour at start of which the line must be drawn", 17, 0, 23)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clr", "Color", "", core.rgb(0, 127, 0))
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Style", "", core.LINE_DOT)
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
end

local source
local dummy, host
local hour, clr, width, style
local canwork, error

function Prepare(onlyname)
    source = instance.source
    clr = instance.parameters.clr
    width = instance.parameters.width
    style = instance.parameters.style
    hour = instance.parameters.hour
    host = core.host

    local s, e = core.getcandle(source:barSize(), 0, host:execute("getTradingDayOffset"), 0)
    canwork = not (math.floor(e - s) >= 1)

    if not canwork then
        errtext = "The indicator must be applied on intraday charts"
        if onlyname then
            assert(false, errtext)
        else
            core.host:execute("setStatus", "error:" .. errtext)
        end
    end

    local name
    name = profile:id() .. "(" .. source:name() .. "," .. hour .. ")"
    instance:name(name)

    if onlyname then
        return
    end

    dummy = instance:addStream("D", core.Line, name .. ".D", "D", clr, 0)
end

local last_s = nil
local id = 0
local last_date

function Update(period, mode)
    if not canwork then
        return
    end

    -- calculation restarted
    if period == 0 then
        host:execute("removeAll")
        id = 0
    end

    local s = source:serial(period)

    if s ~= last_s then
        last_s = s
        local date = source:date(period)
        local t = core.dateToTable(date)
        if t.min == 0 and t.hour == hour then
            last_date = date
            id = id + 1
            host:execute(
                "drawLine",
                id,
                date,
                0,
                date,
                100000,
                clr,
                style,
                width,
                core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date))
            )
        end
        return
    end
    if period == source:size() - 1 then
        if last_date > source:date(NOW) then
            return
        end
        while last_date < source:date(NOW) do
            last_date = last_date + 1
        end
        id = id + 1
        host:execute(
            "drawLine",
            id,
            last_date,
            0,
            last_date,
            100000,
            clr,
            style,
            width,
            core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, last_date))
        )
    end
end
