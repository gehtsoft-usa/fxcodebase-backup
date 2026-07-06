-- Id: 22319
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64999

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

local indi_alerts = {}

function Init()
    indicator:name("Non-Standard Time Frame Choppy market ADX Indicator")
    indicator:description("v1 2018-09-23")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addString("TF", "Time frame", "", "Chart")

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "", 14)
    indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25)
    indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33)
    indicator.parameters:addDouble("Level", "Level", "", 25)

    indicator.parameters:addInteger("Type", "Type", "", 1)
    indicator.parameters:addIntegerAlternative("Type", "Box", "", 1)
    indicator.parameters:addIntegerAlternative("Type", "Candle", "", 2)

    indicator.parameters:addGroup("Style")

    indicator.parameters:addColor("Zone", "Choppy Zone Color", "", core.rgb(255, 128, 0))

    indicator.parameters:addInteger("Transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 80, 0, 100)

    indicator.parameters:addColor("UpColor", "Cross Over Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownColor", "Cross Under Color", "", core.rgb(255, 0, 0))

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Label Symbols")

    indicator.parameters:addInteger("U1", "1. Up Symbol", "", 217)
    indicator.parameters:addInteger("U2", "2. Up Symbol", "", 217)
    indicator.parameters:addInteger("D1", "1. Down Symbol", "", 218)
    indicator.parameters:addInteger("D2", "2. Down Symbol", "", 218)

    indicator.parameters:addGroup("Border Symbols")

    indicator.parameters:addBoolean("ShowBorder", "Show Border", "", true)
    indicator.parameters:addColor("B_Zone", "Choppy Zone Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("B_width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("B_style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("B_style", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Alert Parameters")
    indi_alerts:AddParameters(indicator.parameters)
    indi_alerts:AddAlert("ADX/Level")
    indi_alerts:AddAlert("DMI+/DMI-")

    indicator.parameters:addColor("Up_Candle", "Up Candle Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("Down_Candle", "Down Candle Color", "", core.COLOR_DOWNCANDLE)
end

local loading

local Type
local open = nil
local close = nil
local high = nil
local low = nil

local first
local source = nil
local Period
local Alpha1
local Alpha2
local Zone, B_Zone
local Transparency
local Signal
local Size
local UpColor, DownColor
local Cross
local Second
local U1, U2
local D1, D2
local Up_Candle, Down_Candle
local ShowBorder
local TFl
local SourceData
local dayoffset
local weekoffset
function Prepare(nameOnly)
    indi_alerts:Prepare()
    indi_alerts.source = instance.source
    instance:drawOnMainChart(true)
    dayoffset = core.host:execute("getTradingDayOffset")
    weekoffset = core.host:execute("getTradingWeekOffset")

    source = instance.source
    Period = instance.parameters.Period
    Alpha1 = instance.parameters.Alpha1
    Alpha2 = instance.parameters.Alpha2
    Type = instance.parameters.Type
    TF = instance.parameters.TF
    if TF == "Chart" then
        TF = source:barSize()
    end

    U1 = string.char(instance.parameters.U1)
    U2 = string.char(instance.parameters.U2)
    D1 = string.char(instance.parameters.D1)
    D2 = string.char(instance.parameters.D2)

    Up_Candle = instance.parameters.Up_Candle
    Down_Candle = instance.parameters.Down_Candle

    ShowBorder = instance.parameters.ShowBorder

    UpColor = instance.parameters.UpColor
    DownColor = instance.parameters.DownColor

    Size = instance.parameters.Size

    Transparency = instance.parameters.Transparency
    Zone = instance.parameters.Zone
    B_Zone = instance.parameters.B_Zone

    Level = instance.parameters.Level

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Alpha1 .. ", " .. Alpha2 .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Second = instance:addInternalStream(0, 0)
    Signal = instance:addInternalStream(0, 0)
    Cross = instance:addInternalStream(0, 0)

    assert(
        core.indicators:findIndicator("SMOOTHED_ADX") ~= nil,
        "Please, download and install SMOOTHED_ADX.LUA indicator"
    )

    if TF ~= "Chart" then
        local s1, e1, s2, e2
        s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
        s2, e2 = core.getcandle(TF, 0, 0, 0)
        assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")
    end

    if TF ~= source:barSize() then
        SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101)
        loading = true

        Indicator = core.indicators:create("SMOOTHED_ADX", SourceData, Period, Alpha1, Alpha2)
    else
        Indicator = core.indicators:create("SMOOTHED_ADX", source, Period, Alpha1, Alpha2)
    end

    first = Indicator.DATA:first()

    instance:ownerDrawn(true)

    if Type == 2 then
        open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
        high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
        low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
        close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
        instance:createCandleGroup("ZONE", "", open, high, low, close)
    end
end

function Update(period, mode)
    if (period < first) then
        return
    end

    if Type == 2 then
        high[period] = source.high[period]
        low[period] = source.low[period]
        close[period] = source.close[period]
        open[period] = source.open[period]
    end

    Indicator:update(mode)

    local indicator_period = period
    if TF ~= "Chart" and TF ~= source:barSize() then
        indicator_period = Initialization(period)

        if not indicator_period then
            return
        end
    end

    if Indicator.ADX[indicator_period] < Level then
        Signal[period] = 1
    else
        Signal[period] = 0
    end

    if
        Indicator.DIP[indicator_period] > Indicator.DIM[indicator_period] and
            Indicator.DIP[indicator_period - 1] <= Indicator.DIM[indicator_period - 1]
     then
        Cross[period] = 1
    end

    if
        Indicator.DIP[indicator_period] < Indicator.DIM[indicator_period] and
            Indicator.DIP[indicator_period - 1] >= Indicator.DIM[indicator_period - 1]
     then
        Cross[period] = -1
    end

    Second[period] = 0

    local Line, X = Last(period)
    if X == 1 and source.close[period] > Line and source.close[period - 1] <= Line then
        Second[period] = 1
    end

    if X == -1 and source.close[period] < Line and source.close[period - 1] >= Line then
        Second[period] = -1
    end

    for _, alert in ipairs(indi_alerts.Alerts) do
        Activate(alert, period, indicator_period, period ~= source:size() - 1)
    end
end

function Activate(alert, period, indicator_period, historical_period)
    if indi_alerts.Live ~= "Live" then
        period = period - 1
    end
    alert.Alert[period] = 0
    if alert.id == 1 and alert.ON then
        if Indicator.ADX[indicator_period] > Level and Indicator.ADX[indicator_period - 1] <= Level then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period)
        elseif Indicator.ADX[indicator_period] < Level and Indicator.ADX[indicator_period - 1] >= Level then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period)
        end
    end
    if alert.id == 2 and alert.ON then
        if
            Indicator.DIP[indicator_period] > Indicator.DIM[indicator_period] and
                Indicator.DIP[indicator_period - 1] <= Indicator.DIM[indicator_period]
         then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period)
        elseif
            Indicator.DIP[indicator_period] < Indicator.DIM[indicator_period] and
                Indicator.DIP[indicator_period] >= Indicator.DIM[indicator_period]
         then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period)
        end
    end
    if indi_alerts.FIRST then
        indi_alerts.FIRST = false
    end
