-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=757
-- Id: 11370

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- This indicator will provides Audio / Email Alerts if and when BBands_Stop indication is changed.

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=757&p=1527

function Init()
    indicator:name("BBands_Stop Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "Bollinger Bands Period", 20);
    indicator.parameters:addDouble("Deviation", "Deviation", "Deviation", 2);
    indicator.parameters:addDouble("MoneyRisk", "MoneyRisk", "Offset Factor", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Wine Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "BBands_Stop");
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 1;

local first;
local source = nil;
local Bands = nil;
local TrendBuffer = 0;
local TrendLine = nil;
local smin = 0;
local smax = 0;
local bsmin = 0;
local bsmax = 0;

local Up = {};
local Down = {};
local Label = {};
local ON = {};
local Line;
local up = {};
local down = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

function Prepare(nameOnly)
    source = instance.source;
    MoneyRisk = instance.parameters.MoneyRisk;

    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.MoneyRisk  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Bands = core.indicators:create("BB", source.close, instance.parameters.Length, instance.parameters.Deviation);
    first = Bands.DATA:first() + 1;
    TrendBuffer = instance:addInternalStream(0, 0);

    TrendLine = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", instance.parameters.UP_color, first);
    TrendLine:setWidth(instance.parameters.width);
    TrendLine:setStyle(instance.parameters.style);

    smax = instance:addInternalStream(0, 0);
    smin = instance:addInternalStream(0, 0);
    bsmax = instance:addInternalStream(0, 0);
    bsmin = instance:addInternalStream(0, 0);

    Initialization();
end

function Initialization()
    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;

    local i;
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i);
        ON[i] = instance.parameters:getBoolean("ON" .. i);
    end

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        for i = 1, Number, 1 do
            Up[i] = instance.parameters:getString("Up" .. i);
            Down[i] = instance.parameters:getString("Down" .. i);
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil;
            Down[i] = nil;
        end
    end
    for i = 1, Number, 1 do
        assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do
        U[i] = nil;
        D[i] = nil;
        if ON[i] then
            up[i] = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

function Update(period, mode)
    if (period<first) then
        return;
    end
    Calculation(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData (period);
            up[i]:setNoData (period);
        end
    end

    Activate(1, period);
end

function Activate(id, period)
    local Shift = 0;
    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if TrendBuffer[period] == 1 and TrendBuffer[period - 1] ~= 1 then
            up[id]:set(period, TrendLine[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif TrendBuffer[period] == -1 and TrendBuffer[period - 1] ~= -1 then
            down[id]:set(period, TrendLine[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    end

    if id == 2 and ON[id] then
        if CCI[period] > OB and CCI[period - 1] <= OB then
            up[id]:set(period, OB, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif CCI[period] < OB and CCI[period - 1] >= OB then
            down[id]:set(period, OB, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under " );
                end
            end
        end
    end

    if id == 3 and ON[id] then
        if CCI[period] > OS and CCI[period - 1] <= OS then
            up[id]:set(period, OS, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end
            end
        elseif CCI[period] < OS and CCI[period - 1] >= OS then
            down[id]:set(period, OS, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    end

    if FIRST then
        FIRST = false;
    end
end

function AsyncOperationFinished(cookie, success, message)
end

function Pop(label, note)
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. instance.source:barSize() .. " ) " .. label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end

    local date = source:date(period);
    local DATA = core.dateToTable(date);

    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label  .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local TF = "Time Frame : " .. instance.source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end

function Calculation(period, mode)
    Bands:update(mode);

    smax[period] = Bands.TL[period];
    smin[period] = Bands.BL[period];

    if source.close[period] > smax[period - 1] then
        trend = 1;
    end
    if source.close[period] < smin[period - 1] then
        trend = -1;
    end
    if trend > 0 and smin[period] < smin[period - 1] then
        smin[period] = smin[period - 1];
    end
    if trend < 0 and smax[period] > smax[period - 1] then
        smax[period] = smax[period - 1];
    end

    bsmax[period] = smax[period] + 0.5 * (MoneyRisk - 1) * (smax[period] - smin[period]);
    bsmin[period] = smin[period] - 0.5 * (MoneyRisk - 1) * (smax[period] - smin[period]);

    if trend > 0 and bsmin[period] < bsmin[period - 1] then
        bsmin[period] = bsmin[period - 1];
    end
    if trend < 0 and bsmax[period] > bsmax[period - 1] then
        bsmax[period] = bsmax[period - 1];
    end

    if trend > 0 then
        TrendLine[period] = bsmin[period];
        TrendBuffer[period] = 1;
        TrendLine:setColor(period, instance.parameters.UP_color);
    end

    if trend < 0 then
        TrendLine[period] = bsmax[period];
        TrendBuffer[period] = -1;
        TrendLine:setColor(period, instance.parameters.DN_color)
    end
end
