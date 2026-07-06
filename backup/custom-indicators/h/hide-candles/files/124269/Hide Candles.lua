-- Id: 24104
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("Hide Candles");
    indicator:description("A chart will add a new Candle After passing of Set Number of Base Time Frame elements.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
    
    indicator.parameters:addString("TF", "Base Time Frame", "Base Time Frame" , "m1");
    indicator.parameters:addStringAlternative("TF", "m1", "m1" , "m1");
    indicator.parameters:addStringAlternative("TF", "H1", "H1" , "H1");
    indicator.parameters:addStringAlternative("TF", "D1", "D1" , "D1");
    indicator.parameters:addStringAlternative("TF", "W1", "W1" , "W1");
    indicator.parameters:addStringAlternative("TF", "M1", "M1" , "M1");
    indicator.parameters:addDouble("Step","Number Of Elements","", 1);
    indicator.parameters:addInteger("day_shift", "Days Shift", "Used for W1/M1 timeframes only", 0);

    indicator.parameters:addString("CandleStart", "End/start time", "", "00:00");
    indicator.parameters:addString("StartTime", "Session start", "", "18:00")
    indicator.parameters:addString("EndTime", "Session end", "", "00:00")
    
    indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "From","", -1000);
    indicator.parameters:addDate("to", "To","", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

    indicator.parameters:addBoolean("use_alert", "New Candle Alert","", true);
    indicator.parameters:addInteger("delta", "Delta, in seconds","", 1);
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local ShowAlert;
local Email;
local SendEmail;
local SoundFile = nil;
local RecurrentSound = false;
local Last;
local loading;
local History;
local open, high, low, close, volume;
local offer;
local offset;
local LastTime;
local Instrument;
local Count;
local FIRST;
local Step;
local LastS;
local TF;
local Old;
local time_shift;
local trading_day_offset;
local trading_week_offset;
local delta;
local day_shift = 0;

function ParseTime(time)
    local Pos = string.find(time, ":");
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    local m = tonumber(time);
    return (h / 24.0 +  m / 1440.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60) or (h == 24 and m == 0)); -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function GetBestTimeframe(date)
    local table = core.dateToTable(date);
    local total_minutes = table.hour * 60 + table.min;

    if TF == "D1" or TF == "W1" or TF == "M1" then
        if TF == "W1" or TF == "M1" then
            day_shift = instance.parameters.day_shift;
        end
        if total_minutes == (24 - trading_day_offset) * 60 then
            return TF;
        elseif total_minutes % 60 == 0 then
            return "H1";
        elseif total_minutes % 30 == 0 then
            return "m30";
        elseif total_minutes % 15 == 0 then
            return "m15";
        elseif total_minutes % 5 == 0 then
            return "m5";
        else
            return "m1";
        end
    elseif TF == "H1" then
        if total_minutes % 60 == 0 then
            return "H1";
        elseif total_minutes % 30 == 0 then
            return "m30";
        elseif total_minutes % 15 == 0 then
            return "m15";
        elseif total_minutes % 5 == 0 then
            return "m5";
        else
            return "m1";
        end
    else
        return "m1";
    end
end

local StartTime;
local EndTime;
local period_lenth;

-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST=true;
    Step = instance.parameters.Step;
    TF = instance.parameters.TF;
    Instrument = instance.parameters.Instrument;

    local name = profile:id().. ", " .. Instrument .. ", " .. TF .. "x"..  Step
    instance:name(name);

    if onlyName then
        return ;
    end

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");

    ShowAlert = instance.parameters.ShowAlert;
    RecurrentSound = instance.parameters.RecurrentSound;

    SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    trading_day_offset = core.host:execute("getTradingDayOffset");
    trading_week_offset = core.host:execute("getTradingWeekOffset");
    delta = instance.parameters.delta / 86400.0;
    
    local valid;
    local CandleStart, valid = ParseTime(instance.parameters.CandleStart);
    assert(valid, "Time " .. instance.parameters.CandleStart .. " is invalid");

    StartTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.CandleStart .. " is invalid");
    EndTime, valid = ParseTime(instance.parameters.EndTime);
    assert(valid, "Time " .. instance.parameters.CandleStart .. " is invalid");

    time_shift = CandleStart - (24.0 + trading_day_offset) / 24.0;
    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row=nil;
    row = enum:next();
    while row ~= nil do
        if row.Instrument == Instrument then
            break;
        end
        row = enum:next();
    end
    assert(row ~= nil, "Selected instrument is not available");
    offer = row.OfferID;

    instance:initView(Instrument, row.Digits, row.PointSize, true, true);

    local best_tf = GetBestTimeframe(time_shift);
    History = core.host:execute("getHistory", 1000, Instrument, best_tf, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    loading = true;

    if instance.parameters.to == 0 then 
        core.host:execute("subscribeTradeEvents", 2000, "offers");  
    end
    core.host:execute("setStatus", "Loading");
    timer = core.host:execute("setTimer", 42, 1);

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
    volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, TF);

    local date, e = core.getcandle(best_tf, 0, trading_day_offset, trading_week_offset);
    period_lenth = math.ceil((e - date) * Step * 86400);
