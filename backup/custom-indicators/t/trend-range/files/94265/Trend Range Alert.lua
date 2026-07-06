-- Id: 11851
 
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
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=60756&p=100789

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Trend Range Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("MA Calculation");

    indicator.parameters:addBoolean("Show_MA", "Show MA", "", true);
    indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
    indicator.parameters:addInteger("Period1", "MA Period", "", 50, 2, 2000 );
    indicator.parameters:addString("Method1", "MA Method", "Method", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA", "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA", "WMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "DEMA", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "TEMA", "TEMA", "TEMA");
    indicator.parameters:addStringAlternative("Method1", "PAR_MA", "PAR_MA", "PAR_MA");

    indicator.parameters:addGroup("Range Calculation");
    indicator.parameters:addDouble("Range", "Range", "", 25, 0, 100 );

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("color1", "MA color", "MA color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Label Size", "", 20, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "Trend Range Alert")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true);
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);

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
local up ;
local down ;
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
local Price1;
local OnlyOnce;
local U = {};
local D = {};

local Method1, Period1;
local Range;
local ma, MA;
local Show_MA;
local OnlyOnceFlag;
local Flag;
-- Streams block

-- Routine
function Prepare(nameOnly)
    OnlyOnceFlag = true;
    FIRST = true;
    OnlyOnce = instance.parameters.OnlyOnce;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    Price1 = instance.parameters.Price1;
    Method1 = instance.parameters.Method1;
    Period1 = instance.parameters.Period1;
    Range = instance.parameters.Range;
    Show_MA = instance.parameters.Show_MA;
    

    source = instance.source;

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator( Method1 ) ~= nil, "Please, download and install " .. Method1 .. ".LUA indicator");

     -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    ma = core.indicators:create(Method1, source[Price1], Period1);

    first = ma.DATA:first();

    if Show_MA then
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color1, first);
        MA:setWidth(instance.parameters.width1);
        MA:setStyle(instance.parameters.style1);
    else
        MA = instance:addInternalStream(0, 0);
    end

    Flag = instance:addInternalStream(0, 0);
    Initialization();

    up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
    down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
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
    end
end

function Calculate(period)
    MA[period] = ma.DATA[period];
    --Range
    local range = (source.close[period] - source.low[period]) / ((source.high[period] - source.low[period]) / 100);

    if source.close[period] > MA[period] and range >= (100 - Range)then
        Flag[period] = 1;
        up:set(period, source.low[period], "\217");
    elseif source.close[period] < MA[period] and range <= Range then
        Flag[period] = -1;
        down:set(period, source.high[period], "\218");
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    ma:update(mode);
    down:setNoData(period);
    up:setNoData(period);

    if period < first then
        return;
    end

    Flag[period] = 0;
    Calculate(period, mode);
    Activate(1, period)
end

function Activate(id, period)
    local Shift = 0;
    if Live ~= "Live" then
        period = period-1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if Flag[period] == 1 then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Up ", period);

                if Show then
                    Pop(Label[id], " Up ");
                end

            end
        elseif Flag[period] == -1 then
            U[id] = nil;

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Down", period);
                if Show then
                    Pop(Label[id], " Down ");
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
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  .. label .. " : " .. notee, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( label, Subject, period)
    if not SendEmail then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end

    local date = source:date(period);
    local DATA = core.dateToTable (date);

    local delim = "\013\010";
    local Note =  profile:id() .. delim .. " Label : " .. label  .. delim .. " Alert : " .. Subject ;
    local Symbol = "Instrument : " .. source:instrument() ;
    local TF = "Time Frame : " .. source:barSize();
    local Time =  " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour  .. " / " .. DATA.min .. " / " .. DATA.sec;

    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;

    terminal:alertEmail(Email, profile:id(), text);
end
