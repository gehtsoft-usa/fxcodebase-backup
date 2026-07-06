-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22809&p=39360#p39360

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Tail / Body Ratio");
    indicator:description("Tail / Body Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 1);

    indicator.parameters:addString("Type", "Type of signal", "", "B");
    indicator.parameters:addStringAlternative("Type", "Tail / Body", "", "B");
    indicator.parameters:addStringAlternative("Type", "Tail / Candle", "", "C");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Top Color", " ", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Bottom", "Bottom Color", " ", core.rgb(0, 255, 0));
    indicator.parameters:addDouble("Size", "Font Size", "", 10);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("ArrowSize", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "Top Tail / Body Ratio");
    Parameters(2, "Bottom Tail / Body Ratio");
end

function Parameters( id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    if id == 1 then
        indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
        indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);
    else
        indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
        indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);
    end

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 2;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplier;

local first;
local source = nil;
local Type;
-- Streams block
local arrowdown, arrowup;
local ArrowSize;

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
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

-- Routine
function Prepare(nameOnly)
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    Multiplier = instance.parameters.Multiplier;
    Type = instance.parameters.Type;
    ArrowSize = instance.parameters.ArrowSize;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Multiplier) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        arrowdown = instance:createTextOutput("Up", "Up", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.Bottom, 0);
        arrowup = instance:createTextOutput("Down", "Down", "Wingdings", ArrowSize, core.H_Center, core.V_Top, instance.parameters.Top, 0);
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
            if i == 1 then
                Up[i] = instance.parameters:getString("Up" .. i);
            else
                Up[i] = nil;
            end

            if i == 2 then
                Down[i] = instance.parameters:getString("Down" .. i);
            else
                Down[i] = nil;
            end
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
    if Live ~= "Live" then
        Calculation(period - 1, 1);
    else
        Calculation(period, 0);
    end
end

function Calculation(period, Shift)
    if period < first or not source:hasData(period) then
        return;
    end

    local Bar = math.abs(source.open[period] - source.close[period]);
    local UpMove = source.high[period] - math.max(source.open[period], source.close[period]);
    local DownMove = math.min(source.open[period], source.close[period]) - source.low[period];

    arrowup:setNoData(period);
    arrowdown:setNoData(period);

    if Type == "B" then
        if (Bar * Multiplier) < UpMove then
            arrowup:set(period, source.high[period], "\226");
            Activate(1, period, Shift);
        end

        if (Bar * Multiplier) < DownMove then
            arrowdown:set(period, source.low[period], "\225");
            Activate(2, period, Shift);
        end
    else
        if ((Bar + DownMove) * Multiplier) < UpMove then
            arrowup:set(period, source.high[period], "\226");
            Activate(1, period, Shift);
        end

        if ((Bar + UpMove) * Multiplier) < DownMove then
            arrowdown:set(period, source.low[period], "\225");
            Activate(2, period, Shift);
        end
    end
end

function Activate(id, period, Shift)
    if id == 1 and ON[id] and period == source:size() - 1 - Shift then
        D[id] = nil;
        if U[id] ~= source:serial(period) and not FIRST then
            U[id] = source:serial(period);
            SoundAlert(Up[id]);
            EmailAlert(Label[id], " Down Arrow", period);
            if Show then
                Pop(Label[id], " Down Arrow ");
            end
        end
    elseif id == 2 and ON[id] and period == source:size() - 1 - Shift then
        U[id] = nil;

        if D[id] ~= source:serial(period) and not FIRST then
            D[id] = source:serial(period);
            SoundAlert(Down[id]);
            EmailAlert(Label[id], " Up Arrow", period);
            if Show then
                Pop(Label[id], " Up Arrow ");
            end
        end
    end
    if FIRST then
        FIRST = false;
    end
end

function AsyncOperationFinished (cookie, success, message)
end

function Pop(label, note)
    terminal:alertMessage(source:instrument(), source[NOW], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( label, Subject, period)
    if not SendEmail then
        return
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