end

function AsyncOperationFinished(cookie, success, message)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 100 then
        loading = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loading = true
    end
end

function Last(period)
    local Line = nil
    local X = nil

    for p = period, first, -1 do
        if Signal[p] == 1 or Signal[p] == -1 then
            X = Signal[p]
            if Signal[p] == 1 then
                Line = source.high[p]
            else
                Line = source.low[p]
            end
            break
        end
    end

    return Line, X
end

local init = false

function Draw(stage, context)
    indi_alerts:Draw(stage, context, source)
    if stage ~= 0 then
        return
    end

    if not init then
        context:createSolidBrush(1, Zone)
        context:createFont(
            2,
            "Wingdings",
            context:pointsToPixels(instance.parameters.Size),
            context:pointsToPixels(instance.parameters.Size),
            0
        )
        Transparency = context:convertTransparency(instance.parameters.Transparency)
        context:createPen(3, context:convertPenStyle(instance.parameters.style), instance.parameters.width, UpColor)
        context:createPen(
            4,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            DownColor
        )
        context:createPen(
            5,
            context:convertPenStyle(instance.parameters.B_style),
            context:pointsToPixels(instance.parameters.B_width),
            B_Zone
        )
        init = true
    end

    p1 = nil
    p2 = nil

    local iLevel

    for p = math.max(context:firstBar(), first + 1), math.min(context:lastBar(), source:size() - 1), 1 do
        if Type == 2 then
            if source.close[p] > source.open[p] then
                open:setColor(p, Up_Candle)
            else
                open:setColor(p, Down_Candle)
            end
        end

        p2 = nil

        if Signal[p] == 1 and Signal[p - 1] ~= 1 then
            p1 = p
            p2 = nil
        end

        if (Signal[p - 1] == 1 and Signal[p] ~= 1) or (Signal[p] == 1 and p == source:size() - 1) then
            p2 = p
        end

        if p1 ~= nil and p2 ~= nil then
            min, max, minpos, maxpos = mathex.minmax(source, p1, p2)

            visible, y1 = context:pointOfPrice(max)
            visible, y2 = context:pointOfPrice(min)

            x1, x = context:positionOfBar(math.min(p1, p2))
            x2, x = context:positionOfBar(math.max(p1, p2))
            if Type == 1 then
                if ShowBorder then
                    context:drawRectangle(5, 1, x1, y1, x2, y2, Transparency)
                else
                    context:drawRectangle(-1, 1, x1, y1, x2, y2, Transparency)
                end
            else
                for k = math.min(p1, p2), math.max(p1, p2), 1 do
                    open:setColor(k, Zone)
                end
            end
        end

        if Cross[p] == 1 then
            visible, y = context:pointOfPrice(source.low[p])
            x = context:positionOfBar(p)
            Text = U1
            width, height = context:measureText(2, Text, 0)
            context:drawText(2, Text, UpColor, -1, x - width / 2, y, x + width / 2, y + height, 0)

            visible, y = context:pointOfPrice(source.high[p])

            x1 = x
            p2 = FindNext(p, source.high[p], 1)
            if p2 ~= nil then
                visible, y2 = context:pointOfPrice(source.low[p2])
                x2, x = context:positionOfBar(p2)
                Text = U2
                width, height = context:measureText(2, Text, 0)
                context:drawText(2, Text, UpColor, -1, x2 - width / 2, y2, x2 + width / 2, y2 + height, 0)
                context:drawLine(3, x1, y, x2, y)
            end
        end

        if Cross[p] == -1 then
            x = context:positionOfBar(p)
            visible, y = context:pointOfPrice(source.high[p])
            Text = D1
            width, height = context:measureText(2, Text, 0)
            context:drawText(2, Text, DownColor, -1, x - width / 2, y - height, x + width / 2, y, 0)

            visible, y = context:pointOfPrice(source.low[p])
            x1 = x
            p2 = FindNext(p, source.low[p], -1)
            if p2 ~= nil then
                x2, x = context:positionOfBar(p2)
                visible, y2 = context:pointOfPrice(source.high[p2])
                Text = D2
                width, height = context:measureText(2, Text, 0)
                context:drawText(2, Text, DownColor, -1, x2 - width / 2, y2 - height, x2 + width / 2, y2, 0)
                context:drawLine(4, x1, y, x2, y)
            end
        end
    end
