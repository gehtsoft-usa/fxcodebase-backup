-- Id: 11343
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12937

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The indicator corresponds to the Commodity Channel Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 8 "Sycle Analisis" (page 209-210)

-- Indicator profile initialization routine
function Init()
    indicator:name("Commodity Channel Index");
    indicator:description("Measures the position of price in relation to its moving average.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "", "", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", -100, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

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

    Parameters(1, "Cental Line Cross");
    Parameters(2, "OB Line Cross");
    Parameters(3, "OS Line Cross");
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

local Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local tp = nil;

-- Streams block
local CCI = nil;

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
local OB, OS;
-- Routine
function Prepare(nameOnly)
    assert(instance.parameters.oversold < instance.parameters.overbought, "The overbought must be greater than oversold");

    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    OS = instance.parameters.oversold;
    OB = instance.parameters.overbought;

    n = instance.parameters.N;
    source = instance.source.typical;
     

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first() + n - 1;
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.clrCCI, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2);

    CCI:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

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
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

-- Indicator calculation routine
function Update(period)
    if period < first then
        return;
    end

    Calculation(period);
    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
end

function Calculation(period)
    local from = period - n + 1;
    local to = period;

    local mean = mathex.avg(source, from, to);
    local meandev = mathex.meandev(source, from, to);

    if (meandev == 0) then
        CCI[period] = 0;
    else
        CCI[period] = (source[period] - mean) / (meandev * 0.015);
    end
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if CCI[period] > 0 and CCI[period - 1] <= 0 then
            up[id]:set(period, 0, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif CCI[period] < 0 and CCI[period - 1] >= 0 then
            down[id]:set(period, 0, "\108");
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
                    Pop(Label[id], " Cross Over ");
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
                    Pop(Label[id], " Cross Under " );
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
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local TF = "Time Frame : " .. instance.source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end
