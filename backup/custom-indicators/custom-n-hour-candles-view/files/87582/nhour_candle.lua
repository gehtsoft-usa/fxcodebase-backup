-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58424
-- Id: 9567

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("N-hour candle view with customizable trading day start");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("bid", "Price:", "", "Bid");
    indicator.parameters:addStringAlternative("bid", "Bid", "", "Bid");
    indicator.parameters:addStringAlternative("bid", "Ask", "", "Ask");
    indicator.parameters:addString("frame", "Timeframe", "", "H2");
    indicator.parameters:addStringAlternative("frame", "H2", "", "H2");
    indicator.parameters:addStringAlternative("frame", "H3", "", "H3");
    indicator.parameters:addStringAlternative("frame", "H4", "", "H4");
    indicator.parameters:addStringAlternative("frame", "H6", "", "H6");
    indicator.parameters:addStringAlternative("frame", "H8", "", "H8");
    indicator.parameters:addStringAlternative("frame", "H12", "", "H12");
    indicator.parameters:addStringAlternative("frame", "D1", "", "D1");
    indicator.parameters:addInteger("hour", "Trading Day start hour (EST)", "", 17, 0, 23);
    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "Date From", "", -1000);
    indicator.parameters:addDate("to", "Date to", "", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
end

local loading;
local instrument;
local frame;
local hour;
local frame;
local history;
local open, high, low, close, candleend;
local offer;
local offset;
local bid;

function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    hour = instance.parameters.hour;
    bid = instance.parameters.bid == "Bid";

    if hour == 0 then
        offset = 0;
    elseif hour <= 12 then
        offset = hour;
    else
        offset = -(24 - hour);
    end


    local name = profile:id() .. "(" .. instrument .. "." ..
                                        frame .. "," ..
                                        hour .. ":00EST" ..
                                 ")";
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

    assert(row ~= nil, "Instrument is not found");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, bid, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, "H1", instance.parameters.from, instance.parameters.to, bid);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end

    open = instance:addStream("open", core.Line, name .. ".open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. ".high", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. ".low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. ".close", "close", 0, 0, 0);
    candleend = instance:addInternalStream(0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, nil, frame);
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        handleHistory();
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate();
        end
    end
end

function handleHistory()
    local s = history:size() - 1;
    local i;
    local prevcandle = 0;
    local cstart, cend, cdate;
    local current = open:size() - 1;

    for i = 0, s, 1 do
        cdate = history:date(i);
        if current < 0 or cdate >= candleend[current] then
            cstart, cend = core.getcandle(frame, history:date(i), offset, 0);
            instance:addViewBar(cstart);
            current = current + 1;
            open[current] = history.open[i];
            high[current] = history.high[i];
            low[current] = history.low[i];
            close[current] = history.close[i];
            candleend[current] = cend;
        else
            if high[current] < history.high[i] then
                high[current] = history.high[i];
            end
            if low[current] > history.low[i] then
                low[current] = history.low[i];
            end
            close[current] = history.close[i];
        end
    end
    loading = false;
end

function handleUpdate()
    if not loading and history:size() > 0 then
        local i = history:size() - 1;
        local current = open:size() - 1;
        local lastdate = history:date(i);

        if lastdate >= candleend[current] then
            close[current] = history.close[i - 1];
            cstart, cend = core.getcandle(frame, history:date(i), offset, 0);
            instance:addViewBar(cstart);
            current = current + 1;
            open[current] = history.open[i];
            high[current] = history.high[i];
            low[current] = history.low[i];
            close[current] = history.close[i];
            candleend[current] = cend;
        else
            if high[current] < history.high[i] then
                high[current] = history.high[i];
            end
            if low[current] > history.low[i] then
                low[current] = history.low[i];
            end
            close[current] = history.close[i];
        end
    end
end