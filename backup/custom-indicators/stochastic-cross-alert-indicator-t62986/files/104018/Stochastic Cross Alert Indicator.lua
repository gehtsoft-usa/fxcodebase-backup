-- Id: 15207
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62986

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

-- This indicator will provides Audio / Email Alerts if and when Stochastic K Line cross given level.

-- Up to five signals can be selected.
-- 1. K/D Line Cross
-- 2. K/OB Line Cross
-- 3. K/OS Line
-- 4. K/Central Line Cross
-- 5. In Zone K/D Line Cross

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60567

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Stochastic Cross Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("averageTypeK", "The type of smoothing algorithm for %K", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK", "EMA", "", "EMA");

    indicator.parameters:addString("averageTypeD", "The type of smoothing algorithm for %D", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "EMA", "", "EMA");

    indicator.parameters:addString("ShowOnly", "Show", "", "Both");
	indicator.parameters:addStringAlternative("ShowOnly", "Both", "", "Both");
    indicator.parameters:addStringAlternative("ShowOnly", "Cross Over", "", "CrossOver");
    indicator.parameters:addStringAlternative("ShowOnly", "Cross Under", "", "CrossUnder");

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);


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
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "K/D Line", true);
    Parameters(2, "K/OB Line", false);
    Parameters(3, "K/OS Line", false);
    Parameters(4, "K/Central Line", false);
    Parameters(5, "In Zone K/D Line", false);
end

function Parameters(id, Label,Flag)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", Flag);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 5;

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
local Show;
local Alert;
local Indicator;
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

local slow, Slow;
local Fast, fast;

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;

local obl, osl;
local Indicator;
-- Streams block
local kLine = nil;
local dLine = nil;
local OB, OS;

local ShowOnly;
-- Routine
function Prepare(nameOnly)
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    OB = instance.parameters.overbought;
    OS = instance.parameters.oversold;
	ShowOnly = instance.parameters.ShowOnly;

    averageTypeK = instance.parameters.averageTypeK;
    averageTypeD = instance.parameters.averageTypeD;

    assert(instance.parameters.oversold < instance.parameters.overbought, "OverSold is bigger then OverBought");

    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Indicator = core.indicators:create("STOCHASTIC", source, k, d, sd, averageTypeK, averageTypeD);

    kLine = instance:addInternalStream(Indicator.K:first(),0);
    dLine  = instance:addInternalStream(Indicator.D:first(),0);

    first = math.max(Indicator.D:first(), Indicator.K:first());

     

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
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
        end
    end
end

function Calculate(period, mode)
    Indicator:update(mode);
    if period < first then
        return;
    end

    dLine[period] = Indicator.D[period];
    kLine[period] = Indicator.K[period];
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    Calculate(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end
    if period < first then
        return;
    end

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
    Activate(4, period);
    Activate(5, period);
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if kLine[period] > dLine[period] and kLine[period - 1] <= dLine[period - 1] and ShowOnly ~= "CrossUnder" then
            up[id]:set(period, source.low[period], "\225");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);

                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif kLine[period] < dLine[period] and kLine[period - 1] >= dLine[period - 1]    and ShowOnly ~= "CrossOver"  then
            down[id]:set(period, source.high[period], "\226");
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

    if id == 2 and ON[id] then
        if kLine[period] > OB and kLine[period - 1] <= OB   and ShowOnly ~= "CrossUnder" then
            up[id]:set(period, source.low[period], "\225");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);

                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif kLine[period] < OB and kLine[period - 1] >= OB    and ShowOnly ~= "CrossOver" then
            down[id]:set(period, source.high[period], "\226");
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

    if id == 3 and ON[id] then
        if kLine[period] > OS and kLine[period - 1] <= OS     and ShowOnly ~= "CrossUnder" then
            up[id]:set(period, source.low[period], "\225");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif kLine[period] < OS and kLine[period - 1] >= OS   and ShowOnly ~= "CrossOver" then
            down[id]:set(period, source.high[period], "\226");
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

    if id == 4 and ON[id]  then
        if kLine[period] > 50 and kLine[period - 1] <= 50   and ShowOnly ~= "CrossUnder"  then
            up[id]:set(period, source.low[period], "\225");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end
            end
        elseif kLine[period] < 50 and kLine[period - 1] >= 50   and ShowOnly ~= "CrossOver" then
            down[id]:set(period, source.high[period], "\226");
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

    if id == 5 and ON[id] then
        if kLine[period] > dLine[period] and kLine[period - 1] <= dLine[period - 1] and (dLine[period] > OB or dLine[period] < OS)   and ShowOnly ~= "CrossUnder"  then
            up[id]:set(period, source.low[period], "\225");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end
            end
        elseif kLine[period] < dLine[period] and kLine[period - 1] >= dLine[period - 1] and (dLine[period] > OB or dLine[period] < OS)  and ShowOnly ~= "CrossOver"  then
            down[id]:set(period, source.high[period], "\226");
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
    core.host:execute("prompt", 1, label, " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note);
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
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Price .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end
