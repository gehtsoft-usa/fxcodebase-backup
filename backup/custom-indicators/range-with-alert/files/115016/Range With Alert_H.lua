--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- More information about this indicator can be found at:
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=32324&p=59019

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name(" Range");
    indicator:description(" Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addString("Type", "Calculation Type", "Calculation Type", "ATR");
    indicator.parameters:addStringAlternative("Type", "ATR", "ATR", "ATR");
    indicator.parameters:addStringAlternative("Type", "Pips", " Pips", " Pips");
    indicator.parameters:addStringAlternative("Type", "Percentage", "Percentage", "Percentage");
    indicator.parameters:addInteger("Period", "ATR Period", "Period", 14);
    indicator.parameters:addDouble("Multiplier", "ATR Multiplier", "Multiplier", 1);

    indicator.parameters:addDouble("Percentage", "Percentage Range", "Percentage Range", 1);
    indicator.parameters:addDouble("Pip", "Pip Range", "Pip Range", 100);

    indicator.parameters:addString("TF", " Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price", "Low", "", "low");
    indicator.parameters:addStringAlternative("Price", "Close", "", "close");
    indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
	indicator.parameters:addStringAlternative("Price", "High/Low", "", "High/Low");

    indicator.parameters:addString("PriceShift", "Base Price Period", "", "Previous");
    indicator.parameters:addStringAlternative("PriceShift", "Previous", "", "Previous");
    indicator.parameters:addStringAlternative("PriceShift", "Current / Live", "", "Current");

    indicator.parameters:addString("IndicatorShift", "Algorithm Price Period", "", "Previous");
    indicator.parameters:addStringAlternative("IndicatorShift", "Previous", "", "Previous");
    indicator.parameters:addStringAlternative("IndicatorShift", "Current / Live", "", "Current");

    indicator.parameters:addBoolean("ShowHist", "Show historical data", "", true);

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Widht", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "Top Line")
    Parameters(2, "Bottom Line")
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
local Type;
local Price;
local first;
local source = nil;
local ATR;
local TF;
local Multiplier;
-- Streams block
local day_offset, week_offset;
local Period;
local Color, Widht, Style;
local Source;
local loading = true;
local Shift1, Shift2;
local IndicatorShift, PriceShift, Percentage, Pip;
local ShowHist;

local U = {};
local D = {};

-- Parameters block
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
local Alert;
local PlaySound;

local FIRST = true;
-- Routine
function Prepare(nameOnly)
    FIRST = true;
    IndicatorShift = instance.parameters.IndicatorShift;
    Multiplier = instance.parameters.Multiplier;
    Pip = instance.parameters.Pip;
    Percentage = instance.parameters.Percentage;
    PriceShift = instance.parameters.PriceShift;
    TF = instance.parameters.TF;
    Type = instance.parameters.Type;
    Color = instance.parameters.Color;
    Widht = instance.parameters.Widht;
    Style = instance.parameters.Style;
    Price = instance.parameters.Price;
    Period = instance.parameters.Period;
    ShowHist = instance.parameters.ShowHist;
    source = instance.source;

    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");

    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ", " .. tostring(Percentage) .. ", " .. tostring(Pip) .. ", " .. tostring(Period) .. ", " .. tostring(TF) .. ", " .. tostring(Price) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    local Test = core.indicators:create("ATR", source, Period);
    first = Test.DATA:first();

    if PriceShift == "Previous" then
        Shift1 = 1;
    else
        Shift1 = 0;
    end

    if IndicatorShift  == "Previous" then
        Shift2 = 1;
    else
        Shift2 = 0;
    end

    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), first, 2, 1);
    loading = true;
    ATR = core.indicators:create("ATR", SourceData, Period);

    Initialization();
end

function Initialization()
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

function Calculate(period, mode)
    if (period < source:size() - 1 and not(ShowHist)) or loading then
        return;
    end

    ATR:update(mode);

    if ATR.DATA:size() <= ATR.DATA:first() + 1 then
        return;
    end

    local Top = nil;
    local Bottom = nil;
    local SD_B1=core.findDate(SourceData, source:date(period), false);
    local SD_B2=SD_B1-Shift2;
    SD_B1=SD_B1-Shift1;
    if Type == "ATR" then
	
	    if Price == "High/Low" then
		Top = SourceData["low"][SD_B1] + ATR.DATA[SD_B2] * Multiplier;
        Bottom = SourceData["high"][SD_B1] - ATR.DATA[SD_B2] * Multiplier;
		else
        Top = SourceData[Price][SD_B1] + ATR.DATA[SD_B2] * Multiplier;
        Bottom = SourceData[Price][SD_B1] - ATR.DATA[SD_B2] * Multiplier;
		end
    elseif Type == "Percentage" then
	    if Price == "High/Low" then
		Top = SourceData["low"][SD_B1] + (SourceData["low"][SD_B2] / 100) * Percentage;
        Bottom = SourceData["high"][SD_B1] - (SourceData["high"][SD_B2] / 100) * Percentage;
		else
        Top = SourceData[Price][SD_B1] + (SourceData[Price][SD_B2] / 100) * Percentage;
        Bottom = SourceData[Price][SD_B1] - (SourceData[Price][SD_B2] / 100) * Percentage;
		end
    else
	    if Price == "High/Low" then
		Top = SourceData["low"][SD_B1] + source:pipSize() * Pip;
        Bottom = SourceData["high"][SD_B1] - source:pipSize() * Pip;
		else
        Top = SourceData[Price][SD_B1] + source:pipSize() * Pip;
        Bottom = SourceData[Price][SD_B1] - source:pipSize() * Pip;
		end
    end

    core.host:execute("setStatus", "Top :" .. string.format("%." .. source:getPrecision () .. "f", Top) .. ", Bottom :" .. string.format("%." .. source:getPrecision () .. "f", Bottom));
    local fromDate = nil;
    local toDate = nil;

    local date = source:date(period);
    fromDate, toDate = core.getcandle(TF, date, day_offset, week_offset);

    if fromDate ~= nil and Top ~= nil then
        core.host:execute("drawLine", 2*period+1, fromDate, Top, toDate, Top, Color, Style, Widht);
        core.host:execute("drawLine", 2*period+2, fromDate, Bottom, toDate, Bottom, Color, Style, Widht);
    end

    return Top, Bottom;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    local Top, Bottom;
    Top, Bottom = Calculate(period, mode);
    if Top == nil then
        return;
    end

    Activate(1, period, Top, Bottom)
    Activate(2, period, Top, Bottom)
end

function Activate(id, period, Top, Bottom)
    if id == 1 and ON[id] then
        if source.close[period - 1] < Top and source.close[period] > Top then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source.close[period - 1] > Top and source.close[period] < Top then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 2 and ON[id] then
        if source.close[period - 1] < Bottom and source.close[period] > Bottom then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source.close[period - 1] > Bottom and source.close[period] < Bottom then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end
end

function AsyncOperationFinished(cookie)
    if cookie == 1 then
        loading = true;
        core.host:execute("setStatus", "Loading");
    elseif cookie == 2 then
        loading = false;
        core.host:execute("setStatus", "Loaded");
        instance:updateFrom(0);
    else
        return 0;
    end

    return core.ASYNC_REDRAW;
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

function EmailAlert(Subject)
    if not SendEmail then
        return
    end

    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, profile:id(), "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end
