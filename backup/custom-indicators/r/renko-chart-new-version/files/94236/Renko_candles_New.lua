-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60748

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+



-- Created by MooMooFX based off the original Renko_Chart for use in strategies
-- Changes:
--     Removed localization as I cannot translate all the other languages.
--     Fixed bug handling no history for strategies that crashes backtester
--     History futher enhanced to autoload enough data.
--     Fixed bug to prevent crashing (remove subscription in release instance - thanks Valeria!)
--     Added bars limit for target number of bars initially required.
--     Added dateLimit to prevent loading too long.
--     Added detection of when the server limit of data has been reached, and aborts loading further (which probably makes dateLimit legacy)
--     Forces subscription to new prices (removed load_to date)
--     Default timeframe set to m1 as this is the closest to the real thing. Should be tick really.
--     Added Volume.
function Init()
    indicator:name("Renko Chart New");
    indicator:description("Renko Chart New");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("instrument", "Symbol", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Period", "", "m1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Price type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("Step", "Brick size", "The brick size in pips", 100);
    indicator.parameters:addBoolean("PrintDebug", "Print Debug", "Prints debug messages to the log", false);

    indicator.parameters:addGroup("Range");
    indicator.parameters:addInteger("barLimit", "Bars", "Keep trying to load data until we have AT LEAST this many bars.", 300, 2, 1000);
    -- TODO: Investigate if the dateLimit is now legacy due to the detection of the server's max date.
    indicator.parameters:addDate("dateLimit", "Date Limit", "Keep trying to load data until this date.", -5000);

end

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

local load_from;
local load_to;
local barLimit;
local dateLimit;
local instanceName;
local printDebug;

local Digits;
local PointSize;

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    load_from = core.now() - 100;
    load_to = 0;
    barLimit = instance.parameters.barLimit;
    dateLimit = instance.parameters.dateLimit;
    printDebug = instance.parameters.PrintDebug;

    instanceName = profile:id() .. "(" .. instrument .. "." .. frame .. ")";
    instance:name(instanceName);

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

    Digits = row.Digits;
    PointSize = row.PointSize;

    instance:initView(instrument, Digits, PointSize, false, true);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, load_from, 0, instance.parameters.type);
    core.host:execute("subscribeTradeEvents", 2000, "offers");
    StepPips = instance.parameters.Step * history.close:pipSize();
    core.host:execute("setStatus", "Loading...");

    open = instance:addStream("open", core.Line, instanceName .. "." .. "open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, instanceName .. "." .. "high", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, instanceName .. "." .. "low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, instanceName .. "." .. "close", "close", 0, 0, 0);
    volume = instance:addStream("volume", core.Line, instanceName .. "." .. "volume", "volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, frame);
    
    OneSecond=1/86400;
end

function ReleaseInstance()
    core.host:execute("unsubscribeTradeEvents", "offers");
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 or cookie == 3000 or cookie == 3001 then
        handleHistory(cookie);
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate();
        end
    end
end

local lastDirection;
function calcFirstValueValue(current, i)
    local source = history.close;
    local open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] > open_val + StepPips do
        current = current + 1;
        if current==0 then
            instance:addViewBar(source:date(0));
            volume[0] = i;
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
            volume[current - 1] = volume[current - 1] + 1;
            volume[current] = 1;
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
            volume[0] = i;
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
            volume[current - 1] = volume[current - 1] + 1;
            volume[current] = 1;
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

