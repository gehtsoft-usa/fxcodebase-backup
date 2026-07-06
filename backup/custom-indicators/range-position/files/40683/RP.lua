-- Id: 7469
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23643

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

function Init()
    indicator:name("Range Position");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14, 1, 2000);
    indicator.parameters:addDouble("L1", "1. Level ", "1. Level ", 38.2);
    indicator.parameters:addDouble("L2", "2. Level", "2. Level", 50);
    indicator.parameters:addDouble("L3", "3. Level ", "3. Level", 61.8);

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("RP_color", "Color of RP", "Color of RP", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("L1C", "Color of 1. Level", "Color of 1.Level", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("L1W", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("L1S", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("L1S", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("L2C", "Color of 2. Level", "Color of 2.Level", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("L2W", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("L2S", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("L2S", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("L3C", "Color of 3. Level", "Color of 3.Level", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("L3W", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("L3S", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("L3S", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "1. Line")
    Parameters(2, "2. Line")
    Parameters(3, "3. Line")
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

local Number = 3;

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

local Alert;
local Indicator;
local PlaySound;

local U = {};
local D = {};

local Period;
local L1;
local L2;
local L3;
local RP = nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;

    Period = instance.parameters.Period;
    L1 = instance.parameters.L1;
    L2 = instance.parameters.L2;
    L3 = instance.parameters.L3;

    first = source:first() + Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(L1) .. ", " .. tostring(L2) .. ", " .. tostring(L3) .. ")";
    instance:name(name);

    Initialization();

    if (not (nameOnly)) then
        RP = instance:addStream("RP", core.Line, name, "RP", instance.parameters.RP_color, first);
    RP:setPrecision(math.max(2, instance.source:getPrecision()));
        RP:setWidth(instance.parameters.width);
        RP:setStyle(instance.parameters.style);

        RP:addLevel(0);
        RP:addLevel(100);

        if ON[1] then
            RP:addLevel(L1, instance.parameters.L1S, instance.parameters.L1W, instance.parameters.L1C);
        end
        if ON[2] then
            RP:addLevel(L2, instance.parameters.L2S, instance.parameters.L2W, instance.parameters.L1C);
        end
        if ON[3] then
            RP:addLevel(L3, instance.parameters.L2S, instance.parameters.L3W, instance.parameters.L1C);
        end
    end
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

function Calculate(period, mode)
    if (period < first) then
        return;
    end

    local min, max;
    min, max = mathex.minmax(source, period-1-Period+1, period-1);
    RP[period] = (source.close[period] - min) / ((max - min) / 100);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
        return;
    end
    Calculate(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end
    Activate(1, period)
    Activate(2, period)
    Activate(3, period)
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if RP[period - 1] < L1 and RP[period] > L1 then
            up[id]:set(period, L1, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif RP[period - 1] > L1 and RP[period] < L1 then
            down[id]:set(period, L1, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 2 and ON[id] then
        if RP[period - 1] < L2 and RP[period] > L2 then
            up[id]:set(period, L2, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif RP[period - 1] > L2 and RP[period] < L2 then
            down[id]:set(period, L2, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 3 and ON[id] then
        if RP[period - 1] < L3 and RP[period] > L3 then
            up[id]:set(period, L3, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif RP[period - 1] > L3 and RP[period] < L3 then
            down[id]:set(period, L3, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end
end

function SoundAlert(Sound)
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, profile:id(), "(" .. source:instrument() .. ")" .. source[NOW] .. ", " .. Subject .. ", " .. LABEL);
end
