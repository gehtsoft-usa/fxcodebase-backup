-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59311&p=88941#p88941

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
    indicator:name("Price / Averages Cross Alert")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Alert Parameters")
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live")
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addString("Price2", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price2", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted")

    indicator.parameters:addString("Price1", "MA Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price1", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted")
    indicator.parameters:addInteger("Period1", "Fast Period MA", "", 50, 2, 2000)
    indicator.parameters:addString("Method1", "MA Method", "Method", "MVA")
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3")
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median")
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth")
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA")

    indicator.parameters:addGroup("Filter Calculation")
    indicator.parameters:addBoolean("Use_Filter", "Use Filter", "", true)

    indicator.parameters:addString("PriceA", "1. MA Price Source", "", "close")
    indicator.parameters:addStringAlternative("PriceA", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("PriceA", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("PriceA", "LOW", "", "low")
    indicator.parameters:addStringAlternative("PriceA", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("PriceA", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("PriceA", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("PriceA", "WEIGHTED", "", "weighted")
    indicator.parameters:addInteger("PeriodA", "1. Fast Period MA", "", 50, 2, 2000)
    indicator.parameters:addString("MethodA", "1. MA Method", "Method", "MVA")
    indicator.parameters:addStringAlternative("MethodA", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("MethodA", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("MethodA", "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("MethodA", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("MethodA", "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("MethodA", "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("MethodA", "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("MethodA", "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("MethodA", "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("MethodA", "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("MethodA", "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("MethodA", "T3", "", "T3")
    indicator.parameters:addStringAlternative("MethodA", "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("MethodA", "Median", "", "Median")
    indicator.parameters:addStringAlternative("MethodA", "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("MethodA", "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("MethodA", "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("MethodA", "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("MethodA", "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("MethodA", "JSmooth", "", "JSmooth")
    indicator.parameters:addStringAlternative("MethodA", "KAMA", "", "KAMA")

    indicator.parameters:addString("PriceB", "2. MA Price Source", "", "close")
    indicator.parameters:addStringAlternative("PriceB", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("PriceB", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("PriceB", "LOW", "", "low")
    indicator.parameters:addStringAlternative("PriceB", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("PriceB", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("PriceB", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("PriceB", "WEIGHTED", "", "weighted")
    indicator.parameters:addInteger("PeriodB", "2. Fast Period MA", "", 200, 2, 2000)
    indicator.parameters:addString("MethodB", "2. MA Method", "Method", "MVA")
    indicator.parameters:addStringAlternative("MethodB", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("MethodB", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("MethodB", "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("MethodB", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("MethodB", "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("MethodB", "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("MethodB", "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("MethodB", "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("MethodB", "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("MethodB", "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("MethodB", "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("MethodB", "T3", "", "T3")
    indicator.parameters:addStringAlternative("MethodB", "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("MethodB", "Median", "", "Median")
    indicator.parameters:addStringAlternative("MethodB", "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("MethodB", "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("MethodB", "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("MethodB", "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("MethodB", "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("MethodB", "JSmooth", "", "JSmooth")
    indicator.parameters:addStringAlternative("MethodB", "KAMA", "", "KAMA")

    indicator.parameters:addGroup("Indicator Style")

    indicator.parameters:addBoolean("ShowMA", "Show MA", "", true)
    indicator.parameters:addColor("color1", "Fast MA color", "MA color", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Alert Style")
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

    indicator.parameters:addGroup("Alerts Sound")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

    indicator.parameters:addGroup("Alerts Email")
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
    indicator.parameters:addString("Email", "Email", "", "")
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

    Parameters(1, "Price/MA")
    ParametersTouch(2, "Price/MA Touch")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert")

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "")
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "")
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

    indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

function ParametersTouch(id, Label)
    indicator.parameters:addGroup(Label .. " Alert")

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

    indicator.parameters:addFile("Up" .. id, Label .. " Touch From Bottom Sound", "", "")
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

    indicator.parameters:addFile("Down" .. id, Label .. " Touch From Top Sound", "", "")
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

    indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

local Number = 2

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShowMA
local Up = {}
local Down = {}
local Label = {}
local ON = {}
local first
local source = nil
local Line
local up = {}
local down = {}
local Size
local Email
local SendEmail
local RecurrentSound, SoundFile
local Show
local Alert
local PlaySound
local Live
local FIRST = true
local Price2, Price1
local OnlyOnce
local U = {}
local D = {}

local Method1, Period1
local Method2, Period2
local ma, MA
local OnlyOnceFlag
local Show
-- Streams block
local Use_Filter
local PriceA, MethodA, PeriodA, MA_A
local PriceB, MethodB, PeriodB, MA_B
-- Routine
function Prepare(nameOnly)
    Use_Filter = instance.parameters.Use_Filter
    PriceA = instance.parameters.PriceA
    MethodA = instance.parameters.MethodA
    PeriodA = instance.parameters.PeriodA

    PriceB = instance.parameters.PriceB
    MethodB = instance.parameters.MethodB
    PeriodB = instance.parameters.PeriodB

    OnlyOnceFlag = true
    FIRST = true
    ShowMA = instance.parameters.ShowMA
    OnlyOnce = instance.parameters.OnlyOnce
    Show = instance.parameters.Show
    Live = instance.parameters.Live
    Price2 = instance.parameters.Price2
    Price1 = instance.parameters.Price1
    Method1 = instance.parameters.Method1
    Period1 = instance.parameters.Period1
    Show = instance.parameters.Show
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install   AVERAGES.LUA indicator")

    source = instance.source

    -- Base name of the indicator.
    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. Price1 .. ", " .. Method1 .. ", " .. Period1 .. ", " .. Price2 .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    -- Create short and long EMAs for the source
    ma = core.indicators:create("AVERAGES", source[Price1], Method1, Period1, false)

    MA_A = core.indicators:create("AVERAGES", source[PriceA], MethodA, PeriodA, false)
    MA_B = core.indicators:create("AVERAGES", source[PriceB], MethodB, PeriodB, false)

    first = math.max(ma.DATA:first(), MA_A.DATA:first(), MA_B.DATA:first())

    if ShowMA then
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color1, first)
        MA:setWidth(instance.parameters.width1)
        MA:setStyle(instance.parameters.style1)
    else
        MA = instance:addInternalStream(0, 0)
    end

    Initialization()
end

function Initialization()
    Size = instance.parameters.Size
    SendEmail = instance.parameters.SendEmail

    local i
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i)
        ON[i] = instance.parameters:getBoolean("ON" .. i)
    end

    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        for i = 1, Number, 1 do
            Up[i] = instance.parameters:getString("Up" .. i)
            Down[i] = instance.parameters:getString("Down" .. i)
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil
            Down[i] = nil
        end
    end

    for i = 1, Number, 1 do
        assert(
            not (PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""),
            "Sound file must be chosen"
        )
        assert(
            not (PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""),
            "Sound file must be chosen"
        )
    end

    RecurrentSound = instance.parameters.RecurrentSound

    for i = 1, Number, 1 do
        U[i] = nil
        D[i] = nil

        if ON[i] then
            up[i] =
                instance:createTextOutput(
                "Up",
                "Up",
                "Wingdings",
                Size,
                core.H_Center,
                core.V_Center,
                instance.parameters.Up,
                0
            )
            down[i] =
                instance:createTextOutput(
                "Dn",
                "Dn",
                "Wingdings",
                Size,
                core.H_Center,
                core.V_Center,
                instance.parameters.Down,
                0
            )
        end
    end
end

function Calculate(period, mode)
    ma:update(mode)
    MA_A:update(mode)
    MA_B:update(mode)

    if period < first + 1 then
        return
    end

    MA[period] = ma.DATA[period]
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    Calculate(period, mode)

    local i
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period)
            up[i]:setNoData(period)
        end
    end

    if period < first then
        return
    end

    Activate(1, period)
end

function Activate(id, period)
    local Shift = 0

    if Live ~= "Live" then
        period = period - 1
        Shift = 1
    end

    if id == 1 and ON[id] then
        if
            source[Price2][period] > MA[period] and source[Price2][period - 1] <= MA[period - 1] and
                ((Use_Filter and MA_A.DATA[period] > MA_B.DATA[period]) or not Use_Filter)
        then
            up[id]:set(period, MA[period], "\108")

            D[id] = nil

            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false
                U[id] = source:serial(period)
                SoundAlert(Up[id])
                EmailAlert(Label[id], " Cross Over", period)
                SendAlert("Crossed Over")
                if Show then
                    Pop(Label[id], " Cross Over ")
                end
            end
        elseif
            source[Price2][period] < MA[period] and source[Price2][period - 1] >= MA[period - 1] and
                ((Use_Filter and MA_A.DATA[period] < MA_B.DATA[period]) or not Use_Filter)
        then
            down[id]:set(period, MA[period], "\108")

            U[id] = nil

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false
                D[id] = source:serial(period)
                SoundAlert(Down[id])
                EmailAlert(Label[id], " Cross Under", period)
                SendAlert("Crossed under")
                if Show then
                    Pop(Label[id], " Cross Under ")
                end
            end
        end
    end
    if id == 2 and ON[id] then
        if
            source[Price2][period] == MA[period] and source[Price2][period - 1] < MA[period - 1] and
                ((Use_Filter and MA_A.DATA[period] > MA_B.DATA[period]) or not Use_Filter)
        then
            up[id]:set(period, MA[period], "\108")

            D[id] = nil

            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false
                U[id] = source:serial(period)
                SoundAlert(Up[id])
                EmailAlert(Label[id], " From Bottom", period)
                SendAlert("Touch From Bottom")
                if Show then
                    Pop(Label[id], " From Bottom")
                end
            end
        elseif
            source[Price2][period] == MA[period] and source[Price2][period - 1] > MA[period - 1] and
                ((Use_Filter and MA_A.DATA[period] < MA_B.DATA[period]) or not Use_Filter)
        then
            down[id]:set(period, MA[period], "\108")

            U[id] = nil

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false
                D[id] = source:serial(period)
                SoundAlert(Down[id])
                EmailAlert(Label[id], " From Top", period)
                SendAlert("Touch From Top")
                if Show then
                    Pop(Label[id], " From Top")
                end
            end
        end
    end

    if FIRST then
        FIRST = false
    end
end

function AsyncOperationFinished(cookie, success, message)
end

function Pop(label, note)
    core.host:execute("prompt", 1, label, " ( " .. source:instrument() .. " ) " .. label .. " : " .. note)
end

function SoundAlert(Sound)
    if not PlaySound then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return
    end

    terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return
    end

    local date = source:date(period)
    local DATA = core.dateToTable(date)

    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. source:instrument()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

    local text = Note .. delim .. Symbol .. delim .. Time

    local text = profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. label
    terminal:alertEmail(Email, Subject, text)
end

function SendAlert(message)
    if not ShowAlert then
        return
    end

    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW))
end
