-- Id: 9216
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

-- This indicator provides Audio / Email Alerts, for TMACD indicator,
-- It is possible to define a total of six separate signals.
-- TMACD Cross Over / Under for Central / Signal
-- and Histogram / Central Line Cross Over/Under

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=38761

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Triangular Moving Average Convergence/Divergence with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "", 7, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 14, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
    indicator.parameters:addDouble("CL", "Centaral Line Level", "", 0);

    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("MACD_color", "TMACD color", "(TMACD Color)Red", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MACD_width", "TMACD Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MACD_style", "TMACD Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACD_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "(Signal Color) Blue", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HISTOGRAM_Up_color", "Up Histogram", "Up Histogram", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_Down_color", "Down Histogram", "Down Histogram", core.rgb(255, 0, 0));

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Down", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Up", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "TMACD / Central Line")
    Parameters(2, "TMACD / Signal")
    Parameters(3, "Histogram / Central Line")
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

local Number = 3;

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

local SN;
local LN;
local IN;
local CL;

local U = {};
local D = {};

local tmacd = nil;
local TMACD = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;

local firstPeriodMACD;
local firstPeriodSIGNAL;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    CL = instance.parameters.CL;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;

    

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if (LN <= SN) then
        error("The short EMA period must be smaller than long EMA period");
    end

     -- Create short and long EMAs for the source
    tmacd = core.indicators:create("TMACD", source, SN, LN);

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = tmacd.DATA:first();
    TMACD = instance:addStream("TMACD", core.Line, name .. ".TMACD", "TMACD", instance.parameters.MACD_color, firstPeriodMACD);
    TMACD:setWidth(instance.parameters.MACD_width);
    TMACD:setStyle(instance.parameters.MACD_style);

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("TMA", TMACD, IN);

    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
    HISTOGRAM = instance:addStream("HISTOGRAMUP", core.Bar, name .. ".HISTOGRAMUP", "HISTOGRAMUP", instance.parameters.HISTOGRAM_Up_color, firstPeriodSIGNAL);
	
	TMACD:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));

    first = MVAI.DATA:first();
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
    tmacd:update(mode);

    if (period >= firstPeriodMACD) then
        TMACD[period] = tmacd.DATA[period];
    end

    MVAI:update(mode);

    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
        HISTOGRAM[period] = TMACD[period] - SIGNAL[period];
        if (HISTOGRAM[period] > HISTOGRAM[period - 1]) then
            HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_Up_color);
        else
            HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_Down_color);
        end
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

    Activate(1, period)
    Activate(2, period)
    Activate(3, period)
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if TMACD[period - 1] > CL and TMACD[period] < CL then
            up[id]:set(period, CL, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif TMACD[period - 1] < CL and TMACD[period] > CL then
            down[id]:set(period, CL, "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 2 and ON[id] then
        if TMACD[period - 1] > SIGNAL[period - 1] and TMACD[period] < SIGNAL[period] then
            up[id]:set(period, SIGNAL[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif TMACD[period - 1] < SIGNAL[period - 1] and TMACD[period] > SIGNAL[period] then
            down[id]:set(period, SIGNAL[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end

    elseif id == 3 and ON[id] then
        if HISTOGRAM[period - 1] > CL and HISTOGRAM[period] < CL then
            up[id]:set(period, CL, "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif HISTOGRAM[period - 1] < CL and HISTOGRAM[period] > CL then
            down[id]:set(period, CL, "\108");
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

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;

    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW] .. ", " .. Subject .. ", " .. LABEL);
end

