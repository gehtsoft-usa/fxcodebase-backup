-- Id: 25347
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68422&start=10

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

local indi_alerts = {};

function Init()
    indicator:name("RSI with targets")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    
    indicator.parameters:addString("TF", "Indicator Time Frame", "", "D1")
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS_EDIT)
    indicator.parameters:addInteger("rsi_period", "RSI Period", "Period", 20)
    indicator.parameters:addDouble("rsi_level", "RSI Level", "", 50);
    
    indicator.parameters:addDouble("Level1", "1. Target Ratio", "", 1)
    indicator.parameters:addDouble("Level2", "2. Target Ratio", "", 1.5)
    indicator.parameters:addDouble("Level3", "3. Target Ratio", "", 2)
    indicator.parameters:addDouble("Level4", "Trigger Line (in pips)", "", 0)

    indicator.parameters:addBoolean("Historical", "Show Historical", "", true)
    indicator.parameters:addString("ShowLabel", "Show Label", "", "no")
    indicator.parameters:addStringAlternative("ShowLabel", "Do not show", "", "no")
    indicator.parameters:addStringAlternative("ShowLabel", "At the left", "", "left")
    indicator.parameters:addStringAlternative("ShowLabel", "At the right", "", "right")

    indicator.parameters:addInteger("Lookback", "Label Lookback Period", "", 100)

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addColor("StartLineColor", "Start Line Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Label Style")
    indicator.parameters:addColor("LabelColor", "Label Color", "", core.COLOR_LABEL)
    indicator.parameters:addBoolean("LabelBackground", "Add Label Background", "", false)
    indicator.parameters:addColor("LabelBackgroundColor", "Label Background Color", "", core.COLOR_BACKGROUND)
    indicator.parameters:addInteger("FontSize", "Label Size", "", 8)
    indicator.parameters:addColor("StopLineColor", "Stop Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("TargetLineColor1", "1. Target Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("TargetLineColor2", "2. Target  Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("TargetLineColor3", "3. Target  Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("TargetLineColor4", "Trigger Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE)

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("SAR")
end

local Number = 1
local Size
local Show
local Live
local FIRST = true
local OnlyOnce
local UpTrendColor, DownTrendColor
local OnlyOnceFlag
local ShowAlert
local Shift = 0
local StartLineColor, StopLineColor, TargetLineColor1, TargetLineColor2, TargetLineColor3, TargetLineColor4

local first
local source = nil
local btf_source = nil
local position = nil

local FontSize, LabelColor, font

local Level1, Level2, Level3, Level4
local style1, style2, style3, style4
local width1, width2, width3, width4, width5, width5
local LabelBackgroundColor
local LabelBackground
local Historical, ShowLabel
local Lookback
local TF
local dayoffset
local weekoffset
local rsi_period, rsi_level

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:ownerDrawn(true);
    rsi_period = instance.parameters.rsi_period;
    rsi_level = instance.parameters.rsi_level;

    dayoffset  = core.host:execute("getTradingDayOffset")
    weekoffset = core.host:execute("getTradingWeekOffset")
    source = instance.source
    TF = instance.parameters.TF
    local s1, e1, s2, e2
    s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
    s2, e2 = core.getcandle(TF, 0, 0, 0)
    assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")

    btf_source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101)
    loading    = true

    LabelBackgroundColor = instance.parameters.LabelBackgroundColor
    LabelBackground = instance.parameters.LabelBackground
    FontSize = instance.parameters.FontSize
    LabelColor = instance.parameters.LabelColor
    Historical = instance.parameters.Historical
    ShowLabel = instance.parameters.ShowLabel

    font = core.host:execute("createFont", "Arial", FontSize, false, false)

    OnlyOnceFlag = true
    FIRST = true
    OnlyOnce = instance.parameters.OnlyOnce
    Show = instance.parameters.Show
    Live = instance.parameters.Live
    StartLineColor = instance.parameters.StartLineColor
    StopLineColor = instance.parameters.StopLineColor
    TargetLineColor1 = instance.parameters.TargetLineColor1
    TargetLineColor2 = instance.parameters.TargetLineColor2
    TargetLineColor3 = instance.parameters.TargetLineColor3
    TargetLineColor4 = instance.parameters.TargetLineColor4
    Lookback = instance.parameters.Lookback

    style1 = instance.parameters.style1
    style2 = instance.parameters.style2
    style3 = instance.parameters.style3
    style4 = instance.parameters.style4
    style5 = instance.parameters.style5
    style5 = instance.parameters.style5
    width1 = instance.parameters.width1
    width2 = instance.parameters.width2
    width3 = instance.parameters.width3
    width4 = instance.parameters.width4
    width5 = instance.parameters.width5
    width6 = instance.parameters.width6
    Level1 = instance.parameters.Level1
    Level2 = instance.parameters.Level2
    Level3 = instance.parameters.Level3
    Level4 = instance.parameters.Level4

    first = source:first() + 1

    position = instance:addInternalStream(0, 0)

    Indicator = core.indicators:create("RSI", btf_source.close, rsi_period);

    FIRST_CANDLE = nil
end

local init = false
local label1 = {}
local label2 = {}
local label3 = {}
local label4 = {}
local label5 = {}
local label6 = {}
function Draw(stage, context)
    indi_alerts:Draw(stage, context, source);
    if stage ~= 2 then
        return
    end
    if not init then
        context:createFont(2, "Arial", 0, context:pointsToPixels(FontSize), 0)
        context:createSolidBrush(3, LabelBackgroundColor)
        init = true
    end
    DrawLabel(label1, context)
    DrawLabel(label2, context)
    DrawLabel(label3, context)
    DrawLabel(label4, context)
    DrawLabel(label5, context)
    DrawLabel(label6, context)
end

function DrawLabel(label, context)
    if label.Text ~= nil then
        local visible, y = context:pointOfPrice(label.Rate)
        local width, height = context:measureText(2, label.Text, 0)
        local x
        local pos
        if ShowLabel == "left" then
            x = context:positionOfDate(label.DateEnd)
            pos = context.RIGHT + context.TOP
        else
            x = context:positionOfDate(label.Date) - width
            pos = context.LEFT + context.TOP
        end
        context:drawText(2, label.Text, LabelColor, LabelBackgroundColor, x, y - height, x + width, y, pos)
    end
end

local ID = 0
local ids = {}
function New(period, id)
    if ids[period] == nil then
        ids[period] = {}
    end
    if ids[period][id] == nil then
        ids[period][id] = ID + 1
        ID = ID + 1
    end
    return ids[period][id]
end

function GetPeriod(period)
    local Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset)
    if loading or btf_source:size() == 0 then
        return false
    end
    if period < source:first() then
        return false
    end

    local p = core.findDate(btf_source, Candle, false)
    -- candle is not found
    if p < 0 then
        return false
    else
        return p
    end
end

function GetPrevPeriod(p)
    if p == 0 then
        return -1;
    end
    local prev_date = btf_source:date(p - 1);
    return core.findDate(source, prev_date, false);
end

function Update(period, mode)
    Indicator:update(mode);
    local p = GetPeriod(period)
    if not p then
        return
    end
    if period < first then
        ID = 0
        return
    elseif period == first then
        ID = 0
    end
    local prev_period = GetPrevPeriod(p);
    if (period == first or prev_period == -1) then
        position[period] = 0
    else
        position[period] = position[period - 1]
    end
    if position[period] ~= -1 and core.crossesUnder(Indicator.DATA, rsi_level, period) then
        position[period] = -1
    elseif position[period] ~= 1 and core.crossesOver(Indicator.DATA, rsi_level, period) then
        position[period] = 1
    end

    if (not Historical and period < source:size() - 1) or (Historical and period < source:size() - 1 - Lookback) then
        return
    end

    local p = FindLast(period)
    local Delta
    if p ~= 0 then
        local signalVal = source.close[period];
        if position[p] == 1 then
            Delta = math.abs(signalVal - source.high[p])
            local stop_level = source.high[p] - Delta;
            --Start Line
            core.host:execute("drawLine", New(p, 1), source:date(p), source.high[p], source:date(period), source.high[p], StartLineColor, style1, width1, win32.formatNumber(source.high[p], false, source:getPrecision()))
            --Stop Line
            core.host:execute("drawLine", New(p, 2), source:date(p), stop_level, source:date(period), stop_level, StopLineColor, style2, width2, win32.formatNumber(signalVal, false, source:getPrecision()))

            --1. Target
            core.host:execute("drawLine", New(p, 3), source:date(p), source.high[p] + Delta * Level1, source:date(period), source.high[p] + Delta * Level1, TargetLineColor1, style3, width3, win32.formatNumber(source.high[p] + Delta * Level1, false, source:getPrecision()))

            --2. Target
            core.host:execute("drawLine", New(p, 4), source:date(p), source.high[p] + Delta * Level2, source:date(period), source.high[p] + Delta * Level2, TargetLineColor2, style4, width4, win32.formatNumber(source.high[p] + Delta * Level2, false, source:getPrecision()))

            --3. Target
            core.host:execute("drawLine", New(p, 5), source:date(p), source.high[p] + Delta * Level3, source:date(period), source.high[p] + Delta * Level3, TargetLineColor3, style5, width5, win32.formatNumber(source.high[p] + Delta * Level3, false, source:getPrecision()))
            if Level4 ~= 0 then
                --Trigger
                core.host:execute("drawLine", New(p, 6), source:date(p), source.high[p] + source:pipSize() * Level4, source:date(period), source.high[p] + source:pipSize() * Level4, TargetLineColor4, style6, width6, win32.formatNumber(source.high[p] + source:pipSize() * Level4, false, source:getPrecision()))
            end
            if LabelBackground then
                label1.Text = string.format("Entry : %s", win32.formatNumber(source.high[p], false, source:getPrecision()))
                label1.Date = source:date(period)
                label1.DateEnd = source:date(p)
                label1.Rate = source.high[p]
                label2.Text = string.format("Stop : %s (%s)", win32.formatNumber(stop_level, false, source:getPrecision()), win32.formatNumber(math.abs(signalVal - source.low[p]) / source:pipSize(), false, 1))
                label2.Date = source:date(period)
                label2.DateEnd = source:date(p)
                label2.Rate = signalVal
                label3.Text = string.format("1. Target : %s (%s)", win32.formatNumber(source.high[p] + Delta * Level1, false, source:getPrecision()), win32.formatNumber((Delta * Level1) / source:pipSize(), false, 1))
                label3.Date = source:date(period)
                label3.DateEnd = source:date(p)
                label3.Rate = source.high[p] + Delta * Level1
                label4.Text = string.format("2. Target : %s (%s)", win32.formatNumber(source.high[p] + Delta * Level2, false, source:getPrecision()), win32.formatNumber((Delta * Level2) / source:pipSize(), false, 1))
                label4.Date = source:date(period)
                label4.DateEnd = source:date(p)
                label4.Rate = source.high[p] + Delta * Level2
                label5.Text = string.format("3. Target : %s (%s)", win32.formatNumber(source.high[p] + Delta * Level3, false, source:getPrecision()), win32.formatNumber((Delta * Level3) / source:pipSize(), false, 1))
                label5.Date = source:date(period)
                label5.DateEnd = source:date(p)
                label5.Rate = source.high[p] + Delta * Level3
                label6.Text = string.format("Trigger : %s (%s)", win32.formatNumber(source.high[p] + source:pipSize() * Level4, false, source:getPrecision()), win32.formatNumber(Level4, false, 1))
                label6.Date = source:date(period)
                label6.DateEnd = source:date(p)
                label6.Rate = source.high[p] + source:pipSize() * Level4
            elseif ShowLabel ~= "no" then
                local label1 = string.format("Entry : %s", win32.formatNumber(source.high[p], false, source:getPrecision()))
                local label2 = string.format("Stop : %s (%s)", win32.formatNumber(stop_level, false, source:getPrecision()), win32.formatNumber(math.abs(signalVal - source.low[p]) / source:pipSize(), false, 1))
                local label3 = string.format("1. Target : %s (%s)", win32.formatNumber(source.high[p] + Delta * Level1, false, source:getPrecision()), win32.formatNumber((Delta * Level1) / source:pipSize(), false, 1))
                local label4 = string.format("2. Target : %s (%s)", win32.formatNumber(source.high[p] + Delta * Level2, false, source:getPrecision()), win32.formatNumber((Delta * Level2) / source:pipSize(), false, 1))
                local label5 = string.format("3. Target : %s (%s)", win32.formatNumber(source.high[p] + Delta * Level3, false, source:getPrecision()), win32.formatNumber((Delta * Level3) / source:pipSize(), false, 1))
                local label6 = string.format("Trigger : %s (%s)", win32.formatNumber(source.high[p] + Level4 * source:pipSize(), false, source:getPrecision()), win32.formatNumber(Level4, false, 1))
                local date
                local h_pos
                if ShowLabel == "left" then
                    date = source:date(p)
                    h_pos = core.H_Right
                else
                    date = source:date(period)
                    h_pos = core.H_Left
                end
                core.host:execute("drawLabel1", New(p, 7), date, core.CR_CHART, source.high[p], core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label1)
                core.host:execute("drawLabel1", New(p, 8), date, core.CR_CHART, stop_level, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label2)
                core.host:execute("drawLabel1", New(p, 9), date, core.CR_CHART, source.high[p] + Delta * Level1, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label3)
                core.host:execute("drawLabel1", New(p, 10), date, core.CR_CHART, source.high[p] + Delta * Level2, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label4)
                core.host:execute("drawLabel1", New(p, 11), date, core.CR_CHART, source.high[p] + Delta * Level3, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label5)
                if Level4 ~= 0 then
                    core.host:execute("drawLabel1", New(p, 12), date, core.CR_CHART, source.high[p] + source:pipSize() * Level4, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label6)
                end
            end
        elseif position[p] == -1 then
            Delta = math.abs(signalVal - source.low[p])
            local stop_level = source.high[p] + Delta;

            --Start Line
            core.host:execute("drawLine", New(p, 13), source:date(p), source.low[p], source:date(period), source.low[p], StartLineColor, style1, width1, win32.formatNumber(source.low[p], false, source:getPrecision()))

            --Stop Line
            core.host:execute("drawLine", New(p, 14), source:date(p), stop_level, source:date(period), stop_level, StopLineColor, style2, width2, win32.formatNumber(signalVal, false, source:getPrecision()))

            --1. Target
            core.host:execute("drawLine", New(p, 15), source:date(p), source.low[p] - Delta * Level1, source:date(period), source.low[p] - Delta * Level1, TargetLineColor1, style3, width3, win32.formatNumber(source.low[p] - Delta * Level1, false, source:getPrecision()))

            --2. Target
            core.host:execute("drawLine", New(p, 16), source:date(p), source.low[p] - Delta * Level2, source:date(period), source.low[p] - Delta * Level2, TargetLineColor2, style4, width4, win32.formatNumber(source.low[p] - Delta * Level2, false, source:getPrecision()))

            --3. Target
            core.host:execute("drawLine", New(p, 17), source:date(p), source.low[p] - Delta * Level3, source:date(period), source.low[p] - Delta * Level3, TargetLineColor3, style5, width5, win32.formatNumber(source.low[p] - Delta * Level3, false, source:getPrecision()))

            if Level4 ~= 0 then
                --Trigger
                core.host:execute("drawLine", New(p, 18), source:date(p), source.low[p] - source:pipSize() * Level4, source:date(period), source.low[p] - source:pipSize() * Level4, TargetLineColor4, style5, width5, win32.formatNumber(source.low[p] - source:pipSize() * Level4, false, source:getPrecision()))
            end
            if LabelBackground then
                label1.Text = string.format("Entry : %s", win32.formatNumber(source.low[p], false, source:getPrecision()))
                label1.Date = source:date(period)
                label1.DateEnd = source:date(p)
                label1.Rate = source.low[p]
                label2.Text = string.format("Stop : %s (%s)", win32.formatNumber(stop_level, false, source:getPrecision()), win32.formatNumber(math.abs(signalVal - source.low[p]) / source:pipSize(), false, 1))
                label2.Date = source:date(period)
                label2.DateEnd = source:date(p)
                label2.Rate = signalVal
                label3.Text = string.format("1. Target : %s (%s)", win32.formatNumber(source.low[p] - Delta * Level1, false, source:getPrecision()), win32.formatNumber((Delta * Level1) / source:pipSize(), false, 1))
                label3.Date = source:date(period)
                label3.DateEnd = source:date(p)
                label3.Rate = source.low[p] - Delta * Level1
                label4.Text = string.format("2. Target : %s (%s)", win32.formatNumber(source.low[p] - Delta * Level2, false, source:getPrecision()), win32.formatNumber((Delta * Level2) / source:pipSize(), false, 1))
                label4.Date = source:date(period)
                label4.DateEnd = source:date(p)
                label4.Rate = source.low[p] - Delta * Level2
                label5.Text = string.format("3. Target : %s (%s)", win32.formatNumber(source.low[p] - Delta * Level3, false, source:getPrecision()), win32.formatNumber((Delta * Level3) / source:pipSize(), false, 1))
                label5.Date = source:date(period)
                label5.DateEnd = source:date(p)
                label5.Rate = source.low[p] - Delta * Level3
            elseif ShowLabel ~= "no" then
                local label1 = string.format("Entry : %s", win32.formatNumber(source.low[p], false, source:getPrecision()))
                local label2 = string.format("Stop : %s (%s)", win32.formatNumber(stop_level, false, source:getPrecision()), win32.formatNumber(math.abs(signalVal - source.low[p]) / source:pipSize(), false, 1))
                local label3 = string.format("1. Target : %s (%s)", win32.formatNumber(source.low[p] - Delta * Level1, false, source:getPrecision()), win32.formatNumber((Delta * Level1) / source:pipSize(), false, 1))
                local label4 = string.format("2. Target : %s (%s)", win32.formatNumber(source.low[p] - Delta * Level2, false, source:getPrecision()), win32.formatNumber((Delta * Level2) / source:pipSize(), false, 1))
                local label5 = string.format("3. Target : %s (%s)", win32.formatNumber(source.low[p] - Delta * Level3, false, source:getPrecision()), win32.formatNumber((Delta * Level3) / source:pipSize(), false, 1))
                local label6 = string.format("Trigger : %s (%s)", win32.formatNumber(source.low[p] - source:pipSize() * Level4, false, source:getPrecision()), win32.formatNumber(Level4, false, 1))
                local date
                local h_pos
                if ShowLabel == "left" then
                    date = source:date(p)
                    h_pos = core.H_Right
                else
                    date = source:date(period)
                    h_pos = core.H_Left
                end
                core.host:execute("drawLabel1", New(p, 19), date, core.CR_CHART, source.low[p], core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label1)
                core.host:execute("drawLabel1", New(p, 20), date, core.CR_CHART, stop_level, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label2)
                core.host:execute("drawLabel1", New(p, 21), date, core.CR_CHART, source.low[p] - Delta * Level1, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label3)
                core.host:execute("drawLabel1", New(p, 22), date, core.CR_CHART, source.low[p] - Delta * Level2, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label4)
                core.host:execute("drawLabel1", New(p, 23), date, core.CR_CHART, source.low[p] - Delta * Level3, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label5)
                if Level4 ~= 0 then
                    core.host:execute("drawLabel1", New(p, 24), date, core.CR_CHART, source.low[p] - source:pipSize() * Level4, core.CR_CHART, h_pos, core.V_Top, font, LabelColor, label6)
                end
            end
        end
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function ReleaseInstance()
    core.host:execute("deleteFont", font)
end

function FindLast(period)
    local p = 0

    for i = period, first, -1 do
        if position[i] ~= position[i - 1] then
            p = i
            break
        end
    end

    return p
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if alert.id == 1 and alert.ON then
        if position[period] == 1 and position[period - 1] ~= 1 then
            alert:UpAlert(source, period, alert.Label .. ". Open Long", source.high[period], historical_period);
        elseif (position[period] == -1 and position[period - 1] ~= -1) then
            alert:DownAlert(source, period, alert.Label .. ". Open Short", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 100 then
        loading = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loading = true
    end
end

indi_alerts.Version = "1.3.0";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts.total_alerts = 1;
indi_alerts._alerts = {};
indi_alerts._telegram_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    indicator.parameters:addGroup("External Alerts");
    indicator.parameters:addBoolean("use_telegram", "Send external alert", "Telegram or Telegram Channel", false);
    indicator.parameters:addString("telegram_key", "External Key", "Start converstation with @profit_robots_bot Telegram Bot to get the key", "");
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._telegram_timer and #self._alerts > 0 then if self._telegram_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Notifications":%s}', self._telegram_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
function indi_alerts:ToJSON(item)
    local json = {};
    function json:AddStr(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value)); end
    function json:AddNumber(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0); end
    function json:AddBool(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false"); end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    local first = true; for idx,t in pairs(item) do  local stype = type(t) if stype == "number" then json:AddNumber(idx, t); elseif stype == "string" then json:AddStr(idx, t); elseif stype == "boolean" then json:AddBool(idx, t); elseif stype == "function" or stype == "table" then else core.host:trace(tostring(idx) .. " " .. tostring(stype)); end end
    return json:ToString();
end
function indi_alerts:ArrayToJSON(arr) local str = "["; for i, t in ipairs(self._alerts) do local json = self:ToJSON(t); if str == "[" then str = str .. json; else str = str .. "," .. json; end end return str .. "]"; end
function indi_alerts:AddAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    
    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    
    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
end

indi_alerts.init = false;
function indi_alerts:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not self.init then
        context:createFont(1, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        self.init = true;
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        x, x1, x2= context:positionOfBar(period);
        for _, level in ipairs(self.Alerts) do
            if level.Alert:hasData(period) then
                if level.Alert[period]== 1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\225", 0);
                    context:drawText (1,   "\225", self.UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );    
                elseif level.Alert[period]== -1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\226", 0);
                    context:drawText (1,   "\226", self.DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );    
                end
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:GetTimezone()
    local tz = instance.parameters.ToTime;
    if tz == 1 then
        return core.TZ_EST
    elseif tz == 2 then
        return core.TZ_UTC
    elseif tz == 3 then
        return core.TZ_LOCAL
    elseif tz == 4 then
        return core.TZ_SERVER
    elseif tz == 5 then
        return core.TZ_FINANCIAL
    elseif tz == 6 then
        return core.TZ_TS
    end
end
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    self.ToTime = self:GetTimezone();
    
    self.UpTrendColor = instance.parameters.UpTrendColor;
    self.DownTrendColor = instance.parameters.DownTrendColor;
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, self.total_alerts, 1 do 
        local alert = {};
        alert.id = i;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = instance.parameters:getBoolean("ON" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        alert.Alert = instance:addInternalStream(0, 0);
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:DownAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.D = source:serial(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Down);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:UpAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.U=source:serial(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Up);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        self.Alerts[#self.Alerts + 1] = alert;
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil;
    assert(not(self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified");
    self.RecurrentSound = instance.parameters.RecurrentSound;

    if instance.parameters.telegram_key ~= "" and instance.parameters.use_telegram then
        self._telegram_key = instance.parameters.telegram_key;
        require("http_lua");
        self._telegram_timer = 1234;
        core.host:execute("setTimer", self._telegram_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, self.source:instrument() .. " " .. label .. " : " .. note);
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return;
    end
    terminal:alertSound(Sound, self.RecurrentSound);
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end
