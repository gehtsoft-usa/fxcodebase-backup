-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65636

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Stop all trades");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("BS", "Time frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
end

local tsource = nil;
local minChange;
local BS;
local day_offset;
local week_offset;

function Prepare(onlyName)
    local name;
    name = profile:id() .. "(" .. instance.source:instrument() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    BS = instance.parameters.BS;
    minChange = math.pow(10, -instance.source:getPrecision());
    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");

    core.host:execute("getHistory", 10, instance.source:instrument(), BS, 0, 0, true);
    core.host:execute("addCommand", 1001, "Use this high/low as stop", "");

    tsource = instance.source;
end

local high, low;
local last_serial;

function Update(period)
    local bf_candle = core.getcandle(BS, tsource:date(period), day_offset, week_offset);
    if tsource:date(period) ~= bf_candle then
        return;
    end
    if last_serial == tsource:serial(NOW) or high == nil then
        last_serial = tsource:serial(NOW);
        return;
    end
    last_serial = tsource:serial(NOW);

    local tradesEnum = core.host:findTable("trades"):enumerator();
    local trade = tradesEnum:next();
    while trade ~= nil do
        local stopValue, valuemap, success, msg;
        local stopSide;
        if trade.BS == "B" then
            stopSide = "S";
            stopValue = low;
        else
            stopSide = "B";
            stopValue = high;
        end

        if trade.StopOrderID == "" or trade.StopOrderID == nil then
            valuemap = core.valuemap();
            valuemap.Command = "CreateOrder";
            valuemap.OrderType = "S";
            valuemap.OfferID = trade.OfferID;
            valuemap.AcctID = trade.AccountID;
            valuemap.TradeID = trade.TradeID;
            valuemap.Quantity = trade.Lot;
            valuemap.Rate = stopValue;
            valuemap.BuySell = stopSide;
            success, msg = terminal:execute(200, valuemap);
            if not(success) then
                terminal:alertMessage(tsource:instrument(), tsource[NOW], "Failed create stop " .. msg, tsource:date(NOW));
            end
        else
            if math.abs(stopValue - trade.Stop) > minChange then
                -- stop exists
                valuemap = core.valuemap();
                valuemap.Command = "EditOrder";
                valuemap.AcctID = trade.AccountID;
                valuemap.OrderID = trade.StopOrderID;
                valuemap.Rate = stopValue;
                success, msg = terminal:execute(200, valuemap);
                if not(success) then
                    terminal:alertMessage(tsource:instrument(), tsource[NOW], "Failed change stop " .. msg, tsource:date(NOW));
                end
            end
        end
        trade = tradesEnum:next();
    end
    high = nil;
    low = nil;
end

local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
    
    if level == nil or date == nil then
        return nil;
    end
    
    return tonumber(date);
end

function AsyncOperationFinished(id, success, message)
    if id == 200 then
        if not(success) then
            terminal:alertMessage(tsource:instrument(), tsource[NOW], "Failed create/change stop " .. message, tsource:date(NOW));
        end
    elseif id == 1001 then
        local DateOne = Parse(message);
        local index = core.findDate(tsource, DateOne, false);
        if index >= tsource:size() then
            return;
        end
        high = tsource.high[index];
        low = tsource.low[index];
    end
end