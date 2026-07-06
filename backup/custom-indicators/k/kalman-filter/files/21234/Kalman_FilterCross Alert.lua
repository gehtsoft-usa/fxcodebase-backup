-- Id: 10224
-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=10136


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

-- More information about this indicator can be found at:
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=10136&p=21234

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Kalman_FilterCross Alert");
    indicator:description("");
    indicator:setTag("AllowAllSources", "y");
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("1. Filter Calculation");

    indicator.parameters:addString("Price1", "Price Source (If Bar is Used)", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");

    indicator.parameters:addDouble("K1", "K", "", 1);
    indicator.parameters:addDouble("Sharpness1", "Sharpness", "", 1);

    indicator.parameters:addGroup("2. Filter Calculation");

    indicator.parameters:addString("Price2", "Price Source (If Bar is Used)", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");

    indicator.parameters:addDouble("K2", "K", "", 2);
    indicator.parameters:addDouble("Sharpness2", "Sharpness", "", 1);

    indicator.parameters:addGroup("1. Filter Style");
    indicator.parameters:addColor("MA_color1", "Line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MA_width1", "MA Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("MA_style1", "MA Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MA_style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("2. Filter Style");
    indicator.parameters:addColor("MA_color2", "Line color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("MA_width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("MA_style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MA_style2", core.FLAG_LINE_STYLE);

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

    Parameters(1, "Filter")
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

local Alert;
local Indicator;
local PlaySound;

local FIRST = true;

local U = {};
local D = {};

local Filter1, Filter2;
local Sharpness1, Sharpness2;
local K1, K2;
local Price;
local Price1, Price2;
-- Streams block
local source1, source2;
local Line1, Line2;
-- Routine
function Prepare(nameOnly)  
    Sharpness1 = instance.parameters.Sharpness1;
    Sharpness2 = instance.parameters.Sharpness2;
    K1 = instance.parameters.K1;
    K2 = instance.parameters.K2;
    Price1 = instance.parameters.Price1;
    Price2 = instance.parameters.Price2;

    FIRST = true;

    assert(core.indicators:findIndicator("KALMAN_FILTER" ) ~= nil, "Please, download and install KALMAN_FILTER.LUA indicator");

    source = instance.source;

    if instance.source:isBar() then
        source1 = instance.source[Price1];
        source2 = instance.source[Price2];
    else
        source1 = instance.source;
        source2 = instance.source;
    end

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Price1 .. ", " .. K1 .. ", " .. Sharpness1
                                                      .. ", " .. Price2 .. ", " .. K2 .. ", " .. Sharpness2 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

     -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator("KALMAN_FILTER") ~= nil, "KALMAN_FILTER" .. " indicator must be installed");
    Filter1 = core.indicators:create("KALMAN_FILTER", source1, K1, Sharpness1);
    Filter2 = core.indicators:create("KALMAN_FILTER", source2, K2, Sharpness2);

    Line1 = instance:addStream("One", core.Line, name .. "1. Filter", "1. Filter", instance.parameters.MA_color1,  Filter1.DATA:first());
    Line1:setWidth(instance.parameters.MA_width1);
    Line1:setStyle(instance.parameters.MA_style1);

    Line2 = instance:addStream("Two", core.Line, name .. "2. Filter", "2. Filter", instance.parameters.MA_color2,  Filter2.DATA:first());
    Line2:setWidth(instance.parameters.MA_width2);
    Line2:setStyle(instance.parameters.MA_style2);

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

function Calculate(period, mode)
    Filter1:update(mode);
    Filter2:update(mode);

    if period < math.max(Filter1.DATA:first(), Filter2.DATA:first()) then
        return;
    end

    Line1[period] = Filter1.DATA[period];
    Line2[period] = Filter2.DATA[period];
 end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    Calculate(period, mode);
    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData (period);
            up[i]:setNoData (period);
        end
    end

    if period < math.max(Filter1.DATA:first(), Filter2.DATA:first()) then
        return;
    end

    Activate(1, period)
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if Line1[period - 1] <= Line2[period - 1] and Line1[period] > Line2[period] then
            up[id]:set(period, Line1[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif Line1[period - 1] >= Line2[period - 1] and Line1[period] < Line2[period] then
            down[id]:set(period, Line1[period], "\108");
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
    if not PlaySound then
        return;
    end

    if FIRST then
        FIRST = false;
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( Subject)
    if not SendEmail then
        return
    end

    local date = source:date(NOW);
    local DATA = core.dateToTable (date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour  .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end
