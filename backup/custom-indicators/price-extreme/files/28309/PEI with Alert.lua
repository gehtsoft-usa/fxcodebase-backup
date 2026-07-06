-- Id: 12162
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14942

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
    indicator:name("Price Extreme");
    indicator:description("Price Extreme");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 2, 1, 100);
    indicator.parameters:addInteger("Shift", "Shift", "Shift", 0, 0, 100);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Top", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN", "Color of Bottom", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Font Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "Price Extreme")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true);
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Price Extreme Up Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Price Extreme Down Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 1;

-- Parameters block
local Up = {};
local Down = {};
local Label = {};
local ON = {};
local Line;
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Show;
local Alert;
local Indicator;
local PlaySound;
local Live;
local FIRST = true;
local OnlyOnce;
local U = {};
local D = {};

local OnlyOnceFlag;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Shift;

local first;
local source = nil;
local Size;
-- Streams block
local Top = nil;
local up, down;
local Flag;
function Prepare(nameOnly)
    OnlyOnceFlag = true;
    FIRST = true;
    OnlyOnce = instance.parameters.OnlyOnce;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    Period = (instance.parameters.Period - 1);
    Size = instance.parameters.Size;
    Shift = instance.parameters.Shift;
    source = instance.source;
    first = source:first() + Shift + Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Shift) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Flag = instance:addInternalStream(0, 0);
        up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
        down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
        Initialization();
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
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
        return;
    end
    Calculation(period);
    Activate(1, period);
end

function Calculation(period)
    local UP = true;
    local DOWN = true;
    period = period - Shift;
    local i;
    for i = 0, Period, 1 do
        if source.close[period - i] < source.high[period - i - 1] then
            UP = false;
        end
        if source.close[period - i] > source.low[period - i - 1] then
            DOWN = false;
        end
    end
    Flag[period] = 0;
    if UP then
        up:set(period, source.high[period], "\108");
        Flag[period] = 1;
    else
        up:setNoData(period);
    end

    if DOWN then
        down:set(period, source.low[period], "\108");
        Flag[period] = -1;
    else
        down:setNoData(period);
    end
end

function Activate(id, period)
    local Shift = 0;
    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end
    if id == 1 and ON[id] then
        if Flag[period] == 1 then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Up", period);
                if Show then
                    Pop(Label[id], " Up ");
                end
            end
        elseif Flag[period] == -1 then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Down", period);
                if Show then
                    Pop(Label[id], " Down ");
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
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end
    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end
    local date = source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end
