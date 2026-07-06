
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60291

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Arbitrary Level Equidistant Channel with Alert");
    indicator:description("Equidistant Pivot Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addDouble("Cental", "Cental Line (Price)", "", 0);
    indicator.parameters:addDouble("Level1", "1. Line Distance(in Pips)", "", 20);
    indicator.parameters:addDouble("Level2", "2. Line Distance(in Pips)", "", 40);
    indicator.parameters:addDouble("Level3", "3. Line Distance(in Pips)", "", 60);
    indicator.parameters:addDouble("Level4", "4. Line Distance(in Pips)", "", 80);
    indicator.parameters:addDouble("Level5", "5. Line Distance(in Pips)", "", 100);
    indicator.parameters:addDouble("Level6", "6. Line Distance(in Pips)", "", 120);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Cental Line", "Color of Cental Line", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color1", "Color of 1. Line", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "1. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color2", "Color of 2. Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width2", "2. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "2. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color3", "Color of 3. Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width3", "3. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "3. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color4", "Color of 4. Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width4", "4. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "4. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color5", "Color of 5. Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width5", "5. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "5. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color6", "Color of 6. Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width6", "6. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "6. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);

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

    Parameters(1, "Central Line ");
    Parameters(2, "1. Line ");
    Parameters(3, "2. Line ");
    Parameters(4, "3. Line ");
    Parameters(5, "4. Line ");
    Parameters(6, "5. Line ");
    Parameters(7, "6. Line ");
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

local Number = 7;

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
local Level = {};
local Width = {};
local Style = {};
local Color = {};
local Level = {}
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local ID;
-- Streams block
local First, Second;
local Cental;
-- Routine
function Prepare(nameOnly)
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    Cental = instance.parameters.Cental;
    source = instance.source;

    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Cental)  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
        Color[3] = instance.parameters.color2;
        Style[3] = instance.parameters.style2;
        Width[3] = instance.parameters.width2;

        Color[2] = instance.parameters.color1;
        Style[2] = instance.parameters.style1;
        Width[2] = instance.parameters.width1;

        Color[4] = instance.parameters.color3;
        Style[4] = instance.parameters.style3;
        Width[4] = instance.parameters.width3;

        Color[1] = instance.parameters.color;
        Style[1] = instance.parameters.style;
        Width[1] = instance.parameters.width;

        Color[5] = instance.parameters.color4;
        Style[5] = instance.parameters.style4;
        Width[5] = instance.parameters.width4;

        Color[6] = instance.parameters.color5;
        Style[6] = instance.parameters.style5;
        Width[6] = instance.parameters.width5;

        Color[7] = instance.parameters.color6;
        Style[7] = instance.parameters.style6;
        Width[7] = instance.parameters.width6;

        Level[1] = 0;
        Level[2] = instance.parameters:getDouble("Level1" ) * source:pipSize();
        Level[3] = instance.parameters:getDouble("Level2" ) * source:pipSize();
        Level[4] = instance.parameters:getDouble("Level3" ) * source:pipSize();
        Level[5] = instance.parameters:getDouble("Level4" ) * source:pipSize();
        Level[6] = instance.parameters:getDouble("Level5" ) * source:pipSize();
        Level[7] = instance.parameters:getDouble("Level6" ) * source:pipSize();
    

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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    ID = 0;
    core.host:execute("removeAll")

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
    Activate(4, period);
    Activate(5, period);
    Activate(6, period);
    Activate(7, period);
end

function Plus()
    ID = ID + 1;
    return ID;
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if not ON[id] then
        return;
    end

    local Top = Cental + Level[id];
    local Bottom = Cental - Level[id];

    core.host:execute("drawLine", Plus(), source:date(first), Top, source:date(source:size() - 1), Top, Color[id], Style[id], Width[id]);
    core.host:execute("drawLine", Plus(), source:date(first), Bottom, source:date(source:size() - 1), Bottom, Color[id], Style[id], Width[id]);

    if id ~= 1 then
        if source.close[period] > Top and source.close[period - 1] <= Top then
            up[id]:set(period, Top, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(" Upper " .. Label[id], " Cross Over", id);
                if Show then
                    Pop(" Upper " .. Label[id], " Cross Over ", id);
                end
            end
        elseif source.close[period] < Top and source.close[period - 1] >= Top then
            down[id]:set(period, Top, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert("Upper " .. Label[id], " Cross Under", id);
                if Show then
                    Pop("Upper " .. Label[id], " Cross Under ", id);
                end
            end
        end
        if source.close[period] > Bottom and source.close[period - 1] <= Bottom then
            up[id]:set(period, Bottom, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(" Lower " .. Label[id], " Cross Over", id);
                if Show then
                    Pop(" Lower " .. Label[id], " Cross Over ", id);
                end
            end
        elseif source.close[period] < Bottom and source.close[period - 1] >= Bottom then
            down[id]:set(period, Bottom, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert("Lower " .. Label[id], " Cross Under", id);
                if Show then
                    Pop("Lower " .. Label[id], " Cross Under ", id);
                end
            end
        end
    else
        if source.close[period] > Top and source.close[period - 1] <= Top then
            up[id]:set(period, Top, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", id);
                if Show then
                    Pop(Label[id], " Cross Over ", id);
                end
            end
        elseif source.close[period] < Top and source.close[period - 1] >= Top then
            down[id]:set(period, Top, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", id);
                if Show then
                    Pop(Label[id], " Cross Under ", id);
                end
            end
        end
    end

    if FIRST then
        FIRST = false;
    end
end

function AsyncOperationFinished (cookie, success, message)
end

function Pop(label, note, id)
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " (" .. Level[id] .. ") " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(label, Subject, id)
    if not SendEmail then
        return
    end
    local date = source:date(source:size() - 1);
    local DATA = core.dateToTable(date);

    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label .. " (" .. Level[id] .. ") " .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end