end

-- This file contains helper method related to the signal alerts (message, sound, mail etc).

local gSignalBase = "";     -- the base part of the signal message
local gShowAlert = false;   -- the flag indicating whether the text alert must be shown
--values related to the email text formatting
local gMailIntroduction = "You have received this message because the following signal alert was received:"; -- the part of the email text formatting, the introduction.
local gMailSignalHeader = "Signal: "; -- the part of the email text formatting, the description of the provided 'Signal' value.
local gMailSignalName = "Custom Time Frame Candle View"; -- the part of the email text formatting, the value of the signal name.
local gMailSymbolHeader = "Symbol: "; -- the part of the email text formatting, the description of the provided 'Symbol' value.
local gMailMessageHeader = "Message: "; -- the part of the email text formatting, the description of the provided 'Message' value.
local gMailTimeHeader = "Time: "; -- the part of the email text formatting, the description of the provided 'Time' value.
local gMailPriceHeader = "Price: "; -- the part of the email text formatting, the description of the provided 'Price' value.

function FormatEmail(message)
    --format email subject
    local subject = gSignalBase .. message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = gMailSignalHeader .. gMailSignalName;
    local symbolDescr = gMailSymbolHeader .. History:instrument();
    local messageDescr = gMailMessageHeader .. gSignalBase .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4, History.close:date(NOW)));
    local dateDescr = gMailTimeHeader .. string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = gMailPriceHeader .. History.close[NOW];
    local text = gMailIntroduction .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function Signal(Label)
    if ShowAlert then
        terminal:alertMessage(History:instrument(), History.close[NOW], Label, History.close:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, profile:id().. " : " .. Label, FormatEmail(Label));
    end
end

function Update(period)
end

local start_new_after;
local alert_sent = false;

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then
        handleHistory(); 
        core.host:execute("setStatus", "");
    elseif cookie == 2000 then
        loading = false;
        handleUpdate();
    elseif cookie == 42 then
        if start_new_after ~= nil and not alert_sent and (start_new_after / 86400 - core.now()) <= delta then
            Signal("New candle will start soon");
            alert_sent = true;
        end
    end
end
local ll;
function calcValue(Index, period)
    if period < History:first() then
        return Index;
    end
    local original_date = History:date(period);
    local time = original_date - math.floor(original_date);
    if not InRange(time, StartTime, EndTime) then
        return Index;
    end

    if start_new_after == nil then
        local date_start = math.ceil((original_date + time_shift + day_shift) * 86400);
        while (date_start / 86400 > original_date) do
            date_start = date_start - period_lenth;
        end
        instance:addViewBar(date_start / 86400);
        start_new_after = date_start + period_lenth;
        alert_sent = false;
        Index = Index + 1;
        open[Index] = History.open[period];
        low[Index] = History.low[period];
        close[Index] = History.close[period];
        high[Index] = History.high[period];
    else
        if original_date >= start_new_after / 86400 then
            Index = Index + 1;
            while ((start_new_after + period_lenth) / 86400 < original_date) do
                start_new_after = start_new_after + period_lenth;
            end
            instance:addViewBar(start_new_after / 86400);
            start_new_after = start_new_after + period_lenth;
            alert_sent = false;
            
            open[Index] = History.open[period];  
            low[Index] = History.low[period];   
            close[Index] = History.close[period];  
            high[Index] = History.high[period];  
            Old_volume = History.volume[period]; 
            volume[Index] = Old_volume; 
        else
            close[Index] = History.close[period];
            low[Index] = math.min(low[Index], History.low[period]); 
            high[Index] = math.max(high[Index], History.high[period]); 
            
            if Last ~= (start_new_after - period_lenth) then
                Old_volume = volume[Index] + History.volume[period];
                volume[Index] = Old_volume;
            else
                volume[Index] = Old_volume + History.volume[period]; 
            end
        end
        Last = start_new_after - period_lenth;
    end
    return Index;
end

function handleHistory()
    local s = History:size() - 1;
    local i;
    local current = open:size() - 1;
    for i = 1, s, 1 do
        current = calcValue(current, i);
    end
    loading = false;
    LastTime = History:size() - 1;
end

function handleUpdate()
    local current = open:size() - 1;
    local i;
    for i = LastTime, History:size() - 1, 1 do
        current = calcValue(current, i);
    end
    LastTime = History:size() - 1;
end