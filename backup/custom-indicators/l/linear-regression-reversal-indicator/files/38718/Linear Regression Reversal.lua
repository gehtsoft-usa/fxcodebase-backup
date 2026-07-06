-- Id: 7140
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22433

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
    indicator:name("Linear Regression Reversal");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20, 2, 1000);

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("color", "Line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

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

    Parameters(1, "Zero Line")
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
local name;
local Alert;
local Indicator;
local PlaySound;
local LR, RLR;

local Period;

local U = {};
local D = {};

-- Streams block
local first;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    Period = instance.parameters.Period;

    -- Base name of the indicator.
    name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first() + Period;
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

    LR = instance:addStream("LR", core.Line, name, "LR", instance.parameters.color, first);
    LR:setPrecision(math.max(2, instance.source:getPrecision()));
    LR:setWidth(instance.parameters.width);
    LR:setStyle(instance.parameters.style);

    RLR = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
        return;
    end

    RLR[period] = mathex.lreg(source, period - Period + 1, period);

    if RLR[period - 1] < RLR[period] then
        LR[period] = 1;
    elseif RLR[period - 1] > RLR[period] then
        LR[period] = -1;
    elseif RLR[period - 1] == RLR[period] then
        LR[period] = 0;
    end

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:etNoData (period);
            up[i]:setNoData(period);
        end
    end

    Activate(1, period);
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if LR[period - 1] < LR[period] then
            up[id]:set(period, 0, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif LR[period - 1] > LR[period] then
            down[id]:set(period, 0, "\108");
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
    local DATA = core.dateToTable (date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour  .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW] .. ", " .. Subject .. ", " .. LABEL);
end
