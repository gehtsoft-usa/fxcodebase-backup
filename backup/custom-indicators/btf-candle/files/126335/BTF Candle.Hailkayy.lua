-- Id: 24983
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3987

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
    indicator.parameters:addString("StartTime", "End/start time", "", "00:00")
    indicator.parameters:addGroup("Range")
    indicator.parameters:addDate("from", "From", "", -1000)
    indicator.parameters:addDate("to", "To", "", 0)
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL)

    indicator.parameters:addInteger("DOJI", "Max. Doji Body Lengt", "In Pips", 10, 1, 10000)
    indicator.parameters:addInteger("Wick", "Wick as percentage of candle body", "As percentage", 10, 1, 10000)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UP_Color", "Color for UP", "Color for UP", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DOWN_Color", "Color for DOWN", "Color for DOWN", core.rgb(255, 0, 0))
    indicator.parameters:addColor("DOJI_Color", "Color for Doji", "Color for DOJI", core.rgb(128, 128, 128))

    indicator.parameters:addInteger("transparency", "Transparency", "", 70, 0, 100)
end

local source  -- the source
local host
local FIRST = true
local DOJI
local UP_Color, DOJI_Color, DOWN_Color
local transparency
local Wick
local indi
function Prepare(nameOnly)
    DOJI = instance.parameters.DOJI
    source = instance.source
    host = core.host

    UP_Color = instance.parameters.UP_Color
    DOJI_Color = instance.parameters.DOJI_Color
    DOWN_Color = instance.parameters.DOWN_Color

    Wick = instance.parameters.Wick

    local name = profile:id() .. "(" .. source:name() .. "," .. DOJI .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    indiProfile = core.indicators:findIndicator("CUSTOM TIME FRAME CANDLE VIEW.HAILKAYY")
    assert(indiProfile ~= nil, "Please download and install CUSTOM TIME FRAME CANDLE VIEW.HAILKAYY.lua indicator")
    indi =
        core.indicators:create(
        "CUSTOM TIME FRAME CANDLE VIEW.HAILKAYY",
        source,
        source:instrument(),
        instance.parameters.TF,
        1,
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

    instance:ownerDrawn(true)
end

function Update(period, mode)
end

function AsyncOperationFinished(cookie)
end

function Draw(stage, context)
    if stage ~= 0 then
        return
    end

    if not init then
        context:createSolidBrush(1, UP_Color)
        context:createSolidBrush(2, DOWN_Color)
        context:createSolidBrush(3, DOJI_Color)
        transparency = context:convertTransparency(instance.parameters.transparency)

        init = true
    end
    if indi == nil or indi.DATA:size() == 0 then
        return
    end

    local bf_first = core.findDate(indi.DATA, source:date(context:firstBar(), false))
    local bf_last = core.findDate(indi.DATA, source:date(context:lastBar(), false))
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

    Delta = (x2 - x1)
    x = x1 + Delta / 2
    Percentage = (Delta / 100) * Wick

    if DOJI > math.abs(Close - Open) / source:pipSize() then
        context:drawRectangle(-1, 3, x1, H, x2, L, transparency)
        context:drawRectangle(-1, 3, x - Percentage, high, x + Percentage, H, transparency)
        context:drawRectangle(-1, 3, x - Percentage, L, x + Percentage, low, transparency)
    elseif Close > Open then
        context:drawRectangle(-1, 1, x1, H, x2, L, transparency)
        context:drawRectangle(-1, 1, x - Percentage, high, x + Percentage, H, transparency)
        context:drawRectangle(-1, 1, x - Percentage, L, x + Percentage, low, transparency)
    elseif Close < Open then
        context:drawRectangle(-1, 2, x1, H, x2, L, transparency)
        context:drawRectangle(-1, 2, x - Percentage, high, x + Percentage, H, transparency)
        context:drawRectangle(-1, 2, x - Percentage, L, x + Percentage, low, transparency)
    end
end
