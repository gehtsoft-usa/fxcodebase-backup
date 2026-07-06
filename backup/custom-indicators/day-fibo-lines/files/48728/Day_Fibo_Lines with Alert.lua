-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27807
-- Id: 8299

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Day_Fibo_Lines with Alert give Audio / Email Alerts if Price cross over/under or touch one of fib. levels.

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27807&p=48728

function Init()
    indicator:name("Day Fibo Lines with Alert");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "00:00");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HL_LineClr", "High/Low lines color", "High/Low lines color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("HL_Width", "High/Low lines width", "High/Low lines width", 3, 1, 5);
    indicator.parameters:addInteger("HL_Style", "High/Low lines style", "High/Low lines style", core.LINE_SOLID);
    indicator.parameters:setFlag("HL_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_LineClr", "Central line color", "Central line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Central_Width", "Central line width", "Central line width", 2, 1, 5);
    indicator.parameters:addInteger("Central_Style", "Central line style", "Central line style", core.LINE_DASHDOT);
    indicator.parameters:setFlag("Central_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Fibo_LineClr", "Fibo lines color", "Fibo lines color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Fibo_Width", "Fibo lines width", "Fibo lines width", 1, 1, 5);
    indicator.parameters:addInteger("Fibo_Style", "Fibo lines style", "Fibo lines style", core.LINE_DOT);
    indicator.parameters:setFlag("Fibo_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("LableClr", "Lable Color", "Lable Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("FontSize", "Label font size", "Label font size", 10);
    indicator.parameters:addGroup("Alert Type");
    indicator.parameters:addString("Type", "Alert Type", "", "Cross");
    indicator.parameters:addStringAlternative("Type", "Cross", "", "Cross");
    indicator.parameters:addStringAlternative("Type", "Touch", "", "Touch");
    indicator.parameters:addStringAlternative("Type", "Both", "", "Any");

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpColor", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DownColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("TouchColor", "Touch Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "Top Line");
    Parameters(2, "F1");
    Parameters(3, "F2");
    Parameters(4, "F3");
    Parameters(5, "F4");
    Parameters(6, "F5");
    Parameters(7, "Bottom Line");
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Touch" .. id, Label .. " Touch Sound", "", "");
    indicator.parameters:setFlag("Touch" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 7;

local Up = {};
local Down = {};
local Touch = {};
local Label = {};
local ON = {};
local Line;
local up = {};
local down = {};
local touch = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Type;
local Alert;
local Indicator;
local PlaySound;

local FIRST = true;

local U = {};
local D = {};
local T = {};

local first;
local source = nil;
local BeginT;
local font;
local Out = {};

function Prepare(nameOnly)
    FIRST = true;
    Type = instance.parameters.Type;
    source = instance.source;
    first = source:first() + 2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local BeginTime = instance.parameters.BeginTime;
    local Pos = string.find(BeginTime, ":");
    local BeginH = tonumber(string.sub(BeginTime, 1, Pos - 1));
    local BeginM = tonumber(string.sub(BeginTime, Pos + 1));
    BeginT = 60 * BeginH + BeginM;
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
    Out[1] = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.HL_LineClr, first);
    Out[1] :setWidth(instance.parameters.HL_Width);
    Out[1]:setStyle(instance.parameters.HL_Style);
    Out[7] = instance:addStream("L", core.Line, name .. ".L", "L", instance.parameters.HL_LineClr, first);
    Out[7]:setWidth(instance.parameters.HL_Width);
    Out[7]:setStyle(instance.parameters.HL_Style);

    Out[2] = instance:addStream("F1", core.Line, name .. ".F1", "F1", instance.parameters.Fibo_LineClr, first);
    Out[2]:setWidth(instance.parameters.Fibo_Width);
    Out[2]:setStyle(instance.parameters.Fibo_Style);
    Out[3] = instance:addStream("F2", core.Line, name .. ".F2", "F2", instance.parameters.Fibo_LineClr, first);
    Out[3]:setWidth(instance.parameters.Fibo_Width);
    Out[3]:setStyle(instance.parameters.Fibo_Style);
    Out[4] = instance:addStream("F3", core.Line, name .. ".F3", "F3", instance.parameters.Central_LineClr, first);
    Out[4]:setWidth(instance.parameters.Central_Width);
    Out[4]:setStyle(instance.parameters.Central_Style);
    Out[5] = instance:addStream("F4", core.Line, name .. ".F4", "F4", instance.parameters.Fibo_LineClr, first);
    Out[5]:setWidth(instance.parameters.Fibo_Width);
    Out[5]:setStyle(instance.parameters.Fibo_Style);
    Out[6] = instance:addStream("F5", core.Line, name .. ".F5", "F5", instance.parameters.Fibo_LineClr, first);
    Out[6]:setWidth(instance.parameters.Fibo_Width);
    Out[6]:setStyle(instance.parameters.Fibo_Style); --5

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
            Touch[i] = instance.parameters:getString("Touch" .. i);
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil;
            Down[i] = nil;
            Touch[i] = nil;
        end
    end
    for i = 1, Number, 1 do
        assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound) or (PlaySound and Touch[i] ~= "") or (PlaySound and Touch[i] ~= ""), "Sound file must be chosen");
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do
        U[i] = nil;
        D[i] = nil;
        T[i] = nil;

        if ON[i] then
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.UpColor, first);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.DownColor, first);
            touch[i] = instance:createTextOutput ("Tc", "Tc", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.TouchColor, first);
        end
    end