function calcValue(current, i)
    if current == -1 then
        return calcFirstValueValue(current, i);
    end
    local source = history.close;
    local starting = current;
    local diff = close[current] - open[current];
    if diff > 0 or (diff == 0 and lastDirection == 1) then
        lastDirection = 1;

        while source[i] > close[current] + StepPips do
            current = current + 1;
            if open:date(current-1) < source:date(i) then
                instance:addViewBar(source:date(i));
            else
                instance:addViewBar(open:date(current-1)+OneSecond);
            end
            open[current] = close[current - 1];
            low[current] = open[current];
            close[current]=open[current]+StepPips;
            high[current] = close[current];
            -- volume[current - 1] = volume[current - 1] + 1;
            volume[current] = 1;
        end

        if source[i] < close[current] - 2 * StepPips then
            while source[i]<close[current] - StepPips do
                current = current + 1;
                if open:date(current-1) < source:date(i) then
                    instance:addViewBar(source:date(i));
                else
                    instance:addViewBar(open:date(current-1)+OneSecond);
                end
                if close[current-1] > open[current-1] then
                    open[current] = close[current - 1] - StepPips;
                else
                    open[current] = close[current - 1];
                end
                high[current] = open[current];
                close[current]=open[current]-StepPips;
                low[current] = close[current];
                -- volume[current - 1] = volume[current - 1] + 1;
                volume[current] = 1;
            end  
        end
    end
    
    if diff < 0 or (diff == 0 and lastDirection == -1) then
        lastDirection = -1;

        while source[i] < close[current] - StepPips do
            current = current + 1;
            if open:date(current-1) < source:date(i) then
                instance:addViewBar(source:date(i));
            else
                instance:addViewBar(open:date(current-1)+OneSecond);
            end
            open[current] = close[current - 1];
            high[current] = open[current];
            close[current]=open[current]-StepPips;
            low[current] = close[current];
            -- volume[current - 1] = volume[current - 1] + 1;
            volume[current] = 1;
        end

        if source[i] > close[current] + 2 * StepPips then
            while source[i] > close[current] + StepPips do
                current = current + 1;
                if open:date(current-1) < source:date(i) then
                    instance:addViewBar(source:date(i));
                else
                    instance:addViewBar(open:date(current-1)+OneSecond);
                end
                if close[current-1] < open[current-1] then
                    open[current] = close[current - 1] + StepPips;
                else
                    open[current] = close[current - 1];
                end
                low[current] = open[current];
                close[current]=open[current]+StepPips;
                high[current] = close[current];
                -- volume[current - 1] = volume[current - 1] + 1;
                volume[current] = 1;
            end  
        end
    end

    if (starting == current) then
        -- we didn't added anymore bars, just increment the volume.
        volume[current] = volume[current] + 1;
    end

    return current;
end

local currentOpen, currentClose;
local lastOpen, lastClose;

function calcGhostFirstValueValue(current, i)
    local source = history.close;
    local open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] > open_val + StepPips do
        current = current + 1;
        lastOpen = -1;
        currentOpen = open_val;
        lastClose = -1;
        currentClose = currentOpen+StepPips;
        lastDirection = 1;
        open_val=open_val+StepPips;
    end
    open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] < open_val - StepPips do
        current = current + 1;
        lastOpen = -1;
        currentOpen = open_val;
        lastClose = -1;
        currentClose = currentOpen-StepPips;
        lastDirection = -1;
        open_val=open_val-StepPips;
    end
    
    return current;
end

function calcGhostValue(current, i)
    if current == -1 then
        return calcGhostFirstValueValue(current, i);
    end
    local source = history.close;
    local diff = currentClose - currentOpen;
    if diff > 0 or (diff == 0 and lastDirection == 1) then
        lastDirection = 1;
        while source[i] > currentClose + StepPips do
            current = current + 1;
            lastOpen = currentOpen;
            currentOpen = currentClose;
            lastClose = currentClose;
            currentClose=currentOpen+StepPips;
        end
        if source[i] < currentClose - 2 * StepPips then
            while source[i] < currentClose - StepPips do
                current = current + 1;
                lastOpen = currentOpen;
                if currentClose > currentOpen then
                    currentOpen = currentClose - StepPips;
                else
                    currentOpen = currentClose;
                end
                lastClose = currentClose;
                currentClose=currentOpen-StepPips;
            end  
        end
    end
    
    if diff < 0 or (diff == 0 and lastDirection == -1) then
        lastDirection = -1;
        while source[i] < currentClose - StepPips do
            current = current + 1;
            lastOpen = currentOpen;
            currentOpen = currentClose;
            lastClose = currentClose;
            currentClose=currentOpen-StepPips;
        end
        if source[i] > currentClose + 2 * StepPips then
            while source[i] > currentClose + StepPips do
                current = current + 1;
                lastOpen = currentOpen;
                if currentClose < currentOpen then
                    currentOpen = currentClose + StepPips;
                else
                    currentOpen = currentClose;
                end
                lastClose = currentClose;
                currentClose=currentOpen+StepPips;
            end  
        end
    end

    return current;
