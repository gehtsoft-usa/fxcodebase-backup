-- Id: 11066
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27768


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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Moment In Time");
    indicator:description("Momemt In Time");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Selector");
    indicator.parameters:addInteger("hour", "Hour", "", 0, 0, 24);
    indicator.parameters:addInteger("minute", "Minute", "", 0, 0, 60);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MIT_color", "Color of MIT", "Color of MIT", core.rgb(255, 0, 0));
    indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    indicator.parameters:addGroup("Alert");

    indicator.parameters:addBoolean("On", "Show MIT Alert", "", false);

    indicator.parameters:addFile("Sound", " Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
    indicator.parameters:addString("Label", "Label", "", "MIT Alert");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PlaySound, RecurrentSound, SendEmail, Email, Show, Sound, On, Label;
local Size, Label;
local first;
local source = nil;
local Start;
-- Streams block
local MIT = nil;
local hour, minute;
local dayoffset, weekoffset;
local ChartSize, DSize;

local LabelColor;
local On = {};
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
local Active;

function Prepare(nameOnly)
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    source = instance.source;
    first = source:first();
    Size = instance.parameters.Size;
    LabelColor = instance.parameters.LabelColor;
    hour = instance.parameters.hour;
    minute = instance.parameters.minute;
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

    local s1, e1
    s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
    ChartSize = e1 - s1;
    s1, e1 = core.getcandle("D1", 0, 0, 0);
    DSize = e1 - s1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(hour) .. ", " .. tostring(minute) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
        if DSize > ChartSize then
            MIT = instance:addStream("MIT", core.Line, name, "MIT", instance.parameters.MIT_color, first);
            Start = instance:createTextOutput("Start", "Start", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.LabelColor, first);
        else
            MIT = instance:addStream("MIT", core.Bar, name, "MIT", instance.parameters.MIT_color, first);
        end
        MIT:setPrecision(math.max(2, instance.source:getPrecision()));
    

    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;

    Label = instance.parameters.Label;
    On = instance.parameters.On;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        Sound = instance.parameters.Sound;
    else
        Sound = nil;
    end

    assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen");

    RecurrentSound = instance.parameters.RecurrentSound;
    Active = nil;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first then
        return;
    end

    local date = source:date(period);
    local t = core.dateToTable(date);
    local s, e;
    s, e = core.getcandle("D1", date, dayoffset, weekoffset);
    local second = 1 / 86400;
    s = s + minute * 60 * second + 60 * 60 * hour * second;
    local index, Flag;
    if source:barSize() == "m1" then
        Flag = true;
    else
        Flag = false;
    end
    index = core.findDate(source, s, Flag);
    if DSize > ChartSize then
        MIT[period] = source.close[period] - source.open[index];
        if period == index then
            Start:set(period, 0, "\108");
            Activate(period);
        end
    else
        MIT[period] = source.close[period] - source.open[period - 1];
    end
end

function Activate(period)
    local Shift = 0;
    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if On then
        if Active ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
            Active = source:serial(period);
            SoundAlert(Sound);
            EmailAlert(Label, " Start on the New Period", period);
            if Show then
                Pop(Label, " Start on the New Period ");
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
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, Subject, profile:id() .. text);
end
