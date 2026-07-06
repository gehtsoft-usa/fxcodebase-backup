-- Id: 11752
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59259


--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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

-- This indicator will provides Audio / Email Alerts if and when Cycle Interpreter indicator cross given level.
 
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Cycle Interpreter");
    indicator:description("Cycle Interpreter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 0);
    indicator.parameters:addBoolean("Inverse", "Inverse", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Cycle_color", "Color of Cycle", "Color of Cycle", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("OB/OS Levels");
    indicator.parameters:addDouble("overbought", "Overbought Level", "", 75);
    indicator.parameters:addDouble("oversold", "Oversold Level", "", 25);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

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
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);

    Parameters(1, "1. Level", 75);
    Parameters(2, "2. Level", 50)
    Parameters(3, "3. Level", 25)
end

function Parameters(id, Label, Level)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    indicator.parameters:addDouble("Level" .. id, "Level", "", Level);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 3;

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
local OnlyOnce;
local U = {};
local D = {};
local OnlyOnceFlag;
local Level = {};
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Inverse;
local first;
local source = nil;

-- Streams block
local Cycle = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Inverse = instance.parameters.Inverse;
    source = instance.source;
    first = source:first() + Period;

    OnlyOnceFlag = true;
    FIRST = true;
    OnlyOnce = instance.parameters.OnlyOnce;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
     
	if   (nameOnly) then
        return;
    end
	
     
        Cycle = instance:addStream("Cycle", core.Line, name, "Cycle", instance.parameters.Cycle_color, first);
    Cycle:setPrecision(math.max(2, instance.source:getPrecision()));
        Cycle:setWidth(instance.parameters.width);
        Cycle:setStyle(instance.parameters.style);
        Cycle:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        Cycle:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        Cycle:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
   

    Initialization();
end

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
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
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

    if period < first then
        return;
    end

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
end

function Calculation(period)
    if period < first then
        return;
    end

    local min, max;
    if Period == 0 then
        min, max = mathex.minmax(source, first, source:size() - 2)
    else
        min, max = mathex.minmax(source, period - Period + 1, period)
    end

    if Inverse then
        Cycle[period] = 100 - (source[period] - min) / ((max - min) / 100);
    else
        Cycle[period] = (source[period] - min) / ((max - min) / 100);
    end
end

function Activate(id, period)
    local Shift = 0;
    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if Cycle[period] > Level[id] and Cycle[period - 1] <= Level[id] then
            up[id]:set(period, Level[id], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);

                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif Cycle[period] < Level[id] and Cycle[period - 1] >= Level[id] then
            down[id]:set(period, Level[id], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    elseif id == 2 and ON[id] then
        if Cycle[period] > Level[id] and Cycle[period - 1] <= Level[id] then
            up[id]:set(period, Level[id], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif Cycle[period] < Level[id] and Cycle[period - 1] >= Level[id] then
            down[id]:set(period, Level[id], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    elseif id == 3 and ON[id] then
        if Cycle[period] > Level[id] and Cycle[period - 1] <= Level[id] then
            up[id]:set(period, Level[id], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif Cycle[period] < Level[id] and Cycle[period - 1] >= Level[id] then
            down[id]:set(period, Level[id], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
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
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " ) " .. label .. " : " .. note);
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end

    Alert:invoke("PlaySound", Sound, RecurrentSound);
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
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end