end

function FindNext(p, cross_level, side)
    local Return = nil

    for i = p, source:size() - 1, 1 do
        if
            (source.close[i] > cross_level and source.close[i - 1] <= cross_level and side == 1) or
                (source.close[i] < cross_level and source.close[i - 1] >= cross_level and side == -1)
         then
            Return = i
            break
        end
    end

    return Return
end

function Initialization(period)
    local Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset)

    if loading or SourceData:size() == 0 then
        return false
    end

    if period < source:first() then
        return false
    end

    local p = core.findDate(SourceData, Candle, false)

    -- candle is not found
    if p < 0 then
        return false
    else
        return p
    end
end

indi_alerts.Version = "1.3.2"
indi_alerts.last_id = 0
indi_alerts.FIRST = true
indi_alerts.total_alerts = 2
indi_alerts._alerts = {}
indi_alerts._advanced_alert_timer = nil
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode")
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live")
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

    indicator.parameters:addGroup("Alert Style")
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

    indicator.parameters:addGroup("Alerts")
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

    indicator.parameters:addGroup("Alerts Sound")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

    indicator.parameters:addGroup("Alerts Email")
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
    indicator.parameters:addString("Email", "Email", "", "")
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

    indicator.parameters:addGroup("External Alerts")
    indicator.parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram or Telegram Channel", false)
    indicator.parameters:addString(
        "telegram_key",
        "Advanced Alert Key",
        "Start converstation with @profit_robots_bot Telegram Bot to get the key",
        ""
    )
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and #self._alerts > 0 then
        if self._advanced_alert_key == nil then
            return
        end
        local data = self:ArrayToJSON(self._alerts)
        self._alerts = {}
        local req = http_lua.createRequest()
        local query =
            string.format(
            '{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key,
            string.gsub(self.StrategyName or "", '"', '\\"'),
            data
        )
        req:setRequestHeader("Content-Type", "application/json")
        req:setRequestHeader("Content-Length", tostring(string.len(query)))
        req:start("http://profitrobots.com/api/v1/notification", "POST", query)
    end
