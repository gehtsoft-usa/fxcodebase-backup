-- Id: 25130
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3987&start=30

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

function Init()
    indicator:name("Bigger timeframe Candle")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("TF", "Base Time Frame", "Base Time Frame", "m1")
    indicator.parameters:addStringAlternative("TF", "m1", "m1", "m1")
    indicator.parameters:addStringAlternative("TF", "H1", "H1", "H1")
    indicator.parameters:addStringAlternative("TF", "D1", "D1", "D1")
    indicator.parameters:addStringAlternative("TF", "W1", "W1", "W1")
    indicator.parameters:addStringAlternative("TF", "M1", "M1", "M1")
    indicator.parameters:addDouble("Step", "Number Of Elements", "", 1)
    indicator.parameters:addString("StartTime", "End/start time", "", "00:00")
    indicator.parameters:addGroup("Range")
    indicator.parameters:addDate("from", "From", "", -1000)
    indicator.parameters:addDate("to", "To", "", 0)
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL)
    indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 20)
    indicator.parameters:addInteger("MVA_Period", "MVA_Period", "", 200)

    indicator.parameters:addDouble("RE", "Empty Bar - Spread/Volume Ratio", "Empty Bar - Spread/Volume Ratio", "1.7")
    indicator.parameters:addDouble(
        "RC",
        "Compressed Bar - Spread/Volume Ratio",
        "Compressed Bar - Spread/Volume Ratio",
        "0.5"
    )
    indicator.parameters:addDouble(
        "RC1",
        "Average Compressed Bar - Spread/Volume Ratio",
        "Average Compressed Bar - Spread/Volume Ratio",
        "0.7"
    )

    indicator.parameters:addDouble("OS", "RSI Oversold Level", "RSI Oversold Level", "35")
    indicator.parameters:addDouble("OB", "RSI OverBought Level", "RSI OverBought Level", "65")

    indicator.parameters:addBoolean("ShowCompressed", "Show Compressed bar", "", true)
    indicator.parameters:addBoolean("ShowAvgCompressed", "Show Average Compressed bar", "", true)
    indicator.parameters:addBoolean("ShowEmpty", "Show Empty bar", "", true)
    indicator.parameters:addBoolean("ShowNDNS", "Show No Demand-No Supply bars", "", true)

    indicator.parameters:addColor("clrDefaultUp", "Default UP bar color", "Default UP bar color", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("clrDefaultDn", "Default DN bar color", "Default DN bar color", core.COLOR_DOWNCANDLE)
    indicator.parameters:addColor("clrComp", "Compressed bar color", "Compressed bar color", core.rgb(0, 0, 0))
    indicator.parameters:addColor(
        "clrAvgComp",
        "Average Compressed bar color",
        "Average Compressed Bar color",
        core.rgb(176, 87, 57)
    )
    indicator.parameters:addColor(
        "clrCompOSB",
        "Compressed Over sold/bought bar color",
        "Compressed Over sold/bought bar color",
        core.rgb(0, 255, 0)
    )
    indicator.parameters:addColor("clrNS", "No Supply color", "No Supply color", core.rgb(78, 194, 239))
    indicator.parameters:addColor("clrND", "No Demand color", "No Demand color", core.rgb(255, 0, 255))
    indicator.parameters:addColor("clrEmptyUp", "Empty UP bar color", "Empty UP bar color", core.rgb(192, 192, 192))
    indicator.parameters:addColor("clrEmptyDn", "Empty DN bar color", "Empty DN bar color", core.rgb(192, 192, 192))

    indicator.parameters:addInteger("transparency", "Transparency", "", 70, 0, 100)
end

local source  -- the source
local host
local FIRST = true
local transparency
local indi_src, indi
function Prepare(nameOnly)
    source = instance.source
    host = core.host

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    indiProfile = core.indicators:findIndicator("CUSTOM TIME FRAME CANDLE VIEW.HAILKAYY")
    assert(indiProfile ~= nil, "Please download and install CUSTOM TIME FRAME CANDLE VIEW.HAILKAYY.lua indicator")
    indi_src =
        core.indicators:create(
        "CUSTOM TIME FRAME CANDLE VIEW.HAILKAYY",
        source,
        source:instrument(),
        instance.parameters.TF,
        instance.parameters.Step,
        0,
        instance.parameters.StartTime,
        source:isBid(),
        instance.parameters.from,
        instance.parameters.to,
        false,
        1,
        false,
        false,
        "",
        false
    )
    local profile = core.indicators:findIndicator("BAR ANALYSIS")
    assert(profile ~= nil, "Please, download and install " .. "BAR ANALYSIS" .. ".LUA indicator")
    local indicatorParams = profile:parameters()
    indicatorParams:setInteger("ATR_Period", instance.parameters.ATR_Period)
    indicatorParams:setInteger("MVA_Period", instance.parameters.MVA_Period)
    indicatorParams:setDouble("RE", instance.parameters.RE)
    indicatorParams:setDouble("RC", instance.parameters.RC)
    indicatorParams:setDouble("RC1", instance.parameters.RC1)
    indicatorParams:setDouble("OS", instance.parameters.OS)
    indicatorParams:setDouble("OB", instance.parameters.OB)
    indicatorParams:setBoolean("ShowCompressed", instance.parameters.ShowCompressed)
    indicatorParams:setBoolean("ShowAvgCompressed", instance.parameters.ShowAvgCompressed)
    indicatorParams:setBoolean("ShowEmpty", instance.parameters.ShowEmpty)
    indicatorParams:setBoolean("ShowNDNS", instance.parameters.ShowNDNS)
    indicatorParams:setColor("clrDefaultUp", instance.parameters.clrDefaultUp)
    indicatorParams:setColor("clrDefaultDn", instance.parameters.clrDefaultDn)
    indicatorParams:setColor("clrComp", instance.parameters.clrComp)
    indicatorParams:setColor("clrAvgComp", instance.parameters.clrAvgComp)
    indicatorParams:setColor("clrCompOSB", instance.parameters.clrCompOSB)
    indicatorParams:setColor("clrNS", instance.parameters.clrNS)
    indicatorParams:setColor("clrND", instance.parameters.clrND)
    indicatorParams:setColor("clrEmptyUp", instance.parameters.clrEmptyUp)
    indicatorParams:setColor("clrEmptyDn", instance.parameters.clrEmptyDn)
    indi = core.indicators:create("BAR ANALYSIS", indi_src:getCandleOutput(0), indicatorParams)
    core.host:execute("setStatus", "Loading...")

    instance:ownerDrawn(true)
end

function Update(period, mode)
end

function AsyncOperationFinished(cookie)
end

local colors = {}
local count = 0
function Draw(stage, context)
    if stage ~= 0 then
        return
    end
    indi:update(core.UpdateLast)

    if not init then
        transparency = context:convertTransparency(instance.parameters.transparency)
        init = true
    end
    if indi == nil or indi.DATA:size() == 0 then
        return
    end
    core.host:execute("setStatus", "")

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

    local bf_first = core.findDate(indi.DATA, source:date(context:firstBar()), false)
    local bf_last = core.findDate(indi.DATA, source:date(context:lastBar()), false)
    if bf_first == -1 or bf_last == -1 then
        return
    end
    for period = bf_first, bf_last, 1 do
        Add(context, period)
    end
end

function Add(context, period)
    if not indi.DATA:hasData(period) then
        return
    end

    local start_date = indi.DATA:date(period)
    local end_date = period == indi.DATA:size() - 1 and source:date(NOW) or indi.DATA:date(period + 1)
    p1 = core.findDate(source, start_date, false)
    if p1 == -1 then
        return
    end

    p2 = core.findDate(source, end_date, false) - 1
    if p2 <= -1 then
        return
    end
    core.host:trace(p1 .. " " .. p2)

    Low = indi.low[period]
    High = indi.high[period]
    Open = indi.open[period]
    Close = indi.close[period]

    visible, H = context:pointOfPrice(math.max(Open, Close))
    visible, L = context:pointOfPrice(math.min(Open, Close))

    visible, high = context:pointOfPrice(High)
    visible, low = context:pointOfPrice(Low)

    x, x1 = context:positionOfBar(p1)
    x, _, x2 = context:positionOfBar(p2)

    local color = indi.open:colorI(period)
    if colors[color] == nil then
        colors[color] = count + 1
        count = count + 1
        context:createSolidBrush(count, color)
    end
    local center = (x1 + x2) / 2
    local wick_half_width = math.max(1, (x2 - x1) / 20)

    context:drawRectangle(-1, colors[color], x1, H - 1, x2, L + 1, transparency)
    context:drawRectangle(
        -1,
        colors[color],
        center - wick_half_width,
        high - 1,
        center + wick_half_width,
        H,
        transparency
    )
    context:drawRectangle(
        -1,
        colors[color],
        center - wick_half_width,
        L,
        center + wick_half_width,
        low + 1,
        transparency
    )
end
