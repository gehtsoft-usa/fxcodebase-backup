-- Id: 7169
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22582


--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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
    indicator:name("MA Gap with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addString("Method", "Method", "Method", "A");
    indicator.parameters:addStringAlternative("Method", "Absolute", " ", "A");
    indicator.parameters:addStringAlternative("Method", "Relativ", "", "R");
    indicator.parameters:addStringAlternative("Method", "Pips", "", "P");

    indicator.parameters:addDouble("Level", "Signal Level", "", 0);

    indicator.parameters:addGroup("First Method");
    indicator.parameters:addInteger("Period1", "First Period", "", 10, 2, 1000);

    indicator.parameters:addString("Method1", "Method", "Method", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA");

    indicator.parameters:addGroup("Second Method");

    indicator.parameters:addInteger("Period2", "Second Period", "", 20, 2, 1000);

    indicator.parameters:addString("Method2", "Method", "Method", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA", "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA", "WMA");

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("color", "Line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);

    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "",  1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
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

    Parameters(1, "top line");
    Parameters(2, "bottom line");
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

local Number = 2;

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
local Method;
local Alert;
local Indicator;
local PlaySound;
local Level;

local Period1;
local Period2;

local U = {};
local D = {};

local Method1 = nil;
local Method2 = nil;

-- Streams block
local MA1;
local MA2;
local GAP;

local first;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    Method = instance.parameters.Method;
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    Method1 = instance.parameters.Method1;
    Method2 = instance.parameters.Method2;
    Level = instance.parameters.Level;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Method1 .. ", " .. Period2 .. ", " .. Method2 .. ", " .. Method .. ", " .. Level .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, source, Period2);

    first = math.max(MA1.DATA:first(), MA2.DATA:first());

    GAP = instance:addStream("GAP", core.Line, name .. ".GAP", "GAP", instance.parameters.color, first);
    GAP:setWidth(instance.parameters.width);
    GAP:setStyle(instance.parameters.style);

    GAP:addLevel(instance.parameters.Level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    GAP:addLevel( - (instance.parameters.Level), instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	GAP:setPrecision(math.max(2, instance.source:getPrecision())); 
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
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

function Calculate(period, mode)
    MA1:update(mode);
    MA2:update(mode);

    if period < first then
        return;
    end

    if Method == "A" then
        GAP[period] = MA1.DATA[period] - MA2.DATA[period];
    elseif Method == "R" then
        GAP[period] = (MA1.DATA[period] - MA2.DATA[period]) / ( MA1.DATA[period] / 100);
    elseif Method == "P" then
        GAP[period] = (MA1.DATA[period] - MA2.DATA[period]) / source:pipSize();
    end
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
    Activate(1, period);
    Activate(2, period);
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if GAP[period - 1] < Level and GAP[period] > Level then
            up[id]:set(period, Level, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif GAP[period - 1] > Level and GAP [period] < Level then
            down[id]:set(period, Level, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 2 and ON[id] then
        if GAP[period - 1] < -Level and GAP[period] > -Level then
            up[id]:set(period, -Level, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif GAP[period - 1] > -Level and GAP[period] < -Level then
            down[id]:set(period, -Level, "\108");
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
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW] .. ", " .. Subject .. ", " .. LABEL);
end
