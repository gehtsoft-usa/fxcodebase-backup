-- Id: 23309
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67150

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
    indicator:name("Entrys and SL and TP")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addString("tf_stop", "Stop timeframe", "", "H1");
    indicator.parameters:addString("stop_indi", "Stop indicator", "", "ATR_STOP_DOTS")
    indicator.parameters:setFlag("stop_indi", core.FLAG_INDICATOR);
    indicator.parameters:addString("stop_indi_buy_stream", "Stop indicator stream (long trades)", "", "DOTl")
    indicator.parameters:addString("stop_indi_sell_stream", "Stop indicator stream (short trades)", "", "DOTh")

    indicator.parameters:addString("tf_limit", "Limit timeframe", "", "H1");
    indicator.parameters:addString("limit_indi", "Limit indicator", "", "ATR_STOP_DOTS")
    indicator.parameters:setFlag("limit_indi", core.FLAG_INDICATOR);
    indicator.parameters:addString("limit_indi_buy_stream", "Limit indicator stream (long trades)", "", "DOTh")
    indicator.parameters:addString("limit_indi_sell_stream", "Limit indicator stream (short trades)", "", "DOTl")
    indicator.parameters:addBoolean("extend", "Extend lines", "", true);

    indicator.parameters:addGroup("Indicator Style")
    indicator.parameters:addColor("color_stop", "Stop color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width_stop", "Stop Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style_stop", "Stop Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style_stop", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color_limit", "Limit color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width_limit", "Limit Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style_limit", "Limit Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style_limit", core.FLAG_LINE_STYLE)
end

local stops = {};
local limits = {};

local stop_indi;
local limit_indi;
local stop_buy_stream;
local stop_sell_stream;
local limit_buy_stream;
local limit_stream_stream;
local tradingDayOffset, tradingWeekOffset;
local CREATE_BUY = 5;
local CREATE_SELL = 6;
local extend;
local loading_1;
local loading_2;

function FindStream(indi, streamName)
    for i = 0, indi:getStreamCount() - 1 do
        local stream = indi:getStream(i);
        if stream:id() == streamName then
            return stream;
        end
    end
    return nil;
end

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    extend = instance.parameters.extend;
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    tradingWeekOffset = core.host:execute("getTradingWeekOffset")

    local stop_source = core.host:execute("getSyncHistory", instance.source:instrument(), instance.parameters.tf_stop, instance.source:isBid(), 0, 1, 2)
    assert(core.indicators:findIndicator(instance.parameters.stop_indi) ~= nil, instance.parameters.stop_indi .. " indicator must be installed");
    stop_indi = core.indicators:create(instance.parameters.stop_indi, stop_source, instance.parameters:getCustomParameters("stop_indi"))
    stop_buy_stream = FindStream(stop_indi, instance.parameters.stop_indi_buy_stream);
    assert(stop_buy_stream ~= nil, "Invalid buy stop stream")
    stop_sell_stream = FindStream(stop_indi, instance.parameters.stop_indi_sell_stream);
    assert(stop_sell_stream ~= nil, "Invalid sell stop stream")

    local limit_source = core.host:execute("getSyncHistory", instance.source:instrument(), instance.parameters.tf_limit, instance.source:isBid(), 0, 3, 4)
    assert(core.indicators:findIndicator(instance.parameters.limit_indi) ~= nil, instance.parameters.limit_indi .. " indicator must be installed");
    limit_indi = core.indicators:create(instance.parameters.limit_indi, limit_source, instance.parameters:getCustomParameters("limit_indi"))
    limit_buy_stream = FindStream(limit_indi, instance.parameters.limit_indi_buy_stream);
    assert(limit_buy_stream ~= nil, "Invalid sell limit stream")
    limit_sell_stream = FindStream(limit_indi, instance.parameters.limit_indi_sell_stream);
    assert(limit_sell_stream ~= nil, "Invalid sell limit stream")
    loading = true;
    core.host:execute("setStatus", "Loading...");

    core.host:execute("addCommand", CREATE_BUY, "Buy position", "Buy position");
    core.host:execute("addCommand", CREATE_SELL, "Sell position", "Sell position");
    instance:ownerDrawn(true)
end

local init = false
local STOP_PEN = 1;
local LIMIT_PEN = 2;
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createPen(STOP_PEN, context:convertPenStyle(instance.parameters.style_stop), instance.parameters.width_stop, instance.parameters.color_stop);
        context:createPen(LIMIT_PEN, context:convertPenStyle(instance.parameters.style_limit), instance.parameters.width_limit, instance.parameters.color_limit);
        init = true
    end

    for _, stop in ipairs(stops) do
        local x = context:positionOfDate(stop.OpenDate);
        local x2 = context:right();
        if not extend then
            local s, e = core.getcandle("D1", stop.OpenDate, tradingDayOffset, tradingWeekOffset)
            x2 = context:positionOfDate(e);
        end
        local _, y = context:pointOfPrice(stop.Rate);
        context:drawLine(STOP_PEN, x, y, x2, y);
    end
    for _, limit in ipairs(limits) do
        local x = context:positionOfDate(limit.OpenDate);
        local x2 = context:right();
        if not extend then
            local s, e = core.getcandle("D1", limit.OpenDate, tradingDayOffset, tradingWeekOffset)
            x2 = context:positionOfDate(e);
        end
        local _, y = context:pointOfPrice(limit.Rate);
        context:drawLine(LIMIT_PEN, x, y, x2, y);
    end
end

function Update(period, mode)
    stop_indi:update(core.UpdateLast);
    limit_indi:update(core.UpdateLast);
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loading_1 = false;
        if not loading_2 then
            core.host:execute("setStatus", "");
        end
    elseif cookie == 2 then
        loading_1 = true;
    elseif cookie == 3 then
        loading_2 = false;
        if not loading_1 then
            core.host:execute("setStatus", "");
        end
    elseif cookie == 4 then
        loading_2 = true;
    end
    if stop_indi.DATA:size() == 0 or limit_indi.DATA:size() == 0 then
        return;
    end
    if cookie == CREATE_BUY then
        stop_indi:update(core.UpdateLast);
        limit_indi:update(core.UpdateLast);
        local items = core.parseCsv(message, ";");
        local date = tonumber(items[1])
        local period = core.findDate(stop_buy_stream, date, false);
        local stop = 
        {
            OpenDate = date;
            Rate = stop_buy_stream:tick(period - 1);
        };
        stops[#stops + 1] = stop;
        local limit = 
        {
            OpenDate = date;
            Rate = limit_buy_stream:tick(period - 1);
        };
        limits[#limits + 1] = limit;
    elseif cookie == CREATE_SELL then
        stop_indi:update(core.UpdateLast);
        limit_indi:update(core.UpdateLast);
        local items = core.parseCsv(message, ";");
        local date = tonumber(items[1])
        local period = core.findDate(stop_sell_stream, date, false);
        local stop = 
        {
            OpenDate = date;
            Rate = stop_sell_stream:tick(period - 1);
        };
        stops[#stops + 1] = stop;
        local limit = 
        {
            OpenDate = date;
            Rate = limit_sell_stream:tick(period - 1);
        };
        limits[#limits + 1] = limit;
    end
end
