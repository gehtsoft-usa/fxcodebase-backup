--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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

    indicator.parameters:addString("TF", " Time frame", "", "Chart");
    
    local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1" , "W1", "M1", "Chart"};
    for i= 1, 14, 1 do
    indicator.parameters:addStringAlternative("TF", iTF[i], "", iTF[i]);
    end

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

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Widht", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alerts Sound");
    
    
    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);    
    
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "Top Line")
    Parameters(2, "Bottom Line")
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
local ShowAlert, Show;
local FIRST = true;

local ToTime;
    
-- Routine
function Prepare(nameOnly)
    FIRST = true;
    
    ShowAlert = instance.parameters.ShowAlert;
    Show = instance.parameters.Show;
    
    ToTime=instance.parameters.ToTime;
    
    if ToTime == 1 then
    ToTime=core.TZ_EST;
    elseif ToTime == 2 then
    ToTime=core.TZ_UTC;
    elseif ToTime == 3 then
    ToTime=core.TZ_LOCAL;
    elseif ToTime == 4 then
    ToTime=core.TZ_SERVER;
    elseif ToTime == 5 then
    ToTime=core.TZ_FINANCIAL;
    elseif ToTime == 6 then
    ToTime=core.TZ_TS;
    end
    
    
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
    source = instance.source;
    
    
    if TF== "Chart" then
    TF=source:barSize();
    end

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
    if period < source:size() - 1 or loading then
        return nil ;
    end
    
    local Top, Bottom;

    ATR:update(mode);

    if ATR.DATA:size() <= ATR.DATA:first() + 1 then
        return nil;
    end


    if Type == "ATR" then
    
        if Price == "High/Low" then
        Top = SourceData["low"][SourceData:size() - 1 - Shift1] + ATR.DATA[ATR.DATA:size() - 1 - Shift2] * Multiplier;
        Bottom = SourceData["high"][SourceData:size() - 1 - Shift1] - ATR.DATA[ATR.DATA:size() - 1 - Shift2] * Multiplier;
        else
        Top = SourceData[Price][SourceData:size() - 1 - Shift1] + ATR.DATA[ATR.DATA:size() - 1 - Shift2] * Multiplier;
        Bottom = SourceData[Price][SourceData:size() - 1 - Shift1] - ATR.DATA[ATR.DATA:size() - 1 - Shift2] * Multiplier;
        end
    elseif Type == "Percentage" then
        if Price == "High/Low" then
        Top = SourceData["low"][SourceData:size() - 1 - Shift1] + (SourceData["low"][SourceData:size() - 1 - Shift2] / 100) * Percentage;
        Bottom = SourceData["high"][SourceData:size() - 1 - Shift1] - (SourceData["high"][SourceData:size() - 1 - Shift2] / 100) * Percentage;
        else
        Top = SourceData[Price][SourceData:size() - 1 - Shift1] + (SourceData[Price][SourceData:size() - 1 - Shift2] / 100) * Percentage;
        Bottom = SourceData[Price][SourceData:size() - 1 - Shift1] - (SourceData[Price][SourceData:size() - 1 - Shift2] / 100) * Percentage;
        end
    else
        if Price == "High/Low" then
        Top = SourceData["low"][SourceData:size() - 1 - Shift1] + source:pipSize() * Pip;
        Bottom = SourceData["high"][SourceData:size() - 1 - Shift1] - source:pipSize() * Pip;
        else
        Top = SourceData[Price][SourceData:size() - 1 - Shift1] + source:pipSize() * Pip;
        Bottom = SourceData[Price][SourceData:size() - 1 - Shift1] - source:pipSize() * Pip;
        end
    end

    core.host:execute("setStatus", "Top :" .. string.format("%." .. source:getPrecision () .. "f", Top) .. ", Bottom :" .. string.format("%." .. source:getPrecision () .. "f", Bottom));
    local fromDate = nil;
    local toDate = nil;

    local date = source:date(period);
    fromDate, toDate = core.getcandle(TF, date, day_offset, week_offset);

    if fromDate ~= nil and Top ~= nil then
        core.host:execute("drawLine", 1, fromDate, Top, toDate, Top, Color, Style, Widht);
        core.host:execute("drawLine", 2, fromDate, Bottom, toDate, Bottom, Color, Style, Widht);
        
         return Top, Bottom;
     else
        return nil;
        
    end

   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    local Top, Bottom = Calculate(period, mode);
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
                Pop(Label[id], " Cross Over ", period );      
                SendAlert( Label[id]," Cross Over ");
            end
        elseif source.close[period - 1] > Top and source.close[period] < Top then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
                Pop(Label[id], " Cross Under ", period );      
                SendAlert( Label[id]," Cross Under ");
            end
        end
    elseif id == 2 and ON[id] then
        if source.close[period - 1] < Bottom and source.close[period] > Bottom then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
                Pop(Label[id], " Cross Over ", period );      
                SendAlert( Label[id]," Cross Over ");
            end
        elseif source.close[period - 1] > Bottom and source.close[period] < Bottom then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
                Pop(Label[id], " Cross Under ", period );      
                SendAlert( Label[id]," Cross Under ");
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
    end

    return core.ASYNC_REDRAW;
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end

     local now = core.host:execute("getServerTime");
    now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
    
   local DATA = core.dateToTable (now);
   
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, profile:id(), "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end


function Pop(label , Subject )
  
   if not Show then
   return;
   end
   
   local now = core.host:execute("getServerTime");
    now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
    local DATA = core.dateToTable (now);
    
    
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    core.host:execute("prompt", 3, label , text );
end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
    
    local now = core.host:execute("getServerTime");
    now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
    local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end