end
function indi_alerts:ToJSON(item)
    local json = {}
    function json:AddStr(name, value)
        local separator = ""
        if self.str ~= nil then
            separator = ","
        else
            self.str = ""
        end
        self.str = self.str .. string.format('%s"%s":"%s"', separator, tostring(name), tostring(value))
    end
    function json:AddNumber(name, value)
        local separator = ""
        if self.str ~= nil then
            separator = ","
        else
            self.str = ""
        end
        self.str = self.str .. string.format('%s"%s":%f', separator, tostring(name), value or 0)
    end
    function json:AddBool(name, value)
        local separator = ""
        if self.str ~= nil then
            separator = ","
        else
            self.str = ""
        end
        self.str = self.str .. string.format('%s"%s":%s', separator, tostring(name), value and "true" or "false")
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}"
    end
    local first = true
    for idx, t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t)
        elseif stype == "string" then
            json:AddStr(idx, t)
        elseif stype == "boolean" then
            json:AddBool(idx, t)
        elseif stype == "function" or stype == "table" then
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype))
        end
    end
    return json:ToString()
end
function indi_alerts:ArrayToJSON(arr)
    local str = "["
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t)
        if str == "[" then
            str = str .. json
        else
            str = str .. "," .. json
        end
    end
    return str .. "]"
end
function indi_alerts:AddAlert(Label)
    self.last_id = self.last_id + 1
    indicator.parameters:addGroup(Label .. " Alert")

    indicator.parameters:addBoolean("ON" .. self.last_id, "Show " .. Label .. " Alert", "", true)

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Cross Over Sound", "", "")
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND)
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Up Symbol", "", 217)

    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Cross Under Sound", "", "")
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND)
    indicator.parameters:addInteger("DownSymbol" .. self.last_id, "Down Symbol", "", 218)

    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label)
end

