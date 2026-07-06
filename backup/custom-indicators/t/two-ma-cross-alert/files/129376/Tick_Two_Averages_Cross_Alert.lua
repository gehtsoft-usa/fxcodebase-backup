-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59789

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

function Init()
    indicator:name("Tick Two Averages Cross Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addString("Type", "Allow only this Signal Type", "", "Both");
    indicator.parameters:addStringAlternative("Type", "Both", "", "Both");
    indicator.parameters:addStringAlternative("Type", "Short Only", "", "Short");
    indicator.parameters:addStringAlternative("Type", "Long Only", "", "Long");

    indicator.parameters:addGroup("Calculation");


    indicator.parameters:addInteger("Period1", "Fast Period MA", "", 50, 2, 2000 );

    indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "SQW_MA", "SQW_MA", "SQW_MA");


    indicator.parameters:addInteger("Period2", "Slow Period MA", "", 200, 2, 2000);

    indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "SQW_MA", "SQW_MA", "SQW_MA");

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("color1", "Fast MA color", "MA color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color2", "Slow MA color", "MA color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

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

    Parameters(1, "MA Cross")
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
local Show;
local Alert;
local Indicator;
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

local Method1, Period1;
local Method2, Period2;
local slow, Slow;
local Fast, fast;

local Type;
-- Streams block

-- Routine
function Prepare(nameOnly) 
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    Method1 = instance.parameters.Method1;
    Method2 = instance.parameters.Method2;
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    Type = instance.parameters.Type;

    
    source = instance.source;

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name().. ", " .. Type.. ", " .. Method1 .. ", " .. Period1 .. ", " .. Method2 .. ", " .. Period2 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

    -- Create short and long EMAs for the source
    fast = core.indicators:create("AVERAGES", source, Method1, Period1, false);
    slow = core.indicators:create("AVERAGES", source, Method2, Period2, false);

    first = math.max(slow.DATA:first(), fast.DATA:first());

    Slow = instance:addStream("Slow", core.Line, name .. ".Slow", "Slow", instance.parameters.color2,  first);
    Slow:setWidth(instance.parameters.width2);
    Slow:setStyle(instance.parameters.style2);

    Fast = instance:addStream("Fast", core.Line, name .. ".Fast", "Fast", instance.parameters.color1,  first);
    Fast:setWidth(instance.parameters.width1);
    Fast:setStyle(instance.parameters.style1);

    Initialization();
end

function Initialization ()
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
    slow:update(mode);
    fast:update(mode);

    if period < first then
        return;
    end

    Slow[period] = slow.DATA[period];
    Fast[period] = fast.DATA[period];
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

    if period < first then
        return;
    end

    Activate(1, period)
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if Slow[period] < Fast[period] and Slow[period - 1] >= Fast[period - 1] then
            if Type ~= "Short" then    
                up[id]:set(period, Slow[period], "\108");
            end
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);

                if Type ~= "Short" then    
                    SoundAlert(Up[id]);
                    EmailAlert(Label[id], " Cross Over ", period);

                    if Show then
                        Pop(Label[id], " Cross Over ");
                    end
                end
            end
        elseif Slow[period] > Fast[period] and Slow[period - 1] <= Fast[period - 1] then
            if Type ~= "Long" then                 
                down[id]:set(period, Slow[period], "\108");
            end                           
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                if Type ~= "Long" then    
                    SoundAlert(Down[id]);
                    EmailAlert( Label[id], " Cross Under", period);
                    if Show then
                        Pop(Label[id], " Cross Under " );
                    end
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

function Pop(label, note)
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " ) " .. label .. " : " .. note, source:date(NOW));
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
    local price = win32.formatNumber(source:tick(NOW), false, source:getPrecision());
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. price .. delim .. TF .. delim .. Time;

    terminal:alertEmail(Email, profile:id(), text);
end

