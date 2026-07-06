-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66622

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
    indicator:name("ICH With Alert Kijun-Tenkan inside of the Kumo")
    indicator:description("ICH With Alert Kijun-Tenkan inside of the Kumo")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("group", "Trend")

    indicator.parameters:addGroup("Mode")
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live")
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("X", "Tenkan-sen period", "", 9, 1, 10000)
    indicator.parameters:addInteger("Y", "Kijun-sen period", "", 26, 1, 10000)
    indicator.parameters:addInteger("Z", "Senkou Span B period", "", 52, 1, 10000)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clrTS", "Tenkan-sen Line Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("widthSL", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleSL", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleSL", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clrKS", "Kijun-sen Line Color", "", core.rgb(0, 255, 255))
    indicator.parameters:addInteger("widthTL", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleTL", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clrCS", "Chinkou Span Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("widthCS", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleCS", " Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clrSSA", "Senkou span A Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthSSA", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleSSA", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clrSSB", "Senkou span B Line Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("widthSSB", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleSSB", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addInteger("transp", "Cloud transparency %", "", 80, 0, 100)

    indicator.parameters:addColor("up_color", "Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("down_color", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("neutral_color", "Neutral color", "", core.rgb(128, 128, 128));

    indicator.parameters:addGroup("Alert Style")
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

    indicator.parameters:addGroup("Alerts Sound")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

    indicator.parameters:addGroup("Alerts Email")
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false)
    indicator.parameters:addString("Email", "Email", "", "")
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL)
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)

    Parameters(1, "Kijun and Tenkan inside of the Kumo")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Tenkan
local Kijun
local Senkou

local firstPeriod
local source = nil

local csFirst = nil
local slFirst = nil
local tlFirst = nil
local saFirst = nil
local sbFirst = nil
local chFirst = nil

-- Streams block
local SL = nil
local TL = nil
local CS = nil
local SA = nil
local SB = nil
local SA1 = nil
local SB2 = nil
local clrSSA, clrSSB

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert")
    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "")
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "")
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

    indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

local Up = {}
local Down = {}
local Label = {}
local ON = {}
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
local OnlyOnce
local U = {}
local D = {}
local OnlyOnceFlag

local Number = 1

-- Routine
function Prepare(nameOnly)
    Tenkan = instance.parameters.X
    Kijun = instance.parameters.Y
    Senkou = instance.parameters.Z
    source = instance.source

    FIRST = true
    OnlyOnce = instance.parameters.OnlyOnce
    Show = instance.parameters.Show
    Live = instance.parameters.Live

    firstPeriod = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. Tenkan .. ", " .. Kijun .. ", " .. Senkou .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    SL = instance:addStream("SL", core.Line, name .. ".TL", "TL", instance.parameters.clrTS, firstPeriod + Tenkan - 1)
    SL:setWidth(instance.parameters.widthSL)
    SL:setStyle(instance.parameters.styleSL)
    TL = instance:addStream("TL", core.Line, name .. ".KL", "KL", instance.parameters.clrKS, firstPeriod + Kijun - 1)
    TL:setWidth(instance.parameters.widthTL)
    TL:setStyle(instance.parameters.styleTL)
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, firstPeriod, -Kijun)
    CS:setWidth(instance.parameters.widthCS)
    CS:setStyle(instance.parameters.styleCS)
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, math.max(SL:first(), TL:first()), Kijun)
    SA:setWidth(instance.parameters.widthSSA)
    SA:setStyle(instance.parameters.styleSSA)
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, firstPeriod + Senkou - 1, Kijun)
    SB:setWidth(instance.parameters.widthSSB)
    SB:setStyle(instance.parameters.styleSSB)

    csFirst = CS:first() + Kijun
    slFirst = SL:first()
    tlFirst = TL:first()
    saFirst = SA:first()
    sbFirst = SB:first()

    chFirst = math.max(saFirst, sbFirst)
    SA1 = instance:addInternalStream(chFirst, Kijun)
    SB1 = instance:addInternalStream(chFirst, Kijun)
    instance:createChannelGroup("SA-SB", "SA-SB", SA1, SB1, instance.parameters.clrSSA, 100 - instance.parameters.transp)
    clrSSA = instance.parameters.clrSSA
    clrSSB = instance.parameters.clrSSB

    Initialization()
    instance:ownerDrawn(true);
end

function GetRelation(period)
    if not SL:hasData(period) or not CS:hasData(period) or not TL:hasData(period) or not SA:hasData(period) or not SB:hasData(period) then
        return 0;
    end
    if source.close[period] > SL[period] 
        and source.close[period] > TL[period]
        and source.close[period] > CS[period]
        and source.close[period] > SA[period]
        and source.close[period] > SB[period]
    then
        return 1;
    end
    if source.close[period] < SL[period] 
        and source.close[period] < TL[period]
        and source.close[period] > CS[period]
        and source.close[period] < SA[period]
        and source.close[period] < SB[period]
    then
        return -1;
    end
    
    if source.close[period] > SL[period] 
        and source.close[period] > TL[period]
        and source.close[period] > SA[period]
        and source.close[period] > SB[period]
    then
        return 0.5;
    end
    if source.close[period] < SL[period] 
        and source.close[period] < TL[period]
        and source.close[period] < SA[period]
        and source.close[period] < SB[period]
    then
        return -0.5;
    end
    
    return 0;
end

function GetCandleSizeFactor(period)
    if period < 5 then
        return 0;
    end
    local current_size = source.high[period] - source.low[period];
    for i = 1, 4 do
        local size = source.high[period - i] - source.low[period - i];
        if size >= current_size then
            return 0;
        end
    end
    return 1;
end