indi_alerts.init = false
function indi_alerts:Draw(stage, context)
    if stage ~= 102 then
        return
    end
    if not self.init then
        context:createFont(2, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0)
        self.init = true
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size() - 1), 1 do
        x, x1, x2 = context:positionOfBar(period)
        for _, level in ipairs(self.Alerts) do
            if level.Alert:hasData(period) then
                if level.Alert[period] == 1 then
                    visible, y = context:pointOfPrice(level.AlertLevel[period])
                    width, height = context:measureText(1, level.UpSymbol, 0)
                    context:drawText(
                        2,
                        level.UpSymbol,
                        self.UpTrendColor,
                        -1,
                        x - width / 2,
                        y - height,
                        x + width / 2,
                        y,
                        0
                    )
                elseif level.Alert[period] == -1 then
                    visible, y = context:pointOfPrice(level.AlertLevel[period])
                    width, height = context:measureText(1, level.DownSymbol, 0)
                    context:drawText(
                        2,
                        level.DownSymbol,
                        self.DownTrendColor,
                        -1,
                        x - width / 2,
                        y,
                        x + width / 2,
                        y + height,
                        0
                    )
                end
            end
        end
    end
end
indi_alerts.Alerts = {}
function indi_alerts:GetTimezone()
    local tz = instance.parameters.ToTime
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
    self.Show = instance.parameters.Show
    self.Live = instance.parameters.Live
    self.ShowAlert = instance.parameters.ShowAlert
    self.ToTime = self:GetTimezone()

    self.UpTrendColor = instance.parameters.UpTrendColor
    self.DownTrendColor = instance.parameters.DownTrendColor
    self.Size = instance.parameters.Size
    self.SendEmail = instance.parameters.SendEmail

    self.PlaySound = instance.parameters.PlaySound
    local i
    for i = 1, self.total_alerts, 1 do
        local alert = {}
        alert.id = i
        alert.Label = instance.parameters:getString("Label" .. i)
        alert.ON = instance.parameters:getBoolean("ON" .. i)
        alert.UpSymbol = string.char(instance.parameters:getInteger("UpSymbol" .. i))
        alert.DownSymbol = string.char(instance.parameters:getInteger("DownSymbol" .. i))
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil
        assert(
            not (self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""),
            "Sound file must be chosen"
        )
        assert(
            not (self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""),
            "Sound file must be chosen"
        )
        alert.U = nil
        alert.D = nil
        alert.Alert = instance:addInternalStream(0, 0)
        alert.AlertLevel = instance:addInternalStream(0, 0)
        function alert:DownAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0
            self.Alert[period] = -1
            self.AlertLevel[period] = level
            self.U = nil
            if self.D ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.D = source:serial(period)
                if not historical_period then
                    indi_alerts:SoundAlert(self.Down)
                    indi_alerts:EmailAlert(self.Label, text, period)
                    indi_alerts:SendAlert(self.Label, text, period)
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text)
                    end
                end
            end
        end
        function alert:UpAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0
            self.Alert[period] = 1
            self.AlertLevel[period] = level
            self.D = nil
            if self.U ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.U = source:serial(period)
                if not historical_period then
                    indi_alerts:SoundAlert(self.Up)
                    indi_alerts:EmailAlert(self.Label, text, period)
                    indi_alerts:SendAlert(self.Label, text, period)
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text)
                    end
                end
            end
        end
        self.Alerts[#self.Alerts + 1] = alert
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil
    assert(not (self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified")
    self.RecurrentSound = instance.parameters.RecurrentSound

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key
        require("http_lua")
        self._advanced_alert_timer = 1234
        core.host:execute("setTimer", self._advanced_alert_timer, 1)
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, self.source:instrument() .. " " .. label .. " : " .. note)
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return
    end
    terminal:alertSound(Sound, self.RecurrentSound)
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local now = self.source:date(period)
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now)
    local DATA = core.dateToTable(now)
    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. self.source:instrument()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
    local TF = "Time Frame : " .. source:barSize()
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time
    terminal:alertEmail(self.Email, profile:id(), text)
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return
    end

    local now = self.source:date(period)
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now)
    local DATA = core.dateToTable(now)
    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. self.source:instrument()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
    local TF = "Time Frame : " .. source:barSize()
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW))
end

function indi_alerts:AlertTelegram(message, instrument, timeframe)
    local alert = {}
    alert.Text = message or ""
    alert.Instrument = instrument or ""
    alert.TimeFrame = timeframe or ""
    self._alerts[#self._alerts + 1] = alert
end
