-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68569

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
    indicator:name("Sub Minute Candle View")
    indicator:description("A chart will add a new Candle After passing of Set Number of seconds.")
    indicator:requiredSource(core.Tick)
    indicator:type(core.View)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Instrument", "Instrument", "", "EUR/USD")
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS)

    indicator.parameters:addInteger("Step", "Number Of seconds", "", 10)

    indicator.parameters:addBoolean("type", "Price Type", "", true)
    indicator.parameters:setFlag("type", core.FLAG_BIDASK)

    indicator.parameters:addGroup("Range")
    indicator.parameters:addDate("from", "From", "", -1000)
    indicator.parameters:addDate("to", "To", "", 0)
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL)
end
local Last
local loading
local History
local open, high, low, close, volume
local offer
local offset
local LastTime = nil
local Instrument
local Count
local FIRST
local Step
local LastS
local TF
local OneSecond
local Expires
local LastIndex

local TicksHistory = {};
TicksHistory.Files = {};
function TicksHistory:AddItem(items, item)
    for i = 1, #items.ticks do
        if items.ticks[i].date == item.date then
            return;
        elseif items.ticks[i].date < item.date then
            table.insert(items.ticks, i, item);
            return;
        end
    end
    items.ticks[#items.ticks + 1] = item;
    items.need_to_save = true;
end
function TicksHistory:log(date, tick)
    local dateTable = core.dateToTable(date);
    local filename = string.format("TickHistoryCache/%s/%04d%02d%02d%02d%02d.csv", instance.parameters.Instrument, 
        dateTable.year, dateTable.month, dateTable.day, dateTable.hour, dateTable.min);

    local items = self.Files[filename];
    if items == nil then
        items = {};
        items.ticks = {};
        self.Files[filename] = items;
        local file = io.open(filename, "r");
        if file ~= nil then
            file:close();
            for line in io.lines(filename) do
                if line ~= "" then
                    local item = {};
                    local values = core.parseCsv(line, ";");
                    local parsedyear, parsedmonth, parsedday, parsedhours, parsedminutes, parsedseconds = string.match(values[0], "(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)");
                    local table = 
                    {
                        year = tonumber(parsedyear), 
                        month = tonumber(parsedmonth), 
                        day = tonumber(parsedday), 
                        hour = tonumber(parsedhours), 
                        min = tonumber(parsedminutes), 
                        sec = tonumber(parsedseconds)
                    };
                    item.date = core.tableToDate(table);
                    item.value = tonumber(values[1]);
                    items.ticks[#items.ticks + 1] = item;
                end
            end
        end
        items.need_to_save = false;
    end
    local item = {};
    item.date = date;
    item.value = tick;
    self:AddItem(items, item);
end

function TicksHistory:save()
    for filename, items in pairs(self.Files) do
        if items.need_to_save then
            local file = io.open(filename, "w");
            for i, item in ipairs(items.ticks) do
                local dateTable = core.dateToTable(item.date);
                local formattedItem = string.format("%04d%02d%02d%02d%02d%02d;%f\n", 
                    dateTable.year, dateTable.month, dateTable.day, dateTable.hour, dateTable.min, dateTable.sec, item.value);
                file:write(formattedItem);
            end
            file:close();
            items.need_to_save = false;
        end
    end
end

function TicksHistory:getEnumerator(from, to)
    local enumerator = {};
    enumerator.from = from;
    enumerator.to = to;
    enumerator.items = self.Files;
    function enumerator:next()
        if self.current ~= nil then
            if self.index ~= #self.current then
                self.index = self.index + 1;
                return true;
            end
            from = from + 1.0 / 24.0;
        end
        while from <= to do
            local dateTable = core.dateToTable(from);
            local filename = string.format("TickHistoryCache/%s/%04d%02d%02d%02d%02d.csv", instance.parameters.Instrument, 
                dateTable.year, dateTable.month, dateTable.day, dateTable.hour, dateTable.min);
            local items = self.items[filename];
            if items ~= nil then
                self.current = items;
                self.index = 1;
                return true;
            else
                from = from + 1.0 / 24.0;
            end
        end
        return false;
    end
    function enumerator:getTick()
        return self.current.ticks[self.index].value, self.current.ticks[self.index].date;
    end
    return enumerator;
end

-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST = true
    Step = instance.parameters.Step
    TF = instance.parameters.TF
    Instrument = instance.parameters.Instrument

    local name = profile:id() .. ", " .. Instrument .. ", " .. Step .. " second Candle"
    instance:name(name)

    if onlyName then
        return
    end

    -- check whether the instrument is available
    local offers = core.host:findTable("offers")
    local enum = offers:enumerator()
    local row = nil

    row = enum:next()
    while row ~= nil do
        if row.Instrument == Instrument then
            break
        end
        row = enum:next()
    end

    s, e = core.getcandle("m1", core.now(), 0, 0)
    OneSecond = (e - s) / 60

    assert(row ~= nil, "Selected instrument is not available")
    offer = row.OfferID

    instance:initView(Instrument, row.Digits, row.PointSize, true, true)

    History = core.host:execute("getHistory", 1000, Instrument, "t1", instance.parameters.from, instance.parameters.to, instance.parameters.type)
    loading = true

    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers")
    end
    core.host:execute("setStatus", "Loading")

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0)
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0)
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0)
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0)
    volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0)

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, TF)

    LastTime = nil
    core.host:execute("setTimer", 3000, Step)
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then
        handleHistory()
        core.host:execute("setStatus", "")
    elseif cookie == 2000 then
        loading = false
        handleUpdate()
    elseif loading == false and cookie == 3000 and LastTime ~= nil then
        handleUpdate()
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", 3000)
end

function processTick(date, value)
    local Index = open:size() - 1;
    if open:size() == 0 then
        instance:addViewBar(date)
        Index = Index + 1
        open[Index] = value
        low[Index] = value
        close[Index] = value
        high[Index] = value
        volume[Index] = 1
        Expires = date + OneSecond * Step
        LastIndex = period
    else
        if date > Expires then
            Index = Index + 1
            Count = 1
            instance:addViewBar(date)

            open[Index] = value
            low[Index] = value
            close[Index] = value
            high[Index] = value
            volume[Index] = 1
            Expires = date + OneSecond * Step
        else
            close[Index] = value
            low[Index] = math.min(low[Index], value)
            high[Index] = math.max(high[Index], value)
        end
    end
end

function calcValue(Index, period)
    if period < History:first() then
        return
    end
    TicksHistory:log(History:date(period), History[period]);
    processTick(History:date(period), History[period]);
    return Index
end

function handleHistory()
    local ticks = TicksHistory:getEnumerator(instance.parameters.from, History:date(0));
    while (ticks:next()) do
        local tick, date = ticks:getTick();
        processTick(date, tick);
    end
    local s = History:size() - 1
    local current = open:size() - 1
    for i = 1, s, 1 do
        current = calcValue(current, i)
    end
    loading = false
    LastTime = History:size() - 1
end
local last_date;
function handleUpdate()
    local current = open:size() - 1
    for i = LastTime, History:size() - 1, 1 do
        current = calcValue(current, i)
    end
    LastTime = History:size() - 1

    local s = core.getcandle("m1", History:date(NOW), 0, 0);
    if last_date ~= s then
        TicksHistory:save();
        last_date = s;
    end
end
