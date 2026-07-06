-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68328

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Custom Start/end Candle View");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
    
    indicator.parameters:addString("StartTime", "Start time", "", "10:00");
    indicator.parameters:addString("EndTime", "End time", "", "17:00");
    
    indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "From","", -1000);
    indicator.parameters:addDate("to", "To","", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
end

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
local Old;
local time_shift;
local trading_day_offset;
local trading_week_offset;

function ParseTime(time)
    local Pos = string.find(time, ":");
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    local m = tonumber(time);
    return (h / 24.0 +  m / 1440.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60) or (h == 24 and m == 0)); -- validity flag
end

function GetBestTimeframe(date)
    local table = core.dateToTable(date);
    local total_minutes = table.hour * 60 + table.min;

    if total_minutes == (24 - trading_day_offset) * 60 then
        return "D1";
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
end
local StartTime;
local period_lenth;
-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST=true;
    Step = instance.parameters.Step;
    Instrument = instance.parameters.Instrument;

    local name = profile:id().. ", " .. Instrument
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
    
    local valid;
    StartTime, valid = ParseTime(instance.parameters.StartTime);
    local EndTime, valid = ParseTime(instance.parameters.EndTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    time_shift = StartTime - (24.0 + trading_day_offset) / 24.0;
    period_lenth = EndTime - StartTime;
    if period_lenth < 0 then
        period_lenth = period_lenth + 1;
    end
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
    local best_tf2 = GetBestTimeframe(period_lenth);
    local s, e = core.getcandle(best_tf, 0, trading_day_offset, trading_week_offset);
    local s2, e2 = core.getcandle(best_tf2, 0, trading_day_offset, trading_week_offset);
    if (e2 - s2) < (e - s) then
        best_tf = best_tf2;
    end
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

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, "D1");
end

function Update(period)
end

local date_start, date_end;
local start_new_after;

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then
        handleHistory(); 
        core.host:execute("setStatus", "");
    elseif cookie == 2000 then
        loading = false;
        handleUpdate();
    end
end

function calcValue(Index, period)
    if period < History:first() then
        return;
    end
    local original_date = History:date(period);
    if period == 1 then
        local ts_time = core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, original_date);
        date_start = core.host:execute("convertTime", core.TZ_TS, core.TZ_EST, math.ceil(ts_time) + StartTime) * 86400;
        while (date_start / 86400 > original_date) do
            date_start = date_start - 86400;
        end
        instance:addViewBar(date_start / 86400);
        date_end = date_start + period_lenth * 86400;
        start_new_after = date_start + 86400;
        Index = Index + 1;
        open[Index] = History.open[period];
        low[Index] = History.low[period];
        close[Index] = History.close[period];
        high[Index] = History.high[period];
    else 
        if original_date >= start_new_after / 86400 then
            Index = Index + 1;
            while ((start_new_after + 86400) / 86400 < original_date) do
                start_new_after = start_new_after + 86400;
            end
            instance:addViewBar(start_new_after / 86400);
            date_start = start_new_after;
            date_end = date_start + period_lenth * 86400;
            start_new_after = start_new_after + 86400;
            
            open[Index] = History.open[period];  
            low[Index] = History.low[period];   
            close[Index] = History.close[period];  
            high[Index] = History.high[period];  
            Old_volume = History.volume[period]; 
            volume[Index] = Old_volume; 
        elseif original_date <= date_end / 86400 and original_date >= date_start / 86400 then
            close[Index] = History.close[period];
            low[Index] = math.min(low[Index], History.low[period]); 
            high[Index] = math.max(high[Index], History.high[period]); 
            
            if Last ~= (start_new_after - 86400) then
                Old_volume = volume[Index] + History.volume[period];
                volume[Index] = Old_volume;
            else
                volume[Index] = Old_volume + History.volume[period]; 
            end
        end
        Last = start_new_after - 86400;
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
