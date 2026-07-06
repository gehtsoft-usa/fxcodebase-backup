function Init()
    indicator:name("Future Renko");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Price parameters");
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Timeframe", "", "H1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Price type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("Step", "Step", "", 100, 1, 1000);

    indicator.parameters:addGroup("Dates");
    indicator.parameters:addDate("from", "From", "", -1000);
    indicator.parameters:addDate("to", "To", "", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

    indicator.parameters:addColor("future_down", "Future down color", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("future_up", "Future up color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addInteger("transp", "Future bars transparency", "", 80, 0, 100);
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

    assert(row ~= nil, "Instrument not found");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
    StepPips = instance.parameters.Step * history.close:pipSize();
    core.host:execute("setStatus", "Loading...");

    open = instance:addStream("open", core.Line, name .. ".Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. ".High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. ".Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. ".Close", "close", 0, 0, 0);
    volume = instance:addStream("volume", core.Line, name .. ".Volume", "volume", core.host:execute("getProperty", "VolumeColor"), 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, frame);
    
    OneSecond=1/86400;

    instance:ownerDrawn(true);
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

local init = false;
local DOWN_BRUSH = 1;
local DOWN_PEN = 2;
local UP_BRUSH = 3;
local UP_PEN = 4;
local transp;

function Draw(stage, context)
    local current = open:size() - 1;
    if stage ~= 0 or history:size() == 0 or current <= 0 then
        return;
    end
    if not init then
        context:createPen(DOWN_PEN, context.SOLID, 1, instance.parameters.future_down);
        context:createSolidBrush(DOWN_BRUSH, instance.parameters.future_down);
        context:createPen(UP_PEN, context.SOLID, 1, instance.parameters.future_up);
        context:createSolidBrush(UP_BRUSH, instance.parameters.future_up);
        transp = context:convertTransparency(instance.parameters.transp);
        init = true;
    end
    local diff = history.close[NOW] - close[current];
    local fromPrice = close[current];
    if close[current] > open[current] then
        if diff <= 0 then
            diff = diff + StepPips;
            if diff >= 0 then
                return;
            end
            fromPrice = open[current];
        end
    else
        if diff >= 0 then
            diff = diff - StepPips;
            if diff <= 0 then
                return;
            end
            fromPrice = open[current];
        end
    end
    local pos = current + 1;
    if diff < 0 then
        while (diff < 0) do
            local toPrice = fromPrice - math.min(math.abs(diff), StepPips);
            local x, x1, x2 = context:positionOfBar(pos);
            local _, y1 = context:pointOfPrice(fromPrice)
            local _, y2 = context:pointOfPrice(toPrice)
            context:drawRectangle(DOWN_PEN, DOWN_BRUSH, x1, y1, x2, y2, transp);

            diff = diff + StepPips;
            pos = pos + 1;
            fromPrice = toPrice;
        end
    else
        while (diff > 0) do
            local toPrice = fromPrice + math.min(math.abs(diff), StepPips);
            local x, x1, x2 = context:positionOfBar(pos);
            local _, y1 = context:pointOfPrice(fromPrice)
            local _, y2 = context:pointOfPrice(toPrice)
            context:drawRectangle(UP_PEN, UP_BRUSH, x1, y1, x2, y2, transp);

            diff = diff - StepPips;
            pos = pos + 1;
            fromPrice = toPrice;
        end
    end
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

local lastDirection;

function calcFirstValueValue(current, i)
    local source = history.close;
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

function calcValue(current, i)
    if current == -1 then
        return calcFirstValueValue(current, i);
    end
    local source = history.close;
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
        current = calcValue(current, i);
    end
    loading = false;
    LastTime=history:date(history:size()-1);
end

function handleUpdate()
    if not loading and history:size() > 0 then
        if history:date(history:size()-1)~=LastTime then
            calcValue(open:size() - 1, history:size() - 2);
            LastTime=history:date(history:size()-1);
        end  
    end 
end
