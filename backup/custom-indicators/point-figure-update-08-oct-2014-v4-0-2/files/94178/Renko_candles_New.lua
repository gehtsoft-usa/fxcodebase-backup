function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup(resources:get("R_price_params_group"));
    indicator.parameters:addString("instrument", resources:get("R_instrument_name"), resources:get("R_instrument_desc"), "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", resources:get("R_timeframe_name"), resources:get("R_timeframe_desc"), "H1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", resources:get("R_pricetype_name"), resources:get("R_pricetype_desc"), true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("Step", resources:get("step_name"), resources:get("step_desc"), 100);

    indicator.parameters:addGroup(resources:get("R_range_group"));
    indicator.parameters:addDate("from", resources:get("R_date_from_name"), resources:get("R_date_from_desc"), -1000);
    indicator.parameters:addDate("to", resources:get("R_date_to_name"), resources:get("R_date_to_desc"), 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
end

local loading;
local instrument;
local frame;
local StepPips;
local history;
local open, high, low, close;
local offer;
local offset;
local OneSecond;
local LastTime;

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")";
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

    assert(row ~= nil, resources:get("R_error_instrument_not_found"));

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
    StepPips = instance.parameters.Step * history.close:pipSize();
    core.host:execute("setStatus", resources:get("R_status_loading"));

    open = instance:addStream("open", core.Line, name .. "." .. resources:get("R_open_price"), "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. resources:get("R_high_price"), "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. resources:get("R_low_price"), "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. resources:get("R_close_price"), "close", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, nil, frame);
    
    OneSecond=1/86400;
end

function ReleaseInstance()
    core.host:execute("unsubscribeTradeEvents", "offers");
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        handleHistory();
        core.host:execute("setStatus", "");
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
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
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
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
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
        current = calcValue(current, i);
    end
    loading = false;
    if (s > 1) then
        LastTime=history:date(history:size()-1);
    end
end

function handleUpdate()
    if not loading and history:size() > 0 then
      if history:date(history:size()-1)~=LastTime then
        calcValue(open:size() - 1, history:size() - 2);
        LastTime=history:date(history:size()-1);
      end  
    end 
end
