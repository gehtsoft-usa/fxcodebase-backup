-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25314
-- Id: 7816

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Congestion Identifier");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Short EMA", "", 28);
    indicator.parameters:addDouble("Delta", "Delta (In Pips)", "", 10);
    indicator.parameters:addInteger("Level", "Alert Level", "", 14);
    indicator.parameters:addBoolean("Last", "Use Last Period", "", true);

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("color", "color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);

    indicator.parameters:addGroup("Trigger Line");
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Increasing Congestion Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Decreasing Congestion Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "Congestion");
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up = {};
local Down = {};
local Label = {};
local ON = {};
local first;
local source = nil;
local Line;
local up = {};
local down = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Last;
local Alert;
local Indicator;
local PlaySound;
local Level;

local Period;
local Delta;

local U = {};
local D = {};
local CI;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    Last = instance.parameters.Last;
    Period = instance.parameters.Period;
    Delta = instance.parameters.Delta;
    Level = instance.parameters.Level;

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Delta .. ", " .. Level .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    first = source:first() + Period - 1 + 1;

    CI = instance:addStream("CI", core.Line, name .. ".CI", "CI", instance.parameters.color, first);
    CI:setPrecision(math.max(2, instance.source:getPrecision()));
    CI:setWidth(instance.parameters.width);
    CI:setStyle(instance.parameters.style);
    CI:addLevel(Level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

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
            up[i] = instance:createTextOutput ("Increasing", "Increasing", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Decreasing", "Decreasing", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

function Calculate(period)
    if period < first then
        return;
    end

    local Top, Bottom;
    if Last then
        Top = source.close[period] + Delta * source:pipSize();
        Bottom = source.close[period] - Delta * source:pipSize();
    else
        Top = source.close[period - 1] + Delta * source:pipSize();
        Bottom = source.close[period - 1] - Delta * source:pipSize();
    end

    local i;
    CI[period] = 0;
    if Last then
        for i = period - Period + 1, period, 1 do
            if source.close[i] < Top and source.close[i] > Bottom then
                CI[period] = CI[period] + 1;
            end
        end
    else
        for i = period - 1 - Period + 1, period - 1, 1 do
            if source.close[i] < Top and source.close[i] > Bottom then
                CI[period] = CI[period] + 1;
            end
        end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first then
        return;
    end
    Calculate(period);
    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    Activate(1, period);
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if CI[period - 1] < Level and CI[period] > Level then
            up[id]:set(period, Level, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " is Increasing");
            end
        elseif CI[period - 1] > Level and CI[period] < Level then
            down[id]:set(period, Level, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " is Decreasing");
            end
        end
    end
end

function SoundAlert(Sound)
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end