function GetDirection(period)
    current = GetRelation(period);
    prev = GetRelation(period - 1);

    if current == 0.5 and prev ~= 0.5 then
        return 1;
    end
    if current == -0.5 and prev ~= -0.5 then
        return -1;
    end
    
    if current == 1 and prev ~= 1 then
        return 1 + GetCandleSizeFactor(period);
    end
    
    if current == -1 and prev ~= -1 then
        return -1 - GetCandleSizeFactor(period);
    end
    
    return 0;
end

local small_block = 30;
local big_block = 60;
local init = false;
local up_pen = 1;
local down_pen = 2;
local neutral_pen = 3;
local up_brush = 4;
local down_brush = 5;
local neutral_brush = 6;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(up_pen, context.SOLID, 1, instance.parameters.up_color);
        context:createPen(down_pen, context.SOLID, 1, instance.parameters.down_color);
        context:createPen(neutral_pen, context.SOLID, 1, instance.parameters.neutral_color);
        context:createSolidBrush(up_brush, instance.parameters.up_color);
        context:createSolidBrush(down_brush, instance.parameters.down_color);
        context:createSolidBrush(neutral_brush, instance.parameters.neutral_color);
        init = true;
    end
    for p = context:firstBar(), context:lastBar(), 1 do
        local x, x_s, x_e = context:positionOfBar(p);
        local direction = GetDirection(p);
        if direction == 2 then
            context:drawRectangle(up_pen, up_brush, x_s, context:bottom(), x_e, context:bottom() - big_block);
        elseif direction == 1 then
            context:drawRectangle(up_pen, up_brush, x_s, context:bottom(), x_e, context:bottom() - small_block);
        elseif direction == -2 then
            context:drawRectangle(down_pen, down_brush, x_s, context:bottom(), x_e, context:bottom() - big_block);
        elseif direction == -1 then
            context:drawRectangle(down_pen, down_brush, x_s, context:bottom(), x_e, context:bottom() - small_block);
        else
            context:drawRectangle(neutral_pen, neutral_brush, x_s, context:bottom(), x_e, context:bottom() - small_block);
        end
    end 
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
        assert(not (PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen")
        assert(not (PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen")
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
                Kijun
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
                Kijun
            )
        end
    end
end

function Update(period)
    if (period < chFirst) then
        return
    end

    Calculation(period)

    local i
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period)
            up[i]:setNoData(period)
        end
    end

    Activate(1, period)
end

function Activate(id, period)
    if id == 1 and ON[id] then
        LogicAdvanced(id, SL, TL, period, SA, SB)
    end

    if FIRST then
        FIRST = false
    end
end

function LogicAdvanced(id, SL, TL, period, SA, SB)
    local Shift = 0

    if Live ~= "Live" then
        period = period - 1
        Shift = 1
    end

    if (period < SL:first() or period > SL:size() - 1) or
        not SA:hasData(period-1) or  not SB:hasData(period-1)then
        return
    end

    if SL[period] > TL[period] and SL[period - 1] <= TL[period - 1] and
        TL[period] > math.min(SA[period], SB[period]) and  TL[period] < math.max(SA[period], SB[period]) and 
        SL[period] > math.min(SA[period], SB[period]) and  SL[period] < math.max(SA[period], SB[period]) then

        up[id]:set(period, TL[period], "\108")
        D[id] = nil

        if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
            OnlyOnceFlag = false
            U[id] = source:serial(period)
            SoundAlert(Up[id])
            EmailAlert(Label[id], " Cross Over", period)

            if Show then
                Pop(Label[id], " Cross Over ")
            end
        end
    elseif SL[period] < TL[period] and SL[period - 1] >= TL[period - 1] and
           TL[period] > math.min(SA[period], SB[period]) and  TL[period] < math.max(SA[period], SB[period]) and 
           SL[period] > math.min(SA[period], SB[period]) and  SL[period] < math.max(SA[period], SB[period]) then

        down[id]:set(period, TL[period], "\108")
        U[id] = nil

        if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
            OnlyOnceFlag = false
            D[id] = source:serial(period)
            SoundAlert(Down[id])
            EmailAlert(Label[id], " Cross Under", period)
            if Show then
                Pop(Label[id], " Cross Under ")
            end
        end
    end
end
 
function AsyncOperationFinished(cookie, success, message)
end

function Pop(label, note)
    core.host:execute(
        "prompt",
        1,
        label,
        " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note
    )
end

function SoundAlert(Sound)
    if not PlaySound then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return
    end

    --Alert
    terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return
    end

    local date = source:date(NOW)
    local DATA = core.dateToTable(date)

    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. source:instrument()
    local TF = "Time Frame : " .. source:barSize()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time
    terminal:alertEmail(Email, profile:id(), text)
end

function Calculation(period)
    if (period < csFirst) then
        return
    end
    CS[period - Kijun] = source.close[period]

    local p, hh, ll

    if (period < slFirst) then
        return
    end
    ll, hh = mathex.minmax(source, period - Tenkan + 1, period)
    SL[period] = (hh + ll) / 2

    if (period < tlFirst) then
        return
    end

    ll, hh = mathex.minmax(source, period - Kijun + 1, period)
    TL[period] = (hh + ll) / 2

    local p = period + Kijun

    if (period < saFirst) then
        return
    end
    SA[p] = (SL[period] + TL[period]) / 2

    if (period < sbFirst) then
        return
    end

    ll, hh = mathex.minmax(source, period - Senkou + 1, period)
    SB[p] = (hh + ll) / 2

    if (period < chFirst) then
        return
    end
    SA1[p] = SA[p]
    SB1[p] = SB[p]
    if (SA[p] > SB[p]) then
        SA1:setColor(p, clrSSB)
    else
        SA1:setColor(p, clrSSA)
    end
end
