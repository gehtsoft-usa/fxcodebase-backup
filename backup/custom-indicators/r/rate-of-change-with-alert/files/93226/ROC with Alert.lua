-- Id: 11379
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60456

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

-- More information about this indicator can be found at:
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=60456&p=93226

-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 10 "Volume, Open Interest, and Breadth" (page 240-241)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Rate of Change with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrROC", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthROC", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleROC", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleROC", core.FLAG_LEVEL_STYLE);

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

    Parameters(1, "ROC Level Cross", 0);
end

function Parameters(id, Label, Level)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true);
    indicator.parameters:addDouble("Level" .. id, "Level ", "", Level);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local first;
local source = nil;

-- Streams block
local ROC = nil;

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
local Level = {};
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

function Initialization()
    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;

    local i;
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i);
        ON[i] = instance.parameters:getBoolean("ON" .. i);
        Level[i] = instance.parameters:getDouble("Level" .. i);
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

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    source = instance.source;
    first = source:first() + n + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ROC = instance:addStream("ROC", core.Line, name, "ROC", instance.parameters.clrROC, first)
    ROC:setWidth(instance.parameters.widthROC);
    ROC:setStyle(instance.parameters.styleROC);
    local precision = math.max(2, source:getPrecision());
    ROC:setPrecision(precision);

    Initialization();
end

-- Indicator calculation routine
function Update(period)
    if period <first then
        return;
    end
    ROC[period] = (source[period] / source[period - n] - 1) * 100;

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
    local Shift = 0;
    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if ROC[period] > Level[id] and ROC[period - 1] <= Level[id] then
            up[id]:set(period, Level[id], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period, Level[id]);
                if Show then
                    Pop(Label[id], " Cross Over " .. Level[id]);
                end
            end
        elseif ROC[period] < Level[id] and ROC[period - 1] >= Level[id] then
            down[id]:set(period, Level[id], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period, Level[id]);
                if Show then
                    Pop(Label[id], " Cross Under " .. Level[id]);
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
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(label, Subject, period, iLevel)
    if not SendEmail then
        return
    end
    local date = source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. iLevel .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end
