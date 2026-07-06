-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Pivot With Mid Point")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("group", "Support/Resistance")

    indicator.parameters:addGroup("Parameters")
    indicator.parameters:addString("BS", "Time Frame", "", "D1")
    indicator.parameters:setFlag("BS", core.FLAG_BARPERIODS)

    indicator.parameters:addString("CalcMode", "Calculation Mode", "", "Pivot")
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot")
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla")
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie")
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci")
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor")
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addString("ShowMode", "Mode", "", "TODAY")
    indicator.parameters:addStringAlternative("ShowMode", "TODAY", "", "TODAY")
    indicator.parameters:addStringAlternative("ShowMode", "HIST", "", "HIST")

    indicator.parameters:addString("LabelLoc", "Line labels location", "", "E")
    indicator.parameters:addStringAlternative("LabelLoc", "At the end", "", "E")
    indicator.parameters:addStringAlternative("LabelLoc", "At the beginning", "", "B")
    indicator.parameters:addStringAlternative("LabelLoc", "At the both", "", "A")
    indicator.parameters:addStringAlternative("LabelLoc", "No label", "", "N")

    indicator.parameters:addInteger("font_size", "Font size", "", 8);

    indicator.parameters:addColor("clrP", "Line Color", "", core.rgb(192, 192, 192))
    indicator.parameters:addInteger("widthP", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleP", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleP", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clrS1", "Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthS1", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS1", "Show S1", "", true)

    indicator.parameters:addColor("clrS2", "Line Color", "", core.rgb(224, 0, 0))
    indicator.parameters:addInteger("widthS2", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS2", "Show S2", "", true)

    indicator.parameters:addColor("clrS3", "Line Color", "", core.rgb(192, 0, 0))
    indicator.parameters:addInteger("widthS3", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS3", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS3", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS3", "Show S3", "", true)

    indicator.parameters:addColor("clrS4", "Line Color", "", core.rgb(160, 0, 0))
    indicator.parameters:addInteger("widthS4", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleS4", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleS4", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showS4", "Show S4", "", true)

    indicator.parameters:addColor("clrR1", "Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("widthR1", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR1", "Show R1", "", true)

    indicator.parameters:addColor("clrR2", "Line Color", "", core.rgb(0, 224, 0))
    indicator.parameters:addInteger("widthR2", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR2", "Show R2", "", true)

    indicator.parameters:addColor("clrR3", "Line Color", "", core.rgb(0, 192, 0))
    indicator.parameters:addInteger("widthR3", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR3", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR3", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR3", "Show R3", "", true)

    indicator.parameters:addColor("clrR4", "Line Color", "", core.rgb(0, 160, 0))
    indicator.parameters:addInteger("widthR4", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleR4", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleR4", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("showR4", "Show R4", "", true)

    indicator.parameters:addBoolean("ShowMP", "Show Mid Line", "", false)
    indicator.parameters:addColor("clrMP", "Line Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("widthMP", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleMP", "Line Style", "", core.LINE_DOT)
    indicator.parameters:setFlag("styleMP", core.FLAG_LEVEL_STYLE)
end

local P
local H
local L
local D
local source
local ref
local instr
local BS
local CurrLen
local BSLen
local host
local offset
local weekoffset

local RP = 0
local S1 = 1
local S2 = 2
local S3 = 3
local S4 = 4
local R1 = 5
local R2 = 6
local R3 = 7
local R4 = 8
local PID = 9
local name = {}
local show = {}
local clr = {}
local width = {}
local style = {}
local stream = {}
local fibr = {}

local clrP
local widthP
local styleP

local O_PIVOT = 1
local O_CAM = 2
local O_WOOD = 3
local O_FIB = 4
local O_FLOOR = 5
local O_FIBR = 6
local CalcMode

local O_HIST = 1
local O_TODAY = 2
local ShowMode
local ShowMP
local clrMP
local widthMP
local styleMP
local O_END = 1
local O_BEG = 2
local O_BOTH = 3
local LabelLoc
local eps
local SameSizeBar = false
local loading = false
local mid = {}
local font_size;

function Prepare(onlyName)
    font_size = instance.parameters.font_size;
    host = core.host
    offset = host:execute("getTradingDayOffset")
    weekoffset = host:execute("getTradingWeekOffset")

    source = instance.source
    instr = source:instrument()
    BS = instance.parameters.BS
    clrP = instance.parameters.clrP
    widthP = instance.parameters.widthP
    styleP = instance.parameters.styleP
    ShowMP = instance.parameters.ShowMP
    clrMP = instance.parameters.clrMP
    widthMP = instance.parameters.widthMP
    styleMP = instance.parameters.styleMP

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
    name[S4] = "S4"
    name[R1] = "R1"
    name[R2] = "R2"
    name[R3] = "R3"
    name[R4] = "R4"
    show[S1] = instance.parameters.showS1
    show[S2] = instance.parameters.showS2
    show[S3] = instance.parameters.showS3
    show[S4] = instance.parameters.showS4
    show[R1] = instance.parameters.showR1
    show[R2] = instance.parameters.showR2
    show[R3] = instance.parameters.showR3
    show[R4] = instance.parameters.showR4
    clr[S1] = instance.parameters.clrS1
    clr[S2] = instance.parameters.clrS2
    clr[S3] = instance.parameters.clrS3
    clr[S4] = instance.parameters.clrS4
    clr[R1] = instance.parameters.clrR1
    clr[R2] = instance.parameters.clrR2
    clr[R3] = instance.parameters.clrR3
    clr[R4] = instance.parameters.clrR4
    width[S1] = instance.parameters.widthS1
    width[S2] = instance.parameters.widthS2
    width[S3] = instance.parameters.widthS3
    width[S4] = instance.parameters.widthS4
    width[R1] = instance.parameters.widthR1
    width[R2] = instance.parameters.widthR2
    width[R3] = instance.parameters.widthR3
    width[R4] = instance.parameters.widthR4
    style[S1] = instance.parameters.styleS1
    style[S2] = instance.parameters.styleS2
    style[S3] = instance.parameters.styleS3
    style[S4] = instance.parameters.styleS4
    style[R1] = instance.parameters.styleR1
    style[R2] = instance.parameters.styleR2
    style[R3] = instance.parameters.styleR3
    style[R4] = instance.parameters.styleR4

    fibr[S4] = -0.272
    fibr[S3] = 0
    fibr[S2] = 0.236
    fibr[S1] = 0.382
    fibr[R1] = 0.618
    fibr[R2] = 0.764
    fibr[R3] = 1
    fibr[R4] = 1.272

    -- validate
    local l1, l2
    local s, e

    s, e = core.getcandle(source:barSize(), core.now(), 0)
    l1 = e - s
    s, e = core.getcandle(BS, core.now(), 0)
    l2 = e - s
    BSLen = l2 -- remember length of the period
    CurrLen = l1

    if source:barSize() == BS then
        SameSizeBar = true
    end

    if instance.parameters.ShowMode == "TODAY" then
        ShowMode = O_TODAY
    elseif instance.parameters.ShowMode == "HIST" then
        ShowMode = O_HIST
    end

    if instance.parameters.CalcMode == "Pivot" then
        CalcMode = O_PIVOT
    elseif instance.parameters.CalcMode == "Camarilla" then
        CalcMode = O_CAM
    elseif instance.parameters.CalcMode == "Woodie" then
        CalcMode = O_WOOD
    elseif instance.parameters.CalcMode == "Fibonacci" then
        CalcMode = O_FIB
    elseif instance.parameters.CalcMode == "Floor" then
        CalcMode = O_FLOOR
    elseif instance.parameters.CalcMode == "FibonacciR" then
        CalcMode = O_FIBR
        if ShowMode == O_TODAY then
            name[S1] = tostring(fibr[S1])
            name[S2] = tostring(fibr[S2])
            name[S3] = tostring(fibr[S3])
            name[S4] = tostring(fibr[S4])
            name[R1] = tostring(fibr[R1])
            name[R2] = tostring(fibr[R2])
            name[R3] = tostring(fibr[R3])
            name[R4] = tostring(fibr[R4])
            name[RP] = "0.5"
        end
    end

    if instance.parameters.LabelLoc == "E" then
        LabelLoc = O_END
    elseif instance.parameters.LabelLoc == "B" then
        LabelLoc = O_BEG
    elseif instance.parameters.LabelLoc == "A" then
        LabelLoc = O_BOTH
    else
        LabelLoc = nil
    end

    -- create streams
    local sname
    sname = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.CalcMode .. ")"
    instance:name(sname)

    if onlyName then
        assert(
            l1 <= l2,
            "Chosen base period for the pivot calculation must be equal to or longer than the chart period."
        )
        assert(BS ~= "t1", "Chosen base period for the pivot calculation must not be a tick period")
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
        for i = S1, R4, 1 do
            if show[i] then
                stream[i] = instance:addStream(name[i], core.Line, sname .. "." .. name[i], name[i], clr[i], 0)
                stream[i]:setWidth(width[i])
                stream[i]:setStyle(style[i])
            end
        end
    end

    if ShowMode == O_HIST and ShowMP then
        for i = 1, 6, 1 do
            mid[i] = instance:addStream("MID" .. i, core.Line, "mid" .. i, "mid" .. i, clrMP, 0)
            mid[i]:setWidth(widthMP)
            mid[i]:setStyle(styleMP)
        end
    end

    ref = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), 10, 100, 101)

    loading = true
    instance:ownerDrawn(true);
end

local pday = nil
local d = {}
local canWork = nil
local labels = {};

local init = false;
local FONT = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(font_size), context.LEFT);
        init = true;
    end

    for i, label in pairs(labels) do
        if (label ~= nil) then
            local x = context:positionOfDate(label.date);
            local _, y = context:pointOfPrice(label.rate);
            local w, h = context:measureText(FONT, label.text, context.LEFT);
            local x2 = x + w;
            if not label.alignLeft then
                x2 = x;
                x = x - w;
            end
            context:drawText(FONT, label.text, label.color, -1, x, y - h, x2, y, context.LEFT);
        end
    end
end

function Update(period, mode)
    if canWork == nil then
        if CurrLen > BSLen then
            core.host:execute(
                "setStatus",
                "Chosen base period for the pivot calculation must be equal to or longer than the chart period."
            )
            canWork = false
            return
        elseif BS == "t1" then
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
    candle = core.getcandle(BS, source:date(period), offset, weekoffset)

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
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3
    elseif CalcMode == O_CAM then
        P[period] = ref.close[prev_i]
    elseif CalcMode == O_FIBR then
        P[period] = (ref.high[prev_i] + ref.low[prev_i]) / 2
    elseif CalcMode == O_WOOD then
        local open
        if (prev_i == ref:size() - 1) then
            -- for a live day take close as open of the next period
            open = ref.open[prev_i]
        else
            open = ref.open[prev_i + 1]
        end
        P[period] = (ref.high[prev_i] + ref.low[prev_i] + open * 2) / 4
    end
    H[period] = ref.high[prev_i]
    L[period] = ref.low[prev_i]

    CalculateLevels(period)

    if ShowMP and ShowMode == O_HIST then
        for i = 1, 6, 1 do
            if mid[i][period] ~= mid[i][period - 1] then
                mid[i]:setBreak(period, true)
            end
        end
    end

    if ShowMode == O_HIST then
        local nb
        nb = false
        if P:hasData(period - 1) and math.abs(P[period - 1] - P[period]) > eps and not (SameSizeBar) then
            nb = true
        end

        for i = S1, R4, 1 do
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
    return h, l, p, r
end


function ShowLevels(data, period)
    local i, d1, d2

    --d1 = source:date(0);
    d2 = source:date(period)
    d1, d2 = core.getcandle(BS, d2, offset, weekoffset)

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
        labels[PID] = 
        {
            date = d2,
            rate = P[period],
            text = name[RP],
            alignLeft = false,
            color = clrP
        };
    end
    if LabelLoc == O_BEG or LabelLoc == O_BOTH then
        labels[PID + 100] = 
        {
            date = d1,
            rate = P[period],
            text = name[RP],
            alignLeft = true,
            color = clrP
        };
    end

    for i = S1, R4, 1 do
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
                labels[i] = 
                {
                    date = d2,
                    rate = data[i],
                    text = name[i],
                    alignLeft = false,
                    color = clr[i]
                };
            end
            if LabelLoc == O_BEG or LabelLoc == O_BOTH then
                labels[i + 100] = 
                {
                    date = d1,
                    rate = data[i],
                    text = name[i],
                    alignLeft = true,
                    color = clr[i]
                };
            end
        else
            labels[i] = nil;
            labels[i + 100] = nil;
            host:execute("removeLine", i)
        end
    end

    if ShowMode ~= O_HIST and ShowMP then
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
            labels[PID + 10 + i] = 
            {
                date = d2,
                rate = p,
                text = l,
                alignLeft = false,
                color = clrMP
            };
        end
        if LabelLoc == O_BEG or LabelLoc == O_BOTH then
            labels[PID + 110 + i] = 
            {
                date = d1,
                rate = p,
                text = l,
                alignLeft = true,
                color = clrMP
            };
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
    local h, l, p, r = initCalculateLevel(period)

    if CalcMode == O_PIVOT then
        d[R4] = p + r * 3
        d[R3] = p + r * 2
        d[R2] = p + r
        d[R1] = p * 2 - l

        d[S1] = p * 2 - h
        d[S2] = p - r
        d[S3] = p - r * 2
        d[S4] = p - r * 3
    elseif CalcMode == O_CAM then
        d[R4] = p + r * 1.1 / 2
        d[R3] = p + r * 1.1 / 4
        d[R2] = p + r * 1.1 / 6
        d[R1] = p + r * 1.1 / 12

        d[S1] = p - r * 1.1 / 12
        d[S2] = p - r * 1.1 / 6
        d[S3] = p - r * 1.1 / 4
        d[S4] = p - r * 1.1 / 2
    elseif CalcMode == O_WOOD then
        d[R4] = h + (2 * (p - l) + r)
        d[R3] = h + 2 * (p - l)
        d[R2] = p + r
        d[R1] = p * 2 - l

        d[S1] = p * 2 - h
        d[S2] = p - r
        d[S3] = l - 2 * (h - p)
        d[S4] = l - (r + 2 * (h - p))
    elseif CalcMode == O_FIB then
        d[R4] = p + 1.618 * (h - l)
        d[R3] = p + 1 * (h - l)
        d[R2] = p + 0.618 * (h - l)
        d[R1] = p + 0.382 * (h - l)

        d[S1] = p - 0.382 * (h - l)
        d[S2] = p - 0.618 * (h - l)
        d[S3] = p - 1 * (h - l)
        d[S4] = p - 1.618 * (h - l)
    elseif CalcMode == O_FLOOR then
        d[R4] = 0
        d[R3] = h + (p - l) * 2
        d[R2] = p + r
        d[R1] = p * 2 - l

        d[S1] = p * 2 - h
        d[S2] = p - r
        d[S3] = l - (h - p) * 2
        d[S4] = 0
    elseif CalcMode == O_FIBR then
        d[R4] = l + (h - l) * fibr[R4]
        d[R3] = l + (h - l) * fibr[R3]
        d[R2] = l + (h - l) * fibr[R2]
        d[R1] = l + (h - l) * fibr[R1]

        d[S1] = l + (h - l) * fibr[S1]
        d[S2] = l + (h - l) * fibr[S2]
        d[S3] = l + (h - l) * fibr[S3]
        d[S4] = l + (h - l) * fibr[S4]
    end

    if ShowMP and ShowMode == O_HIST then
        AddMPP(1, period, d[S2], d[S3])
        AddMPP(2, period, d[S1], d[S2])
        AddMPP(3, period, P[period], d[S1])
        AddMPP(4, period, P[period], d[R1])
        AddMPP(5, period, d[R1], d[R2])
        AddMPP(6, period, d[R2], d[R3])
    end

    return
end

function AddMPP(i, period, p1, p2)
    local p = (p1 + p2) / 2

    mid[i][period] = p
end

function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end