end

local lastLoaded = -1;
function handleHistory(cookie)
    local s = history:size() - 1;
    if (printDebug) then
        core.host:trace(instanceName .. " Cookie: " .. cookie .. " History size: " .. s);
    end
    local i;
    -- ghost run to try to calculate how many bars we will get.
    local current = open:first() - 1;
    for i = 1, s, 1 do
        current = calcGhostValue(current, i);
    end

    -- how far have we loaded data until.
    local to;
    if (s ~= -1) then
        to = history.close:date(history.close:first());

        if (cookie ~= 3001 and current < barLimit and lastLoaded ~= to) then
            -- if we haven't exceeded our dateLimit or barLimit
            -- and we haven't tried to load the same data twice (meaning we have hit the hard date limit for this data)
            -- try to load more data!

            if (printDebug) then
                core.host:trace(instanceName .. " Not enough data! Calculated " .. current .. " but need " .. barLimit .. ". Requesting more.");
            end

            lastLoaded = to;
            local from = to - 100; -- request 100 days of data at a time.
            local token = 3000;
            if (from < 0) then
                from = 1;
            end
            if (from < dateLimit) then
                from = dateLimit;
                token = 3001;
            end
            if (printDebug) then
                core.host:trace(instanceName .. " Load from was " .. FormatDate(load_from) .. " vs actual: " .. FormatDate(to));
                core.host:trace(instanceName .. " extendHistory from " .. FormatDate(from) .. " to " .. FormatDate(to));
            end
            load_from = from;
            core.host:execute("extendHistory", token, history, from, to);
              
            return;
        end

        if (printDebug) then
            if (lastLoaded == to) then
                core.host:trace(instanceName .. " Could not load anymore data from server.");
            elseif (cookie == 3001) then
                core.host:trace(instanceName .. " Date limit has been exceeded.");
            end
        end

        -- we have as much data as we can get, or enough data
        -- so calculate the real renko bars and add them to the chart.

        local current = open:first() - 1;
        for i = 1, s, 1 do
            current = calcValue(current, i);
        end
        if (printDebug) then
            core.host:trace(instanceName .. " Renko Bars Calculated: " .. current);
        end
    
        LastTime=history:date(history:size()-1);
    else
        core.host:trace(instanceName .. " Renko Bars Unable to load any history. Likely reason is running in Backtester or Debugger. Ensure sufficient data has been loaded manually.");
        LastTime=nil;
    end

    loading = false;
    core.host:execute("setStatus", "");
end

function handleUpdate()
    if not loading and history:size() > 0 then
      if history:date(history:size()-1)~=LastTime then
        calcValue(open:size() - 1, history:size() - 2);
        LastTime=history:date(history:size()-1);
      end  
    end 
end

-- ---------------------------------------------------------
-- Returns the passed in datetime in a nice formatted fashion and in the display timezone
-- @param inputDate The datetime to format
-- ---------------------------------------------------------
function FormatDate(inputDate)
    local theDate = core.dateToTable(core.host:execute("convertTime", 1, 4, inputDate));

    return string.format("%d/%02d/%02d %02d:%02d:%02d", theDate.year, theDate.month, theDate.day, theDate.hour, theDate.min, theDate.sec);
end
