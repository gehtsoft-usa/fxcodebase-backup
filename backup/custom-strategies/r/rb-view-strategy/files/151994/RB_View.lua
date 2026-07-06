-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3614

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


function Init()
    indicator:name("Range Bars");
    indicator:description("Range Bars");
    indicator:type(core.View);

    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("instrument", "Symbol", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Period", "", "m1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Price type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    
    indicator.parameters:addInteger("RangeSize", "Range of bar in pips", "", 10);
    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "From","", -1000);
    indicator.parameters:addDate("to", "To","", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
end

local lastDirection = -1;
local loading;
local instrument;
local frame;
local StepPips;
local history;
local open, high, low, close, volume;
local offer;
local offset;
local OneSecond;
local LastTime;
local RangeSize;

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    RangeSize = instance.parameters.RangeSize;

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. "/" .. RangeSize .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end

    assert(row ~= nil, "Symbol not found.");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
    StepPips = instance.parameters.RangeSize * history.close:pipSize();
    core.host:execute("setStatus", "Loading...");

    open = instance:addStream("open", core.Line, name .. ".open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. ".high", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. ".low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. ".close", "close", 0, 0, 0);
    volume = instance:addStream("volume", core.Line, name .. ".volume", "volume", core.host:execute("getProperty", "VolumeColor"), 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, frame);
    
    OneSecond=1/86400;
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        if success then
            handleHistory();
            core.host:execute("setStatus", "");
        else
            core.host:trace("The indicator could not get the history");
        end
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate();
        end
    end
end

function calcFirstValueValue(current, i, source)
    local open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] > open_val + StepPips do
        current = current + 1;
        if current==0 then
            instance:addViewBar(source:date(0));
            volume[current]=history.volume[i];
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
            volume[current]=0;
        end
        open[current] = open_val;
        close[current] = open[current]+StepPips;
        low[current] = open[current];
        high[current] = close[current];
        lastDirection = 1;
        open_val=open_val+StepPips;
    end
    open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] < open_val - StepPips do
        current = current + 1;
        if current==0 then
            instance:addViewBar(source:date(0));
            volume[current]=history.volume[i];
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
            volume[current]=0;
        end
        open[current] = open_val;
        close[current] = open[current]-StepPips;
        high[current] = open[current];
        low[current] = close[current];
        lastDirection = -1;
        open_val=open_val-StepPips;
    end
    
    return current;
end

function calcValue(current, i, source)
    if current == -1 then
        return calcFirstValueValue(current, i, source);
    end

    local diff = close[current] - open[current];
    if diff > 0 or (diff == 0 and lastDirection == 1) then
        lastDirection = 1;
        if source[i] <= close[current] + StepPips and source[i] >= close[current] - 2 * StepPips then
         volume[current]=volume[current]+history.volume[i];
        end
        while source[i] > close[current] + StepPips do
            current = current + 1;
            if open:date(current-1) < source:date(i) then
                instance:addViewBar(source:date(i));
                volume[current]=history.volume[i];
            else
                instance:addViewBar(open:date(current-1)+OneSecond);
                volume[current]=0;
            end
            open[current] = close[current - 1];
            low[current] = open[current];
            close[current]=open[current]+StepPips;
            high[current] = close[current];
        end
        if source[i] < close[current] - 2 * StepPips then
            while source[i]<close[current] - StepPips do
                current = current + 1;
                if open:date(current-1) < source:date(i) then
                 instance:addViewBar(source:date(i));
                 volume[current]=history.volume[i];
                else
                 instance:addViewBar(open:date(current-1)+OneSecond);
                 volume[current]=0;
                end
                if close[current-1] > open[current-1] then
                    open[current] = close[current - 1] - StepPips;
                else
                    open[current] = close[current - 1];
                end
                high[current] = open[current];
                close[current]=open[current]-StepPips;
                low[current] = close[current];
            end  
        end
    end
    
    if diff < 0 or (diff == 0 and lastDirection == -1) then
        lastDirection = -1;
        if source[i] >= close[current] - StepPips and source[i] <= close[current] + 2 * StepPips then
         volume[current]=volume[current]+history.volume[i];
        end
        while source[i] < close[current] - StepPips do
            current = current + 1;
            if open:date(current-1) < source:date(i) then
                instance:addViewBar(source:date(i));
                volume[current]=history.volume[i];
            else
                instance:addViewBar(open:date(current-1)+OneSecond);
                volume[current]=0;
            end
            open[current] = close[current - 1];
            high[current] = open[current];
            close[current]=open[current]-StepPips;
            low[current] = close[current];
        end
        if source[i] > close[current] + 2 * StepPips then
            while source[i] > close[current] + StepPips do
                current = current + 1;
                if open:date(current-1) < source:date(i) then
                 instance:addViewBar(source:date(i));
                 volume[current]=history.volume[i];
                else
                 instance:addViewBar(open:date(current-1)+OneSecond);
                 volume[current]=0;
                end
                if close[current-1] < open[current-1] then
                    open[current] = close[current - 1] + StepPips;
                else
                    open[current] = close[current - 1];
                end
                low[current] = open[current];
                close[current]=open[current]+StepPips;
                high[current] = close[current];
            end  
        end
    end
    return current;
end

function handleHistory()
    local s = history:size() - 1;
    local i;
    local current = open:size() - 1;
    for i = 1, s, 1 do
        if history.close[i] >= history.open[i] then
            current = calcValue(current, i, history.open);
            current = calcValue(current, i, history.low);
            current = calcValue(current, i, history.high);
            current = calcValue(current, i, history.close);
        else
            current = calcValue(current, i, history.open);
            current = calcValue(current, i, history.high);
            current = calcValue(current, i, history.low);
            current = calcValue(current, i, history.close);
        end
    end
    loading = false;
    LastTime=history:date(history:size()-1);
end

function handleUpdate()
    if not loading and history:size() > 0 then
      if history:date(history:size()-1)~=LastTime then
        local c = open:size() - 1;
        local h = history:size() - 2
        if history.close[h] >= history.open[h] then
            c = calcValue(c, h, history.open);
            c = calcValue(c, h, history.low);
            c = calcValue(c, h, history.high);
            c = calcValue(c, h, history.close);
        else
            c = calcValue(c, h, history.open);
            c = calcValue(c, h, history.high);
            c = calcValue(c, h, history.low);
            c = calcValue(c, h, history.close);
        end
        LastTime=history:date(history:size()-1);
      end  
    end 
end