--Touch
end

function DayNumber(period)
    local D = source:date(period);
    local T = core.dateToTable(D);
    local wday = T.wday;
    local CandleTime = 60 * T.hour + T.min;
    if CandleTime < BeginT then
        wday = wday - 1;
        if wday < 1 then
            wday = 7;
        end
    end
    return wday;
end

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
            touch[i]:setNoData(period);
        end
    end

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
    Activate(4, period);
    Activate(5, period);
    Activate(6, period);
    Activate(7, period);
end

function Activate(id, period)
    if  ON[id] and Type ~= "Touch" then
        if source.close[period - 1] < Out[id][period - 1] and source.close[period] > Out[id][period] then
            up[id]:set(period, Out[id][period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source.close[period - 1] > Out[id][period - 1] and source.close[period] < Out[id][period] then
            down[id]:set(period, Out[id][period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end

    if ON[id] and Type ~= "Cross" then
        if source.low[period] < Out[id][period] and source.high[period] > Out[id][period] then
            touch[id]:set(period, Out[id][period], "\108");
            if T[id] ~= source:serial(period) and period == source:size() - 1 then
                T[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Touch");
            end
        end
    end
end

function Calculate(period, mode)
    if period > first then
        local DN = DayNumber(period);
        local DN2 = DayNumber(period - 1);
        if DN2 ~= DN then
            Out[1][period] = source.high[period];
            Out[7][period] = source.low[period];
        else
            Out[1][period] = math.max(Out[1][period - 1], source.high[period]);
            Out[7][period] = math.min(Out[7][period - 1], source.low[period]);
        end
        Out[2][period] = 0.236 * (Out[1][period] - Out[7][period]) + Out[7][period];
        Out[3][period] = 0.382 * (Out[1][period] - Out[7][period]) + Out[7][period];
        Out[4][period] = 0.5 * (Out[1][period] - Out[7][period]) + Out[7][period];
        Out[5][period] = 0.618 * (Out[1][period] - Out[7][period]) + Out[7][period];
        Out[6][period] = 0.764 * (Out[1][period] - Out[7][period]) + Out[7][period];
    elseif period == first then
        Out[1][period] = source.high[period];
        Out[7][period] = source.low[period];
    end
end

function SoundAlert(Sound)
    if FIRST then
        FIRST = false;
        return;
    end
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL =  DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end
