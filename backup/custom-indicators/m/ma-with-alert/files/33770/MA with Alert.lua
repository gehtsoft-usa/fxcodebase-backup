-- Id: 6610
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18926


--+------------------------------------------------------------------+
--|                               Copyright � 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

local MAS = {"EMA", "KAMA", "LWMA", "MVA", "SMMA", "TMA", "VIDYA", "WMA"};
function Init()
    indicator:name("MA with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");

    local i;
    indicator.parameters:addString("MA", "MA Method", "", "MVA");

    for i = 1, 8, 1 do
        indicator.parameters:addStringAlternative("MA", MAS[i], "", MAS[i]);
    end
    indicator.parameters:addInteger("Period", "Period", "",  14);

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("Show", "Show MA Line", "", true);
    indicator.parameters:addBoolean("Cross", "Show MA Cross", "", true);
    indicator.parameters:addBoolean("Slope", "Show MA Slope Change", "", false);
    indicator.parameters:addGroup("MA Line Style");

    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local MA;
local Period;
local first;
local source = nil;
local Line;
local up, down;
local Size;
local Email;
local SendEmail;
local PlaySound, RecurrentSound, SoundFile;
local Crossover, Crossunder;
local Alert;
local Indicator;
local Show;
local UpSlope = nil;
local DownSlope = nil;
local Slope;
local Cross;
-- Routine
function Prepare()
    Slope = instance.parameters.Slope;
    Cross = instance.parameters.Cross;
    source = instance.source;
    MA = instance.parameters.MA;
    Size = instance.parameters.Size;
    Period = instance.parameters.Period;
    SendEmail = instance.parameters.SendEmail;
    Show = instance.parameters.Show;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");
    RecurrentSound = instance.parameters.RecurrentSound;

    Crossover = nil;
    Crossunder = nil;
    UpSlope = nil;
    DownSlope = nil;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    assert(core.indicators:findIndicator(MA) ~= nil, MA .. " indicator must be installed");
    Indicator = core.indicators:create(MA, source, Period)
    first = Indicator.DATA:first();

    if Show then
        Out = instance:addStream(tostring(MA), core.Line, "", MA, instance.parameters.Color, first);
        Out:setWidth(instance.parameters.width);
        Out:setStyle(instance.parameters.style);
    end

    up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
    down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
end

local LAST;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
        return;
    end

    Indicator:update(mode);

    if Show then
        Out[period] = Indicator.DATA[period];
    end

    down:setNoData(period);
    up:setNoData(period);

    if Cross then
        if Indicator.DATA[period - 1] > source[period - 1] and Indicator.DATA[period] < source[period] then
            up:set(period, Indicator.DATA[period], "\108");
            down:setNoData(period);
            Crossunder = nil;
            if Crossover ~= source:serial(period) and period == source:size() - 1 then
                Crossover = source:serial(period);
                SoundAlert();
                EmailAlert("Cross Over");
            end
        elseif Indicator.DATA[period - 1] < source[period - 1] and Indicator.DATA[period] > source[period] then
            down:set(period, Indicator.DATA[period], "\108");
            up:setNoData(period);
            Crossover = nil;
            if Crossunder ~= source:serial(period) and period == source:size() - 1 then
                Crossunder = source:serial(period);
                SoundAlert();
                EmailAlert("Cross Under");
            end
        end
    end

    if Slope then
        if Indicator.DATA[period - 1] <= Indicator.DATA[period - 2] and Indicator.DATA[period] > Indicator.DATA[period - 1] then
            up:set(period, Indicator.DATA[period], "\108");
            down:setNoData(period);
            DownSlope = nil;
            if UpSlope ~= source:serial(period) and period == source:size() - 1 then
                UpSlope = source:serial(period);
                SoundAlert();
                EmailAlert("Up Slope");
            end
        elseif Indicator.DATA[period - 1] >= Indicator.DATA[period - 2] and Indicator.DATA[period] < Indicator.DATA[period - 1] then
            down:set(period, Indicator.DATA[period], "\108");
            up:setNoData(period);
            UpSlope = nil;
            if DownSlope ~= source:serial(period) and period == source:size() - 1 then
                DownSlope = source:serial(period);
                SoundAlert();
                EmailAlert("Down Slope");
            end
        end
    end
end

function SoundAlert()
    terminal:alertSound(SoundFile, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW] .. ", " .. Subject .. ", " .. LABEL);
end
