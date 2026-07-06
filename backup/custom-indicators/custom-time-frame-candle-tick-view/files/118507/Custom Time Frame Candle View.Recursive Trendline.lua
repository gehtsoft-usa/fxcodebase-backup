-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60537
-- Id: 20832

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
    indicator:name("Custom Time Frame Candle View");
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
    indicator.parameters:addInteger("time_shift", "Time shift, in hours", "", 0);
    
    indicator.parameters:addInteger("Step","Number Of Elements","", 1);
    
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
local TF;
local target_TF;
local Old_volume;
local time_shift;
local trading_day_offset;
local trading_week_offset;

-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST=true;
    Step = instance.parameters.Step;
    TF = instance.parameters.TF;
    Instrument = instance.parameters.Instrument;
    time_shift = instance.parameters.time_shift;

    local shift = "";
    if TF == "D1" or TF == "W1" or TF == "M1" then
        target_TF = TF;
        if time_shift > 0 then
            shift = string.format(", NY+%d", time_shift);
            TF = "H1";
        elseif time_shift < 0 then
            shift = string.format(", NY%d", time_shift);
            TF = "H1";
        end
    else
        target_TF = TF;
    end
    trading_day_offset = core.host:execute("getTradingDayOffset") + time_shift;
    trading_week_offset = core.host:execute("getTradingWeekOffset");
    local name = string.format("%s, %s, %s, %s%s", profile:id(), Instrument, target_TF, Step, shift);
    instance:name(name);

    if onlyName then
        return ;
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

    History = core.host:execute("getHistory", 1000, Instrument, TF, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    loading = true;
    
    if instance.parameters.to == 0 then 
         core.host:execute("subscribeTradeEvents", 2000, "offers");  
    end
    core.host:execute("setStatus", "Loading");

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
    volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, target_TF);
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then        
        handleHistory(); 
        core.host:execute("setStatus", "");         
    elseif cookie == 2000 then      
        loading = false;  
        handleUpdate()                   
    end
end

local start_new_after;

function calcValue(Index, period)
    if period < History:first() then
        return;
    end
        
    if period == 1 then
        local date, e = core.getcandle(target_TF, History:date(1), trading_day_offset, trading_week_offset);
        instance:addViewBar(date);
        start_new_after = date + (e - date) * Step;
        Index = Index + 1;
        open[Index] = History.open[period];
        low[Index] = History.low[period];
        close[Index] = History.close[period];
        high[Index] = History.high[period];
    else 
        local date, e = core.getcandle(target_TF, History:date(period), trading_day_offset, trading_week_offset);
        if date >= start_new_after then
            Index = Index + 1;
            instance:addViewBar(date);
            start_new_after = date + (e - date) * Step;
            
            open[Index] = History.open[period];  
            low[Index] = History.low[period];   
            close[Index] = History.close[period];  
            high[Index] = History.high[period];  
            volume[Index] = History.volume[period]; 
            Old_volume = History.volume[period]; 
        else
            close[Index] = History.close[period];     
            low[Index] = math.min(low[Index], History.low[period]); 
            high[Index] = math.max(high[Index], History.high[period]); 
            
            if Last ~= date then
                Old_volume = volume[Index] + History.volume[period];
                volume[Index] = Old_volume;
            else
                volume[Index] = Old_volume + History.volume[period]; 
            end                
        end
        Last = date;
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