-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66942

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
    indicator:name("Fibonacci Projections And Daily Pivots")
    indicator:description("The indicator shows pivot point and the last period levels")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addBoolean("use_tf", "Use custom timeframe", "", true);
    indicator.parameters:addString("TF", "Time Frame ", "", "D1")
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addString("ShowMode", "Show Mode", "The mode of pivot presentation.", "TODAY")
    indicator.parameters:addStringAlternative("ShowMode", "Today", "", "TODAY")
    indicator.parameters:addStringAlternative("ShowMode", "Historical", "", "HIST")
    indicator.parameters:addString("LabelLoc", "Line labels location", "Defines the location of line labels.", "E")
    indicator.parameters:addStringAlternative("LabelLoc", "At the end", "", "E")
    indicator.parameters:addStringAlternative("LabelLoc", "At the beginning", "", "B")
    indicator.parameters:addStringAlternative("LabelLoc", "At both", "", "A")
    indicator.parameters:addStringAlternative("LabelLoc", "Do NOT Use Labels", "", "NO")

    indicator.parameters:addInteger("Size", "Font Size", "", 10)
    indicator.parameters:addColor("Color", "Label Color", "", core.COLOR_LABEL)

    indicator.parameters:addColor("clrP", "Pivot line Color", "", core.rgb(192, 192, 192))
    indicator.parameters:addInteger("widthP", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleP", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleP", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clrS1", "S1 line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthS1", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS1", "Show S1", "", true)

    indicator.parameters:addColor("clrS2", "S2 line Color", "", core.rgb(224, 0, 0))
    indicator.parameters:addInteger("widthS2", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS2", "Show S2", "", true)

    indicator.parameters:addColor("clrS3", "S3 line Color", "", core.rgb(192, 0, 0))
    indicator.parameters:addInteger("widthS3", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS3", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS3", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS3", "Show S3", "", true)

    indicator.parameters:addColor("clrR1", "R1 line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("widthR1", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR1", "Show R1", "", true)

    indicator.parameters:addColor("clrR2", "R2 line Color", "", core.rgb(0, 224, 0))
    indicator.parameters:addInteger("widthR2", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR2", "Show R2", "", true)

    indicator.parameters:addColor("clrR3", "R3 line Color", "", core.rgb(0, 192, 0))
    indicator.parameters:addInteger("widthR3", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR3", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR3", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR3", "Show R3", "", true)

    indicator.parameters:addBoolean(
        "ShowMP",
        "Show midpoint lines",
        "Defines whether the midpoint lines are shown.",
        false
    )
    indicator.parameters:addColor("clrMP", "Midpoint lines Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("widthMP", "Midpoint width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleMP", "Midpoint style", "", core.LINE_DOT)
    indicator.parameters:setFlag("styleMP", core.FLAG_LEVEL_STYLE)
end

local font, Size, Color

local P
local H
local L
local D
local source
local ref
local instr
local TF
local CurrLen
local BSLen
local host
local offset
local weekoffset

local RP = 0
local S1 = 1
local S2 = 2
local S3 = 3

local R1 = 4
local R2 = 5
local R3 = 6

local PID = 7
local name = {}
local show = {}
local clr = {}
local width = {}
local style = {}
local stream = {}

local clrP
local widthP
local styleP

local CalcMode

local O_HIST = 1
local O_TODAY = 2
local ShowMode
local ShowMP
local clrMP
local widthMP
local styleMP
local O_NO = 0
local O_END = 1
local O_BEG = 2
local O_BOTH = 3
local LabelLoc
local eps
local SameSizeBar = false
local loading = false

function Prepare(onlyName)
    host = core.host
    offset = host:execute("getTradingDayOffset")
    weekoffset = host:execute("getTradingWeekOffset")

    source = instance.source
    instr = source:instrument()
    TF = instance.parameters.TF
    if instance.parameters.use_tf then
        TF = source:barSize()
    end

    clrP = instance.parameters.clrP
    widthP = instance.parameters.widthP
    styleP = instance.parameters.styleP
    ShowMP = instance.parameters.ShowMP
    clrMP = instance.parameters.clrMP
    widthMP = instance.parameters.widthMP
    styleMP = instance.parameters.styleMP

    Size = instance.parameters.Size
    font = core.host:execute("createFont", "Arial", Size, false, false)
    Color = instance.parameters.Color

    local precision = source:getPrecision()
    if precision > 0 then
        eps = math.pow(10, -precision)
    else
        eps = 1
    end

    name[RP] = "P"
    name[S1] = "S1"
    name[S2] = "S2"
    name[S3] = "S3"

    name[R1] = "R1"
    name[R2] = "R2"
    name[R3] = "R3"

    show[S1] = instance.parameters.showS1
    show[S2] = instance.parameters.showS2
    show[S3] = instance.parameters.showS3

    show[R1] = instance.parameters.showR1
    show[R2] = instance.parameters.showR2
    show[R3] = instance.parameters.showR3

    clr[S1] = instance.parameters.clrS1
    clr[S2] = instance.parameters.clrS2
    clr[S3] = instance.parameters.clrS3

    clr[R1] = instance.parameters.clrR1
    clr[R2] = instance.parameters.clrR2
    clr[R3] = instance.parameters.clrR3

    width[S1] = instance.parameters.widthS1
    width[S2] = instance.parameters.widthS2
    width[S3] = instance.parameters.widthS3

    width[R1] = instance.parameters.widthR1
    width[R2] = instance.parameters.widthR2
    width[R3] = instance.parameters.widthR3

    style[S1] = instance.parameters.styleS1
    style[S2] = instance.parameters.styleS2
    style[S3] = instance.parameters.styleS3

    style[R1] = instance.parameters.styleR1
    style[R2] = instance.parameters.styleR2
    style[R3] = instance.parameters.styleR3

    -- validate
    local l1, l2
    local s, e

    s, e = core.getcandle(source:barSize(), core.now(), 0)
    l1 = e - s
    s, e = core.getcandle(TF, core.now(), 0)
    l2 = e - s
    BSLen = l2 -- remember length of the period
    CurrLen = l1

    if source:barSize() == TF then
        SameSizeBar = true
    end

    if instance.parameters.ShowMode == "TODAY" then
        ShowMode = O_TODAY
    elseif instance.parameters.ShowMode == "HIST" then
        ShowMode = O_HIST
    end

    if instance.parameters.LabelLoc == "E" then
        LabelLoc = O_END
    elseif instance.parameters.LabelLoc == "B" then
        LabelLoc = O_BEG
    elseif instance.parameters.LabelLoc == "A" then
        LabelLoc = O_BOTH
    elseif instance.parameters.LabelLoc == "NO" then
        LabelLoc = O_NO
    else
        assert(false, "Unknown label location" .. ": " .. instance.parameters.LabelLoc)
    end

    -- create streams
    local sname
    sname = profile:id() .. "(" .. source:name() .. ")"
    instance:name(sname)

    if onlyName then
        assert(
            l1 <= l2,
            "Chosen base period for the pivot calculation must be equal to or longer than the chart period."
        )
        assert(TF ~= "t1", "Chosen base period for the pivot calculation must not be a tick period")
        return
    end

    -- pivot
    if ShowMode == O_HIST then
        P = instance:addStream("P", core.Line, sname .. "." .. "P", "P", clrP, 0)
        P:setWidth(widthP)
        P:setStyle(styleP)
    else
        D = instance:addInternalStream(0, 0)
        D:setWidth(widthP)
        D:setStyle(styleP)
        P = instance:addInternalStream(0, 0)
    end
    -- range
    H = instance:addInternalStream(0, 0)
    L = instance:addInternalStream(0, 0)
    -- show stream for historical mode
    if ShowMode == O_HIST then
        for i = S1, R3, 1 do
            if show[i] then
                stream[i] = instance:addStream(name[i], core.Line, sname .. "." .. name[i], name[i], clr[i], 0)
                stream[i]:setWidth(width[i])
                stream[i]:setStyle(style[i])
                if ffi then
                    ffi_stream[i] = ffi.cast(pv, stream[i].ffi_ptr)
                end
            end
        end
    end

    ref = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 10, 100, 101)

    loading = true
end

local pday = nil
local d = {}
local canWork = nil

function Update(period, mode)
    if canWork == nil then
        if CurrLen > BSLen then
            core.host:execute(
                "setStatus",
                "Chosen base period for the pivot calculation must be equal to or longer than the chart period."
            )
            canWork = false
            return
        elseif TF == "t1" then
            core.host:execute("setStatus", "Chosen base period for the pivot calculation must not be a tick period")
            canWork = false
            return
        else
            canWork = true
        end
    elseif not (canWork) then
        return
    end

    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle
    candle = core.getcandle(TF, source:date(period), offset, weekoffset)

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading then
        return
    end

    if ref:size() == 0 then
        return
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < ref:date(0)) then
        return
    end

    -- find the lastest completed period which is not saturday's period (to avoid
    -- collecting the saturday's data
    local prev_i = nil
    local start

    if (pday == nil) then
        start = 0
    elseif ref:date(pday) >= candle then
        start = 0
    else
        start = pday
    end

    for i = start, ref:size() - 1, 1 do
        local td
        -- skip nontrading candles
        if BSLen > 1 or not (core.isnontrading(ref:date(i), offset)) then
            if (ref:date(i) >= candle) then
                break
            else
                prev_i = i
            end
        end
    end

    if (prev_i == nil) then
        -- assert(false, "prev_i is nil");
        return
    end

    pday = prev_i

    P[period] = (ref.high[prev_i - 1] + ref.close[prev_i - 1] + ref.low[prev_i - 1]) / 3

    H[period] = ref.high[prev_i - 1]
    L[period] = ref.low[prev_i - 1]

    CalculateLevels(period)
    if ShowMode == O_HIST then
        local nb
        nb = false
        if P:hasData(period - 1) and math.abs(P[period - 1] - P[period]) > eps and not (SameSizeBar) then
            nb = true
        end

        for i = S1, R3, 1 do
            if show[i] and d[i] ~= 0 then
                stream[i][period] = d[i]
                if nb then
                    stream[i]:setBreak(period, true)
                end
            end
        end
    end
    if (period == source:size() - 1) then
        ShowLevels(d, period)
    end
end

function initCalculateLevel(period)
    local h, l, p, r

    p = P[period]
    h = H[period]
    l = L[period]
    r = h - l
    return h, l, p, r, l, h
end

function ShowLevels(data, period)
    local i, d1, d2

    --d1 = source:date(0);
    d2 = source:date(period)
    d1, d2 = core.getcandle(TF, d2, offset, weekoffset)

    host:execute(
        "drawLine",
        PID,
        d1,
        P[period],
        d2,
        P[period],
        clrP,
        styleP,
        widthP,
        "P(" .. round(P[period], source:getPrecision()) .. ")"
    )
    if LabelLoc == O_END or LabelLoc == O_BOTH then
        --  host:execute("drawLabel", PID, d2, P[period], name[RP]);
        host:execute(
            "drawLabel1",
            PID,
            d2,
            core.CR_CHART,
            P[period],
            core.CR_CHART,
            core.H_Right,
            core.V_Top,
            font,
            Color,
            name[RP]
        )
    end
    if LabelLoc == O_BEG or LabelLoc == O_BOTH then
        --  host:execute("drawLabel", PID + 100, d1, P[period], name[RP]);
        host:execute(
            "drawLabel1",
            PID + 100,
            d1,
            core.CR_CHART,
            P[period],
            core.CR_CHART,
            core.H_Left,
            core.V_Top,
            font,
            Color,
            name[RP]
        )
    end

    for i = S1, R3, 1 do
        if show[i] and data[i] ~= 0 then
            host:execute(
                "drawLine",
                i,
                d1,
                data[i],
                d2,
                data[i],
                clr[i],
                style[i],
                width[i],
                name[i] .. "(" .. round(data[i], source:getPrecision()) .. ")"
            )
            if LabelLoc == O_END or LabelLoc == O_BOTH then
                -- host:execute("drawLabel", i, d2, data[i], name[i]);
                host:execute(
                    "drawLabel1",
                    i,
                    d2,
                    core.CR_CHART,
                    data[i],
                    core.CR_CHART,
                    core.H_Right,
                    core.V_Top,
                    font,
                    Color,
                    name[i]
                )
            end
            if LabelLoc == O_BEG or LabelLoc == O_BOTH then
                --  host:execute("drawLabel", i + 100, d1, data[i], name[i]);
                host:execute(
                    "drawLabel1",
                    i + 100,
                    d1,
                    core.CR_CHART,
                    data[i],
                    core.CR_CHART,
                    core.H_Left,
                    core.V_Top,
                    font,
                    Color,
                    name[i]
                )
            end
        else
            host:execute("removeLine", i)
            host:execute("removeLabel", i)
            host:execute("removeLabel", i + 100)
        end
    end

    if ShowMP then
        ShowMPP(0, d1, d2, d[S2], d[S3], "M0")
        ShowMPP(1, d1, d2, d[S1], d[S2], "M1")
        ShowMPP(2, d1, d2, P[period], d[S1], "M2")
        ShowMPP(3, d1, d2, P[period], d[R1], "M3")
        ShowMPP(4, d1, d2, d[R1], d[R2], "M4")
        ShowMPP(5, d1, d2, d[R2], d[R3], "M5")
    end
end

function ShowMPP(i, d1, d2, p1, p2, l)
    if p1 ~= 0 and p2 ~= 0 then
        local p = (p1 + p2) / 2
        host:execute(
            "drawLine",
            PID + 10 + i,
            d1,
            p,
            d2,
            p,
            clrMP,
            styleMP,
            widthMP,
            l .. "(" .. round(p, source:getPrecision()) .. ")"
        )
        if LabelLoc == O_END or LabelLoc == O_BOTH then
            host:execute(
                "drawLabel1",
                PID + 10 + i,
                d2,
                core.CR_CHART,
                l,
                core.CR_CHART,
                core.H_Right,
                core.V_Top,
                font,
                Color,
                1
            )
        end
        if LabelLoc == O_BEG or LabelLoc == O_BOTH then
            host:execute(
                "drawLabel1",
                PID + 110 + i,
                d1,
                core.CR_CHART,
                l,
                core.CR_CHART,
                core.H_Left,
                core.V_Top,
                font,
                Color,
                1
            )
        end
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        pday = nil
        loading = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loading = true
    end
end

function CalculateLevels(period)
    local ph, pl, pp, r, l, h = initCalculateLevel(period)

    d[R3] = pp * 2 + (h - 2 * l)
    d[R2] = pp + r
    d[R1] = pp * 2 - pl

    d[S1] = pp * 2 - ph
    d[S2] = pp - r
    d[S3] = pp * 2 - (2 * h - l)

    return
end
function ReleaseInstance()
    core.host:execute("deleteFont", font)
end

function round(num, idp)
    --local mult = 10^(idp or 0)
    --return math.floor(num * mult + 0.5) / mult

    return win32.formatNumber(num, false, idp)
end
